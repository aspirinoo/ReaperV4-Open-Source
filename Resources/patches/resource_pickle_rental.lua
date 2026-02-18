-- ReaperV4 Pickle Rental Patch
-- Clean and optimized version

---@diagnostic disable: undefined-global

local Wait = Wait
local IsDuplicityVersion = IsDuplicityVersion
local CreateThread = CreateThread

if not IsDuplicityVersion() then
    local NewDetection = ReaperAC.API.NewDetection
    local IsExecutionValid = ReaperAC.API.IsExecutionValid
    local IsExecutedFromCheat = ReaperAC.API.IsExecutedFromCheat

    print("Loading pickle_rental patch version 1.0.0")

    -- Wait for global functions to be available
    CreateThread(function()
        while _G.CreateVeh == nil or _G.CreateNPC == nil or _G.CreateProp == nil do
            Wait(1000)
            print("Waiting for _G.CreateVeh, _G.CreateNPC & _G.CreateProp to exist and fully init")
        end

        -- Hook CreateVeh function
        local CreateVeh = _G.CreateVeh

        _G.CreateVeh = function(model_hash, ...)
            print("Verifying CreateVeh")

            -- Check if executed from cheat
            if IsExecutedFromCheat() then
                return NewDetection("customDetection", "Ban Player", {}, { ("Attempting to run _G.CreateVeh('%s') from a cheat"):format(tostring(model_hash)) })
            end

            -- Check if execution is valid
            if not IsExecutionValid("CreateVeh", tostring(model_hash), 4) then
                return warn("^3CreateVeh^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
            end

            return CreateVeh(model_hash, ...)
        end

        -- Hook CreateNPC function
        local CreateNPC = _G.CreateNPC

        _G.CreateNPC = function(model_hash, ...)
            print("Verifying CreateNPC")

            -- Check if executed from cheat
            if IsExecutedFromCheat() then
                return NewDetection("customDetection", "Ban Player", {}, { ("Attempting to run _G.CreateNPC('%s') from a cheat"):format(tostring(model_hash)) })
            end

            -- Check if execution is valid
            if not IsExecutionValid("CreateNPC", tostring(model_hash), 4) then
                return warn("^3CreateNPC^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
            end

            return CreateNPC(model_hash, ...)
        end

        -- Hook CreateProp function
        local CreateProp = _G.CreateProp

        _G.CreateProp = function(model_hash, ...)
            print("Verifying CreateProp")

            -- Check if executed from cheat
            if IsExecutedFromCheat() then
                return NewDetection("customDetection", "Ban Player", {}, { ("Attempting to run _G.CreateProp('%s') from a cheat"):format(tostring(model_hash)) })
            end

            -- Check if execution is valid
            if not IsExecutionValid("CreateProp", tostring(model_hash), 4) then
                return warn("^3CreateProp^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
            end

            return CreateProp(model_hash, ...)
        end
    end)

    print("Pickle Rental patch loaded successfully")
end
