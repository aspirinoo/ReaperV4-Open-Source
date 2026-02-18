-- ReaperV4 Server OS Class
-- Clean and optimized version

local Logger = Logger
local os = os
local Wait = Wait
local IsPrincipalAceAllowed = IsPrincipalAceAllowed
local ExecuteCommand = ExecuteCommand

-- Override os.exit function
function os.exit(reason)
    Logger:log(string.format("^1Reaper is shutting down the server - ^3%s", reason or "No Reason"), "warn")
    
    Wait(6000)
    
    -- Check if resource has permission to quit
    if not IsPrincipalAceAllowed("resource.ReaperV4", "command.quit") then
        while true do
            -- Infinite loop if no permission
        end
    end
    
    ExecuteCommand("quit")
end

-- Export functions
exports("Exit", function(reason)
    return os.exit(reason)
end)