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
local core                  = require('openmw.core')
local types                 = require('openmw.types')
local pself                 = require('openmw.self')
local MOD_NAME              = require("scripts.AshVigil.ns")
local settings   = require("scripts.AshVigil.settings.settings")

local function onTombInterloperActive(actor)
    settings.debugPrint("onTombInterloperActive start")
end

local function onTombInterlopersCleared(cellID)
    settings.debugPrint("onTombInterlopersCleared start")
    local currentCell = cellID
    ---@type PurifyQuest|nil
    local purifyQuest = nil
    local quests = types.Player.quests(pself)

    for questId, quest in pairs(quests) do
        if quests[questId] and
            quests[questId].destCell:lower() == currentCell:lower() and
            quests[currentCell].startStage == quest.stage then
            purifyQuest = quests[questId]
        end
    end

    if not purifyQuest then
        return
    end

    core.sendGlobalEvent(MOD_NAME .. "onSetGlobalVariable", {
        name = purifyQuest.global,
        value = 1,
        player = pself,
    })
end


return {
    eventHandlers = {
        [MOD_NAME .. "onTombInterloperActive"] = onTombInterloperActive,
        [MOD_NAME .. "onTombInterlopersCleared"] = onTombInterlopersCleared,
    }
}
