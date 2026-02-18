-- Reaper AntiCheat - Stream Cast Client System
-- Cleaned and deobfuscated version

local Security = Security
local Logger = Logger
local RPC = RPC
local Player = Player
local NUI = NUI

-- Register stream cast request handler
RPC.register("stream_cast_request", function(requestData)
    NUI.ui_toolsEmit("REQUEST_STREAMING", requestData)
    return true
end)