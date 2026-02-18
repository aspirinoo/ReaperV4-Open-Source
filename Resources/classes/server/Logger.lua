-- ReaperV4 Server Logger Class
-- Clean and optimized version

local class = class
local GetHashKey = GetHashKey
local GetConvarInt = GetConvarInt
local GetConvar = GetConvar
local GetResourcePath = GetResourcePath
local GetCurrentResourceName = GetCurrentResourceName
local GetInvokingResource = GetInvokingResource
local os = os
local string = string
local table = table
local math = math
local json = json
local print = print
local Citizen = Citizen
local AddEventHandler = AddEventHandler
local CreateThread = CreateThread
local Wait = Wait
local xpcall = xpcall
local exports = exports

-- Logger class definition
local LoggerClass = class("Logger")

-- Console log native hash
local REAPER_CONSOLE_LOG = GetHashKey("REAPER_CONSOLE_LOG")
local consoleLogEnabled = true

-- Create logs directory
local logsPath = string.format("%s/logs", GetResourcePath(GetCurrentResourceName()))
local success, errorMsg = os.createdir(logsPath)
if not success and not string.match(errorMsg, "Directory already exists") then
    consoleLogEnabled = false
    Logger.log(Logger, string.format("Failed to create logs directory. Reason: %s", errorMsg), "error")
end

-- Directory creation cache
local createdDirs = {}

-- Ensure directory exists
local function ensureDir(path)
    if createdDirs[path] then
        return 1
    end
    
    local fullPath = "/" .. path
    local fileName = string.match(fullPath, "^.+/(.+)$")
    if not fileName then
        fileName = path
    end
    
    local dirPath = string.sub(fullPath, 1, #fullPath - #fileName)
    local pathParts = string.split(dirPath, "/")
    
    for _, part in pairs(pathParts) do
        dirPath = dirPath .. "/" .. part
        os.createdir(dirPath)
    end
    
    createdDirs[path] = true
    return 1
end

-- Constructor
function LoggerClass:constructor()
    self.level = GetConvarInt("reaper_log_level", 0)
    self.history = {}
    self.full_history = {}
    self.custom_artifacts = GetConvar("sv_reaper_custom_build", "false") == "true"
    self.log_reaper_log_to_console = GetConvar("reaper_log_console_to_file", "false") == "true"
    self.channelCache = {}
    self.binds = {}
    
    -- Console log event handler
    AddEventHandler("ReaperConsoleLog", function(channel, message)
        if not self:customArtifacts() then
            return print(message .. "^0")
        end
        
        table.insert(self.history, message)
        if #self.history >= 50 then
            table.remove(self.history, 1)
        end
        
        Citizen.InvokeNative(REAPER_CONSOLE_LOG, channel, message .. "^0\n")
    end)
    
    -- File logger
    self.file_logger = {}
    CreateThread(function()
        while true do
            xpcall(function()
                local currentLogger = self.file_logger
                self.file_logger = {}
                
                -- Group messages by channel
                local groupedMessages = {}
                for _, logEntry in pairs(currentLogger) do
                    if not groupedMessages[logEntry.channel] then
                        groupedMessages[logEntry.channel] = {}
                    end
                    table.insert(groupedMessages[logEntry.channel], logEntry.message)
                end
                
                -- Write to files
                for channel, messages in pairs(groupedMessages) do
                    local content = "\n"
                    for _, message in pairs(messages) do
                        content = content .. message .. "\n"
                    end
                    content = string.sub(content, 1, -2)
                    
                    ensureDir(channel)
                    local file = io.open(string.format("%s/%s", logsPath, channel), "a+")
                    if file then
                        file:write(content)
                        file:close()
                    else
                        Logger.log(Logger, string.format("(Logger:log_to_file) failed to save file %s", channel), "error")
                    end
                end
            end, function(...)
                print("LOGGER_ERROR", ...)
            end)
            Wait(2000)
        end
    end)
    
    -- Pending logs upload
    self.pending_logs = {}
    CreateThread(function()
        while true do
            if Security == nil then
                Wait(1000)
            end
            local sessionId = Security.genUUID()
            
            while true do
                Wait(5000)
                if #self.pending_logs ~= 0 then
                    local logsToUpload = self.pending_logs
                    self.pending_logs = {}
                    
                    -- Wait for secret to be available
                    while Cache.get("secret", "unknown") == "unknown" do
                        Wait(1000)
                    end
                    
                    -- Upload logs
                    local response = HTTP.awaitSuccess(string.format("https://api.reaperac.com/api/v1/servers/%s/logs/batch", Cache.get("dbId")), "POST", json.encode(table.map(logsToUpload, function(log)
                        log.metadata.session_id = sessionId
                        return log
                    end)), {
                        ["content-type"] = "application/json"
                    })
                    
                    if response.status ~= 200 then
                        Logger.log(Logger, string.format("Failed to upload logs to https://api.reaperac.com. The server responded with %s", response.status), "error")
                    end
                end
            end
        end
    end)
end

-- Set log level
function LoggerClass:setLevel(level)
    self.level = level
end

-- Format channel name
function LoggerClass:formatChannel(channel)
    if not self.channelCache[channel] then
        self.channelCache[channel] = string.format("^%s", math.random(1, 9))
    end
    return self.channelCache[channel]
end

-- Get custom artifacts status
function LoggerClass:customArtifacts()
    return self.custom_artifacts
end

-- Get log history
function LoggerClass:getHistory()
    return self.history
end

-- Get full history
function LoggerClass:getFullHistory()
    return self.full_history
end

-- Bind callback
function LoggerClass:bind(callback)
    table.insert(self.binds, callback)
end

-- Log message
function LoggerClass:log(message, level)
    local isDebug = level ~= "debug"
    
    -- Format message based on level
    if level == "info" then
        message = "[^2INFO^7] - " .. message
    elseif level == "debug" then
        message = "[^4DEBUG^7] - " .. message
    elseif level == "error" then
        message = "[^1ERROR^7] - " .. message
    elseif level == "warn" then
        message = "[^3WARNING^7] - " .. message
    elseif level == "none" then
        -- No formatting
    elseif level == "severe" then
        message = "[^6SEVERE^7] - " .. message
    end
    
    -- Log to file if enabled
    if self.log_reaper_log_to_console then
        self:log_to_file("reaper.log", message)
    end
    
    -- Skip console output for debug messages
    if isDebug == false then
        return
    end
    
    -- Add to history
    table.insert(self.history, message)
    if #self.history >= 150 then
        -- Upload history if feature is enabled
        if Features.enabled("log_history") then
            HTTP.request(string.format("https://api.reaperac.com/api/v1/servers/%s/log_history", Cache.get("dbId")), "POST", json.encode({
                log_history = self.history
            }), {
                ["content-type"] = "application/json"
            })
        end
        table.remove(self.history, 1)
    end
    
    -- Clean up message formatting
    message = message:gsub("%%", "")
    
    -- Output to console or native
    if self:customArtifacts() then
        xpcall(function()
            Citizen.InvokeNative(REAPER_CONSOLE_LOG, "reaperac.com", message .. "^0\n")
        end, function(...)
            print("ERROR_LOGGING", message)
        end)
    else
        print(message .. "^0")
    end
    
    -- Call bound callbacks
    for _, callback in pairs(self.binds) do
        callback(message)
    end
end

-- New log entry
function LoggerClass:NewLog(message, level, dataset, metadata, skipConsole)
    -- Add resource info if available
    local invokingResource = GetInvokingResource()
    if invokingResource then
        message = "[^3resource:" .. invokingResource .. "^7] " .. message
    end
    
    -- Validate message
    if type(message) ~= "string" then
        return false, "INVALID_MESSAGE"
    end
    
    -- Validate level
    local validLevels = {
        info = true,
        debug = true,
        error = true,
        warn = true,
        none = true,
        severe = true
    }
    if not validLevels[level] then
        return false, "INVALID_LEVEL"
    end
    
    -- Validate dataset
    if type(dataset) ~= "string" then
        return false, "INVALID_DATASET"
    end
    
    -- Validate metadata
    if type(metadata) ~= "table" then
        return false, "INVALID_METADATA"
    end
    
    -- Add to pending logs
    table.insert(self.pending_logs, {
        message = message,
        level = level,
        dataset = dataset,
        metadata = table.numbers_to_string(metadata)
    })
    
    -- Log to console unless skipped
    if not skipConsole then
        self:log(message, level)
    end
    
    return true, ""
end

-- Channel log
function LoggerClass:channelLog(message, channel)
    if not self:customArtifacts() then
        return print(message .. "^0")
    end
    
    Citizen.InvokeNative(REAPER_CONSOLE_LOG, channel, message .. "^0\n")
end

-- Log to file
function LoggerClass:log_to_file(channel, message)
    if not consoleLogEnabled then
        return 0
    end
    
    table.insert(self.file_logger, {
        channel = channel,
        message = message
    })
    return 1
end

-- Create logger instance
Logger = LoggerClass.new()

-- Event handlers
AddEventHandler("Reaper:log_to_file", function(channel, message)
    Logger:log_to_file(channel, message)
end)

AddEventHandler("Reaper:NewLog", function(message, level, dataset, metadata, skipConsole)
    Logger:NewLog(message, level, dataset, metadata, skipConsole)
end)

-- Export function
exports("InvokeSLogger", function(method, ...)
    if type(method) == "string" then
        if Logger[method] ~= nil then
            return Logger[method](Logger, ...)
        end
    end
    return "INVALID_METHOD"
end)
