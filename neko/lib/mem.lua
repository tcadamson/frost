local match = string.match
local floor = math.floor
local huge = math.huge
local nr = neko.run
local ffi = require("ffi")
local mem = {}
local bufs = {}
local block = 256
local tick = 1

function mem.new(cdef, weak)
    local id = match(cdef, "(%w+)%s-$")
    local ref = setmetatable({
        blocks = {},
        weak = weak,
        id = id,
        uid = 0,
        min = 0
    }, {
        __index = mem
    })
    setmetatable(ref.blocks, {
        __index = function(t, uid)
            uid = floor(uid / block) + 1
            while uid > #t do
                t[#t + 1] = ffi.new(ref.id .. "[?]", block)
            end
            return t[uid]
        end
    })
    ffi.cdef(cdef)
    bufs[id] = ref
    return ref
end

function mem:get(uid)
    return self.blocks[uid][uid % block]
end

function mem:set(uid, struct)
    self.blocks[uid][uid % block] = struct
end

function mem:fetch()
    if self.weak and nr.tick > tick then
        -- # of allocations at file level (min) are reserved
        self.uid = self.min
        tick = nr.tick
    end
    local uid = self.uid
    self.uid = self.uid + 1
    return self:get(uid)
end

return mem