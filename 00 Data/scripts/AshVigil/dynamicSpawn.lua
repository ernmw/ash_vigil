--[[
AshVigil for OpenMW.
Copyright (C) 2026 Ash Vigil contributors (see AUTHORS)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]
local MOD_NAME          = require("scripts.AshVigil.ns")
local const = require("scripts.AshVigil.const")
local storage  = require('openmw.storage')
local world    = require('openmw.world')
local async    = require('openmw.async')
local types    = require('openmw.types')
local core    = require('openmw.core')
local aux_util = require('openmw_aux.util')
local settings = require("scripts.AshVigil.settings.settings")
local interfaces = require('openmw.interfaces')
local vfs = require('openmw.vfs')
local dynSpawns             = require("scripts.AshVigil.dynamicSpawnInfo.load")

local persist = {
    finishedCells = {},
}
local function onLoad(data)
    if data then
        persist = data
    end
end
local function onSave()
    return persist
end

---@param spawnInfo DynamicSpawnInfo
local function spawnInCell(spawnInfo)
    local obj = world.createObject(spawnInfo.objectRecord, 1)
    if obj == nil then
        error("bad record: "..tostring(spawnInfo.objectRecord))
    end
    ---@type PlaceRequest
    local opts = {
        object = obj,
        cell = world.getCellById(spawnInfo.cell) or world.getCellByName(spawnInfo.cell),
        tiles = spawnInfo.tiles
    }
    local result = interfaces.AshVigilObjectPlacer.Place(opts)
    if result then
        settings.debugPrint("placed " .. spawnInfo.objectRecord .. " in cell")
    else
        settings.debugPrint("failed to place " .. spawnInfo.objectRecord .. " in cell")
    end
end

local function onCellEntered(cellID)
    if persist.finishedCells[cellID] then
        return
    end
    for _, spawnDef in ipairs(dynSpawns[cellID] or {}) do
        spawnInCell(spawnDef)
    end
    persist.finishedCells[cellID] = true
end

return {
    eventHandlers = {
        [MOD_NAME .. "onCellEntered"] = onCellEntered,
    },
    engineHandlers = {
        onLoad = onLoad,
        onSave = onSave,
    },
}
