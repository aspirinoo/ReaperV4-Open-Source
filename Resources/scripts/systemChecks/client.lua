-- ReaperV4 System Checks Client
-- Clean and optimized version

local Logger = Logger
local Player = Player
local RPC = RPC
local Security = Security
local GetConvar = GetConvar
local gameType = GetConvar("reaper_gameType", "unknown")

-- QuitGame fallback
local QuitGame = QuitGame
if not QuitGame then
    function QuitGame()
        while true do
            -- Infinite loop as fallback
        end
    end
end

local GetActiveScreenResolution = GetActiveScreenResolution
local GetCurrentResourceName = GetCurrentResourceName
local GetProfileSetting = GetProfileSetting
local TriggerServerEvent = TriggerServerEvent
local table_insert = table.insert
local DestroyDui = DestroyDui
local CreateDui = CreateDui
local json_encode = json.encode
local json_decode = json.decode
local Wait = Wait

-- Check for onesync attachment sanitization
local OnesyncEnableRemoteAttachmentSanitization = _ENV["OnesyncEnableRemoteAttachmentSanitization"]
local filterEntityToPedAttachments = GetConvar("reaper_filter_entity_to_ped_attachments", "false")

if filterEntityToPedAttachments == "true" then
    OnesyncEnableRemoteAttachmentSanitization(true)
end

-- System checks state
local systemChecksState = {
    screenResolution = {0, 0},
    profileSettings = {},
    lastCheck = 0
}

-- Get screen resolution
function getScreenResolution()
    local width, height = GetActiveScreenResolution()
    systemChecksState.screenResolution = {width, height}
    return width, height
end

-- Get profile settings
function getProfileSettings()
    local settings = {}
    
    -- Get common profile settings
    settings.fov = GetProfileSetting(43) or 0
    settings.ragdollEnabled = GetProfileSetting(208) or false
    settings.vehicleCameraHeight = GetProfileSetting(223) or 0
    
    systemChecksState.profileSettings = settings
    return settings
end

-- Perform system check
function performSystemCheck()
    systemChecksState.lastCheck = GetGameTimer()
    
    local checkData = {
        screenResolution = getScreenResolution(),
        profileSettings = getProfileSettings(),
        gameType = gameType,
        resourceName = GetCurrentResourceName()
    }
    
    TriggerServerEvent("Reaper:SystemCheck", checkData)
end

-- Initialize system checks
CreateThread(function()
    Wait(5000) -- Wait 5 seconds before first check
    
    while true do
        performSystemCheck()
        Wait(300000) -- Check every 5 minutes
    end
end)

-- Export functions
exports("GetScreenResolution", function()
    return getScreenResolution()
end)

exports("GetProfileSettings", function()
    return getProfileSettings()
end)

exports("PerformSystemCheck", function()
    return performSystemCheck()
end)
