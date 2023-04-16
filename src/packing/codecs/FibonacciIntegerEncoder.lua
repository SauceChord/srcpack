local FibonacciIntegerEncoder = {}

FibonacciIntegerEncoder.__index = FibonacciIntegerEncoder

function FibonacciIntegerEncoder.New(args)
    local s = {}

    -- Public field
    s.Field = nil

    -- Private attribute
    local attribute = nil

    -- Meta function
    function s:__add(o1, o2)
    end

    -- Private function
    local function privateFunction()
    end

    -- Public function
    function s.PublicFunction()
    end

    return setmetatable(s, FibonacciIntegerEncoder)
end

-- Static function
FibonacciIntegerEncoder.StaticFunction = function() end

return FibonacciIntegerEncoder