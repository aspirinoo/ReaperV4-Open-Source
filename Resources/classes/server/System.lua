-- ReaperV4 Server System Class
-- Clean and optimized version

local class = class
local os_getenv = os.getenv
local GetConvar = GetConvar
local Wait = Wait
local string_format = string.format

-- System class definition
local SystemClass = class("System")

-- Constructor
function SystemClass:constructor()
    local osEnv = os_getenv("os")
    if osEnv == "Windows_NT" or osEnv == "Windows" then
        self.os = "Windows"
    else
        self.os = "Linux"
    end
end

-- Get operating system
function SystemClass:getOs()
    return self.os
end

-- Get base URL
function SystemClass:getBaseUrl()
    local baseUrl = "web_barUrl_failed"
    
    while baseUrl == "web_barUrl_failed" do
        baseUrl = GetConvar("web_baseUrl", "web_barUrl_failed")
        Wait(250)
    end
    
    Logger:log(string_format("Base url fetched as %s", baseUrl), "debug")
    return baseUrl
end

-- Create System instance
System = SystemClass.new()

-- Export functions
exports("GetOS", function()
    return System:getOs()
end)

exports("GetBaseUrl", function()
    return System:getBaseUrl()
end)