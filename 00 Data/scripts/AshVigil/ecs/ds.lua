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
local const    = require("scripts.AshVigil.const")
local pself    = require("openmw.self")
local core                  = require("openmw.core")
local nearby                = require("openmw.nearby")
local interfaces = require("openmw.interfaces")
local animation  = require('openmw.animation')
local types          = require('openmw.types')
local SCRIPTS        = require("scripts.AshVigil.ecs.scripts")

local persist    = {
    player = nil,
    elapsedDuration = 0
}

local function calmSelf()
    pself.type.activeSpells(pself):add({
        id = const.PEACE_SPELL,
        effects = { 0 },
        ignoreResistances = true,
        ignoreSpellAbsorption = true,
        ignoreReflect = true
    })
end


local function onKissDone()
    print("kiss done")
    core.sendGlobalEvent(MOD_NAME .. "onKissStop", { player = persist.player, actor = pself })
end

local function start()
    interfaces.AnimationController.addTextKeyHandler("AVblowkiss", function(groupname, key)
        if key == "stop" then
            --- all done with kiss!
            onKissDone()
        end
    end)
    interfaces.AnimationController.playBlendedAnimation("AVblowkiss", { startkey = "start", stopkey = "stop", priority = animation.PRIORITY.Scripted })
end


local function onInit(data)
    if data ~= nil then
        persist = {player = data.player, elapsedDuration = 0}
    end
    start()
end

local function onActivate()
    start()
end

local function onLoad(data)
    if data ~= nil then
        persist = data
    end
end

local function onSave()
    return persist
end

local healthStart = pself.type.stats.dynamic.health(pself)
local function onUpdate(dt)
    --- invincible
    persist.elapsedDuration = (persist.elapsedDuration or 0) + dt
    healthStart.base = 10000
    healthStart.current = 10000
end

return {
    engineHandlers = {
        onUpdate = onUpdate,
        onActivate = onActivate,
        onInit = onInit,
        onLoad = onLoad,
        onSave = onSave,
    },
}
