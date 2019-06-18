local match = string.match
local floor = math.floor
local huge = math.huge
local nr = neko.run
local ffi = require("ffi")
local mem = {}
local bufs = {}
local block = 256

function mem.new(cdef, weak)
    local id = match(cdef, "(%w+)%s-$")
    local ref = setmetatable({
        blocks = {},
        tick = weak and nr.tick or huge,
        id = id,
        uid = 0
    }, {
        __index = mem
    })
    ffi.cdef(cdef)
    bufs[id] = ref
    return ref
end

function mem:expand()
    self.blocks[#self.blocks + 1] = ffi.new(self.id .. "[?]", block)
end

function mem:get()
    if nr.tick > self.tick then
        -- skip first reset to not lose allocations at file level
        if self.tick > 1 then self.uid = 0 end
        self.tick = nr.tick
    end
    local uid = self.uid
    local i = floor(uid / block) + 1
    if i > #self.blocks then self:expand() end
    self.uid = self.uid + 1
    return self.blocks[i][uid % block]
end

return mem