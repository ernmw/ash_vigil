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
local MOD_NAME = require("scripts.AshVigil.ns")
local vfs      = require('openmw.vfs')
local markup     = require('openmw.markup')
local core   = require('openmw.core')
local settings = require("scripts.AshVigil.settings.settings")
local collection = require("scripts.AshVigil.collection")

---@class DynamicSpawnInfo
---@field cell string cell id
---@field tiles string[] valid target tile record ids to place on
---@field objectRecord string object record to insert into cell

---@type DynamicSpawnInfo[]
local spawnInfo    = {}

local function load()
    local count = 0
    local function hasSuffix(str, suffix)
        if #suffix == 0 then return true end
        return str:sub(- #suffix) == suffix
    end

    local function loadFile(fileName)
        local result = markup.loadYaml(fileName)
        for _, v in ipairs(result.dynamicSpawnInfo) do
            ---@param v DynamicSpawnInfo
            ---@return DynamicSpawnInfo|ErrMsg
            local function loadSpawn(v)
                if not v.cell then
                    return "unknown spawn: no cell"
                end
                if not v.objectRecord then
                    return "unknown spawn: no object record"
                end
                if #(v.tiles) <= 0 then
                    return "unknown spawn: no tiles"
                end
                v.cell = v.cell:lower()
                v.objectRecord = v.objectRecord:lower()
                for i, val in ipairs(v.tiles) do
                    v.tiles[i] = val:lower()
                end
                return v
            end
            ---@cast v DynamicSpawnInfo
            local parsed = loadSpawn(v)
            if parsed then
                if type(parsed) == "string" then
                    print("Spawn load ERROR: " .. parsed)
                else
                    table.insert(spawnInfo, v)
                    count = count + 1
                end
            end
        end
    end


    for fileName in vfs.pathsWithPrefix("scripts\\" .. MOD_NAME .. "\\dynamicSpawnInfo") do
        if hasSuffix(fileName:lower(), ".yaml") then
            loadFile(fileName)
        end
    end

    settings.debugPrint("Loaded " .. tostring(count) .. " dynamic spawn infos.")
end

load()

return spawnInfo
