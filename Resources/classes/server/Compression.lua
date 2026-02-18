-- ReaperV4 Server Compression Class
-- Clean and optimized version

local class = class
local string_find = string.find
local string_len = string.len
local string_sub = string.sub
local string_rep = string.rep
local string_pack = string.pack
local string_unpack = string.unpack
local string_byte = string.byte
local math_clamp = math.clamp
local bit32_lshift = bit32.lshift
local bit32_rshift = bit32.rshift
local bit32_band = bit32.band
local table_insert = table.insert
local table_unpack = table.unpack
local msgpack_pack_args = msgpack.pack_args
local msgpack_unpack = msgpack.unpack

-- LZ4 compression class definition
local LZ4Class = class("LZ4")

-- Constructor
function LZ4Class:constructor()
    -- Initialize LZ4 compression class
end

-- Plain find function
function LZ4Class:plainFind(haystack, needle)
    return string_find(haystack, needle, 0, true)
end

-- Create streamer object
function LZ4Class:streamer(source)
    local streamer = {
        Offset = 0,
        Source = source,
        Length = string_len(source),
        IsFinished = false,
        LastUnreadBytes = 0
    }
    
    -- Read function
    function streamer:read(count, seek)
        count = count or 1
        if not count then
            count = 1
        end
        
        local shouldSeek = true
        if seek ~= nil then
            shouldSeek = seek
        end
        
        local result = string_sub(self.Source, self.Offset + 1, self.Offset + count)
        local actualLength = string_len(result)
        local unreadBytes = count - actualLength
        
        if shouldSeek then
            self:seek(count)
        end
        
        self.LastUnreadBytes = unreadBytes
        return result
    end
    
    -- Seek function
    function streamer:seek(count)
        count = count or 1
        if not count then
            count = 1
        end
        
        self.Offset = math_clamp(self.Offset + count, 0, self.Length)
        self.IsFinished = self.Offset >= self.Length
    end
    
    -- Append function
    function streamer:append(data)
        self.Source = self.Source .. data
        self.Length = string_len(self.Source)
        self:seek(0)
    end
    
    -- Move to end
    function streamer:toEnd()
        self:seek(self.Length)
    end
    
    return streamer
end

-- Compress chunk
function LZ4Class:compress_chunk(data)
    local chunks = {}
    local streamer = self:streamer(data)
    
    if streamer.Length > 12 then
        local header = streamer:read(4)
        local literal = ""
        local match = ""
        local isLiteral = true
        
        repeat
            isLiteral = true
            local chunk = streamer:read()
            local findResult = self:plainFind(literal, chunk)
            
            if findResult then
                local matchData = streamer:read(3, false)
                local matchLength = string_len(matchData)
                
                if matchLength < 3 then
                    literal = literal .. chunk
                    match = matchData
                    streamer:seek(3)
                else
                    literal = literal .. chunk
                    match = matchData
                    local matchFind = self:plainFind(literal, match)
                    
                    if matchFind then
                        streamer:seek(3)
                        repeat
                            local nextByte = streamer:read(1)
                            match = match .. nextByte
                            local nextFind = self:plainFind(literal, match)
                            
                            if nextFind then
                                literal = match
                                streamer:seek(1)
                            end
                            
                            local continueFind = self:plainFind(literal, match)
                            if not continueFind then
                                break
                            end
                        until streamer.IsFinished
                        
                        local matchLen = string_len(match)
                        local shouldCompress = true
                        local remainingBytes = streamer.Length - streamer.Offset
                        
                        if remainingBytes <= 5 then
                            literal = match
                            shouldCompress = false
                        end
                        
                        if shouldCompress then
                            isLiteral = false
                            local literalLen = string_len(literal)
                            literalLen = literalLen - findResult
                            literal = literal .. match
                            
                            table_insert(chunks, {
                                Literal = literal,
                                LiteralLength = string_len(literal),
                                MatchOffset = findResult + 1,
                                MatchLength = matchLen
                            })
                            literal = ""
                        end
                    else
                        literal = chunk
                    end
                end
            else
                literal = chunk
            end
            
            if isLiteral then
                literal = literal .. match
                literal = literal .. chunk
            end
        until streamer.IsFinished
        
        table_insert(chunks, {
            Literal = literal,
            LiteralLength = string_len(literal)
        })
    else
        table_insert(chunks, {
            Literal = streamer.Source,
            LiteralLength = string_len(streamer.Source)
        })
    end
    
    -- Create compressed data
    local compressedData = string_rep("\0", 4)
    
    local function append(data)
        compressedData = compressedData .. data
    end
    
    for i, chunk in pairs(chunks) do
        local literalLength = chunk.LiteralLength
        local matchLength = chunk.MatchLength or 4
        matchLength = matchLength - 4
        
        literalLength = math_clamp(literalLength, 0, 15)
        matchLength = math_clamp(matchLength, 0, 15)
        
        local token = bit32_lshift(literalLength, 4) + matchLength
        append(string_pack("<I1", token))
        
        -- Handle literal length extension
        if literalLength >= 15 then
            literalLength = literalLength - 15
            repeat
                local extension = math_clamp(literalLength, 0, 255)
                append(string_pack("<I1", extension))
                if extension == 255 then
                    literalLength = literalLength - 255
                end
            until extension < 255
        end
        
        append(chunk.Literal)
        
        -- Handle match
        if i ~= #chunks then
            append(string_pack("<I2", chunk.MatchOffset))
            
            if matchLength >= 15 then
                matchLength = matchLength - 15
                repeat
                    local extension = math_clamp(matchLength, 0, 255)
                    append(string_pack("<I1", extension))
                    if extension == 255 then
                        matchLength = matchLength - 255
                    end
                until extension < 255
            end
        end
    end
    
    local compressedLength = string_len(compressedData) - 4
    local originalLength = streamer.Length
    
    return string_pack("<I4", compressedLength) .. 
           string_pack("<I4", originalLength) .. 
           compressedData
end

-- Compress data
function LZ4Class:compress(data)
    local chunks = {}
    local chunkSize = 90000
    
    for i = 1, #data, chunkSize do
        local chunk = data:sub(i, i + chunkSize - 1)
        table_insert(chunks, self:compress_chunk(chunk))
    end
    
    return msgpack_pack_args(chunks)
end

-- Decompress data
function LZ4Class:decompress(data)
    local chunks = table_unpack(msgpack_unpack(data))
    local result = ""
    
    for _, chunk in pairs(chunks) do
        result = result .. self:decompress_chunk(chunk)
    end
    
    return result
end

-- Decompress chunk
function LZ4Class:decompress_chunk(data)
    local streamer = self:streamer(data)
    
    local compressedLength = string_unpack("<I4", streamer:read(4))
    local originalLength = string_unpack("<I4", streamer:read(4))
    
    if compressedLength == 0 then
        return streamer:read(originalLength)
    end
    
    local output = self:streamer("")
    
    repeat
        local token = string_byte(streamer:read())
        local literalLength = bit32_rshift(token, 4)
        local matchLength = bit32_band(token, 15) + 4
        
        -- Handle literal length extension
        if literalLength >= 15 then
            repeat
                local extension = string_byte(streamer:read())
                literalLength = literalLength + extension
            until extension ~= 255
        end
        
        local literal = streamer:read(literalLength)
        output:append(literal)
        output:toEnd()
        
        if originalLength > output.Length then
            local matchOffset = string_unpack("<I2", streamer:read(2))
            
            -- Handle match length extension
            if matchLength >= 19 then
                repeat
                    local extension = string_byte(streamer:read())
                    matchLength = matchLength + extension
                until extension ~= 255
            end
            
            output:seek(-matchOffset)
            local match = output:read(matchLength)
            output:toEnd()
            
            -- Handle unread bytes
            if output.LastUnreadBytes then
                local unreadBytes = output.LastUnreadBytes
                local unreadData = nil
                
                repeat
                    output.Offset = output.Offset
                    local readData = output:read(unreadBytes)
                    unreadData = readData
                    unreadBytes = output.LastUnreadBytes
                    match = match .. unreadData
                until unreadBytes <= 0
            end
            
            output:append(match)
            output:toEnd()
        end
    until originalLength <= output.Length
    
    return output.Source
end

-- Create LZ4 instance
LZ4 = LZ4Class.new()

-- Export functions
exports("Compress", function(data)
    return LZ4:compress(data)
end)

exports("Decompress", function(data)
    return LZ4:decompress(data)
end)

exports("CompressChunk", function(data)
    return LZ4:compress_chunk(data)
end)

exports("DecompressChunk", function(data)
    return LZ4:decompress_chunk(data)
end)