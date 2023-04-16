local function range(from, to, step)
    step = step or 1
    return function(_, lastvalue)
        local nextvalue = lastvalue + step
        if step > 0 and nextvalue <= to or step < 0 and nextvalue >= to or step == 0 then
            return nextvalue
        end
    end, nil, from - step
end

local function f() return 10, 0, -1 end

for i in range(f()) do
    print(i)
end