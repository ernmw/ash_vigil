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
local MOD_NAME                     = require("scripts.AshVigil.ns")
local content                      = require('openmw.content')
local const                     = require("scripts.AshVigil.const")

content.globals.records[const.URNS_LOST_GVAR] = 0
content.globals.records[const.URNS_DELIVERED_GVAR]      = 0
content.globals.records[const.HAS_URN_GVAR] = 0
content.globals.records[const.URN_DELIVERY_ACTIVE_GVAR] = 0
content.globals.records[const.KOTD_RANK_GVAR]      = -1
content.globals.records[const.KOTD_REPUTATION_GVAR] = 0
content.globals.records[const.KOTD_EXPELLED_GVAR] = 0
