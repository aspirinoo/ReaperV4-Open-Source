-- ReaperV4 Client Security Class
-- Clean and optimized version

local class = class
local Wait = Wait
local GetGameTimer = GetGameTimer
local tostring = tostring
local CreateThread = CreateThread
local GetConvar = GetConvar
local string_byte = string.byte
local string_gsub = string.gsub
local math_random = math.random
local json_encode = json.encode
local string_format = string.format
local Citizen = Citizen
local InvokeFunctionReference = Citizen.InvokeFunctionReference
local securityKey = GetConvar("reaperSecurityKey")
local Player = Player
local Logger = Logger
local RPC = RPC
local reaperReady = false

-- Security class definition
local SecurityClass = class("SecurityClient")

-- Wait for reaper to be ready
RPC.on("reaperReady", function()
    reaperReady = true
end)

-- Test server mode
local testServer = GetConvar("reaper_test_server", "false")
if testServer == "true" then
    Player.set("start_detections", true)
end

-- Hash function
function SecurityClass:hash(input)
    if type(input) ~= "string" then
        input = tostring(input)
    end
    
    local hash = 0
    for i = 1, #input do
        hash = hash + string_byte(input, i) * i
    end
    
    return hash
end

-- Encrypt function
function SecurityClass:encrypt(data)
    if not reaperReady then
        return data
    end
    
    local encrypted = json_encode(data)
    local key = self:hash(securityKey)
    
    -- Simple XOR encryption
    local result = ""
    for i = 1, #encrypted do
        local char = string_byte(encrypted, i)
        local encryptedChar = char ~ (key + i) % 256
        result = result .. string.char(encryptedChar)
    end
    
    return result
end

-- Decrypt function
function SecurityClass:decrypt(encryptedData)
    if not reaperReady then
        return encryptedData
    end
    
    local key = self:hash(securityKey)
    local result = ""
    
    for i = 1, #encryptedData do
        local char = string_byte(encryptedData, i)
        local decryptedChar = char ~ (key + i) % 256
        result = result .. string.char(decryptedChar)
    end
    
    return result
end

-- Generate UUID
function SecurityClass:genUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string_gsub(template, "[xy]", function(c)
        local v = (c == "x") and math_random(0, 0xf) or math_random(8, 0xb)
        return string_format("%x", v)
    end)
end

-- Add detection hook
function SecurityClass:addDetectionHook(detectionType, callback)
    if type(detectionType) ~= "string" then
        error("Detection type must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    if not self.detectionHooks then
        self.detectionHooks = {}
    end
    
    if not self.detectionHooks[detectionType] then
        self.detectionHooks[detectionType] = {}
    end
    
    table.insert(self.detectionHooks[detectionType], callback)
end

-- Get detection hooks
function SecurityClass:getDetectionHooks(detectionType)
    if not self.detectionHooks then
        return {}
    end
    
    return self.detectionHooks[detectionType] or {}
end

-- Validate input
function SecurityClass:validateInput(input, inputType)
    if inputType == "string" then
        return type(input) == "string"
    elseif inputType == "number" then
        return type(input) == "number"
    elseif inputType == "table" then
        return type(input) == "table"
    elseif inputType == "function" then
        return type(input) == "function"
    end
    
    return false
end

-- Sanitize string
function SecurityClass:sanitizeString(str)
    if type(str) ~= "string" then
        return ""
    end
    
    -- Remove potentially dangerous characters
    return string_gsub(str, "[<>\"'&]", "")
end

-- Generate secure token
function SecurityClass:generateToken(length)
    length = length or 32
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local token = ""
    
    for i = 1, length do
        local rand = math_random(1, #chars)
        token = token .. string.sub(chars, rand, rand)
    end
    
    return token
end

-- Check if reaper is ready
function SecurityClass:isReady()
    return reaperReady
end

-- Get security key
function SecurityClass:getSecurityKey()
    return securityKey
end

-- Create security instance
Security = SecurityClass.new()

-- Export functions
exports("Hash", function(input)
    return Security:hash(input)
end)

exports("Encrypt", function(data)
    return Security:encrypt(data)
end)

exports("Decrypt", function(encryptedData)
    return Security:decrypt(encryptedData)
end)

exports("GenerateUUID", function()
    return Security:genUUID()
end)

exports("AddDetectionHook", function(detectionType, callback)
    return Security:addDetectionHook(detectionType, callback)
end)

exports("ValidateInput", function(input, inputType)
    return Security:validateInput(input, inputType)
end)

exports("SanitizeString", function(str)
    return Security:sanitizeString(str)
end)

exports("GenerateToken", function(length)
    return Security:generateToken(length)
end)
