local Encoder = require "packing.codecs.FibonacciIntegerEncoder"

describe("packing.codecs.FibonacciIntegerEncoder", function()
    describe("encode", function ()
        it("is being explored", function ()
            local bitWriter = {}
            stub(bitWriter, "greet")
            bitWriter.greet("hey")
            assert.stub(bitWriter.greet).was.called_with("hey")
            local encoder = Encoder.New(bitWriter)
        end)
    end)
end)