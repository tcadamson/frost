local unpack = unpack
local axis = {}
local q = setmetatable({}, {
    __index = function(t, k)
        local batch = {}
        t[k] = batch
        return batch
    end
})
local max = 1

function axis.queue(z, f, ...)
    local arg = {...}
    local batch = q[z]
    if z > max then max = z end
    batch[#batch + 1] = function()
        f(unpack(arg))
    end
end

function axis.draw()
    for z = 1, max do
        local batch = q[z]
        for i = 1, #batch do
            batch[i]()
        end
    end
end

function axis.refresh()
    local red = 0
    for z = 1, max do
        local batch = q[z]
        red = #batch > 1 and 0 or red + 1
        for i = 1, #batch do
            batch[i] = nil
        end
    end
    max = max - red
end

return axis