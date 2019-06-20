local type = type
local unpack = unpack
local format = string.format
local remove = table.remove
local nu = neko.util
local nm = neko.mem
local ffi = require("ffi")
local ecs = {}
local dead = {}
local com = {
    pos = "double x, y",
    phys = "double v",
    steer = "double x, y",
    target = "uint16_t e",
    tex = "const char* file; uint16_t x, y, w, h"
}
local uid = 0

for k, v in pairs(com) do
    com[k] = nm.new(format([[
        typedef struct {
            %s;
            uint8_t status;
        } %s
    ]], v, k))
    ecs[k] = setmetatable({}, {
        __index = function(t, e)
            return com[k]:get(e)
        end,
        __newindex = function(t, e, v)
            v.status = 1
            com[k]:set(e, v)
        end
    })
end

function ecs.new(data)
    local e = uid
    uid = remove(dead) or uid + 1
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
        com[k]:set(e, {})
    end
    dead[#dead + 1] = e
end

function ecs.toggle(e, id)
    local struct = com[id]:get(e)
    struct.status = struct.status > 0 and 0 or 1
end

function ecs.update(dt)
    for e = 0, uid do
        for i = 1, #ecs do
            local sys = ecs[i]
            local buf = sys.buf
            local hole
            for j = 1, #sys do
                local id = sys[j]
                local struct = com[id]:get(e)
                if struct.status > 0 then
                    buf[j] = struct
                else
                    hole = true
                    break
                end
            end
            if not hole then sys.update(dt, unpack(buf)) end
        end
    end
end

return ecs