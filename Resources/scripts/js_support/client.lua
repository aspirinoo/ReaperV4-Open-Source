-- Reaper AntiCheat - Client JavaScript Support System
-- Cleaned and deobfuscated version

local Security = Security
local Logger = Logger
local Player = Player
local table = table
local LocalPlayer = LocalPlayer
local GetConvar = GetConvar
local TriggerServerEvent = TriggerServerEvent
local TriggerLatentServerEvent = TriggerLatentServerEvent
local TriggerEvent = TriggerEvent
local GetInvokingResource = GetInvokingResource
local GetGameTimer = GetGameTimer
local tostring = tostring
local exports = exports

-- TriggerServerEvent export with JS support
exports("TriggerServerEvent", function(eventName, ...)
    local invokingResource = GetInvokingResource()
    local allowJsEvents = GetConvar("reaper_allow_js_events", "false")
    
    if allowJsEvents == "false" then
        Logger.log("The resource ^3%s^7 attempted to trigger the event ^3%s^7 with ^3exports.ReaperV4:TriggerServerEvent^7 but the convar ^3reaper_allow_js_events^7 was set to false", "info")
        return
    end
    
    TriggerServerEvent(eventName, ...)
end)

-- TriggerLatentServerEvent export with JS support
exports("TriggerLatentServerEvent", function(eventName, ...)
    local invokingResource = GetInvokingResource()
    local allowJsEvents = GetConvar("reaper_allow_js_events", "false")
    
    if allowJsEvents == "false" then
        Logger.log("The resource ^3%s^7 attempted to trigger the event ^3%s^7 with ^3exports.ReaperV4:TriggerServerEvent^7 but the convar ^3reaper_allow_js_events^7 was set to false", "info")
        return
    end
    
    TriggerLatentServerEvent(eventName, ...)
end)

-- TriggerEvent export with JS support
exports("TriggerEvent", function(eventName, ...)
    local invokingResource = GetInvokingResource()
    local allowJsEvents = GetConvar("reaper_allow_js_events", "false")
    
    if allowJsEvents == "false" then
        Logger.log("The resource ^3%s^7 attempted to trigger the event ^3%s^7 with ^3exports.ReaperV4:TriggerServerEvent^7 but the convar ^3reaper_allow_js_events^7 was set to false", "info")
        return
    end
    
    TriggerEvent(eventName, ...)
end)

-- SetStateJs export for JavaScript state management
exports("SetStateJs", function(key, value)
    local allowJsEvents = GetConvar("reaper_allow_js_events", "false")
    
    if allowJsEvents == "false" then
        return
    end
    
    local invokingResource = GetInvokingResource()
    local currentTime = GetGameTimer()
    
    -- Set the state value
    LocalPlayer.state:set(key, value)
    
    -- Set security hash for the state
    local stateKey = "reaper:" .. Security.hash(key)
    local securityData = {
        key = Security.hash(key .. tostring(value) .. currentTime),
        key2 = currentTime,
        key3 = value,
        eventName = key
    }
    
    LocalPlayer.state:set(stateKey, securityData)
    
    -- Record the state change
    table.insert(StateRecorder, {
        index = key,
        value = value,
        invoking_resource = invokingResource,
        path = "js_invoke",
        time = currentTime
    })
end)