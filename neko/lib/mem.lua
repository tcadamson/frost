local match = string.match
local floor = math.floor
local nr = neko.run
local ffi = require("ffi")
local mem = {}
local bufs = {}
local block = 256
local tick = 1

local function access(blocks, uid, init)
    if uid then
        local i = floor(uid / block) + 1
        local j = uid % block
        if init then blocks[i][j] = init end
        return blocks[i][j]
    end
end

function mem.new(cdef)
    local id = match(cdef, "(%w+)%s-$")
    local ref = setmetatable({
        blocks = {},
        cdef = cdef,
        id = id,
        uid = 0,
        reserved = 0
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

function mem:set(uid, init)
    access(self.blocks, uid, init)
end

function mem:add(init)
    if not nr.loaded then self.reserved = self.reserved + 1 end
    if nr.tick > tick then
        -- file-level allocations are reserved
        -- these structs should be modified directly (e.g. vec:set(...))
        self.uid = self.reserved
        tick = nr.tick
    end
    local uid = self.uid
    self.uid = self.uid + 1
    return access(self.blocks, uid, init)
end

return mem