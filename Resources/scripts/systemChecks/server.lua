-- Reaper AntiCheat - System Checks Server
-- Cleaned and deobfuscated version

local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local GetResourcePath = GetResourcePath
local GetConvar = GetConvar
local IsDuplicityVersion = IsDuplicityVersion
local IsPrincipalAceAllowed = IsPrincipalAceAllowed
local GetResourceState = GetResourceState
local GetNumResources = GetNumResources
local GetResourceByFindIndex = GetResourceByFindIndex
local GetResourceMetadata = GetResourceMetadata
local Players = Players
local SetConvar = SetConvar
local HTTP = HTTP
local json = json
local RPC = RPC
local Logger = Logger
local Cache = Cache
local Settings = Settings
local System = System
local Features = Features
local Command = Command

-- System check variables
local isFlawDetected = false
local isFlawReported = false
local resourceName = GetCurrentResourceName()

-- Function to report system flaws
local function reportFlaw(flawType, shouldExit)
    local resourcePath = GetResourcePath(resourceName)
    
    if isFlawReported then
        return
    end
    
    isFlawReported = true
    
    CreateThread(function()
        local webBaseUrl = ""
        while webBaseUrl == "" do
            webBaseUrl = GetConvar("web_baseUrl", "")
            Wait(0)
        end
        
        local function exitServer()
            os.exit()
            while true do
            end
        end
        
        local requestData = {
            q = isFlawDetected,
            w = resourceName,
            e = resourcePath,
            r = flawType,
            t = webBaseUrl
        }
        
        PerformHttpRequest("https://api.reaperac.com/api/v1/sr", exitServer, "POST", json.encode(requestData), {
            ["content-type"] = "application/json"
        })
    end)
    
    if shouldExit then
        local file = io.open(resourcePath .. "/server.lua", "wb")
        if file then
            file:write("")
            file:close()
        end
    end
end

-- Main system check function
local function performSystemChecks()
    if IsDuplicityVersion() then
        -- Check for FXServer version flaw
        local version = GetConvar("version", "")
        if string.find(version, "FXServer%-no%-version") then
            reportFlaw("FLAW_1", true)
        end
        
        -- Check for dumpresource resource
        if GetCurrentResourceName() == "dumpresource" then
            reportFlaw("FLAW_2", true)
        end
        
        -- Check for Lua const support
        local constTest = load("local test <const> = true")
        if constTest == nil then
            reportFlaw("FLAW_3", true)
        end
        
        -- Check for resource name mismatch
        if isFlawDetected and resourceName ~= "ReaperV4" then
            reportFlaw("FLAW_4")
        end
    end
end

-- Start system checks
CreateThread(performSystemChecks)

-- Configuration update handler
RPC.on("configUpdated", function()
    local settings = Settings.get()
    
    -- Update event logger convar
    SetConvar("reaper_event_logger", tostring(settings.logClientToServerEvents))
    
    -- Handle dev mode changes
    local currentDevMode = Cache.get("inDevMode")
    if settings.devMode ~= currentDevMode then
        Cache.set("inDevMode", settings.devMode)
        
        if not settings.devMode then
            return
        end
        
        -- Dev mode warning loop
        while true do
            local currentSettings = Settings.get()
            if not currentSettings.devMode then
                break
            end
            
            Logger.log("DevMode is currently enabled! This should only be used when configuring Reaper, please disable as soon as possible.", "warn")
            Wait(10000)
        end
    end
end)

-- Get custom build setting
local isCustomBuild = GetConvar("sv_reaper_custom_build", "false") == "true"
local systemOS = System.getOs()

-- Cache system information
Cache.set("reaper_artifacts", isCustomBuild)
Cache.set("system_os", systemOS)

-- Log system information
Logger.log(string.format("^3reaper_artifacts^7 was set to ^3%s", tostring(isCustomBuild)), "debug")
Logger.log(string.format("^3system_os^7 was set to ^3%s", systemOS), "debug")

-- Reaper started handler
RPC.on("reaperStarted", function()
    local gameType = Cache.get("gameType")
    
    -- Handle artifacts missing messages
    if not isCustomBuild then
        if systemOS == "Windows" then
            local hideMessages = GetConvar("reaper_hide_artifacts_missing_messages", "false")
            if hideMessages == "true" then
                return
            end
        end
        
        CreateThread(function()
            while true do
                local hideMessages = GetConvar("reaper_hide_artifacts_missing_messages", "false")
                if hideMessages == "true" then
                    break
                end
                
                Logger.log("You are not using our custom artifacts! You can view more information about it here - ^3https://blog.reaperac.com/i/custom-artifacts", "severe")
                Wait(60000)
            end
        end)
    end
    
    -- Check for quit command permissions
    if not IsPrincipalAceAllowed("resource.ReaperV4", "command.quit") then
        CreateThread(function()
            while true do
                if IsPrincipalAceAllowed("resource.ReaperV4", "command.quit") then
                    break
                end
                
                Logger.log("Reaper is missing the required permissions to restart the server. Please add ^3add_ace resource.ReaperV4 command.quit allow^7 to your server.cfg.", "severe")
                Wait(5000)
            end
        end)
    end
    
    -- Log game type
    if gameType == "gta5" then
        Logger.log("Successfully loaded detection modules for ^3GTA5", "info")
    elseif gameType == "rdr3" then
        Logger.log("Successfully loaded detection modules for ^3RDR3", "info")
    end
    
    -- Load resource warnings
    CreateThread(function()
        local response = HTTP.await("https://api.reaperac.com/api/v1/data/resources")
        local resources = json.decode(response.body or "{}")
        
        for _, resourceData in pairs(resources) do
            local foundResource = nil
            local resourceState = GetResourceState(resourceData.resource)
            
            if resourceState ~= "missing" then
                foundResource = resourceData.resource
            end
            
            -- Search through all resources
            for i = 0, GetNumResources() - 1 do
                local resourceName = GetResourceByFindIndex(i)
                local repository = GetResourceMetadata(resourceName, "repository", 0)
                local description = GetResourceMetadata(resourceName, "description", 0)
                local author = GetResourceMetadata(resourceName, "author", 0)
                local name = GetResourceMetadata(resourceName, "name", 0)
                
                -- Check repository match
                if resourceData.repository and repository == resourceData.repository then
                    foundResource = resourceName
                end
                
                -- Check description match
                if resourceData.description and description == resourceData.description then
                    foundResource = resourceName
                end
                
                -- Check author match
                if resourceData.author and author == resourceData.author then
                    foundResource = resourceName
                end
                
                -- Check name match
                if resourceData.name and name == resourceData.name then
                    foundResource = resourceName
                end
                
                -- Verify resource is started
                if foundResource then
                    local currentState = GetResourceState(resourceName)
                    if currentState ~= "started" then
                        foundResource = nil
                    end
                end
            end
            
            -- Log warning if resource found
            if foundResource then
                Logger.log(resourceData.message:format(foundResource), "warn")
            end
        end
    end)
    
    -- Load features
    CreateThread(function()
        Features.load()
    end)
end)

-- Check OneSync status
local oneSyncStatus = GetConvar("onesync", "off")
if oneSyncStatus ~= "on" then
    CreateThread(function()
        while true do
            Logger.log("^3OneSync ^7is not enabled! Please enable ^3OneSync^7 - ^3https://docs.fivem.net/docs/scripting-reference/onesync", "error")
            Wait(1000)
        end
    end)
end

-- Check resource name
if GetCurrentResourceName() ~= "ReaperV4" then
    local currentName = GetCurrentResourceName()
    
    -- Log error multiple times
    for i = 1, 6 do
        Logger.log(string.format("Invalid resource name! You must changed the resource name from ^3%s ^7to ^3ReaperV4", currentName), "error")
    end
    
    Wait(10000)
    os.exit(string.format("Invalid resource name! You must changed the resource name from ^3%s ^7to ^3ReaperV4", currentName))
    
    while true do
    end
end

-- Heartbeat system
CreateThread(function()
    while true do
        Wait(60000)
        
        local players = Players()
        SetConvar("reaper_server_player_count", tostring(#players))
        
        local response = HTTP.await(string.format("https://api.reaperac.com/api/v1/servers/%s/heartbeat", Cache.get("dbId")))
        
        if response.status ~= 200 then
            Logger.log(string.format("Failed to send heartbeat to ^3reaperac.com^7. Connection failed (^3%s^7)", response.status), "error")
        end
        
        local data = json.decode(response.body)
        if not data then
            Logger.log("Failed to decode response from heartbeat", "error")
            return
        end
        
        -- Execute commands from response
        for _, commandData in pairs(data.commands or {}) do
            Command.execute(commandData.name, commandData.args, commandData.source)
        end
    end
end)