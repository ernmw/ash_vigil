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
local aux_util = require('openmw_aux.util')
local world        = require('openmw.world')
local util = require('openmw.util')
local settings = require("scripts.AshVigil.settings.settings")
local core = require('openmw.core')
local types = require('openmw.types')

local dsScriptPath = string.lower("scripts\\" .. MOD_NAME .. "\\ecs\\ds.lua")

---@class onKissData
---@field player table
---@field actor table

---@param data onKissData
local function onKissStart(data)
    --- this is called when the player hits the DS kiss dialogue.
    settings.debugPrint("onKissStart: " .. aux_util.deepToString(data, 5))
    if not data.actor:hasScript(dsScriptPath) then
        data.actor:addScript(dsScriptPath, {
            player = data.player,
        })
    end
end

---@param data onKissData
local function onKissStop(data)
    --- this is called when the kiss animation stops
    settings.debugPrint("onKissStop: " .. aux_util.deepToString(data, 5))

    local actorPosition = data.actor.position

    --- play recall VFX
    local recall = core.magic.effects.records[core.magic.EFFECT_TYPE.Recall]
    local model = types.Static.records[recall.castStatic].model
    core.world.vfx.spawn(model, data.actor.position, {
        particleTextureOverride = recall.particle,
        loop = false,
    })
    --- disable the actor
    data.actor:remove()
    --- spawn hostile scamps
    local summonEffect = core.magic.effects.records[
        core.magic.EFFECT_TYPE.SummonCreature01
    ]
    local summonModel = types.Static.records[summonEffect.castStatic].model
    local summonScamp = function(position)
        local scamp = world.createObject("scamp")
        scamp:teleport(data.player.cell, position, { onGround = true })

        world.vfx.spawn(summonModel, position, {
            particleTextureOverride = summonEffect.particle,
            loop = false,
        })
    end

    summonScamp(actorPosition+util.vector3(20,20,0))
    summonScamp(actorPosition+util.vector3(20,-20,0))
    summonScamp(actorPosition + util.vector3(-20, 20, 0))
    summonScamp(actorPosition+util.vector3(-20,-20,0))
end

return {
    eventHandlers = {
        [MOD_NAME .. "onKissStart"] = onKissStart,
        [MOD_NAME .. "onKissStop"] = onKissStop,
    },
}
