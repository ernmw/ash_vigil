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
local const    = require("scripts.AshVigil.const")
local pself    = require("openmw.self")
local core     = require("openmw.core")
local nearby    = require("openmw.nearby")

local function calmSelf()
    pself.type.activeSpells(pself):add({
        id = const.PEACE_SPELL,
        effects = { 0 },
        ignoreResistances = true,
        ignoreSpellAbsorption = true,
        ignoreReflect = true
    })
end


local function onInit(data)
    calmSelf()
end

local function onActive()
    calmSelf()
end

local function onDisturb()
    for _, spell in pairs(pself.type.activeSpells(pself)) do
        if spell.id == const.PEACE_SPELL then
            pself.type.activeSpells(pself):remove(spell.activeSpellId)
        end
    end
end

local function onHit()
    onDisturb()
    for _, actor in pairs(nearby.actors) do
        actor:sendEvent(MOD_NAME .. "onDisturb")
    end
end

return {
    eventHandlers = {
        [MOD_NAME .. "onDisturb"] = onDisturb,
        Hit = onHit,
    },
    engineHandlers = {
        onActive = onActive,
        onInit = onInit,
    },
}
