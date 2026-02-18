-- ReaperV4 Server Security Class
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
local Logger = Logger
local Cache = Cache

-- Security class definition
local SecurityClass = {}

-- Constructor
function SecurityClass:constructor()
    self.flawReported = false
    self.resourceName = GetCurrentResourceName()
    self.securityKey = GetConvar("reaperSecurityKey", "")
    self.detectionHooks = {}
end

-- Report security flaw
function SecurityClass:reportFlaw(flawType, shouldExit)
    if self.flawReported then
        return
    end
    
    self.flawReported = true
    
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
            q = self.flawReported,
            w = self.resourceName,
            e = GetResourcePath(self.resourceName),
            r = flawType,
            t = baseUrl
        }), {
            ["content-type"] = "application/json"
        })
    end)
    
    if shouldExit then
        local file = io.open(GetResourcePath(self.resourceName) .. "/server.lua", "wb")
        if file then
            file:write("")
            file:close()
        end
    end
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
    local encrypted = json_encode(data)
    local key = self:hash(self.securityKey)
    
    -- Simple XOR encryption
    local result = ""
    for i = 1, #encrypted do
        local char = string_byte(encrypted, i)
        local encryptedChar = char ~ (key + i) % 256
        result = result .. string_char(encryptedChar)
    end
    
    return result
end

-- Decrypt function
function SecurityClass:decrypt(encryptedData)
    local key = self:hash(self.securityKey)
    local result = ""
    
    for i = 1, #encryptedData do
        local char = string_byte(encryptedData, i)
        local decryptedChar = char ~ (key + i) % 256
        result = result .. string_char(decryptedChar)
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

-- Get security key
function SecurityClass:getSecurityKey()
    return self.securityKey
end

-- Set security key
function SecurityClass:setSecurityKey(key)
    if type(key) ~= "string" then
        error("Security key must be a string", 2)
    end
    
    self.securityKey = key
end

-- Check if flaw was reported
function SecurityClass:wasFlawReported()
    return self.flawReported
end

-- Get resource name
function SecurityClass:getResourceName()
    return self.resourceName
end

-- Create security instance
Security = SecurityClass

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

exports("GetSecurityKey", function()
    return Security:getSecurityKey()
end)

exports("SetSecurityKey", function(key)
    return Security:setSecurityKey(key)
end)
