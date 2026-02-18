-- ReaperV4 Client Logger Class
-- Clean and optimized version

local GetConvar = GetConvar
local GetConvarInt = GetConvarInt
local print = print
local class = class

-- Logger class definition
local LoggerClass = class("LoggerLoggerC")

-- Constructor
function LoggerClass:constructor()
    self.level = GetConvarInt("reaper_log_level", 0)
    self.custom_artifacts = GetConvar("sv_reaper_custom_build", "false") == "true"
    self.messages = {}
    
    -- Register command to reload log level
    RegisterCommand("reaperreloadloglevel", function()
        self.level = GetConvarInt("reaper_log_level", 0)
    end)
end

-- Get custom artifacts status
function LoggerClass:customArtifacts()
    return self.custom_artifacts
end

-- Get log messages
function LoggerClass:getLogs()
    return self.messages
end

-- Get current log level
function LoggerClass:getLogLevel()
    return self.level
end

-- Log message with level and formatting
function LoggerClass:log(message, level, saveToMessages)
    local isDebug = level ~= "debug"
    
    -- Format message based on level
    if level == "info" then
        message = "[^2INFO^7] - " .. message
    elseif level == "debug" then
        message = "[^4DEBUG^7] - " .. message
    elseif level == "error" then
        message = "[^1ERROR^7] - " .. message
    elseif level == "severe" then
        message = "[^6SEVERE^7] - " .. message
    elseif level == "warn" then
        message = "[^3WARNING^7] - " .. message
    end
    
    -- Print to console if not debug or level is not -1
    if isDebug then
        if self.level ~= -1 then
            print(string.format("[^3REAPER^7] %s", message))
        end
    end
    
    -- Save to messages array if requested
    if saveToMessages then
        table.insert(self.messages, message)
    end
end

-- Create logger instance
Logger = LoggerClass.new()

-- Export function for external access
exports("InvokeCLogger", function(method, ...)
    if type(method) == "string" then
        if Logger[method] ~= nil then
            return Logger[method](Logger, ...)
        end
    end
    return "INVALID_METHOD"
end)

-- Clean up global logger after 5 seconds
CreateThread(function()
    Wait(5000)
    _G.Logger = nil
end)
