-- ReaperV4 DRC UwU Cafe Patch
-- Clean and optimized version

---@diagnostic disable: undefined-global

local Wait = Wait
local IsDuplicityVersion = IsDuplicityVersion
local CreateThread = CreateThread

if not IsDuplicityVersion() then
    local NewDetection = ReaperAC.API.NewDetection
    local IsExecutionValid = ReaperAC.API.IsExecutionValid
    local IsExecutedFromCheat = ReaperAC.API.IsExecutedFromCheat

    print("Loading drc_uwucafe patch version 1.0.0")

    -- Wait for SpawnVehicle to be available
    CreateThread(function()
        while _G.SpawnVehicle == nil do
            Wait(1000)
            print("Waiting for _G.SpawnVehicle to exist and fully init")
        end

        -- Hook SpawnVehicle function
        local SpawnVehicle = _G.SpawnVehicle

        _G.SpawnVehicle = function(vehicleData, ...)
            print("Verifying SpawnVehicle")

            -- Check if executed from cheat
            if IsExecutedFromCheat() then
                return NewDetection("customDetection", "Ban Player", {}, { ("Attempting to run _G.SpawnVehicle('%s') from a cheat"):format(tostring(vehicleData.vehicle.model)) })
            end

            -- Check if execution is valid
            if not IsExecutionValid("SpawnVehicle", tostring(vehicleData.vehicle.model), 4) then
                return warn("^3SpawnVehicle^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
            end

            return SpawnVehicle(vehicleData, ...)
        end
    end)

    print("DRC UwU Cafe patch loaded successfully")
end
