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
local types    = require('openmw.types')

local sacred_item_types = {
    [types.Container] = true,
    [types.Apparatus] = true,
    [types.Armor] = true,
    [types.Book] = true,
    [types.Clothing] = true,
    [types.Ingredient] = true,
    [types.Light] = true,
    [types.Lockpick] = true,
    [types.Miscellaneous] = true,
    [types.Potion] = true,
    [types.Probe] = true,
    [types.Repair] = true,
    [types.Weapon] = true,
}

local function onActivate(object, actor)
    if not sacred_item_types[object.type] then
        return
    end
    if not types.Player.objectIsInstance(actor) then
        return
    end
    for _, other in pairs(object.cell:getAll(types.NPC)) do
        if not types.Player.objectIsInstance(other) then
            other:sendEvent(MOD_NAME .. "onDisturb")
        end
    end
    for _, other in pairs(object.cell:getAll(types.Creature)) do
        other:sendEvent(MOD_NAME .. "onDisturb")
    end
end

return {
    engineHandlers = {
        onActivate = onActivate
    }
}
