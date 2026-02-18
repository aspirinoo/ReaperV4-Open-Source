-- ReaperV4 Client Benchmark Class
-- Clean and optimized version

local GetGameTimer = GetGameTimer
local print = print
local table = table

-- Benchmark class
local Benchmark = {}

-- Results storage
local results = {}

-- Run benchmark for specified iterations
function Benchmark.run(iterations, name, func)
    local startTime = GetGameTimer()
    
    for i = 1, iterations do
        func()
    end
    
    local endTime = GetGameTimer()
    local avgTime = (endTime - startTime) / iterations
    
    table.insert(results, {avgTime, name})
end

-- Print benchmark results
function Benchmark.printResults(iterations)
    print(string.format("Average results from %d iterations (ms)", iterations))
    
    -- Sort results by time
    table.sort(results, function(a, b)
        return a[1] < b[1]
    end)
    
    -- Print sorted results
    for i, result in ipairs(results) do
        print(string.format("#%d - %.4f\t(%s)", i, result[1] / 1000000.0, result[2]))
    end
    
    -- Clear results
    table.wipe(results)
end

-- Run benchmarks for multiple functions
function Benchmark.runBenchmarks(iterations, benchmarks)
    for name, func in pairs(benchmarks) do
        Benchmark.run(iterations, name, func)
    end
    
    Benchmark.printResults(iterations)
end

return Benchmark