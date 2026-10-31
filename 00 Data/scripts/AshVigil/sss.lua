---@omw-context global
local I            = require('openmw.interfaces')
local core         = require('openmw.core')
local MOD_NAME     = require("scripts.AshVigil.ns")
local localization = core.l10n(MOD_NAME)

local function onPlayerAdded(player)
    player:sendEvent("ShowMessage", { message = localization("sssTooOld"), showInDialogue = false })
end

local SSS = I.StaticSwitcher_G
if not SSS or SSS.version < 5 then
    print("Version of Static Switching System is too old")
    return {
        engineHandlers = {
            onPlayerAdded = onPlayerAdded,
        }
    }
end

return {}
