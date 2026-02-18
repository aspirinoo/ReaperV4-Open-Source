-- ReaperV4 QB-Core Patch
-- Clean and optimized version

if not IsDuplicityVersion() then
    local RegisterEventHook = ReaperAC.API.RegisterEventHook
    local GetEventSource = ReaperAC.API.GetEventSource
    local GetEventPath = ReaperAC.API.GetEventPath
    local GetEventKey = ReaperAC.API.GetEventKey
    local VerifyEventKeyLock = ReaperAC.API.VerifyEventKeyLock

    -- Check if wasabi_bridge resource is available
    if GetResourceState("wasabi_bridge") ~= "missing" then
        -- Register event hook for QBCore:Server:TriggerCallback
        RegisterEventHook("QBCore:Server:TriggerCallback", function(callback_name)
            -- Only handle wasabi_bridge:registerShop callback
            if callback_name ~= "wasabi_bridge:registerShop" then
                return true
            end

            -- Get event information
            local event_invoker = GetEventSource()
            local event_path = GetEventPath()
            local event_key = GetEventKey()

            -- Verify event key lock
            return not VerifyEventKeyLock("wasabi_bridge:registerShop", event_key, event_path, event_invoker)
        end)
    end
end
