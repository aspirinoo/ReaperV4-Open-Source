-- ReaperV4 LB-Phone Patch
-- Clean and optimized version

---@diagnostic disable: undefined-global

local Wait = Wait
local IsDuplicityVersion = IsDuplicityVersion

if not IsDuplicityVersion() then
    local NewDetection = ReaperAC.API.NewDetection
    local IsExecutionValid = ReaperAC.API.IsExecutionValid
    local IsExecutedFromCheat = ReaperAC.API.IsExecutedFromCheat
    local AdvancedHook = ReaperAC.API.AdvancedHook

    print("Loading lb-phone patch version 1.0.0")

    -- Hook CreateFrameworkVehicle function
    AdvancedHook("CreateFrameworkVehicle", function(original_func, vehicleData, ...)
        print("Verifying CreateFrameworkVehicle")

        -- Check if executed from cheat
        if IsExecutedFromCheat() then
            return NewDetection("customDetection", "Ban Player", {}, { ("Attempting to run _G.CreateFrameworkVehicle('%s') from a cheat"):format(tostring(vehicleData.vehicle.model)) })
        end

        -- Check if execution is valid
        if not IsExecutionValid("CreateFrameworkVehicle", tostring(vehicleData.vehicle.model), 4) then
            return warn("^3CreateFrameworkVehicle^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(vehicleData, ...)
    end)

    print("LB-Phone patch loaded successfully")
end
