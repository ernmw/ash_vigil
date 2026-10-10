
local MOD_NAME          = require("scripts.AshVigil.ns")
local const = require("scripts.AshVigil.const")
local settings = require("scripts.AshVigil.settings.settings")
local util  = require('openmw.util')
local world = require('openmw.world')
local types = require('openmw.types')
local core  = require('openmw.core')

---@alias GameObject table
---@alias Cell      table

local EPSILON = 0.05
local ZERO = util.vector3(0, 0, 0)
local UNIT = { util.vector3(1, 0, 0), util.vector3(0, 1, 0), util.vector3(0, 0, 1) }

--- A bounding box with its projections precomputed.
---@class PreppedBox
---@field verts Vector3[]    the 8 corners, world space
---@field axes Vector3[]     3 normalized box axes, world space
---@field ranges number[][]  ranges[i] = { min, max } of the corners along axes[i]
---@field mnx number
---@field mny number
---@field mnz number
---@field mxx number
---@field mxy number
---@field mxz number

---@class Tile
---@field obj GameObject
---@field box PreppedBox

---@class PlaceOptions
---@field maxAttempts? integer  default 200
---@field margin? number        default 32, keep-out from tile edges (xy)
---@field rotation? Transform   default: the object's current rotation
---@field randomYaw? boolean    random yaw per attempt (overrides rotation)
---@field token? any            echoed back in ObjectPlaced

---@class PlaceRequest
---@field object GameObject
---@field cell string           interior cell name
---@field tiles string[]        static record ids that count as room tiles
---@field options? PlaceOptions

---@param verts Vector3[]
---@param axis Vector3
---@return number lo
---@return number hi
local function project(verts, axis)
    local lo, hi = math.huge, -math.huge
    for _, v in ipairs(verts) do
        local d = v:dot(axis)
        if d < lo then lo = d end
        if d > hi then hi = d end
    end
    return lo, hi
end

---@param verts Vector3[]
---@param axes Vector3[]
---@return PreppedBox
local function prepVerts(verts, axes)
    local ranges = {}
    for i = 1, 3 do
        local lo, hi = project(verts, axes[i])
        ranges[i] = { lo, hi }
    end
    local mnx, mny, mnz = math.huge, math.huge, math.huge
    local mxx, mxy, mxz = -math.huge, -math.huge, -math.huge
    for _, v in ipairs(verts) do
        mnx = math.min(mnx, v.x); mxx = math.max(mxx, v.x)
        mny = math.min(mny, v.y); mxy = math.max(mxy, v.y)
        mnz = math.min(mnz, v.z); mxz = math.max(mxz, v.z)
    end
    return {
        verts = verts, axes = axes, ranges = ranges,
        mnx = mnx, mny = mny, mnz = mnz, mxx = mxx, mxy = mxy, mxz = mxz,
    }
end

---@param box Box
---@return PreppedBox
local function prepBox(box)
    local t = box.transform
    local o = t:apply(ZERO)
    local axes = {}
    for i = 1, 3 do axes[i] = (t:apply(UNIT[i]) - o):normalize() end
    return prepVerts(box.vertices, axes)
end

--- True if the boxes overlap on every separating axis.
---@param a PreppedBox
---@param b PreppedBox
---@return boolean
local function intersects(a, b)
    if a.mxx - b.mnx <= EPSILON or b.mxx - a.mnx <= EPSILON then return false end
    if a.mxy - b.mny <= EPSILON or b.mxy - a.mny <= EPSILON then return false end
    if a.mxz - b.mnz <= EPSILON or b.mxz - a.mnz <= EPSILON then return false end

    ---@param axis Vector3
    ---@return boolean
    local function separated(axis)
        local alo, ahi = project(a.verts, axis)
        local blo, bhi = project(b.verts, axis)
        return ahi - blo <= EPSILON or bhi - alo <= EPSILON
    end

    for i = 1, 3 do
        if separated(a.axes[i]) or separated(b.axes[i]) then return false end
    end
    for i = 1, 3 do
        for j = 1, 3 do
            local c = a.axes[i] ^ b.axes[j]
            if c:length2() > 1e-6 and separated(c:normalize()) then return false end
        end
    end
    return true
end

--- True if `a` lies entirely within `b`.
---@param b PreppedBox  the container
---@param a PreppedBox  the contained
---@return boolean
local function contains(b, a)
    for i = 1, 3 do
        local lo, hi = project(a.verts, b.axes[i])
        if lo < b.ranges[i][1] - EPSILON or hi > b.ranges[i][2] + EPSILON then
            return false
        end
    end
    return true
end

------------------------------------------------------------------------
-- Cell scan
------------------------------------------------------------------------

---@param cell Cell
---@param exceptions table<string, boolean>  object ids to skip
---@param tileSet table<string, boolean>     lowercase tile record ids
---@return Tile[] tiles
---@return PreppedBox[] obstacles
local function scanCell(cell, exceptions, tileSet)
    local tiles, obstacles = {}, {}
    for _, obj in ipairs(cell:getAll()) do
        if exceptions[obj.id] == nil and obj.enabled then
            local box = obj:getBoundingBox()
            local h = box.halfSize
            if h.x > 0.5 or h.y > 0.5 or h.z > 0.5 then
                if tileSet[obj.recordId] and types.Static.objectIsInstance(obj) then
                    tiles[#tiles + 1] = { obj = obj, box = prepBox(box) }
                else
                    obstacles[#obstacles + 1] = prepBox(box)
                end
            end
        end
    end
    return tiles, obstacles
end

---@param tile Tile
---@param margin number
---@return Vector3
local function randomPointWithinTile(tile, margin)
    local b = tile.box
    local p = ZERO
    for i = 1, 2 do
        local lo, hi = b.ranges[i][1] + margin, b.ranges[i][2] - margin
        if hi < lo then lo, hi = (lo + hi) / 2, (lo + hi) / 2 end
        p = p + b.axes[i] * (lo + math.random() * (hi - lo))
    end
    return p
end

--- The object's box if it had rotation `delta` applied and its origin at `pos`.
---@param relVerts Vector3[]  box corners relative to the object's origin
---@param relAxes Vector3[]   box axes
---@param delta Transform     rotation from the current orientation to the candidate one
---@param pos Vector3
---@return PreppedBox
local function boxAt(relVerts, relAxes, delta, pos)
    local verts, axes = {}, {}
    for i, v in ipairs(relVerts) do verts[i] = delta:apply(v) + pos end
    for i = 1, 3 do axes[i] = delta:apply(relAxes[i]) end
    return prepVerts(verts, axes)
end

---@param data PlaceRequest
---@return boolean true if the object was placed ok
local function onPlaceObject(data)
    local obj, opts = data.object, data.options or {}
    local margin    = opts.margin or 32

    local cell = world.getCellByName(data.cell)
    if not cell then return false end

    ---@type table<string, boolean>
    local tileSet = {}
    for _, id in ipairs(data.tiles) do tileSet[id:lower()] = true end
    local tiles, obstacles = scanCell(cell, { [obj.id] = true }, tileSet)
    if #tiles == 0 then return false end

    -- the object's current box, relative to its own origin
    local cur = prepBox(obj:getBoundingBox())
    ---@type Vector3[]
    local relVerts = {}
    for i, v in ipairs(cur.verts) do relVerts[i] = v - obj.position end
    local curInv = obj.rotation:inverse()

    for _ = 1, opts.maxAttempts or 200 do
        local tile = tiles[math.random(#tiles)]
        local xy = randomPointWithinTile(tile, margin)

        local rot = opts.rotation or obj.rotation
        if opts.randomYaw then rot = util.transform.rotateZ(math.random() * 2 * math.pi) end
        local delta = rot * curInv

        -- rest the box's lowest point on the tile's lowest point
        local minZ = math.huge
        for _, v in ipairs(relVerts) do minZ = math.min(minZ, delta:apply(v).z) end
        local pos = util.vector3(xy.x, xy.y, tile.box.mnz - minZ)

        local mine = boxAt(relVerts, cur.axes, delta, pos)

        local free = contains(tile.box, mine)
        if free then
            for _, ob in ipairs(obstacles) do
                if intersects(mine, ob) then free = false; break end
            end
        end

        if free then
            obj:teleport(cell, pos + util.vector3(0, 0, 8), { onGround = true, rotation = rot })
            return true
        end
    end

    return false
end

return {
    interfaceName = MOD_NAME .. "PlaceObject",
    interface = {
        PlaceObject = onPlaceObject
    }
}
