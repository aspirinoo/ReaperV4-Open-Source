-- ReaperV4 Client Compression Class
-- Clean and optimized version

local class = class
local string = string
local math = math
local table = table

-- LZ4 Compression class
local LZ4Class = class("LZ4")

-- Constructor
function LZ4Class:constructor()
    -- Constructor implementation
end

-- Plain string find function
function LZ4Class:plainFind(source, pattern)
    return string.find(source, pattern, 0, true)
end

-- Create streamer object
function LZ4Class:streamer(source)
    local streamer = {
        Offset = 0,
        Source = source,
        Length = string.len(source),
        IsFinished = false,
        LastUnreadBytes = 0
    }
    
    -- Read function
    function streamer:read(count, advance)
        count = count or 1
        advance = advance ~= nil and advance or true
        
        local data = string.sub(self.Source, self.Offset + 1, self.Offset + count)
        local unreadBytes = count - string.len(data)
        
        if advance then
            self:seek(count)
        end
        
        self.LastUnreadBytes = unreadBytes
        return data
    end
    
    -- Seek function
    function streamer:seek(amount)
        amount = amount or 1
        self.Offset = math.clamp(self.Offset + amount, 0, self.Length)
        self.IsFinished = self.Offset >= self.Length
    end
    
    -- Append function
    function streamer:append(data)
        self.Source = self.Source .. data
        self.Length = string.len(self.Source)
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
    local tokens = {}
    local streamer = self:streamer(data)
    
    if streamer.Length > 12 then
        local magic = streamer:read(4)
        local literal = ""
        local match = ""
        local hasMatch = true
        
        repeat
            hasMatch = true
            local byte = streamer:read()
            
            if self:plainFind(magic, byte) then
                local nextBytes = streamer:read(3, false)
                
                if string.len(nextBytes) < 3 then
                    match = byte .. nextBytes
                    streamer:seek(3)
                else
                    match = byte .. nextBytes
                    
                    if self:plainFind(magic, match) then
                        streamer:seek(3)
                        
                        repeat
                            local nextByte = streamer:read(1, false)
                            match = match .. nextByte
                            
                            if self:plainFind(magic, match) then
                                streamer:seek(1)
                            end
                        until not self:plainFind(magic, match) or streamer.IsFinished
                        
                        local matchLength = string.len(match)
                        local isComplete = streamer.Length - streamer.Offset > 5
                        
                        if not isComplete then
                            match = match
                            hasMatch = false
                        end
                        
                        if isComplete then
                            hasMatch = false
                            local magicLength = string.len(magic) - matchLength
                            magic = magic .. match
                            
                            table.insert(tokens, {
                                Literal = literal,
                                LiteralLength = string.len(literal),
                                MatchOffset = magicLength + 1,
                                MatchLength = matchLength
                            })
                            literal = ""
                        end
                    else
                        match = byte
                    end
                end
            else
                match = byte
            end
            
            if hasMatch then
                literal = literal .. match
                magic = magic .. byte
            end
        until streamer.IsFinished
        
        table.insert(tokens, {
            Literal = literal,
            LiteralLength = string.len(literal)
        })
    else
        tokens[1] = {
            Literal = streamer.Source,
            LiteralLength = string.len(streamer.Source)
        }
    end
    
    local output = string.rep("\000", 4)
    
    local function write(data)
        output = output .. data
    end
    
    for i, token in ipairs(tokens) do
        local literalLength = token.LiteralLength
        local matchLength = token.MatchLength or 4
        matchLength = matchLength - 4
        
        literalLength = math.clamp(literalLength, 0, 15)
        matchLength = math.clamp(matchLength, 0, 15)
        
        local tokenByte = bit32.lshift(literalLength, 4) + matchLength
        write(string.pack("<I1", tokenByte))
        
        if literalLength >= 15 then
            literalLength = literalLength - 15
            repeat
                local lengthByte = math.clamp(literalLength, 0, 255)
                write(string.pack("<I1", lengthByte))
                if lengthByte == 255 then
                    literalLength = literalLength - 255
                end
            until lengthByte < 255
        end
        
        write(token.Literal)
        
        if i ~= #tokens then
            write(string.pack("<I2", token.MatchOffset))
            
            if matchLength >= 15 then
                matchLength = matchLength - 15
                repeat
                    local lengthByte = math.clamp(matchLength, 0, 255)
                    write(string.pack("<I1", lengthByte))
                    if lengthByte == 255 then
                        matchLength = matchLength - 255
                    end
                until lengthByte < 255
            end
        end
    end
    
    local outputLength = string.len(output) - 4
    local originalLength = streamer.Length
    
    local header = string.pack("<I4", outputLength) .. string.pack("<I4", originalLength)
    return header .. output
end

-- Compress data
function LZ4Class:compress(data)
    local chunks = {}
    local chunkSize = 90000
    
    for i = 1, #data, chunkSize do
        local chunk = data:sub(i, i + chunkSize - 1)
        table.insert(chunks, self:compress_chunk(chunk))
    end
    
    return msgpack.pack_args(chunks)
end

-- Decompress data
function LZ4Class:decompress(data)
    local chunks = table.unpack(msgpack.unpack(data))
    local result = ""
    
    for i, chunk in ipairs(chunks) do
        result = result .. self:decompress_chunk(chunk)
    end
    
    return result
end

-- Decompress chunk
function LZ4Class:decompress_chunk(data)
    local streamer = self:streamer(data)
    
    local outputLength = string.unpack("<I4", streamer:read(4))
    local originalLength = string.unpack("<I4", streamer:read(4))
    local magic = string.unpack("<I4", streamer:read(4))
    
    if outputLength == 0 then
        return streamer:read(originalLength)
    end
    
    local output = self:streamer("")
    
    repeat
        local tokenByte = string.byte(streamer:read())
        local literalLength = bit32.rshift(tokenByte, 4)
        local matchLength = bit32.band(tokenByte, 15) + 4
        
        if literalLength >= 15 then
            repeat
                local lengthByte = string.byte(streamer:read())
                literalLength = literalLength + lengthByte
            until lengthByte ~= 255
        end
        
        local literal = streamer:read(literalLength)
        output:append(literal)
        output:toEnd()
        
        if output.Length < originalLength then
            local matchOffset = string.unpack("<I2", streamer:read(2))
            
            if matchLength >= 19 then
                repeat
                    local lengthByte = string.byte(streamer:read())
                    matchLength = matchLength + lengthByte
                until lengthByte ~= 255
            end
            
            output:seek(-matchOffset)
            local match = output:read(matchLength)
            local unreadBytes = output.LastUnreadBytes
            
            if unreadBytes then
                repeat
                    output.Offset = output.Offset - unreadBytes
                    local unreadData = output:read(unreadBytes)
                    match = match .. unreadData
                    unreadBytes = output.LastUnreadBytes
                until unreadBytes <= 0
            end
            
            output:append(match)
            output:toEnd()
        end
    until output.Length >= originalLength
    
    return output.Source
end

-- Create LZ4 instance
local LZ4 = LZ4Class.new()

return LZ4