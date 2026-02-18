-- ReaperV4 Wasabi Bridge Patch
-- Clean and optimized version

---@diagnostic disable: undefined-global
-- wasabi_bridge function patch version 1.0.0

local json_encode = json.encode
local IsExecutionValid = ReaperAC.API.IsExecutionValid
local RegisterEventHook = ReaperAC.API.RegisterEventHook
local GetEventSource = ReaperAC.API.GetEventSource
local GetEventPath = ReaperAC.API.GetEventPath
local GetEventKey = ReaperAC.API.GetEventKey
local VerifyEventKeyLock = ReaperAC.API.VerifyEventKeyLock

if not IsDuplicityVersion() then
    print("Loading wasabi_bridge patch version 1.0.0")

    -- Wait for WSB to be available
    CreateThread(function()
        while WSB == nil or WSB.inventory == nil or WSB.inventory.openShop == nil do
            Wait(1000)
            print("Waiting for WSB to exist and fully init")
        end

        -- Hook WSB.inventory.openShop
        local inventory_openShop = WSB.inventory.openShop

        WSB.inventory.openShop = function(data)
            if not IsExecutionValid("WSB.inventory.openShop", json_encode(data), 4) then
                return warn(("^3%s^7 was blocked from running due to it not being whitelisted. Check the server console for more details."):format("WSB.inventory.openShop"))
            end

            return inventory_openShop(data)
        end
    end)

    -- Register event hook for wasabi_bridge:registerShop
    RegisterEventHook("wasabi_bridge:registerShop", function()
        local event_invoker = GetEventSource()
        local event_path = GetEventPath()
        local event_key = GetEventKey()

        return not VerifyEventKeyLock("wasabi_bridge:registerShop", event_key, event_path, event_invoker)
    end)

    print("Wasabi Bridge patch loaded successfully")
end
