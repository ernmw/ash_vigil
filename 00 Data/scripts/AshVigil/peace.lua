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


local function getRecord(obj)
    return obj.type.record(obj)
end

local function removePeace(cell)
    for _, creature in ipairs(cell:getAll(types.Creature)) do
        for _, spell in pairs(creature.type.activeSpells(creature)) do
            if spell.id == const.PEACE_SPELL then
                settings.debugPrint("Disturbing " .. tostring(getRecord(creature).id))
                creature.type.activeSpells(creature):remove(spell.activeSpellId)
            end
        end
    end
end

local function onTombContainerActivated(data)
    removePeace(data.container.cell)
end

local function onTombItemActivated(data)
    removePeace(data.item.cell)
    --- remove script attached to item, too.
    --- this shouldn't keep re-activating
    local itemScript = string.lower("scripts\\" .. MOD_NAME .. "\\attached\\tomb_item.lua")
    if data.item:hasScript(itemScript) then
        data.item:removeScript(itemScript)
    end
end

local function onTombUndeadActive(data)
    local players = data.actor.cell:getAll(types.Player)
    --- TODO: if player is in KotD...
    --- calm
    data.actor.type.activeSpells(data.actor):add({
        id = const.PEACE_SPELL,
        effects = { 0 },
        ignoreResistances = true,
        ignoreSpellAbsorption = true,
        ignoreReflect = true
    })
end

return {
    eventHandlers = {
        [MOD_NAME .. "onTombContainerActivated"] = onTombContainerActivated,
        [MOD_NAME .. "onTombItemActivated"] = onTombItemActivated,
        [MOD_NAME .. "onTombUndeadActive"] = onTombUndeadActive,
    }
}
