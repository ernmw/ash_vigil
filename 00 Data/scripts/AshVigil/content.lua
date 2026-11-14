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
local content = require("openmw.content")
local MOD_NAME = require("scripts.AshVigil.ns")
local const = require("scripts.AshVigil.const")
local core = require("openmw.core")
local localization = core.l10n(MOD_NAME)

content.globals.records[const.URNS_LOST_GVAR] = 0
content.globals.records[const.URNS_DELIVERED_GVAR]      = 0
content.globals.records[const.HAS_URN_GVAR] = 0
content.globals.records[const.URN_DELIVERY_ACTIVE_GVAR] = 0

content.globals.records[const.KOTD_RANK_GVAR]      = -1
content.globals.records[const.KOTD_REPUTATION_GVAR] = 0
content.globals.records[const.KOTD_EXPELLED_GVAR] = 0

local function onContentFilesLoaded()
    content.magicEffects.records[const.SUMMON_CLATTERBONES_EFFECT] = {
        template    = content.magicEffects.records["summonskeletalminion"],
        name        = localization("AV_summon_clatterbones_effect_name"),
        description = localization("AV_summon_clatterbones_effect_description"),
        icon        = "icons/s/b_tx_s_smmn_skltlmnn.dds",
        baseCost    = 30,
        casterLinked = false,
        allowsEnchanting = false,
        allowsSpellmaking = false,
    }

    content.spells.records[const.SUMMON_CLATTERBONES_SPELL] = {
        name    = localization("AV_summon_clatterbones_effect_name"),
        cost    = 30,
        effects = {
            { id = const.SUMMON_CLATTERBONES_EFFECT, range = 0, duration = 0, area = 0,
              magnitudeMin = 1, magnitudeMax = 1 },
        },
    }
end

return {
    engineHandlers = {
        onContentFilesLoaded = onContentFilesLoaded,
    },
}
