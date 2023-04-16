local FibonacciInteger = {
    Numbers = { }
}

-- Initialize numbers with all fibonacci numbers that fit for signed 64 bit integer
local a, b, c = 0, 0, 1
for i = 1, 86 do
    a = b b = c c = a + b
    FibonacciInteger.Numbers[i] = c
end

return FibonacciInteger
