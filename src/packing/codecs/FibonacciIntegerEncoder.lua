local FibonacciIntegerEncoder = {}

FibonacciIntegerEncoder.__index = FibonacciIntegerEncoder
---@alias WriteBits fun(integer, integer)

---Creates a new FibonacciIntegerEncoderInstance
---@param writeBits WriteBits Function that takes care of writing bits
---@return FibonacciIntegerEncoderInstance instance
function FibonacciIntegerEncoder.New(writeBits)
    ---@class FibonacciIntegerEncoderInstance
    local s = {}
    function s.Encode(n)
        writeBits(n, n)
    end
    return s
end

-- Static function
FibonacciIntegerEncoder.StaticFunction = function() end

return FibonacciIntegerEncoder