-- ReaperV4 Client NUI Class
-- Clean and optimized version

local class = class
local SendNUIMessage = SendNUIMessage
local RegisterNUICallback = RegisterNUICallback
local SetNuiFocus = SetNuiFocus
local promise_new = promise.new
local GetGameTimer = GetGameTimer
local Citizen_Await = Citizen.Await
local GetActiveScreenResolution = GetActiveScreenResolution
local CreateDui = CreateDui
local SendDuiMessage = SendDuiMessage
local IsDuiAvailable = IsDuiAvailable
local json_encode = json.encode
local GetConvar = GetConvar
local Wait = Wait
local Logger = Logger
local CreateThread = CreateThread

-- NUI class definition
local NUIClass = class("NUI")

-- Constructor
function NUIClass:constructor()
    self.callbacks = {}
    self.pendingPromises = {}
    self.requestId = 0
    self.duiHandle = nil
    self.screenWidth = 0
    self.screenHeight = 0
end

-- Wait for Security to be available
CreateThread(function()
    while _G.Security == nil do
        Wait(100)
    end
    self.security = _G.Security
end)

-- Initialize screen resolution
CreateThread(function()
    local width, height = GetActiveScreenResolution()
    self.screenWidth = width
    self.screenHeight = height
end)

-- Send NUI message
function NUIClass:sendMessage(data)
    if type(data) ~= "table" then
        error("Data must be a table", 2)
    end
    
    SendNUIMessage(data)
end

-- Register NUI callback
function NUIClass:on(callbackName, callback)
    if type(callbackName) ~= "string" then
        error("Callback name must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    self.callbacks[callbackName] = callback
    
    RegisterNUICallback(callbackName, function(data, cb)
        local result = callback(data, cb)
        return result
    end)
end

-- Set NUI focus
function NUIClass:setFocus(hasFocus, hasCursor)
    SetNuiFocus(hasFocus, hasCursor or false)
end

-- Send message and await response
function NUIClass:sendMessageAndAwait(data, timeout)
    timeout = timeout or 5000
    
    local requestId = self.requestId + 1
    self.requestId = requestId
    
    local promise = promise_new(function(resolve, reject)
        self.pendingPromises[requestId] = {
            resolve = resolve,
            reject = reject,
            timeout = GetGameTimer() + timeout
        }
    end)
    
    data.requestId = requestId
    self:sendMessage(data)
    
    return promise
end

-- Handle NUI response
function NUIClass:handleResponse(requestId, success, result, error)
    local pendingPromise = self.pendingPromises[requestId]
    if not pendingPromise then
        return
    end
    
    self.pendingPromises[requestId] = nil
    
    if success then
        pendingPromise.resolve(result)
    else
        pendingPromise.reject(error)
    end
end

-- Clean up expired promises
function NUIClass:cleanupExpiredPromises()
    local currentTime = GetGameTimer()
    
    for requestId, promise in pairs(self.pendingPromises) do
        if currentTime > promise.timeout then
            promise.reject("NUI request timeout")
            self.pendingPromises[requestId] = nil
        end
    end
end

-- Clip screen
function NUIClass:clipScreen()
    if not self.security then
        return nil
    end
    
    local data = {
        type = "clipScreen",
        timestamp = GetGameTimer()
    }
    
    return self:sendMessageAndAwait(data)
end

-- Take screenshot
function NUIClass:screenshot()
    if not self.security then
        return nil
    end
    
    local data = {
        type = "screenshot",
        timestamp = GetGameTimer()
    }
    
    return self:sendMessageAndAwait(data)
end

-- Get OCR text
function NUIClass:getOCRText()
    if not self.security then
        return nil
    end
    
    local data = {
        type = "getOCRText",
        timestamp = GetGameTimer()
    }
    
    return self:sendMessageAndAwait(data)
end

-- Create DUI
function NUIClass:createDUI(url, width, height)
    if type(url) ~= "string" then
        error("URL must be a string", 2)
    end
    
    width = width or 800
    height = height or 600
    
    self.duiHandle = CreateDui(url, width, height)
    return self.duiHandle
end

-- Send DUI message
function NUIClass:sendDUIMessage(message)
    if not self.duiHandle then
        error("DUI not created", 2)
    end
    
    if type(message) ~= "string" then
        message = json_encode(message)
    end
    
    SendDuiMessage(self.duiHandle, message)
end

-- Check if DUI is available
function NUIClass:isDUIAvailable()
    if not self.duiHandle then
        return false
    end
    
    return IsDuiAvailable(self.duiHandle)
end

-- Get screen resolution
function NUIClass:getScreenResolution()
    return self.screenWidth, self.screenHeight
end

-- Get screen center
function NUIClass:getScreenCenter()
    return self.screenWidth / 2, self.screenHeight / 2
end

-- Convert world to screen coordinates
function NUIClass:worldToScreen(worldX, worldY, worldZ)
    local screenX, screenY = GetScreenCoordFromWorldCoord(worldX, worldY, worldZ)
    return screenX, screenY
end

-- Convert screen to world coordinates
function NUIClass:screenToWorld(screenX, screenY)
    local worldX, worldY, worldZ = GetWorldCoordFromScreenCoord(screenX, screenY)
    return worldX, worldY, worldZ
end

-- Create NUI instance
NUI = NUIClass.new()

-- Cleanup thread
CreateThread(function()
    while true do
        NUI:cleanupExpiredPromises()
        Wait(5000)
    end
end)

-- Handle NUI responses
RegisterNUICallback("nuiResponse", function(data, cb)
    if data.requestId then
        NUI:handleResponse(data.requestId, data.success, data.result, data.error)
    end
    cb("ok")
end)

-- Export functions
exports("SendNUIMessage", function(data)
    return NUI:sendMessage(data)
end)

exports("OnNUICallback", function(callbackName, callback)
    return NUI:on(callbackName, callback)
end)

exports("SetNUIFocus", function(hasFocus, hasCursor)
    return NUI:setFocus(hasFocus, hasCursor)
end)

exports("ClipScreen", function()
    return NUI:clipScreen()
end)

exports("Screenshot", function()
    return NUI:screenshot()
end)

exports("GetOCRText", function()
    return NUI:getOCRText()
end)

exports("CreateDUI", function(url, width, height)
    return NUI:createDUI(url, width, height)
end)

exports("SendDUIMessage", function(message)
    return NUI:sendDUIMessage(message)
end)

exports("IsDUIAvailable", function()
    return NUI:isDUIAvailable()
end)
