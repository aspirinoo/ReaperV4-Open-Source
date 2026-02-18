-- Reaper AntiCheat - Stream Cast Server System
-- Cleaned and deobfuscated version

local HTTP = HTTP
local json = json
local Player = Player

-- Listen for POST requests to /stream-view/start
HTTP.listen("/stream-view/start", function(request, response)
    -- Decode JSON body
    local body = json.decode(request.body)
    if not body then
        return response.send({ error = true, message = "Invalid Body" })
    end

    local targetId = body.target or 0
    local player = Player(targetId)
    if not player then
        return response.send({ error = true, message = "invalid target" })
    end

    local guid = player:getGuid()
    local session = player:rpc_await("stream_cast_request", { guid }, 3, 5000)
    if session == "RESPONSE_FAILED" then
        return response.send({ error = true, message = "client did not respond with session" })
    end

    return response.send({ error = false, response = guid })
end)