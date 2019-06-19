local match = string.match
local floor = math.floor
local huge = math.huge
local nr = neko.run
local ffi = require("ffi")
local mem = {}
local bufs = {}
local block = 256
local tick = 1

local function access(blocks, uid, struct)
    local i = floor(uid / block) + 1
    local j = uid % block
    if struct then blocks[i][j] = struct end
    return blocks[i][j]
end

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
        __index = function(t, k)
            while k > #t do
                t[#t + 1] = ffi.new(ref.id .. "[?]", block)
            end
            return t[k]
        end
    })
    ffi.cdef(cdef)
    bufs[id] = ref
    return ref
end

function mem:get(uid)
    return access(self.blocks, uid)
end

function mem:set(uid, struct)
    access(self.blocks, uid, struct)
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