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
local aux_util = require('openmw_aux.util')
local settings = require("scripts.AshVigil.settings.settings")

---@class onRemoveScriptData
---@field object table
---@field script string

---@param data onRemoveScriptData
local function onRemoveScript(data)
    settings.debugPrint("onRemoveScript: " .. aux_util.deepToString(data, 5))
    if not data.object:hasScript(data.script:lower()) then
        data.object:removeScript(data.script:lower())
    end
end

return {
    eventHandlers = {
        [MOD_NAME .. "onRemoveScript"] = onRemoveScript,
    },
}
