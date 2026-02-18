-- ReaperV4 Server Benchmark Class
-- Clean and optimized version

local class = class
local os_nanotime = os.nanotime
local print = print
local string_format = string.format
local table_sort = table.sort
local table_wipe = table.wipe
local pairs = pairs

-- Benchmark class definition
local BenchmarkClass = class("Benchmark")

-- Constructor
function BenchmarkClass:constructor()
    self.results = {}
end

-- Run benchmark
function BenchmarkClass:run(iterations, name, func)
    if type(iterations) ~= "number" or iterations <= 0 then
        error("Iterations must be a positive number", 2)
    end
    
    if type(name) ~= "string" then
        error("Name must be a string", 2)
    end
    
    if type(func) ~= "function" then
        error("Function must be a function", 2)
    end
    
    local startTime = os_nanotime()
    
    -- Run the function for the specified number of iterations
    for i = 1, iterations do
        func()
    end
    
    local endTime = os_nanotime()
    local totalTime = endTime - startTime
    local averageTime = totalTime / iterations
    
    -- Store result
    table.insert(self.results, {
        name = name,
        iterations = iterations,
        totalTime = totalTime,
        averageTime = averageTime
    })
    
    return averageTime
end

-- Print results
function BenchmarkClass:printResults(iterations)
    if type(iterations) ~= "number" then
        iterations = 0
    end
    
    print(string_format("Average results from %d iterations (ms)", iterations))
    
    -- Sort results by average time
    table_sort(self.results, function(a, b)
        return a.averageTime < b.averageTime
    end)
    
    -- Print results
    for i, result in ipairs(self.results) do
        print(string_format("#%d - %.4f\t(%s)", 
            i, 
            result.averageTime / 1000000.0, 
            result.name
        ))
    end
    
    -- Clear results
    table_wipe(self.results)
end

-- Run multiple benchmarks
function BenchmarkClass:runMultiple(iterations, benchmarks)
    if type(iterations) ~= "number" or iterations <= 0 then
        error("Iterations must be a positive number", 2)
    end
    
    if type(benchmarks) ~= "table" then
        error("Benchmarks must be a table", 2)
    end
    
    -- Run each benchmark
    for name, func in pairs(benchmarks) do
        self:run(iterations, name, func)
    end
    
    -- Print results
    self:printResults(iterations)
end

-- Get results
function BenchmarkClass:getResults()
    return self.results
end

-- Clear results
function BenchmarkClass:clearResults()
    table_wipe(self.results)
end

-- Create benchmark instance
Benchmark = BenchmarkClass.new()

-- Export functions
exports("RunBenchmark", function(iterations, name, func)
    return Benchmark:run(iterations, name, func)
end)

exports("RunMultipleBenchmarks", function(iterations, benchmarks)
    return Benchmark:runMultiple(iterations, benchmarks)
end)

exports("PrintBenchmarkResults", function(iterations)
    return Benchmark:printResults(iterations)
end)

exports("GetBenchmarkResults", function()
    return Benchmark:getResults()
end)

exports("ClearBenchmarkResults", function()
    return Benchmark:clearResults()
end)