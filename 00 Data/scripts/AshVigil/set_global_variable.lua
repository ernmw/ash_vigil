--[[
AshVigil for OpenMW.
Copyright (C) 2026 Ash Vigil contributors (see AUTHORS.md)

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
local aux_util = require('openmw_aux.util')
local world = require('openmw.world')
local settings = require("scripts.AshVigil.settings.settings")

---@class onSetGlobalVariableData
---@field name string
---@field value number
---@field player table?

---@param data onSetGlobalVariableData
local function onSetGlobalVariable(data)
    settings.debugPrint("onSetGlobalVariable: " .. aux_util.deepToString(data, 5))

    local players = {}
    if data.player then
        table.insert(players, data.player)
    else
        players = world.players
    end

    for _, player in pairs(world.players) do
        local vars = world.mwscript.getGlobalVariables(data.player)
        vars[data.name] = data.value
    end

end

return {
    eventHandlers = {
        [MOD_NAME .. "onSetGlobalVariable"] = onSetGlobalVariable,
    },
}
