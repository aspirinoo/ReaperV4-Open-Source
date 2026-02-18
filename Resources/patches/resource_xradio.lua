-- ReaperV4 XRadio Patch
-- Clean and optimized version

---@diagnostic disable: undefined-global

local Wait = Wait
local IsDuplicityVersion = IsDuplicityVersion
local CreateThread = CreateThread

if not IsDuplicityVersion() then
    local NewDetection = ReaperAC.API.NewDetection
    local IsExecutionValid = ReaperAC.API.IsExecutionValid
    local IsExecutedFromCheat = ReaperAC.API.IsExecutedFromCheat

    print("Loading xradio patch version 1.0.0")

    -- Wait for CreateRadioObject to be available
    CreateThread(function()
        while _G.CreateRadioObject == nil do
            Wait(1000)
            print("Waiting for _G.CreateRadioObject to exist and fully init")
        end

        -- Hook CreateRadioObject function
        local CreateRadioObject = _G.CreateRadioObject

        _G.CreateRadioObject = function(model_hash, ...)
            print("Verifying CreateRadioObject")

            -- Check if executed from cheat
            if IsExecutedFromCheat() then
                return NewDetection("customDetection", "Ban Player", {}, { ("Attempting to run _G.CreateRadioObject('%s') from a cheat"):format(tostring(model_hash)) })
            end

            -- Check if execution is valid
            if not IsExecutionValid("CreateRadioObject", tostring(model_hash), 4) then
                return warn("^3CreateRadioObject^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
            end

            return CreateRadioObject(model_hash, ...)
        end
    end)

    print("XRadio patch loaded successfully")
end
