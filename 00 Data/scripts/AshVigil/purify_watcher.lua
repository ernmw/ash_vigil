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
local settings = require("scripts.AshVigil.settings.settings")
local purifyQuests             = require("scripts.AshVigil.purifyQuests.load")

local function onTombInterlopersCleared(cellID)
    settings.debugPrint("onTombInterlopersCleared start - "..tostring(cellID))
    local currentCell = cellID
    ---@type PurifyQuest|nil
    local purifyQuest = nil
    local quests = types.Player.quests(pself)

    for questId, quest in pairs(quests) do
        if purifyQuests[questId] and
            purifyQuests[questId].destCell:lower() == currentCell:lower() and
            purifyQuests[questId].startStage == quest.stage then
            purifyQuest = purifyQuests[questId]
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
        [MOD_NAME .. "onTombInterlopersCleared"] = onTombInterlopersCleared,
    }
}
