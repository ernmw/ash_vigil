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
local MOD_NAME        = require("scripts.AshVigil.ns")
local pself           = require("openmw.self")
local core     = require("openmw.core")
local const    = require("scripts.AshVigil.const")

local function onDied()
    print("elvas savel died")
    core.sendGlobalEvent(MOD_NAME .. "onSetGlobalVariable", {
        name = const.ELVAS_SAVEL_DEAD_GVAR,
        value = 1
    })
end


return {
    eventHandlers = {
        Died = onDied,
    }
}
