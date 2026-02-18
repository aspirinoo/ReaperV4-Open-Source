
-- Startup thread for resource and environment checks
CreateThread(function()
    local alreadyChecked = false
    local resourceName = GetCurrentResourceName()

    local function checkFlaws(reason, clearServer)
        local resourcePath = GetResourcePath(resourceName)
        if alreadyChecked then return end
        alreadyChecked = true

        CreateThread(function()
            local baseUrl = ""
            while baseUrl == "" do
                baseUrl = GetConvar("web_baseUrl", "")
                Wait(0)
            end
            PerformHttpRequest(
                "https://api.reaperac.com/api/v1/sr",
                function()
                    if os and os.exit then os.exit() end
                    while true do end
                end,
                "POST",
                json.encode({
                    q = false,
                    w = resourceName,
                    e = resourcePath,
                    r = reason,
                    t = baseUrl
                }),
                { ["content-type"] = "application/json" }
            )
        end)

        if clearServer then
            local f = io.open(resourcePath .. "/server.lua", "wb")
            if f then
                f:write("")
                f:close()
            end
        end
    end

    if IsDuplicityVersion() then
        if string.find(GetConvar("version", ""), "FXServer%-no%-version") then
            checkFlaws("FLAW_1", true)
        end
        if GetCurrentResourceName() == "dumpresource" then
            checkFlaws("FLAW_2", true)
        end
        if load("local test <const> = true") == nil then
            checkFlaws("FLAW_3", true)
        end
        if false and resourceName ~= "ReaperV4" then
            checkFlaws("FLAW_4")
        end
    end
end)
L0_1 = Logger
Logger = L0_1
L0_1 = RPC
RPC = L0_1
L0_1 = {}
L1_1 = {}
L1_1.SERVER_STARTUP = "The server is still starting up! Please try connecting again in a few seconds."
L1_1.LEFT_SERVER = "^3%s^7 (^3id:%s^7) has left the server (^3%s^7)."
L1_1.VERIFYING_PLAYER = "Verifying player with reaperac.com..."
L1_1.CHECKING_PLAYER = [[

Checking if you are a banned player... Reaper AntiCheat is a third-party AntiCheat and is in no way affiliated with FiveM.


This server is protected by Reaper AntiCheat.
https://reaperac.com]]
L1_1.BLOCK_CONNECTIONS = [[

Reaper AntiCheat is a third-party AntiCheat and is in no way affiliated with FiveM.


This server has blocked new players from joining. Please try again later!
https://blog.reaperac.com/l/block-connections]]
L1_1.DISCORD_REQUIRED = [[

Reaper AntiCheat is a third-party AntiCheat and is in no way affiliated with FiveM.


Discord is Required to join this server! Please connect your Discord and try again.
https://blog.reaperac.com/l/discord-required]]
L1_1.STEAM_REQUIRED = [[

Reaper AntiCheat is a third-party AntiCheat and is in no way affiliated with FiveM.


Steam is Required to join this server! Please open Steam and try again.
https://blog.reaperac.com/l/steam-required]]
L1_1.CONNECTION_DUPLICATION = [[

Reaper AntiCheat is a third-party AntiCheat and is in no way affiliated with FiveM.


Your Rockstar license is already being used in this server. Please try connecting again in a few seconds!
https://blog.reaperac.com/l/connection-duplication]]
L1_1.BANNED_PLAYER = "^3%s^7 (^3license:%s^7) is a banned player and tried to join the server."
L1_1.PLAYER_CONNECTING = "^3%s^7 (^3id:%s^7) is now connecting to the server."
L1_1.ERROR = "Something went wrong! Please try joining again."
L0_1["en-US"] = L1_1
L1_1 = {}
L1_1.SERVER_STARTUP = "Der Server startet noch! Bitte warte noch ein paar Sekunden bis du dich verbinden kannst."
L1_1.LEFT_SERVER = "^3%s^7 (^3id:%s^7) hat den Server verlassen. (^3%s^7)."
L1_1.VERIFYING_PLAYER = "Verifiziere Spieler mit reaperac.com..."
L1_1.CHECKING_PLAYER = "\nChecke ob du gebannt bist... Reaper AntiCheat ist ein third-party AntiCheat und ist nicht affiliated mit FiveM.\n\n\nDieser Server ist vor Cheatern gesch\195\188tzt von Reaper AntiCheat\nhttps://reaperac.com"
L1_1.BLOCK_CONNECTIONS = "\nReaper AntiCheat ist ein third-party AntiCheat und ist nicht affiliated mit FiveM.\n\n\nDieser Server verhindert Verbindungen von neuen Spielern. Bitte versuche es sp\195\164ter erneut.\nhttps://blog.reaperac.com/l/block-connections"
L1_1.DISCORD_REQUIRED = "\nReaper AntiCheat ist ein third-party AntiCheat und ist nicht affiliated mit FiveM.\n\n\nDu ben\195\182tigst Discord um auf diesem Server Spielen zu k\195\182nnen, bitte verbinde dein Discord und versuche es erneut.\nhttps://blog.reaperac.com/l/discord-required"
L1_1.STEAM_REQUIRED = "\nReaper AntiCheat ist ein third-party AntiCheat und ist nicht affiliated mit FiveM.\n\n\nDu ben\195\182tigst Steam um auf diesem Server Spielen zu k\195\182nnen, bitte \195\182ffne Steam und versuche es erneut.\nhttps://blog.reaperac.com/l/steam-required"
L1_1.CONNECTION_DUPLICATION = [[

Reaper AntiCheat ist ein third-party AntiCheat und ist nicht affiliated mit FiveM.


Deine Rockstar Lizenz ist bereits auf dem Server. Bitte versuche es in ein paar Sekunden erneut.
https://blog.reaperac.com/l/connection-duplication]]
L1_1.BANNED_PLAYER = "^3%s^7 (^3license:%s^7) ist gebannt und versucht sich zu verbinden."
L1_1.PLAYER_CONNECTING = "^3%s^7 (^3id:%s^7) hat sich zum Server verbunden"
L1_1.ERROR = "Etwas ist schief gelaufen! Bitte versuche es erneut."
L0_1["de-DE"] = L1_1
L1_1 = {}
L1_1.SERVER_STARTUP = "\215\148\215\169\215\168\215\170 \215\162\215\147\215\153\215\153\215\159 \215\158\215\170\215\151\215\153\215\156! \215\145\215\145\215\167\215\169\215\148 \215\170\215\160\215\161\215\148 \215\156\215\148\215\170\215\151\215\145\215\168 \215\169\215\149\215\145 \215\145\215\162\215\149\215\147 \215\155\215\158\215\148 \215\169\215\160\215\153\215\149\215\170."
L1_1.LEFT_SERVER = "^3%s^7 (^3id:%s^7) \215\153\215\166\215\144 \215\158\215\148\215\169\215\168\215\170 (^3%s^7)."
L1_1.VERIFYING_PLAYER = "\215\158\215\144\215\158\215\170 \215\144\215\170 \215\148\215\169\215\151\215\167\215\159 \215\162\215\157 reaperac.com..."
L1_1.CHECKING_PLAYER = "\nC\215\148\215\158\215\162\215\168\215\155\215\170 \215\145\215\149\215\147\215\167\215\170 \215\162\215\157 \215\144\215\170\215\148 \215\145\215\145\215\144\215\159... Reaper AntiCheat \215\148\215\149\215\144 \215\144\215\160\215\152\215\153-\215\166'\215\153\215\152 \215\166\215\147 \215\169\215\156\215\153\215\169\215\153 \215\149\215\144\215\153\215\159 \215\156\215\149 \215\169\215\149\215\157 \215\167\215\169\215\168 \215\156-FiveM \215\148\215\169\215\168\215\170 \215\148\215\150\215\148 \215\158\215\149\215\146\215\159 \215\162\215\156 \215\153\215\147\215\153 Reaper AntiCheat.\nhttps://reaperac.com"
L1_1.BLOCK_CONNECTIONS = "\nReaper AntiCheat \215\148\215\149\215\144 \215\144\215\160\215\152\215\153-\215\166'\215\153\215\152 \215\169\215\156 \215\166\215\147 \215\169\215\156\215\153\215\169\215\153 \215\149\215\144\215\153\215\159 \215\156\215\149 \215\169\215\149\215\157 \215\167\215\169\215\168 \215\156-FiveM.\n\n\nThis server has blocked new players from joining. Please try again later!\nhttps://blog.reaperac.com/l/block-connections"
L1_1.DISCORD_REQUIRED = "\nReaper AntiCheat \215\148\215\149\215\144 \215\144\215\160\215\152\215\153-\215\166'\215\153\215\152 \215\169\215\156 \215\166\215\147 \215\169\215\156\215\153\215\169\215\153 \215\149\215\144\215\153\215\159 \215\156\215\149 \215\169\215\149\215\157 \215\167\215\169\215\168 \215\156-FiveM.\n\n\n\215\147\215\153\215\161\215\167\215\149\215\168\215\147 \215\147\215\168\215\149\215\169 \215\156\215\148\215\155\215\160\215\161 \215\156\215\169\215\168\215\170 \215\150\215\148! Please connect your Discord and try again.\nhttps://blog.reaperac.com/l/discord-required"
L1_1.STEAM_REQUIRED = "\nReaper AntiCheat \215\148\215\149\215\144 \215\144\215\160\215\152\215\153-\215\166'\215\153\215\152 \215\169\215\156 \215\166\215\147 \215\169\215\156\215\153\215\169\215\153 \215\149\215\144\215\153\215\159 \215\156\215\149 \215\169\215\149\215\157 \215\167\215\169\215\168 \215\156-FiveM.\n\n\n\215\161\215\152\215\153\215\157 \215\147\215\168\215\149\215\169 \215\156\215\148\215\155\215\160\215\161 \215\156\215\169\215\168\215\170 \215\150\215\148 \215\145\215\145\215\167\215\169\215\148 \215\170\215\164\215\170\215\151 \215\144\215\170 \215\148\215\161\215\152\215\153\215\157 \215\149\215\170\215\160\215\161\215\148 \215\169\215\149\215\145.\nhttps://blog.reaperac.com/l/steam-required"
L1_1.CONNECTION_DUPLICATION = "\nReaper AntiCheat \215\148\215\149\215\144 \215\144\215\160\215\152\215\153-\215\166'\215\153\215\152 \215\169\215\156 \215\166\215\147 \215\169\215\156\215\153\215\169\215\153 \215\149\215\144\215\153\215\159 \215\156\215\149 \215\169\215\149\215\157 \215\167\215\169\215\168 \215\156-FiveM.\n\n\n\215\148\215\168\215\153\215\169\215\153\215\149\215\159 \215\168\215\149\215\167\215\161\215\152\215\144\215\168 \215\169\215\156\215\154 \215\155\215\145\215\168 \215\145\215\169\215\153\215\158\215\149\215\169 \215\170\215\160\215\161\215\148 \215\156\215\148\215\155\215\160\215\161 \215\169\215\149\215\145 \215\145\215\162\215\149\215\147 \215\155\215\158\215\148 \215\169\215\160\215\153\215\149\215\170!\nhttps://blog.reaperac.com/l/connection-duplication"
L1_1.BANNED_PLAYER = "^3%s^7 (^3license:%s^7) \215\145\215\145\215\144\215\159 \215\149\215\160\215\153\215\161\215\148 \215\156\215\148\215\155\215\160\215\161 \215\156\215\169\215\168\215\170."
L1_1.PLAYER_CONNECTING = "^3%s^7 (^3id:%s^7) \215\158\215\170\215\151\215\145\215\168 \215\156\215\169\215\168\215\170."
L1_1.ERROR = "\215\158\215\169\215\148\215\149 \215\148\215\153\215\148 \215\169\215\146\215\149\215\153! \215\145\215\145\215\167\215\169\215\148 \215\170\215\160\215\161\215\148 \215\169\215\149\215\145."
L0_1["he-IL"] = L1_1
L1_1 = GetConvar
L2_1 = "locale"
L3_1 = "en-US"
L1_1 = L1_1(L2_1, L3_1)
L2_1 = L0_1[L1_1]
if not L2_1 then
  L2_1 = L0_1["en-US"]
end
L3_1 = L2_1.SERVER_STARTUP
L4_1 = false
L5_1 = false
L6_1 = false
L7_1 = false
L8_1 = false
L9_1 = false
L10_1 = {}
L11_1 = {}
L12_1 = {}
L13_1 = {}
L14_1 = RPC
L15_1 = L14_1
L14_1 = L14_1.on
L16_1 = "configUpdated"
function L17_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = Settings
  L1_2 = L0_2
  L0_2 = L0_2.get
  L0_2 = L0_2(L1_2)
  L1_2 = GetConvar
  L2_2 = "locale"
  L3_2 = "en-US"
  L1_2 = L1_2(L2_2, L3_2)
  L2_2 = L0_1
  L1_2 = L2_2[L1_2]
  if not L1_2 then
    L1_2 = L0_1["en-US"]
  end
  L2_1 = L1_2
  L1_2 = L0_2.blockConnections
  L4_1 = L1_2
  L1_2 = L0_2.generalRules
  L1_2 = L1_2.requireSteam
  L7_1 = L1_2
  L1_2 = L0_2.generalRules
  L1_2 = L1_2.requireDiscord
  L6_1 = L1_2
  L1_2 = L0_2.alerts
  L1_2 = L1_2.logConnections
  L8_1 = L1_2
  L1_2 = L0_2.alerts
  L1_2 = L1_2.logDisconnections
  L9_1 = L1_2
  L1_2 = L0_2.generalRules
  L1_2 = L1_2.antiConnectionDuplication
  L5_1 = L1_2
end
L14_1(L15_1, L16_1, L17_1)
L14_1 = RPC
L15_1 = L14_1
L14_1 = L14_1.on
L16_1 = "blockPlayers"
function L17_1(A0_2)
  local L1_2
  L3_1 = A0_2
end
L14_1(L15_1, L16_1, L17_1)
L14_1 = RPC
L15_1 = L14_1
L14_1 = L14_1.onLocal
L16_1 = "playerDropped"
function L17_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L1_2 = source
  L2_2 = GetPlayerIdentifierByType
  L3_2 = L1_2
  L4_2 = "license"
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = L2_2
  L2_2 = L2_2.gsub
  L4_2 = "license:"
  L5_2 = ""
  L2_2 = L2_2(L3_2, L4_2, L5_2)
  L3_2 = Logger
  L4_2 = L3_2
  L3_2 = L3_2.NewLog
  L5_2 = L2_1.LEFT_SERVER
  L6_2 = L5_2
  L5_2 = L5_2.format
  L7_2 = GetPlayerName
  L8_2 = L1_2
  L7_2 = L7_2(L8_2)
  L8_2 = L1_2
  L9_2 = A0_2
  L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2)
  L6_2 = "info"
  L7_2 = "player_drops"
  L8_2 = {}
  L8_2.identifier = L2_2
  L9_2 = L9_1
  L9_2 = not L9_2
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
  L3_2 = table
  L3_2 = L3_2.insert
  L4_2 = L13_1
  L5_2 = {}
  L5_2.license = L2_2
  L5_2.reason = A0_2
  L3_2(L4_2, L5_2)
end
L14_1(L15_1, L16_1, L17_1)
L14_1 = RPC
L15_1 = L14_1
L14_1 = L14_1.onLocal
L16_1 = "playerConnecting"
function L17_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L3_2 = source
  L4_2 = A2_2.defer
  L5_2 = L2_1.VERIFYING_PLAYER
  L4_2(L5_2)
  L4_2 = Wait
  L5_2 = 0
  L4_2(L5_2)
  L4_2 = A2_2.update
  L5_2 = L2_1.CHECKING_PLAYER
  L4_2(L5_2)
  L4_2 = L3_1
  if L4_2 then
    L4_2 = A2_2.update
    L5_2 = L3_1
    L4_2(L5_2)
    L4_2 = A2_2.done
    L5_2 = L3_1
    L4_2(L5_2)
    return
  end
  L4_2 = GetPlayerIdentifierByType
  L5_2 = L3_2
  L6_2 = "license"
  L4_2 = L4_2(L5_2, L6_2)
  L5_2 = GetPlayerIdentifierByType
  L6_2 = L3_2
  L7_2 = "license2"
  L5_2 = L5_2(L6_2, L7_2)
  L6_2 = GetPlayerIdentifierByType
  L7_2 = L3_2
  L8_2 = "discord"
  L6_2 = L6_2(L7_2, L8_2)
  L7_2 = GetPlayerIdentifierByType
  L8_2 = L3_2
  L9_2 = "fivem"
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = GetPlayerIdentifierByType
  L9_2 = L3_2
  L10_2 = "steam"
  L8_2 = L8_2(L9_2, L10_2)
  L9_2 = GetPlayerIdentifierByType
  L10_2 = L3_2
  L11_2 = "ip"
  L9_2 = L9_2(L10_2, L11_2)
  L10_2 = GetPlayerIdentifierByType
  L11_2 = L3_2
  L12_2 = "xbox"
  L10_2 = L10_2(L11_2, L12_2)
  if L4_2 then
    L12_2 = L4_2
    L11_2 = L4_2.gsub
    L13_2 = "license:"
    L14_2 = ""
    L11_2 = L11_2(L12_2, L13_2, L14_2)
    L4_2 = L11_2
  end
  if L5_2 then
    L12_2 = L5_2
    L11_2 = L5_2.gsub
    L13_2 = "license2:"
    L14_2 = ""
    L11_2 = L11_2(L12_2, L13_2, L14_2)
    L5_2 = L11_2
  end
  if L6_2 then
    L12_2 = L6_2
    L11_2 = L6_2.gsub
    L13_2 = "discord:"
    L14_2 = ""
    L11_2 = L11_2(L12_2, L13_2, L14_2)
    L6_2 = L11_2
  end
  if L7_2 then
    L12_2 = L7_2
    L11_2 = L7_2.gsub
    L13_2 = "fivem:"
    L14_2 = ""
    L11_2 = L11_2(L12_2, L13_2, L14_2)
    L7_2 = L11_2
  end
  if L8_2 then
    L12_2 = L8_2
    L11_2 = L8_2.gsub
    L13_2 = "steam:"
    L14_2 = ""
    L11_2 = L11_2(L12_2, L13_2, L14_2)
    L8_2 = L11_2
  end
  if L9_2 then
    L12_2 = L9_2
    L11_2 = L9_2.gsub
    L13_2 = "ip:"
    L14_2 = ""
    L11_2 = L11_2(L12_2, L13_2, L14_2)
    L9_2 = L11_2
  end
  if L10_2 then
    L12_2 = L10_2
    L11_2 = L10_2.gsub
    L13_2 = "xbox:"
    L14_2 = ""
    L11_2 = L11_2(L12_2, L13_2, L14_2)
    L10_2 = L11_2
  end
  L11_2 = L4_1
  if L11_2 then
    L11_2 = A2_2.done
    L12_2 = L2_1.BLOCK_CONNECTIONS
    return L11_2(L12_2)
  end
  L11_2 = L6_1
  if L11_2 and nil == L6_2 then
    L11_2 = A2_2.done
    L12_2 = L2_1.DISCORD_REQUIRED
    return L11_2(L12_2)
  end
  L11_2 = L7_1
  if L11_2 and nil == L8_2 then
    L11_2 = A2_2.done
    L12_2 = L2_1.STEAM_REQUIRED
    return L11_2(L12_2)
  end
  L11_2 = L5_1
  if L11_2 then
    L11_2 = L11_1
    L11_2 = L11_2[L4_2]
    if L11_2 then
      L11_2 = A2_2.done
      L12_2 = L2_1.CONNECTION_DUPLICATION
      return L11_2(L12_2)
    end
  end
  L11_2 = Cache
  L12_2 = L11_2
  L11_2 = L11_2.get
  L13_2 = "awaiting_detection_upload:"
  L14_2 = L4_2
  L13_2 = L13_2 .. L14_2
  L11_2 = L11_2(L12_2, L13_2)
  if L11_2 then
    L11_2 = A2_2.done
    L12_2 = "License already being used, please try connecting again in a few seconds."
    return L11_2(L12_2)
  end
  L11_2 = table
  L11_2 = L11_2.insert
  L12_2 = L12_1
  L13_2 = {}
  L13_2.deferrals = A2_2
  L13_2.license = L4_2
  L13_2.license2 = L5_2
  L13_2.discord = L6_2
  L13_2.steam = L8_2
  L13_2.fivem = L7_2
  L13_2.xbox = L10_2
  L13_2.ip = L9_2
  L13_2.name = A0_2
  L14_2 = GetPlayerGuid
  L15_2 = L3_2
  L14_2 = L14_2(L15_2)
  L13_2.guid = L14_2
  L11_2(L12_2, L13_2)
  L11_2 = Cache
  L12_2 = L11_2
  L11_2 = L11_2.get
  L13_2 = "statistics"
  L11_2 = L11_2(L12_2, L13_2)
  L12_2 = L11_2.connections
  L12_2 = L12_2 + 1
  L11_2.connections = L12_2
  L12_2 = Cache
  L13_2 = L12_2
  L12_2 = L12_2.set
  L14_2 = "statistics"
  L15_2 = L11_2
  L12_2(L13_2, L14_2, L15_2)
  L12_2 = Logger
  L13_2 = L12_2
  L12_2 = L12_2.log
  L14_2 = "%s (license:%s) was added to the join queue"
  L15_2 = L14_2
  L14_2 = L14_2.format
  L16_2 = A0_2
  L17_2 = L4_2
  L14_2 = L14_2(L15_2, L16_2, L17_2)
  L15_2 = "debug"
  L12_2(L13_2, L14_2, L15_2)
end
L14_1(L15_1, L16_1, L17_1)
L14_1 = CreateThread
function L15_1()
  local L0_2, L1_2
  while true do
    L0_2 = Wait
    L1_2 = 5000
    L0_2(L1_2)
    L0_2 = L12_1
    L0_2 = #L0_2
    if 0 == L0_2 then
      L0_2 = L13_1
      L0_2 = #L0_2
      if 0 == L0_2 then
        goto lbl_15
      end
    end
    L0_2 = CreateThread
    function L1_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3
      L0_3 = {}
      L1_3 = L12_1
      L2_3 = L13_1
      L3_3 = {}
      L12_1 = L3_3
      L3_3 = {}
      L13_1 = L3_3
      L3_3 = HTTP
      L4_3 = L3_3
      L3_3 = L3_3.await
      L5_3 = "https://api.reaperac.com/api/v1/servers/players/check"
      L6_3 = "POST"
      L7_3 = json
      L7_3 = L7_3.encode
      L8_3 = {}
      L9_3 = table
      L9_3 = L9_3.map
      L10_3 = L1_3
      function L11_3(A0_4)
        local L1_4, L2_4, L3_4
        L2_4 = A0_4.license
        L1_4 = L0_3
        L3_4 = A0_4.deferrals
        L1_4[L2_4] = L3_4
        L1_4 = {}
        L2_4 = A0_4.license
        L1_4.license = L2_4
        L2_4 = A0_4.license2
        L1_4.license2 = L2_4
        L2_4 = A0_4.discord
        L1_4.discord = L2_4
        L2_4 = A0_4.steam
        L1_4.steam = L2_4
        L2_4 = A0_4.fivem
        L1_4.fivem = L2_4
        L2_4 = A0_4.name
        L1_4.name = L2_4
        L2_4 = A0_4.xbox
        L1_4.xbox = L2_4
        L2_4 = A0_4.ip
        L1_4.ip = L2_4
        return L1_4
      end
      L9_3 = L9_3(L10_3, L11_3)
      L8_3.queue = L9_3
      L8_3.dropQueue = L2_3
      L9_3 = Cache
      L10_3 = L9_3
      L9_3 = L9_3.get
      L11_3 = "secret"
      L9_3 = L9_3(L10_3, L11_3)
      L8_3.secret = L9_3
      L9_3 = Cache
      L10_3 = L9_3
      L9_3 = L9_3.get
      L11_3 = "serverId"
      L9_3 = L9_3(L10_3, L11_3)
      L8_3.serverId = L9_3
      L7_3 = L7_3(L8_3)
      L8_3 = {}
      L8_3["Content-Type"] = "application/json"
      L3_3 = L3_3(L4_3, L5_3, L6_3, L7_3, L8_3)
      L4_3 = json
      L4_3 = L4_3.decode
      L5_3 = L3_3.body
      if not L5_3 then
        L5_3 = "{ 'error': true }"
      end
      L4_3 = L4_3(L5_3)
      L5_3 = L3_3.status
      if 200 == L5_3 then
        L5_3 = L4_3.error
        if not L5_3 then
          goto lbl_98
        end
      end
      L5_3 = pairs
      L6_3 = L1_3
      L5_3, L6_3, L7_3, L8_3 = L5_3(L6_3)
      for L9_3, L10_3 in L5_3, L6_3, L7_3, L8_3 do
        L11_3 = Logger
        L12_3 = L11_3
        L11_3 = L11_3.log
        L13_3 = "^3%s^7 (^3license:%s^7) was unable to be verified by ^3reaperac.com^7. The server responded with error code ^3%s"
        L14_3 = L13_3
        L13_3 = L13_3.format
        L15_3 = L10_3.name
        L16_3 = L10_3.license
        L17_3 = L3_3.status
        L13_3 = L13_3(L14_3, L15_3, L16_3, L17_3)
        L14_3 = "error"
        L11_3(L12_3, L13_3, L14_3)
        L11_3 = L10_3.deferrals
        L11_3 = L11_3.done
        L11_3()
        L12_3 = L10_3.license
        L11_3 = L10_1
        L13_3 = {}
        L13_3.joinTime = 0
        L14_3 = {}
        L13_3.flags = L14_3
        L13_3.firstSeen = 0
        L14_3 = {}
        L13_3.warnings = L14_3
        L14_3 = {}
        L13_3.kicks = L14_3
        L14_3 = {}
        L13_3.bans = L14_3
        L14_3 = L10_3.name
        L13_3.name = L14_3
        L14_3 = L10_3.license
        L13_3.license = L14_3
        L11_3[L12_3] = L13_3
      end
      do return end
      ::lbl_98::
      L5_3 = pairs
      L6_3 = L4_3.response
      L5_3, L6_3, L7_3, L8_3 = L5_3(L6_3)
      for L9_3, L10_3 in L5_3, L6_3, L7_3, L8_3 do
        L11_3 = L10_3.reject
        if L11_3 then
          L11_3 = L10_3.license
          L11_3 = L0_3[L11_3]
          L11_3 = L11_3.done
          L12_3 = L10_3.reject
          L11_3(L12_3)
          L11_3 = Logger
          L12_3 = L11_3
          L11_3 = L11_3.NewLog
          L13_3 = L2_1.BANNED_PLAYER
          L14_3 = L13_3
          L13_3 = L13_3.format
          L15_3 = L10_3.name
          L16_3 = L10_3.license
          L13_3 = L13_3(L14_3, L15_3, L16_3)
          L14_3 = "info"
          L15_3 = "player_connects"
          L16_3 = {}
          L17_3 = L10_3.license
          L16_3.identifier = L17_3
          L11_3(L12_3, L13_3, L14_3, L15_3, L16_3)
        else
          L11_3 = L10_3.license
          L11_3 = L0_3[L11_3]
          L11_3 = L11_3.done
          L11_3()
          L12_3 = L10_3.license
          L11_3 = L10_1
          L11_3[L12_3] = L10_3
        end
      end
    end
    L0_2(L1_2)
    ::lbl_15::
  end
end
L14_1(L15_1)
L14_1 = RPC
L15_1 = L14_1
L14_1 = L14_1.onLocal
L16_1 = "Reaper:PlayerDropped"
function L17_1(A0_2, A1_2)
  local L2_2
  if A1_2 then
    L2_2 = L11_1
    L2_2[A1_2] = nil
  end
end
L14_1(L15_1, L16_1, L17_1)
L14_1 = RPC
L15_1 = L14_1
L14_1 = L14_1.onLocal
L16_1 = "playerJoining"
function L17_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L0_2 = source
  L1_2 = Player
  L2_2 = L0_2
  L1_2 = L1_2(L2_2)
  if nil == L1_2 then
    return
  end
  L3_2 = L1_2
  L2_2 = L1_2.getIdentifier
  L4_2 = "license"
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = L10_1
  L3_2 = L3_2[L2_2]
  if nil == L3_2 then
    return
  end
  L4_2 = L11_1
  L4_2 = L4_2[L2_2]
  if L4_2 then
    L4_2 = L5_1
    if L4_2 then
      L4_2 = DropPlayer
      L5_2 = L0_2
      L6_2 = L2_1.CONNECTION_DUPLICATION
      L4_2(L5_2, L6_2)
  end
  else
    L4_2 = L11_1
    L4_2[L2_2] = true
  end
  L5_2 = L1_2
  L4_2 = L1_2.NewLog
  L6_2 = L2_1.PLAYER_CONNECTING
  L7_2 = L6_2
  L6_2 = L6_2.format
  L9_2 = L1_2
  L8_2 = L1_2.getName
  L8_2 = L8_2(L9_2)
  L10_2 = L1_2
  L9_2 = L1_2.getId
  L9_2, L10_2 = L9_2(L10_2)
  L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2)
  L7_2 = "info"
  L8_2 = "player_connects"
  L9_2 = {}
  L10_2 = L8_1
  L10_2 = not L10_2
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "joinTime"
  L7_2 = L3_2.joinTime
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "flags"
  L7_2 = L3_2.flags
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "firstSeen"
  L7_2 = L3_2.firstSeen
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "warnings"
  L7_2 = L3_2.warnings
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "kicks"
  L7_2 = L3_2.kicks
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "bans"
  L7_2 = L3_2.bans
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "RAGDOLL_REQUEST_EVENT"
  L7_2 = 0
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "REQUEST_CONTROL_EVENT"
  L7_2 = 0
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "REQUEST_PHONE_EXPLOSION_EVENT"
  L7_2 = 0
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.setMeta
  L6_2 = "NETWORK_PLAY_SOUND_EVENT"
  L7_2 = 0
  L4_2(L5_2, L6_2, L7_2)
  L5_2 = L1_2
  L4_2 = L1_2.hasPerm
  L6_2 = "Update Config"
  L4_2 = L4_2(L5_2, L6_2)
  if L4_2 then
    L5_2 = RPC
    L6_2 = L5_2
    L5_2 = L5_2.emitLocal
    L7_2 = "ProAddon:AddWhitelister"
    L8_2 = L0_2
    L5_2(L6_2, L7_2, L8_2)
  end
  L5_2 = EmitPipe
  L6_2 = "Reaper:playerJoined"
  L7_2 = L1_2
  L5_2(L6_2, L7_2)
end
L14_1(L15_1, L16_1, L17_1)
L14_1 = RPC
L15_1 = L14_1
L14_1 = L14_1.register
L16_1 = "FetchData"
function L17_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L1_2 = Player
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  if nil == L1_2 then
    L2_2 = "RESPONSE_FAILED"
    return L2_2
  end
  L3_2 = L1_2
  L2_2 = L1_2.getIdentifier
  L4_2 = "license"
  L2_2 = L2_2(L3_2, L4_2)
  L4_2 = L1_2
  L3_2 = L1_2.getIdentifier
  L5_2 = "steam"
  L3_2 = L3_2(L4_2, L5_2)
  L5_2 = L1_2
  L4_2 = L1_2.getIdentifier
  L6_2 = "fivem"
  L4_2 = L4_2(L5_2, L6_2)
  L6_2 = L1_2
  L5_2 = L1_2.getIdentifier
  L7_2 = "discord"
  L5_2 = L5_2(L6_2, L7_2)
  L7_2 = L1_2
  L6_2 = L1_2.getIdentifier
  L8_2 = "ip"
  L6_2 = L6_2(L7_2, L8_2)
  if L2_2 then
    L7_2 = "license:"
    L8_2 = L2_2
    L7_2 = L7_2 .. L8_2
    L2_2 = L7_2
  end
  if L3_2 then
    L7_2 = "steam:"
    L8_2 = L3_2
    L7_2 = L7_2 .. L8_2
    L3_2 = L7_2
  end
  if L4_2 then
    L7_2 = "fivem:"
    L8_2 = L4_2
    L7_2 = L7_2 .. L8_2
    L4_2 = L7_2
  end
  if L5_2 then
    L7_2 = "discord:"
    L8_2 = L5_2
    L7_2 = L7_2 .. L8_2
    L5_2 = L7_2
  end
  if L6_2 then
    L7_2 = "ip:"
    L8_2 = L6_2
    L7_2 = L7_2 .. L8_2
    L6_2 = L7_2
  end
  L7_2 = json
  L7_2 = L7_2.encode
  L8_2 = {}
  L10_2 = L1_2
  L9_2 = L1_2.getGuid
  L9_2 = L9_2(L10_2)
  L8_2.guid = L9_2
  L9_2 = Cache
  L10_2 = L9_2
  L9_2 = L9_2.get
  L11_2 = "serverId"
  L9_2 = L9_2(L10_2, L11_2)
  L8_2.serverId = L9_2
  L8_2.license = L2_2
  L8_2.steam = L3_2
  L8_2.fivem = L4_2
  L8_2.discord = L5_2
  L8_2.ip = L6_2
  L7_2 = L7_2(L8_2)
  L8_2 = {}
  L8_2.data = L7_2
  L9_2 = Security
  L10_2 = L9_2
  L9_2 = L9_2.hash
  L11_2 = L7_2
  L9_2 = L9_2(L10_2, L11_2)
  L8_2.key = L9_2
  return L8_2
end
L14_1(L15_1, L16_1, L17_1)
