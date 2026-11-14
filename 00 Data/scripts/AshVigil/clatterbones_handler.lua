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
local const          = require("scripts.AshVigil.const")
local aux_util = require('openmw_aux.util')
local world        = require('openmw.world')
local util = require('openmw.util')
local settings = require("scripts.AshVigil.settings.settings")
local core = require("openmw.core")
local localization = core.l10n(MOD_NAME)
local types = require('openmw.types')

local persist  = {
    clatterbonesRef = nil
}

local function onLoad(data)
    if data ~= nil then
        persist = data
    end
end
local function onSave()
    return persist
end

---@class onClatterbonesActiveData
---@field object table

---@param data onClatterbonesActiveData
local function onClatterbonesActive(data)
    settings.debugPrint("found clatterbones")
    if data ~= nil then
        persist.clatterbonesRef = data.object
    end
end

local forward = util.vector3(0.0, 1.0, 0.0)

local function onSummonClatterbones(data)
    settings.debugPrint("summoning clatterbones")

    --- don't summon if dead. clatterbones will resurrect in molag mar via mwscript.
    if persist.clatterbonesRef == nil or types.Creature.isDead(persist.clatterbonesRef) or types.Creature.isDeathFinished(persist.clatterbonesRef) then
        data.player:sendEvent("ShowMessage", { message = localization("AV_summon_clatterbones_effect_fail") })
        return
    end

    local script = world.mwscript.getLocalScript(persist.clatterbonesRef)

    --- don't summon if not a companion
    if script.variables["companion"] == 0 then
        data.player:sendEvent("ShowMessage", { message = localization("AV_summon_clatterbones_effect_fail") })
        return
    end

    --- unset pending travel to molag mar.
    script.variables["gotomm"] = 0

    local facing = data.player.rotation:apply(forward):normalize() * 100
    local pos = data.player.position + facing

    local summonEffect = core.magic.effects.records[const.SUMMON_CLATTERBONES_EFFECT]
    local summonModel = types.Static.records[summonEffect.castStatic].model

    persist.clatterbonesRef:teleport(data.player.cell, pos, { onGround = true })

    world.vfx.spawn(summonModel, pos, {
        particleTextureOverride = summonEffect.particle,
        loop = false,
    })

end

return {
    engineHandlers = {
        onSave = onSave,
        onLoad = onLoad,
    },
    eventHandlers = {
        [MOD_NAME .. "onClatterbonesActive"] = onClatterbonesActive,
        [MOD_NAME .. "onSummonClatterbones"] = onSummonClatterbones,
    },
}
