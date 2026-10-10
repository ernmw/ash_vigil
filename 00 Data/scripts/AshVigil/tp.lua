local util  = require('openmw.util')
local world = require('openmw.world')
local types = require('openmw.types')
local core  = require('openmw.core')

local ZERO = util.vector3(0, 0, 0)
local UNIT = { util.vector3(1, 0, 0), util.vector3(0, 1, 0), util.vector3(0, 0, 1) }

------------------------------------------------------------------------
-- Oriented bounding box helpers
------------------------------------------------------------------------

local function project(verts, axis)
    local lo, hi = math.huge, -math.huge
    for _, v in ipairs(verts) do
        local d = v:dot(axis)
        if d < lo then lo = d end
        if d > hi then hi = d end
    end
    return lo, hi
end

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

local function prepBox(box)
    local t = box.transform
    local o = t:apply(ZERO)
    local axes = {}
    for i = 1, 3 do axes[i] = (t:apply(UNIT[i]) - o):normalize() end
    return prepVerts(box.vertices, axes)
end

local function intersects(a, b, eps)
    if a.mxx - b.mnx <= eps or b.mxx - a.mnx <= eps then return false end
    if a.mxy - b.mny <= eps or b.mxy - a.mny <= eps then return false end
    if a.mxz - b.mnz <= eps or b.mxz - a.mnz <= eps then return false end

    local function separated(axis)
        local alo, ahi = project(a.verts, axis)
        local blo, bhi = project(b.verts, axis)
        return ahi - blo <= eps or bhi - alo <= eps
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

local function contains(b, a, eps)
    for i = 1, 3 do
        local lo, hi = project(a.verts, b.axes[i])
        if lo < b.ranges[i][1] - eps or hi > b.ranges[i][2] + eps then
            return false
        end
    end
    return true
end

------------------------------------------------------------------------
-- Cell scan
------------------------------------------------------------------------

local function scanCell(cell, exceptions, tileSet)
    local tiles, obstacles = {}, {}
    for _, obj in ipairs(cell:getAll()) do
        if exceptions[obj.id] == nil and obj.enabled then
            local ok, box = pcall(function() return o:getBoundingBox() end)
            if ok and box then
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
    end
    return tiles, obstacles
end

------------------------------------------------------------------------
-- Placement
------------------------------------------------------------------------

-- Random point inside the tile's horizontal footprint, `margin` from its edges.
local function randomXY(tile, margin)
    local b = tile.box
    local p = ZERO
    for i = 1, 2 do
        local lo, hi = b.ranges[i][1] + margin, b.ranges[i][2] - margin
        if hi < lo then lo, hi = (lo + hi) / 2, (lo + hi) / 2 end
        p = p + b.axes[i] * (lo + math.random() * (hi - lo))
    end
    return p
end

-- The object's box if it had rotation `rot` and its origin at `pos`.
-- Built from its current box, so nothing has to be moved to test a spot.
local function boxAt(relVerts, relAxes, delta, pos)
    local verts, axes = {}, {}
    for i, v in ipairs(relVerts) do verts[i] = delta:apply(v) + pos end
    for i = 1, 3 do axes[i] = delta:apply(relAxes[i]) end
    return prepVerts(verts, axes)
end

-- Event: PlaceObject
--   object  : GameObject to place
--   cell    : interior cell name
--   tiles   : list of static record ids that count as room tiles
--   options : maxAttempts (200), margin (32), tolerance (4),
--             rotation, randomYaw (false), token (any)
local function onPlaceObject(data)
    local obj, opts = data.object, data.options or {}
    local cell      = world.getCellByName(data.cell)
    local tolerance = opts.tolerance or 4
    local margin    = opts.margin or 32

    local function report(ok, pos, tile)
        core.sendGlobalEvent('ObjectPlaced', {
            object = obj, ok = ok, position = pos, tile = tile, token = opts.token,
        })
    end

    local tileSet = {}
    for _, id in ipairs(data.tiles) do tileSet[id:lower()] = true end
    local exceptions = {[obj.id]=true}
    local tiles, obstacles = scanCell(cell, exceptions, tileSet)
    if #tiles == 0 then return report(false) end

    -- the object's current box, relative to its own origin
    local cur = prepBox(obj:getBoundingBox())
    local relVerts = {}
    for i, v in ipairs(cur.verts) do relVerts[i] = v - obj.position end
    local curInv = obj.rotation:inverse()

    for _ = 1, opts.maxAttempts or 200 do
        local tile = tiles[math.random(#tiles)]
        local xy = randomXY(tile, margin)

        local rot = opts.rotation or obj.rotation
        if opts.randomYaw then rot = util.transform.rotateZ(math.random() * 2 * math.pi) end
        local delta = rot * curInv

        -- rest the box's lowest point on the tile's lowest point
        local minZ = math.huge
        for _, v in ipairs(relVerts) do minZ = math.min(minZ, delta:apply(v).z) end
        local pos = util.vector3(xy.x, xy.y, tile.box.mnz - minZ)

        local mine = boxAt(relVerts, cur.axes, delta, pos)

        local free = contains(tile.box, mine, tolerance)
        if free then
            for _, ob in ipairs(obstacles) do
                if intersects(mine, ob, tolerance) then free = false; break end
            end
        end

        if free then
            -- lift slightly, let the engine settle it onto the real floor
            obj:teleport(cell, pos + util.vector3(0, 0, 8), { onGround = true, rotation = rot })
            return report(true, pos, tile.obj)
        end
    end

    report(false)
end

return {
    eventHandlers = { PlaceObject = onPlaceObject },
}
