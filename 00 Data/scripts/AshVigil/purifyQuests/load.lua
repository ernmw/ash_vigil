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
local vfs      = require('openmw.vfs')
local markup     = require('openmw.markup')
local core       = require('openmw.core')
local types   = require('openmw.types')
local settings = require("scripts.AshVigil.settings.settings")
local collection = require("scripts.AshVigil.collection")

---@class PurifyQuest
---@field id string this is the journal topic id
---@field destCell string
---@field global string
---@field startStage number the start stage to 'activate' the quest. default 10.

---@type {[string]: PurifyQuest}
local quests    = {}

local function dialogueRecordInfoWithStage(infoRecords, stage)
    for _, rec in pairs(infoRecords) do
        if rec.questStage == stage then
            return rec
        end
    end
    return nil
end

local function load()
    local count = 0
    local function hasSuffix(str, suffix)
        if #suffix == 0 then return true end
        return str:sub(- #suffix) == suffix
    end

    ---@param v PurifyQuest
    ---@return PurifyQuest|ErrMsg
    local function loadQuest(v)
        local id = tostring(v.id or "unknown quest")
        if v.startStage == nil then
            v.startStage = 10
        end
        v.id = v.id:lower()
        v.destCell = v.destCell:lower()
        local journalRecord = core.dialogue.journal.records[v.id]
        if journalRecord == nil then
            return id..":  no dialogue journal record with id " .. tostring(v.id)
        end
        if dialogueRecordInfoWithStage(journalRecord.infos, v.startStage) == nil then
            return id..": missing start stage " .. tostring(v.startStage)
        end
        return v
    end

    local function loadFile(fileName)
        local result = markup.loadYaml(fileName)
        for _, v in ipairs(result.quests) do
            ---@cast v PurifyQuest
            local parsed = loadQuest(v)
            if parsed then
                if type(parsed) == "string" then
                    print("Quest load ERROR: " .. parsed)
                else
                    quests[v.id] = v
                    count = count + 1
                end
            end
        end
    end


    for fileName in vfs.pathsWithPrefix("scripts\\" .. MOD_NAME .. "\\purifyQuests") do
        if hasSuffix(fileName:lower(), ".yaml") then
            loadFile(fileName)
        end
    end

    settings.debugPrint("Loaded " .. tostring(count) .. " purify quests.")
end

load()

return quests
