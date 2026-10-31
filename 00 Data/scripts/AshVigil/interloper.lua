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
local MOD_NAME = require("scripts.AshVigil.ns")
local world    = require('openmw.world')
local types    = require('openmw.types')
local SCRIPTS        = require("scripts.AshVigil.ecs.scripts")

local function onTombInterloperActive(object)
    for _, player in pairs(world.players) do
        if player.cell.id == object.cell.id then
            player:sendEvent(MOD_NAME .. "onTombInterloperActive", object)
        end
    end
end

local function remaining(cell)
    local count = 0
    for _, npc in pairs(cell:getAll(types.NPC)) do
        if npc:hasScript(SCRIPTS.interloper) and npc.enabled and npc:isValid() and not npc.type.isDead(npc) then
            count = count + 1
        end
    end
    for _, creature in pairs(cell:getAll(types.Creature)) do
        if creature:hasScript(SCRIPTS.interloper) and creature.enabled and creature:isValid() and not creature.type.isDead(creature) then
            count = count + 1
        end
    end
    return count
end

local function onTombInterloperDied(object)
    local count = remaining(object.cell)
    --print("onTombInterloperDied remaining: "..tostring(count))

    for _, player in pairs(world.players) do
        if player.cell.id == object.cell.id then
            player:sendEvent(MOD_NAME .. "onTombInterloperDied", object)
            if count == 0 then
                print("tombcleared")
                player:sendEvent(MOD_NAME .. "onTombInterlopersCleared", object.cell.id)
            end
        end
    end
end

return {
    eventHandlers = {
        [MOD_NAME .. "onTombInterloperDied"] = onTombInterloperDied,
        [MOD_NAME .. "onTombInterloperActive"] = onTombInterloperActive,
    }
}
