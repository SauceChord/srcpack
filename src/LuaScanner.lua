---@class LuaScanner
---@field source string
---@field tokens integer[]
---@field start integer
---@field current integer
---@field line integer
local LuaScanner = {}

local LuaToken = require "LuaToken"

---@return string
function LuaScanner:tostring()
    return string.format("LuaScanner")
end

---@return integer[]
function LuaScanner:scanTokens()
    while not self:isAtEnd() do
        self:scanToken()
    end
    table.insert(self.tokens, LuaToken.new(LuaToken.EndOfStream, nil, nil, self.line))
    return self.tokens
end

function LuaScanner:scanToken()
    if self:isAtEnd() then return LuaToken.new(LuaToken.EndOfStream, nil, nil, self.line) end
    local c = self:advance()
    local switch = {
        ['('] = function() return self:addToken(LuaToken.OpenBracket) end,
        [')'] = function() return self:addToken(LuaToken.CloseBracket) end,
        ['{'] = function() return self:addToken(LuaToken.OpenScope) end,
        ['}'] = function() return self:addToken(LuaToken.CloseScope) end,
        [','] = function() return self:addToken(LuaToken.Comma) end,
        ['.'] = function()
            if self:isDigit() then return self:buildNumeral() end
            return self:addToken(self:matchAny('.') and (self:matchAny('.') and LuaToken.VarArgs or LuaToken.Concat) or
            LuaToken.FieldSelector)
        end,
        ['-'] = function()
            if self:matchAny('-') then
                if self:matchMany('[[') then
                    return self:buildMultilineComment()
                else
                    while self:peek() ~= '\r' and self:peek() ~= '\n' and not self:isAtEnd() do
                        self:advance()
                    end
                    local token = self:addToken(LuaToken.Comment)
                    return token
                end
            else
                return self:addToken(LuaToken.Minus)
            end
        end,
        ['+'] = function() return self:addToken(LuaToken.Plus) end,
        [';'] = function() return self:addToken(LuaToken.Terminator) end,
        ['*'] = function() return self:addToken(LuaToken.Multiply) end,
        ['%'] = function() return self:addToken(LuaToken.Modulus) end,
        ['^'] = function() return self:addToken(LuaToken.Exponent) end,
        ['&'] = function() return self:addToken(LuaToken.BinaryAnd) end,
        ['|'] = function() return self:addToken(LuaToken.BinaryOr) end,
        ['/'] = function() return self:addToken(self:matchAny('/') and LuaToken.DivideFloor or LuaToken.Divide) end,
        ['~'] = function() return self:addToken(self:matchAny('=') and LuaToken.NotEquals or LuaToken.BinaryNot) end,
        ['<'] = function() return self:addToken(self:matchAny('<') and LuaToken.BinaryShl or (self:matchAny('=') and LuaToken.LessThanOrEquals or LuaToken.LessThan)) end,
        ['>'] = function() return self:addToken(self:matchAny('>') and LuaToken.BinaryShr or (self:matchAny('=') and LuaToken.GreaterThanOrEquals or LuaToken.GreaterThan)) end,
        ['='] = function() return self:addToken(self:matchAny('=') and LuaToken.Equals or LuaToken.Assign) end,
        [':'] = function() return self:addToken(self:matchAny(':') and LuaToken.Label or LuaToken.MethodCall) end,
        ['\r'] = function()
            self.line = self.line + 1
            self.start = self.current
            while self:matchAny("\r\n") do
                self.line = self.line + 1
                self.start = self.current
            end
            return self:scanToken()
        end,
        ['\n'] = function()
            self.line = self.line + 1
            self.start = self.current
            while self:matchAny("\r\n") do
                self.line = self.line + 1
                self.start = self.current
            end
            return self:scanToken()
        end,
        [' '] = function()
            self:skipWhiteSpace()
            return self:scanToken()
        end,
        ['\t'] = function()
            self:skipWhiteSpace()
            return self:scanToken()
        end,
        ['\f'] = function()
            self:skipWhiteSpace()
            return self:scanToken()
        end,
        ['\v'] = function()
            self:skipWhiteSpace()
            return self:scanToken()
        end,
        ["'"] = function() return self:buildStringToken("'") end,
        ['"'] = function() return self:buildStringToken('"') end,
        ['['] = function()
            if self:matchAny('[') then
                return self:buildStringToken(']]')
            else
                return self:addToken(LuaToken.OpenIndex)
            end
        end,
        [']'] = function() return self:addToken(LuaToken.CloseIndex) end,
        -- Numerals
        ['0'] = function() return self:buildNumeral() end,
        ['1'] = function() return self:buildNumeral() end,
        ['2'] = function() return self:buildNumeral() end,
        ['3'] = function() return self:buildNumeral() end,
        ['4'] = function() return self:buildNumeral() end,
        ['5'] = function() return self:buildNumeral() end,
        ['6'] = function() return self:buildNumeral() end,
        ['7'] = function() return self:buildNumeral() end,
        ['8'] = function() return self:buildNumeral() end,
        ['9'] = function() return self:buildNumeral() end,
    }
    return (switch[c] or function() return self:addToken(LuaToken.Error) end)()
end

function LuaScanner:buildNumeral()
    if self:matchAny("xX") then
        while not self:isAtEnd() do
            if self:matchAny("pP") then
                self:matchAny("-+")
            elseif self:isHexadecimalDigit() or self:peek() == '.' then
                self:advance()
            else
                break
            end
        end
    else
        while not self:isAtEnd() do
            if self:matchAny("eE") then
                self:matchAny("-+")
            elseif self:matchAny(".") then
            elseif self:isDigit() then
                self:advance()
            else
                break
            end
        end
    end
    local literal = tonumber(self.source:sub(self.start, self.current - 1))
    return self:addToken(LuaToken.Number, literal)
end

function LuaScanner:buildMultilineComment()
    while not self:isAtEnd() and not self:matchMany(']]') do self:advance() end
    local token = self:addToken(LuaToken.MultilineComment)
    local _, newLineCount = token.lexeme:gsub("[\r\n]", "")
    self.line = self.line + newLineCount
    return token
end

function LuaScanner:buildStringToken(endChars)
    local line = self.line
    local reachedEnd = false
    while not self:isAtEnd() do
        if self:peek() == '\\' then
            self:advance()
            self:advance()
        elseif self:matchMany(endChars) then
            reachedEnd = true
            break
        else
            if self:peek() == '\r' or self:peek() == '\n' then
                self.line = self.line + 1
            end
            self:advance()
        end
    end
    if not reachedEnd then
        error(string.format("Unterminated string on line %d", line))
    end
    local value = self.source:sub(self.start + #endChars, self.current - #endChars - 1)
    local token = self:addToken(LuaToken.String, value, line)
    return token
end

---@return boolean isHexadecimalDigit
function LuaScanner:isHexadecimalDigit()
    if self:isAtEnd() then return false end
    local byte = self.source:byte(self.current, self.current)
    return (byte >= 48 and byte <= 57)  -- 0-9
        or (byte >= 97 and byte <= 102) -- a-f
        or (byte >= 65 and byte <= 70)  -- A-F
end

---@return boolean isDigit
function LuaScanner:isDigit()
    if self:isAtEnd() then return false end
    local digit = self.source:byte(self.current, self.current)
    return digit >= 48 and digit <= 57 -- 0-9
end

function LuaScanner:skipWhiteSpace()
    while self:matchAny(" \t\v\f") do
    end
    self.start = self.current
end

function LuaScanner:peekMany(expected)
    if self.current + #expected > #self.source then return false end
    for i = 1, #expected do
        if self.source:sub(self.current + i, self.current + i) ~= expected:sub(i, i) then
            return false
        end
    end
    return true
end

---@return string char
function LuaScanner:peek()
    if self:isAtEnd() then return '\0' end
    return self.source:sub(self.current, self.current)
end

---@return string char
function LuaScanner:advance()
    self.current = self.current + 1
    return self.source:sub(self.current - 1, self.current - 1)
end

---@param type string
---@param literal any
---@param line integer|nil
---@return LuaToken token
function LuaScanner:addToken(type, literal, line)
    line = line or self.line
    local text = self.source:sub(self.start, self.current - 1)
    local token = LuaToken.new(type, text, literal, line)
    table.insert(self.tokens, token)
    self.start = self.current
    return token
end

---@param expected string
---@return boolean match
function LuaScanner:matchMany(expected)
    if self.current + #expected > #self.source + 1 then return false end
    for i = 1, #expected do
        if self.source:sub(self.current + i - 1, self.current + i - 1) ~= expected:sub(i, i) then
            return false
        end
    end
    self.current = self.current + #expected
    return true
end

---Advances word window on match
---@param expected string any characters to match
---@return boolean matches
function LuaScanner:matchAny(expected)
    if self:isAtEnd() then return false end
    local char = self:peek()
    local found = expected:find(char, 1, true)
    if found then
        self.current = self.current + 1
    end
    return found ~= nil
end

---@return boolean
function LuaScanner:isAtEnd()
    return self.current > #self.source
end

local mt = { __index = LuaScanner, __tostring = LuaScanner.tostring }

---@param source string
---@return LuaScanner
function LuaScanner.new(source)
    local o = {
        source = source,
        tokens = {},
        start = 1,
        current = 1,
        line = 1,
    }
    setmetatable(o, mt)
    return o
end

return LuaScanner
