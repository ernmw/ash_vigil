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

---@class Tomb
---@field id string cell id
---@field region string region id

---@type {[string]: Tomb}
local tombs    = {}

local function load()
    local count = 0
    local function hasSuffix(str, suffix)
        if #suffix == 0 then return true end
        return str:sub(- #suffix) == suffix
    end

    ---@param v Tomb
    ---@return Tomb|ErrMsg
    local function loadTomb(v)
        if v.id == nil then
            return "unknown tomb: no id"
        end
        return v
    end

    local function loadFile(fileName)
        local result = markup.loadYaml(fileName)
        for _, v in ipairs(result.quests) do
            ---@cast v Tomb
            local parsed = loadTomb(v)
            if parsed then
                if type(parsed) == "string" then
                    print("Tomb load ERROR: " .. parsed)
                else
                    tombs[v.id] = v
                    count = count + 1
                end
            end
        end
    end


    for fileName in vfs.pathsWithPrefix("scripts\\" .. MOD_NAME .. "\\tombs") do
        if hasSuffix(fileName:lower(), ".yaml") then
            loadFile(fileName)
        end
    end

    settings.debugPrint("Loaded " .. tostring(count) .. " tombs.")
end

load()

return tombs
