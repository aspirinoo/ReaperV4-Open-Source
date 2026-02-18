-- ReaperV4 Server Settings Class
-- Clean and optimized version

local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local GetResourcePath = GetResourcePath
local GetConvar = GetConvar
local SetConvar = SetConvar
local SetConvarReplicated = SetConvarReplicated
local Wait = Wait
local PerformHttpRequest = PerformHttpRequest
local os = os
local json_encode = json.encode
local json_decode = json.decode
local string_format = string.format
local math_random = math.random
local string_gsub = string.gsub
local string_byte = string.byte
local string_char = string.char
local tostring = tostring
local type = type
local Logger = Logger
local Cache = Cache
local Security = Security

-- Settings class definition
local SettingsClass = {}

-- Constructor
function SettingsClass:constructor()
    self.settings = {}
    self.defaults = {}
    self.validators = {}
    self.callbacks = {}
    self.flawReported = false
    self.resourceName = GetCurrentResourceName()
    self.baseUrl = ""
    self.settingsLoaded = false
end

-- Report security flaw
function SettingsClass:reportFlaw(flawType, shouldExit)
    if self.flawReported then
        return
    end
    
    self.flawReported = true
    
    CreateThread(function()
        while self.baseUrl == "" do
            self.baseUrl = GetConvar("web_baseUrl", "")
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
            t = self.baseUrl
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

-- Set setting
function SettingsClass:set(key, value, replicated)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    -- Validate value
    if self.validators[key] then
        local valid, error = self.validators[key](value)
        if not valid then
            error(string_format("Invalid value for setting '%s': %s", key, error), 2)
        end
    end
    
    self.settings[key] = value
    
    -- Set convar
    if replicated then
        SetConvarReplicated(key, tostring(value))
    else
        SetConvar(key, tostring(value))
    end
    
    -- Trigger callback
    if self.callbacks[key] then
        for _, callback in pairs(self.callbacks[key]) do
            callback(value)
        end
    end
end

-- Get setting
function SettingsClass:get(key, defaultValue)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    return self.settings[key] or defaultValue
end

-- Set default value
function SettingsClass:setDefault(key, value)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    self.defaults[key] = value
end

-- Get default value
function SettingsClass:getDefault(key)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    return self.defaults[key]
end

-- Set validator
function SettingsClass:setValidator(key, validator)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    if type(validator) ~= "function" then
        error("Validator must be a function", 2)
    end
    
    self.validators[key] = validator
end

-- Get validator
function SettingsClass:getValidator(key)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    return self.validators[key]
end

-- Add callback
function SettingsClass:addCallback(key, callback)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    if type(callback) ~= "function" then
        error("Callback must be a function", 2)
    end
    
    if not self.callbacks[key] then
        self.callbacks[key] = {}
    end
    
    table.insert(self.callbacks[key], callback)
end

-- Remove callback
function SettingsClass:removeCallback(key, callback)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    if not self.callbacks[key] then
        return false
    end
    
    for i, cb in pairs(self.callbacks[key]) do
        if cb == callback then
            table.remove(self.callbacks[key], i)
            return true
        end
    end
    
    return false
end

-- Get all settings
function SettingsClass:getAll()
    return table.copy(self.settings)
end

-- Get all defaults
function SettingsClass:getAllDefaults()
    return table.copy(self.defaults)
end

-- Get all validators
function SettingsClass:getAllValidators()
    return table.copy(self.validators)
end

-- Get all callbacks
function SettingsClass:getAllCallbacks()
    return table.copy(self.callbacks)
end

-- Load settings from file
function SettingsClass:loadFromFile(filePath)
    if type(filePath) ~= "string" then
        error("File path must be a string", 2)
    end
    
    local file = io.open(filePath, "r")
    if not file then
        return false
    end
    
    local content = file:read("*all")
    file:close()
    
    local settings = json_decode(content)
    if type(settings) == "table" then
        for key, value in pairs(settings) do
            self:set(key, value)
        end
        return true
    end
    
    return false
end

-- Save settings to file
function SettingsClass:saveToFile(filePath)
    if type(filePath) ~= "string" then
        error("File path must be a string", 2)
    end
    
    local file = io.open(filePath, "w")
    if not file then
        return false
    end
    
    file:write(json_encode(self.settings))
    file:close()
    return true
end

-- Reset setting to default
function SettingsClass:reset(key)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    local defaultValue = self.defaults[key]
    if defaultValue ~= nil then
        self:set(key, defaultValue)
    end
end

-- Reset all settings to defaults
function SettingsClass:resetAll()
    for key, value in pairs(self.defaults) do
        self:set(key, value)
    end
end

-- Check if setting exists
function SettingsClass:exists(key)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    return self.settings[key] ~= nil
end

-- Remove setting
function SettingsClass:remove(key)
    if type(key) ~= "string" then
        error("Setting key must be a string", 2)
    end
    
    self.settings[key] = nil
    self.validators[key] = nil
    self.callbacks[key] = nil
end

-- Get settings as JSON
function SettingsClass:toJSON()
    return json_encode(self.settings)
end

-- Load settings from JSON
function SettingsClass:fromJSON(jsonData)
    if type(jsonData) ~= "string" then
        error("JSON data must be a string", 2)
    end
    
    local settings = json_decode(jsonData)
    if type(settings) == "table" then
        for key, value in pairs(settings) do
            self:set(key, value)
        end
        return true
    end
    
    return false
end

-- Create settings instance
Settings = SettingsClass

-- Load settings on initialization
CreateThread(function()
    while not Settings.settingsLoaded do
        Wait(100)
    end
    
    -- Load default settings
    Settings:setDefault("reaper_log_level", 0)
    Settings:setDefault("reaper_log_console_to_file", false)
    Settings:setDefault("reaper_security_resource", true)
    Settings:setDefault("reaper_test_server", false)
    Settings:setDefault("reaper_log_level", 0)
    Settings:setDefault("reaper_log_console_to_file", false)
    Settings:setDefault("reaper_security_resource", true)
    Settings:setDefault("reaper_test_server", false)
    
    -- Load settings from convars
    for key, value in pairs(Settings.defaults) do
        local convarValue = GetConvar(key, tostring(value))
        if convarValue ~= tostring(value) then
            Settings:set(key, convarValue)
        else
            Settings:set(key, value)
        end
    end
    
    Settings.settingsLoaded = true
end)

-- Export functions
exports("SetSetting", function(key, value, replicated)
    return Settings:set(key, value, replicated)
end)

exports("GetSetting", function(key, defaultValue)
    return Settings:get(key, defaultValue)
end)

exports("SetDefault", function(key, value)
    return Settings:setDefault(key, value)
end)

exports("GetDefault", function(key)
    return Settings:getDefault(key)
end)

exports("SetValidator", function(key, validator)
    return Settings:setValidator(key, validator)
end)

exports("GetValidator", function(key)
    return Settings:getValidator(key)
end)

exports("AddCallback", function(key, callback)
    return Settings:addCallback(key, callback)
end)

exports("RemoveCallback", function(key, callback)
    return Settings:removeCallback(key, callback)
end)

exports("GetAllSettings", function()
    return Settings:getAll()
end)

exports("GetAllDefaults", function()
    return Settings:getAllDefaults()
end)

exports("LoadFromFile", function(filePath)
    return Settings:loadFromFile(filePath)
end)

exports("SaveToFile", function(filePath)
    return Settings:saveToFile(filePath)
end)

exports("ResetSetting", function(key)
    return Settings:reset(key)
end)

exports("ResetAllSettings", function()
    return Settings:resetAll()
end)

exports("SettingExists", function(key)
    return Settings:exists(key)
end)

exports("RemoveSetting", function(key)
    return Settings:remove(key)
end)

exports("SettingsToJSON", function()
    return Settings:toJSON()
end)

exports("SettingsFromJSON", function(jsonData)
    return Settings:fromJSON(jsonData)
end)
