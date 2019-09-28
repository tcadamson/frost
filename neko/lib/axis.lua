local unpack = unpack
local nu = neko.util
local axis = {}
local queue = nu.new("grow")
local min = 1
local max = 1

function axis.queue(z, f, ...)
    local arg = {...}
    local batch = queue[z]
    if z > max then
        max = z
    elseif z < min then
        min = z
    end
    batch[#batch + 1] = function()
        f(unpack(arg))
    end
end

function axis.draw()
    for z = min, max do
        local batch = queue[z]
        for i = 1, #batch do
            batch[i]()
        end
    end
end

function axis.refresh()
    for z = min, max do
        local batch = queue[z]
        if #batch > 0 then
            -- before queueing, min is set to the observed max
            -- min is then set to lowest z during queueing
            max = z
            min = z
        end
        for i = 1, #batch do
            batch[i] = nil
        end
    end
end

return axis