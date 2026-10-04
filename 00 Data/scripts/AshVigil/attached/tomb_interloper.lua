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
local core           = require("openmw.core")
local pself           = require("openmw.self")
local types           = require("openmw.types")

---@class TombInterloperData
---@field tomb Tomb?

---@type TombInterloperData
local persist  = {}

---@param data Tomb
local function onLoad(data)
    if data then
        persist = data
    end
end
local function onSave()
    return persist
end

local function onDied()
    core.sendGlobalEvent(MOD_NAME .. "onTombInterloperDied", { actor = pself.object })

    for _, player in pairs(pself.cell:getAll(types.Player)) do
        player:sendEvent(MOD_NAME .. "onTombInterloperDied", {actor = pself.object})
    end

end

local function onActive()
    core.sendGlobalEvent(MOD_NAME .. "onTombInterloperActive", { actor = pself.object })

    for _, player in pairs(pself.cell:getAll(types.Player)) do
        player:sendEvent(MOD_NAME .. "onTombInterloperActive", {actor = pself.object})
    end
end

---@param data Tomb
local function onInit(data)
    if data then
        persist = { tomb = data }
        onActive()
    end
end

return {
    eventHandlers = {
        Died = onDied,
    },
    engineHandlers = {
        onLoad = onLoad,
        onSave = onSave,
        onActive = onActive,
        onInit = onInit,
    },
}
