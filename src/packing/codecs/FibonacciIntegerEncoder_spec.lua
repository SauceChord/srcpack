local Encoder = require "packing.codecs.FibonacciIntegerEncoder"

describe("packing.codecs.FibonacciIntegerEncoder", function()
    describe("encode", function()
        it("encodes 2", function()
            -- Setup spy
            local actualArgs = {}
            local spy = function(a, b) table.insert(actualArgs, { a, b }) end

            -- Setup object under test
            local encoder = Encoder.New(spy)
            encoder.Encode(2)

            -- Expected
            local expectedWriteBitArgs = {
                { 2, 2 },
                { 2, 2 },
            }
            assert.are_same(expectedWriteBitArgs, actualArgs)
        end)
    end)
end)
