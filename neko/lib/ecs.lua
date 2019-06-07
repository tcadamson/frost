local type = type
local unpack = unpack
local format = string.format
local gmatch = string.gmatch
local remove = table.remove
local nu = neko.util
local ffi = require("ffi")
local ecs = {}
local sys = {}
local dead = {}
local com = {
    pos = "double x, y",
    phys = "double v",
    control = "double x, y",
    target = "uint16_t e",
    tex = "const char* file; uint16_t id, x, y, w, h"
}
local uid = 0
local fill = 1

nu.crawl("neko/system", function(id, path)
    sys[#sys + 1] = setmetatable(require(path), {
        __index = ecs
    })
end)
for k, v in pairs(com) do
    ffi.cdef(format([[
        typedef struct {
            %s;
            uint8_t status;
        } %s;
    ]], v, k))
    com[k] = ffi.new(k .. "[?]", fill)
    ecs[k] = setmetatable({}, {
        __index = function(t, uid) return com[k][uid] end,
        __newindex = function(t, uid, v)
            v.status = 1
            com[k][uid] = v
        end
    })
end

function ecs.new(data)
    local e = uid
    uid = remove(dead) or uid + 1
    if uid > fill then
        fill = fill * 2
        for k, v in pairs(com) do
            local buf = ffi.new(k .. "[?]", fill)
            ffi.copy(buf, v, ffi.sizeof(v))
            com[k] = buf
        end
    end
    for k, v in pairs(data) do
        if type(k) == "number" then
            k = v
            v = {}
        end
        ecs[k][e] = v
    end
    return e
end

function ecs.kill(e)
    for k, v in pairs(com) do
        com[k][e] = {}
    end
    dead[#dead + 1] = e
end

function ecs.toggle(e, id)
    local struct = com[id][e]
    struct.status = struct.status > 0 and 0 or 1
end

function ecs.update(dt)
    for i = 0, fill - 1 do
        for j = 1, #sys do
            local sys = sys[j]
            local buf = {}
            local hole
            for k = 1, #sys do
                local id = sys[k]
                local struct = com[id][i]
                if struct.status > 0 then
                    buf[#buf + 1] = struct
                else
                    hole = true
                    break
                end
            end
            if not hole then sys:update(dt, unpack(buf)) end
        end
    end
end

return ecs