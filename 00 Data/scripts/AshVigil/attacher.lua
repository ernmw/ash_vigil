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
local types    = require('openmw.types')
local settings = require("scripts.AshVigil.settings.settings")
local allTombs = require("scripts.AshVigil.tombs.load")
local interfaces            = require('openmw.interfaces')
local world    = require('openmw.world')
local FollowerDetectionUtil = interfaces.FollowerDetectionUtil
local aux_util = require('openmw_aux.util')

--- this script is in charge of dynamically attaching scripts to
--- stuff we're interested in.
--- it's like a bad ECS framework

--- don't forget to add these to the omwscripts file!
local scripts               = {
    tomb_actor = string.lower("scripts\\" .. MOD_NAME .. "\\attached\\tomb_actor.lua"),
    tomb_container = string.lower("scripts\\" .. MOD_NAME .. "\\attached\\tomb_container.lua"),
    tomb_interloper = string.lower("scripts\\" .. MOD_NAME .. "\\attached\\tomb_interloper.lua"),
    tomb_item = string.lower("scripts\\" .. MOD_NAME .. "\\attached\\tomb_item.lua"),
    tomb_undead = string.lower("scripts\\" .. MOD_NAME .. "\\attached\\tomb_undead.lua"),
}

local function getRecord(obj)
    if obj.type ~= nil then
        return obj.type.record(obj)
    else
        return nil
    end
end

local function attachOnce(script, object, data)
    if not object:hasScript(script) then
        settings.debugPrint("Attaching "..script.." to "..tostring(getRecord(object).id)..": "..aux_util.deepToString(data, 5))
        object:addScript(script, data)
    end
end

---@class Tomb
---@field id string cell id
---@field region string region id
---@field unrestfulDead boolean? if true, the undead occupants will not be at Peace

local function isUndead(creature)
    return types.Creature.objectIsInstance(creature) and
    types.Creature.record(creature).type == types.Creature.TYPE.Undead
end

local function isBandit(actor)
    --- just check the first player
    for _, player in pairs(world.players) do
        -- 30 is normal for friendly NPCs.
        -- chargen boat guard has 70!
        -- bandits have 90 and 0 disposition
        local fightStat = types.Actor.stats.ai.fight(actor).base
        if types.NPC.objectIsInstance(actor) then
            local startDisposition = types.NPC.getBaseDisposition(actor, player)
            if fightStat >= 90 and startDisposition <= 40 then
                return true
            end
        end
        return fightStat >= 90
    end
    return false
end

local function isFollower(actor)
    local followers = {}
    if FollowerDetectionUtil then
        followers = FollowerDetectionUtil.getFollowerList()
    end
    for _, player in pairs(world.players) do
        if followers[player.id] then
            --- it's a follower
            return true
        end
    end
    return false
end

local function handleGhost(actor)
    if not types.Creature.objectIsInstance(actor) then
        return false
    end

    if not actor:isValid() or types.Actor.isDead(actor) then
        return false
    end
    if not isUndead(actor) then
        return false
    end
    local tombInfo = allTombs[actor.cell.id]
    if tombInfo == nil then
        return false
    end
    if isFollower(actor) then
        return false
    end

    attachOnce(scripts.tomb_undead, actor, tombInfo)
    return true
end


local function handleInterloper(actor)
    if not types.Actor.objectIsInstance(actor) then
        return false
    end
    if not actor:isValid() or types.Actor.isDead(actor) then
        return false
    end
    if isBandit(actor) then
        return false
    end
    local tombInfo = allTombs[actor.cell.id]
    if tombInfo == nil then
        return false
    end
    if isFollower(actor) then
        return false
    end

    attachOnce(scripts.tomb_interloper, actor, tombInfo)
    return true
end

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

local function handleTombItems(object)
    if not sacred_item_types[object.type] then
        --settings.debugPrint("handleTombItems type is "..tostring(object.type))
       return
    end
    local tombInfo = allTombs[object.cell.id]
    if tombInfo == nil then
        return false
    end
    local genPrefix = "generated"
    if string.sub(getRecord(object).id:lower(), 1, #genPrefix) == genPrefix then
        --- dynamic items skipped.
        --- this allows me to skip ash interment urns
        --- this is kinda yucky
        return false
    end
    attachOnce(scripts.tomb_item, object, tombInfo)
    return true
end

local function handleTombContainers(object)
    if not types.Container.objectIsInstance(object) then
        return false
    end
    local tombInfo = allTombs[object.cell.id]
    if tombInfo == nil then
        return false
    end
    attachOnce(scripts.tomb_container, object, tombInfo)
    return true
end

---@type (fun(actor : table): boolean)[]
local handlers = {
    handleTombItems,
    handleTombContainers,
    handleGhost,
    handleInterloper
}

local function onObjectActive(object)
    if not getRecord(object) then
        -- markers
        return
    end
    --settings.debugPrint("onObjectActive: "..tostring(getRecord(object).id))
    for _, handler in ipairs(handlers) do
        if handler(object) then
            return
        end
    end
end

return {
    engineHandlers = {
        onObjectActive = onObjectActive,
    }
}
