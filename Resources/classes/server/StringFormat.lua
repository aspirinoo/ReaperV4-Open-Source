-- ReaperV4 Server StringFormat Class
-- Clean and optimized version

local class = class

-- StringFormat class definition
local StringFormatClass = class("StringFormat")

-- Constructor
function StringFormatClass:constructor()
    self.supportLinks = {
        blacklistedParticles = "",
        entityRatelimit = "",
        BlacklistedExplosions = "",
        particleRatelimits = "",
        antiWeaponRemoveGive = "https://blog.reaperac.com/l/anti-give-remove-weapons",
        antiClearPedTasks = "https://blog.reaperac.com/l/anti-remove-from-vehicle",
        antiSpectate = "- https://blog.reaperac.com/l/anti-spectate",
        antiInvisible = "https://blog.reaperac.com/l/anti-invisible",
        executorDetected = "",
        antiGodMode = "https://blog.reaperac.com/l/anti-godmode",
        antiFreeCam = "",
        antiVehicleModifier = "",
        antiAiFolder = "https://blog.reaperac.com/l/anti-aifolder-x64",
        antiDevTools = "https://blog.reaperac.com/l/anti-dev-tools",
        antiTeleport = "https://blog.reaperac.com/l/anti-teleport",
        antiNoClip = "https://blog.reaperac.com/l/anti-noclip",
        autoAntiWeaponSpawn = "https://blog.reaperac.com/l/auto-anti-weapon-spawn",
        configSyncTamper = "",
        antiWeaponModifier = "",
        antiTrigger = "",
        antiBypass = "",
        antiVoiceExploits = "https://blog.reaperac.com/l/anti-voice-exploits",
        antiTriggerClientEvent = "",
        eventModification = "",
        killPlayer = ""
    }
end

-- Get support link
function StringFormatClass:getSupportLink(key)
    return self.supportLinks[key]
end

-- Create StringFormat instance
StringFormat = StringFormatClass.new()

-- Export functions
exports("GetSupportLink", function(key)
    return StringFormat:getSupportLink(key)
end)

exports("GetAllSupportLinks", function()
    return StringFormat.supportLinks
end)