-- ReaperV4 Bypass Client
-- Clean and optimized version

-- Check if running on server
if IsDuplicityVersion() then
    return
end

-- Load shared Reaper functions
local LoadSharedReaper = LoadSharedReaper
if not LoadSharedReaper then
    print("[REAPER] - Failed to load needed dependencies from @ReaperV4/imports/bypass.lua")
    return
end

-- Load shared Reaper
local sharedReaper = LoadSharedReaper()

-- Deep copy function
function deepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return setmetatable(copy, getmetatable(original))
end

-- Client bypass state
local bypassState = {
    enabled = true,
    hooks = {},
    detections = {},
    lastUpdate = 0
}

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
        hooks = getAllBypassHooks(),
        detections = getAllBypassDetections(),
        lastUpdate = bypassState.lastUpdate
    }
end

-- Update bypass state
function updateBypassState()
    bypassState.lastUpdate = GetGameTimer()
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
