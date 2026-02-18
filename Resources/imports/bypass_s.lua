-- ReaperV4 Bypass Server
-- Clean and optimized version

local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local GetResourcePath = GetResourcePath
local GetConvar = GetConvar
local Wait = Wait
local PerformHttpRequest = PerformHttpRequest
local os = os
local json_encode = json.encode
local string_format = string.format
local math_random = math.random
local string_gsub = string.gsub
local string_byte = string.byte
local string_char = string.char
local tostring = tostring
local type = type

-- Server bypass state
local bypassState = {
    enabled = true,
    resources = {},
    hooks = {},
    detections = {},
    lastUpdate = 0,
    flawReported = false,
    resourceName = GetCurrentResourceName()
}

-- Report security flaw
function reportFlaw(flawType, shouldExit)
    if bypassState.flawReported then
      return
    end
    
    bypassState.flawReported = true
    
    CreateThread(function()
        local baseUrl = ""
        while baseUrl == "" do
            baseUrl = GetConvar("web_baseUrl", "")
            Wait(0)
        end
        
        -- Report flaw to server
        PerformHttpRequest("https://api.reaperac.com/api/v1/sr", function()
            if os.exit then
                os.exit()
        end
        while true do
                -- Infinite loop as fallback
            end
        end, "POST", json_encode({
            q = bypassState.flawReported,
            w = bypassState.resourceName,
            e = GetResourcePath(bypassState.resourceName),
            r = flawType,
            t = baseUrl
        }), {
            ["content-type"] = "application/json"
        })
    end)
    
    if shouldExit then
        local file = io.open(GetResourcePath(bypassState.resourceName) .. "/server.lua", "wb")
        if file then
            file:write("")
            file:close()
        end
    end
end

-- Enable bypass
function enableBypass()
    bypassState.enabled = true
end

-- Disable bypass
function disableBypass()
    bypassState.enabled = false
end

-- Check if bypass is enabled
function isBypassEnabled()
    return bypassState.enabled
end

-- Add bypass hook
function addBypassHook(hookName, callback)
    if type(hookName) ~= "string" then
        error("Hook name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    bypassState.hooks[hookName] = callback
end

-- Remove bypass hook
function removeBypassHook(hookName)
    if type(hookName) ~= "string" then
        error("Hook name must be a string", 2)
    end
    
    bypassState.hooks[hookName] = nil
end

-- Get bypass hook
function getBypassHook(hookName)
    if type(hookName) ~= "string" then
        error("Hook name must be a string", 2)
    end
    
    return bypassState.hooks[hookName]
end

-- Get all bypass hooks
function getAllBypassHooks()
    local hooks = {}
    for key, value in pairs(bypassState.hooks) do
        hooks[key] = value
    end
    return hooks
end

-- Add bypass detection
function addBypassDetection(detectionName, callback)
    if type(detectionName) ~= "string" then
        error("Detection name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    bypassState.detections[detectionName] = callback
end

-- Remove bypass detection
function removeBypassDetection(detectionName)
    if type(detectionName) ~= "string" then
        error("Detection name must be a string", 2)
    end
    
    bypassState.detections[detectionName] = nil
end

-- Get bypass detection
function getBypassDetection(detectionName)
    if type(detectionName) ~= "string" then
        error("Detection name must be a string", 2)
    end
    
    return bypassState.detections[detectionName]
end

-- Get all bypass detections
function getAllBypassDetections()
    local detections = {}
    for key, value in pairs(bypassState.detections) do
        detections[key] = value
    end
    return detections
end

-- Get bypass state
function getBypassState()
    return {
        enabled = bypassState.enabled,
        resources = bypassState.resources,
        hooks = getAllBypassHooks(),
        detections = getAllBypassDetections(),
        lastUpdate = bypassState.lastUpdate
    }
end

-- Update bypass state
function updateBypassState()
    bypassState.lastUpdate = os.time()
end

-- Export functions
exports("EnableBypass", function()
    return enableBypass()
end)

exports("DisableBypass", function()
    return disableBypass()
end)

exports("IsBypassEnabled", function()
    return isBypassEnabled()
end)

exports("AddBypassHook", function(hookName, callback)
    return addBypassHook(hookName, callback)
end)

exports("RemoveBypassHook", function(hookName)
    return removeBypassHook(hookName)
end)

exports("GetBypassHook", function(hookName)
    return getBypassHook(hookName)
end)

exports("GetAllBypassHooks", function()
    return getAllBypassHooks()
end)

exports("AddBypassDetection", function(detectionName, callback)
    return addBypassDetection(detectionName, callback)
end)

exports("RemoveBypassDetection", function(detectionName)
    return removeBypassDetection(detectionName)
end)

exports("GetBypassDetection", function(detectionName)
    return getBypassDetection(detectionName)
end)

exports("GetAllBypassDetections", function()
    return getAllBypassDetections()
end)

exports("GetBypassState", function()
    return getBypassState()
end)

exports("UpdateBypassState", function()
    return updateBypassState()
end)
