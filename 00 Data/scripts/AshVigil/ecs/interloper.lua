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
local MOD_NAME        = require("scripts.AshVigil.ns")
local pself           = require("openmw.self")
local types           = require("openmw.types")
local core                  = require("openmw.core")
local interfaces           = require("openmw.interfaces")
local FollowerDetectionUtil = interfaces.FollowerDetectionUtil

local function isFollower()
    if FollowerDetectionUtil then
        return FollowerDetectionUtil.getState().leader ~= nil
    else
        return false
    end
end

local function onActive()
    if isFollower() then
        core.sendGlobalEvent(MOD_NAME .. "onRemoveScript", {
            object = pself.object,
            script = string.lower("scripts\\" .. MOD_NAME .. "\\ecs\\interloper.lua")
        })
    else
        for _, player in pairs(pself.cell:getAll(types.Player)) do
            player:sendEvent(MOD_NAME .. "onTombInterloperActive", { actor = pself.object })
        end
    end
end

local function onDied()
    for _, player in pairs(pself.cell:getAll(types.Player)) do
        player:sendEvent(MOD_NAME .. "onTombInterloperDied", { actor = pself.object })
    end
    core.sendGlobalEvent(MOD_NAME .. "onRemoveScript", {
        object = pself.object,
        script = string.lower("scripts\\" .. MOD_NAME .. "\\ecs\\interloper.lua")
    })
end

local function onInactive()
    core.sendGlobalEvent(MOD_NAME .. "onRemoveScript", {
        object = pself.object,
        script = string.lower("scripts\\" .. MOD_NAME .. "\\ecs\\peaceful.lua")
    })
end

return {
    eventHandlers = {
        onActive = onActive,
        Died = onDied,
        onInactive = onInactive,
    }
}
