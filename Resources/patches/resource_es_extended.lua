-- ReaperV4 ESX Extended Patch
-- Clean and optimized version

---@diagnostic disable: undefined-global
-- ESX function patch version 1.0.0

local GetInvokingResource = GetInvokingResource
local GetResourceState = GetResourceState
local tostring = tostring

if not IsDuplicityVersion() then
    local NewDetection = ReaperAC.API.NewDetection
    local IsExecutionValidRaw = ReaperAC.API.IsExecutionValidRaw
    local GetInvokingResourceData = ReaperAC.API.GetInvokingResourceData
    local AppendExtraEntityData = ReaperAC.API.AppendExtraEntityData
    local AdvancedHook = ReaperAC.API.AdvancedHook

    print("Loading es_extended patch version 1.0.0")

    -- Hook ESX.Game.SpawnVehicle
    AdvancedHook("ESX.Game.SpawnVehicle", function(original_func, model, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { ("Attempting to run ESX.Game.SpawnVehicle('%s') from es_extended"):format(tostring(model)) })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { ("Attempting to run ESX.Game.SpawnVehicle('%s') from a cheat"):format(tostring(model)) })
        end

        if not IsExecutionValidRaw("ESX.Game.SpawnVehicle", tostring(model), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.SpawnVehicle^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(model, ...)
    end)

    -- Hook ESX.Game.DeleteVehicle
    AdvancedHook("ESX.Game.DeleteVehicle", function(original_func, vehicle, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.DeleteVehicle from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.DeleteVehicle from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.DeleteVehicle", tostring(vehicle), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.DeleteVehicle^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(vehicle, ...)
    end)

    -- Hook ESX.Game.GetVehicleProperties
    AdvancedHook("ESX.Game.GetVehicleProperties", function(original_func, vehicle, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetVehicleProperties from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetVehicleProperties from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.GetVehicleProperties", tostring(vehicle), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.GetVehicleProperties^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(vehicle, ...)
    end)

    -- Hook ESX.Game.SetVehicleProperties
    AdvancedHook("ESX.Game.SetVehicleProperties", function(original_func, vehicle, props, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.SetVehicleProperties from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.SetVehicleProperties from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.SetVehicleProperties", tostring(vehicle), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.SetVehicleProperties^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(vehicle, props, ...)
    end)

    -- Hook ESX.Game.GetClosestVehicle
    AdvancedHook("ESX.Game.GetClosestVehicle", function(original_func, coords, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetClosestVehicle from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetClosestVehicle from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.GetClosestVehicle", tostring(coords), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.GetClosestVehicle^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(coords, ...)
    end)

    -- Hook ESX.Game.GetClosestPed
    AdvancedHook("ESX.Game.GetClosestPed", function(original_func, coords, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetClosestPed from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetClosestPed from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.GetClosestPed", tostring(coords), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.GetClosestPed^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(coords, ...)
    end)

    -- Hook ESX.Game.GetClosestObject
    AdvancedHook("ESX.Game.GetClosestObject", function(original_func, coords, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetClosestObject from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetClosestObject from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.GetClosestObject", tostring(coords), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.GetClosestObject^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(coords, ...)
    end)

    -- Hook ESX.Game.GetClosestPlayer
    AdvancedHook("ESX.Game.GetClosestPlayer", function(original_func, coords, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetClosestPlayer from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetClosestPlayer from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.GetClosestPlayer", tostring(coords), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.GetClosestPlayer^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(coords, ...)
    end)

    -- Hook ESX.Game.GetPlayers
    AdvancedHook("ESX.Game.GetPlayers", function(original_func, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetPlayers from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetPlayers from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.GetPlayers", "", invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.GetPlayers^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(...)
    end)

    -- Hook ESX.Game.GetPlayerFromId
    AdvancedHook("ESX.Game.GetPlayerFromId", function(original_func, playerId, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetPlayerFromId from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetPlayerFromId from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.GetPlayerFromId", tostring(playerId), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.GetPlayerFromId^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(playerId, ...)
    end)

    -- Hook ESX.Game.GetPlayerFromServerId
    AdvancedHook("ESX.Game.GetPlayerFromServerId", function(original_func, serverId, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetPlayerFromServerId from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetPlayerFromServerId from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.GetPlayerFromServerId", tostring(serverId), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.GetPlayerFromServerId^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(serverId, ...)
    end)

    -- Hook ESX.Game.GetPlayerFromServerId
    AdvancedHook("ESX.Game.GetPlayerFromServerId", function(original_func, serverId, ...)
        local invoking_execution_data = GetInvokingResourceData()

        if invoking_execution_data == nil then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetPlayerFromServerId from es_extended" })
        end

        if invoking_execution_data.ran_from_cheat then
            return NewDetection("customDetection", "Ban Player", {}, { "Attempting to run ESX.Game.GetPlayerFromServerId from a cheat" })
        end

        if not IsExecutionValidRaw("ESX.Game.GetPlayerFromServerId", tostring(serverId), invoking_execution_data.path, invoking_execution_data.extended_hash) then
            return warn("^3ESX.Game.GetPlayerFromServerId^7 was blocked from running due to it not being whitelisted. Check the server console for more details.")
        end

        return original_func(serverId, ...)
    end)

    print("ESX Extended patch loaded successfully")
end
