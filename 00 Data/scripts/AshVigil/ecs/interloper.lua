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
local MOD_NAME        = require("scripts.AshVigil.ns")
local pself           = require("openmw.self")
local types           = require("openmw.types")
local core                  = require("openmw.core")
local interfaces           = require("openmw.interfaces")
local FollowerDetectionUtil = interfaces.FollowerDetectionUtil
local SCRIPTS        = require("scripts.AshVigil.ecs.scripts")

local function isFollower()
    if FollowerDetectionUtil then
        return FollowerDetectionUtil.getState().leader ~= nil
    else
        return false
    end
end

local recordName = pself.type.record(pself.object).name
--print("interloper script created - " .. recordName)

local function start()
    print("interloper start - "..recordName)
    if isFollower() then
        core.sendGlobalEvent(MOD_NAME .. "onRemoveScript", {
            object = pself.object,
            script = SCRIPTS.interloper
        })
    else
        core.sendGlobalEvent(MOD_NAME .. "onTombInterloperActive", pself.object)
    end
end

local function onInit(data)
    start()
end

local function onActive()
    start()
end


local function onDied()
    print("interloper died - "..recordName)
    core.sendGlobalEvent(MOD_NAME .. "onTombInterloperDied", pself.object)
    core.sendGlobalEvent(MOD_NAME .. "onRemoveScript", {
        object = pself.object,
        script = SCRIPTS.interloper
    })
end

local function onInactive()
    core.sendGlobalEvent(MOD_NAME .. "onRemoveScript", {
        object = pself.object,
        script = SCRIPTS.interloper
    })
end

return {
    eventHandlers = {
        Died = onDied,
    },
    engineHandlers = {
        onInit = onInit,
        onActive = onActive,
        onInactive = onInactive
    }
}
