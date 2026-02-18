-- ReaperV4 Server JSON Class
-- Clean and optimized version

local json = json
local LZ4 = LZ4

-- JSON compression function
function json.compress(data)
    local jsonString = json.encode(data)
    return LZ4:compress(jsonString)
end

-- JSON decompression function
function json.decompress(compressedData)
    local jsonString = LZ4:decompress(compressedData)
    return json.decode(jsonString)
end

-- Export functions
exports("CompressJSON", function(data)
    return json.compress(data)
end)

exports("DecompressJSON", function(compressedData)
    return json.decompress(compressedData)
end)