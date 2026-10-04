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
local types    = require('openmw.types')
local settings = require("scripts.AshVigil.settings.settings")
local allTombs             = require("scripts.AshVigil.tombs.load")

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

local function kotdStanding(player)
    local kotdRep = types.NPC.getFactionReputation(player, const.KOTD_NAME)
    --- 0 means not in the faction
    local kotdRank = types.NPC.getFactionRank(player, const.KOTD_NAME)
    local kotdExpelled = (types.NPC.isExpelled(player, const.KOTD_NAME) or types.NPC.isExpelled(player, "temple"))
    return kotdRep > 0 and kotdRank > 0 and not kotdExpelled
end

local function onTombUndeadActive(data)
    local kotdPresent = false
    for _, player in pairs(data.actor.cell:getAll(types.Player)) do
        kotdPresent = kotdPresent or kotdStanding(player)
    end
    if not kotdPresent then
        return
    end

    local tombData = allTombs[data.actor.cell.id]
    if tombData.unrestfulDead ~= true then
        return
    end

    local hasPeace = false
    for _, spell in pairs(data.actor.type.activeSpells(data.actor)) do
        hasPeace = hasPeace or (spell.id == const.PEACE_SPELL)
    end
    if not hasPeace then
        settings.debugPrint("Calming " .. getRecord(data.actor).id)
        data.actor.type.activeSpells(data.actor):add({
            id = const.PEACE_SPELL,
            effects = { 0 },
            ignoreResistances = true,
            ignoreSpellAbsorption = true,
            ignoreReflect = true
        })
    end

end

return {
    eventHandlers = {
        [MOD_NAME .. "onTombContainerActivated"] = onTombContainerActivated,
        [MOD_NAME .. "onTombItemActivated"] = onTombItemActivated,
        [MOD_NAME .. "onTombUndeadActive"] = onTombUndeadActive,
    }
}
