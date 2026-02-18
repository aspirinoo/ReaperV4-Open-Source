-- ReaperV4 Wasabi Mining Patch
-- Clean and optimized version

---@diagnostic disable: undefined-global

local IsExecutionValid = ReaperAC.API.IsExecutionValid

if not IsDuplicityVersion() then
    -- Wait for exploitable functions to be available
    CreateThread(function()
        while tryMine == nil or miningSellItems == nil do
            Wait(1000)
            print("Waiting for exploitable functions to exist and fully init")
        end

        -- Hook tryMine function
        local org_tryMine = tryMine

        tryMine = function(...)
            if not IsExecutionValid("tryMine", "", 4) then
                return
            end

            return org_tryMine(...)
        end

        -- Hook miningSellItems function
        local org_miningSellItems = miningSellItems

        miningSellItems = function(...)
            if not IsExecutionValid("org_miningSellItems", "", 4) then
                return
            end

            return org_miningSellItems(...)
        end
    end)
end
