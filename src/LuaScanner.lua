---@class LuaScanner
---@field source string
---@field tokens integer[]
local LuaScanner = { }

---@return string
function LuaScanner:tostring()
    return string.format("LuaScanner")
end

local mt = { __index = LuaScanner, __tostring = LuaScanner.tostring }

---@param source string
---@return LuaScanner
function LuaScanner.new(source)
    local o = {
        source = source,
        tokens = {}
    }
    setmetatable(o, mt)
    return o
end

return LuaScanner
