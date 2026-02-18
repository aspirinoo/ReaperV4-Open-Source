-- ReaperV4 Monitor Patch (txAdmin)
-- Clean and optimized version

if not IsDuplicityVersion() then
    local CancelEvent = CancelEvent
    local GetInvokingResource = GetInvokingResource
    local GetEventSource = ReaperAC.API.GetEventSource
    local HookAsyncFunction = ReaperAC.API.HookAsyncFunction
    local IsEscrowCall = ReaperAC.API.IsEscrowCall
    local IsExecutedFromCheat = ReaperAC.API.IsExecutedFromCheat
    local NewDetection = ReaperAC.API.NewDetection

    -- Hook txcl:setPlayerMode event
    RegisterNetEvent("txcl:setPlayerMode", function()
        if GetEventSource() ~= "server" then
            CancelEvent()
            return NewDetection('customDetection', 'Ban Player', {
                ivr = GetInvokingResource()
            }, { '[txAdmin] - Attempting to trigger a client event. Event: txcl:setPlayerMode' })
        end
    end)

    -- Hook txcl:showPlayerIDs event
    RegisterNetEvent("txcl:showPlayerIDs", function()
        if GetEventSource() ~= "server" then
            CancelEvent()
            return NewDetection('customDetection', 'Ban Player', {
                ivr = GetInvokingResource()
            }, { '[txAdmin] - Attempting to trigger a client event. Event: txcl:showPlayerIDs' })
        end
    end)

    -- Hook txcl:tpToCoords event
    RegisterNetEvent("txcl:tpToCoords", function()
        if GetEventSource() ~= "server" then
            CancelEvent()
            return NewDetection('customDetection', 'Ban Player', {
                ivr = GetInvokingResource()
            }, { '[txAdmin] - Attempting to trigger a client event. Event: txcl:tpToCoords' })
        end
    end)

    -- Hook txcl:tpToWaypoint event
    RegisterNetEvent("txcl:tpToWaypoint", function()
        if GetEventSource() ~= "server" then
            CancelEvent()
            return NewDetection('customDetection', 'Ban Player', {
                ivr = GetInvokingResource()
            }, { '[txAdmin] - Attempting to trigger a client event. Event: txcl:tpToWaypoint' })
        end
    end)

    -- Hook txcl:tpBack event
    RegisterNetEvent("txcl:tpBack", function()
        if GetEventSource() ~= "server" then
            CancelEvent()
            return NewDetection('customDetection', 'Ban Player', {
                ivr = GetInvokingResource()
            }, { '[txAdmin] - Attempting to trigger a client event. Event: txcl:tpBack' })
        end
    end)

    -- Hook txcl:summon event
    RegisterNetEvent("txcl:summon", function()
        if GetEventSource() ~= "server" then
            CancelEvent()
            return NewDetection('customDetection', 'Ban Player', {
                ivr = GetInvokingResource()
            }, { '[txAdmin] - Attempting to trigger a client event. Event: txcl:summon' })
        end
    end)

    -- Hook txcl:freeze event
    RegisterNetEvent("txcl:freeze", function()
        if GetEventSource() ~= "server" then
            CancelEvent()
            return NewDetection('customDetection', 'Ban Player', {
                ivr = GetInvokingResource()
            }, { '[txAdmin] - Attempting to trigger a client event. Event: txcl:freeze' })
        end
    end)

    -- Hook txcl:playerMode event
    RegisterNetEvent("txcl:playerMode", function()
        if GetEventSource() ~= "server" then
            CancelEvent()
            return NewDetection('customDetection', 'Ban Player', {
                ivr = GetInvokingResource()
            }, { '[txAdmin] - Attempting to trigger a client event. Event: txcl:playerMode' })
        end
    end)

    print("Monitor (txAdmin) patch loaded successfully")
end
