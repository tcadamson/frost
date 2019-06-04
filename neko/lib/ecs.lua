local type = type
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
    target = "uint16_t e"
}
local uid = 0
local fill = 1

-- local function assign(com, buf)
--     ecs[com] = setmetatable({}, {
--         __index = buf,
--         __newindex = function(_, k, v)
--             v.status = 1
--             buf[k] = v
--         end
--     })
-- end

-- local pos = {}
-- local ffi = require("ffi")
-- ffi.cdef("typedef struct { uint16_t x, y; } pos;")
-- -- list = ffi.new("test[?]", 1)
-- -- list2 = ffi.new("test[?]", 2)

-- -- function pos.new(e, data)
-- --     for k, v in pairs(data) do
-- --         pos[e][k] = v
-- --     end
-- --     -- ffi.copy(list2, list, 1)
-- -- end

-- -- function pos.update(e)
-- --     -- if pos[e].x == 20 then print("holy fucking yikes") end
-- --     -- local hm = e.x * 10
-- -- end

-- return pos

nu.crawl("neko/system", function(id, path)
    -- sys[#sys + 1] = setmetatable(require(path), {
    --     __newindex = function(t, k, v)
    --         if type(v) == "table" then print(t.e) com[k][t.e] = v else rawset(t, k, v) end
    --     end
    -- })
    sys[#sys + 1] = require(path)
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
    -- if uid > fill then
    --     for k in pairs(com) do
    --         local com = ecs[k]
    --         local buf = ffi.new(k .. "[?]", fill * 2)
    --         local bytes = ffi.sizeof(k)
    --         -- ffi.copy(buf, getmetatable(com).__index, fill * bytes)
    --         fill = ffi.sizeof(buf) / bytes
    --         -- assign(k, buf)
    --         setmetatable(com, {
    --             __index = buf,
    --             __newindex = function(_, k, v)
    --                 v.status = 1
    --                 buf[k] = v
    --             end
    --         })
    --     end
    -- end
    -- for k, v in pairs(data) do
    --     -- v.status = 1
    --     ecs[k][e] = v
    -- end
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

-- local function check(com)
--     return com.status > 0
-- end

-- local mem = {}
-- local function check(e, filter)
--     mem[e] = mem[e] or {}
--     local result = mem[e][filter]
--     if not result then
--         local test
--         for f in gmatch(filter, "[^:]+") do
--             test = test or true and com[f][e].status > 0
--         end
--         mem[e][filter] = test
--     end
--     return result
-- end

function ecs.update(dt)
    for i = 0, fill - 1 do
        for j = 1, #sys do
            local sys = sys[j]
            local hole
            for k = 1, #sys do
                local id = sys[k]
                local struct = com[id][i]
                if struct.status > 0 then
                    sys[id] = struct
                else
                    hole = true
                    break
                end
            end
            if not hole then sys:update(dt) end
        end
    end
    -- for i = 1, #sys do
    --     for j = 0, fill - 1 do
    --         local sys = sys[i]
    --         local test = true
    --         for filter in gmatch(sys.filter, "[^:]+") do
    --             test = test and com[filter][j].status > 0
    --         end
    --         if test then sys.update(j) end
    --         -- if check(j, sys.filter) then sys.update(j) end
    --     end
    --     -- local test
    --     -- for com in gmatch(sys.filter, "[^:]+") do
    --     --     for j = 0, fill - 1 do
    --     --         test = test or true and ecs[com][j].status > 0
    --     --     end
    --     -- end
    -- end
    -- for i = 1, #sys do
    --     for j = 0, fill - 1 do
    --         -- -- for com in gmatch(sys.filter, "[^:]+") do
    --         -- --     test = ecs[com][j].status > 0
    --         -- -- end
    --         -- local sys = sys[i]
    --         -- local test
    --         -- -- for com in gmatch(sys.filter, "[^:]+") do
    --         -- --     test = test or true and ecs[com][j].status > 0
    --         -- -- end
    --         -- -- local a, b, c, d, e, f = unpack({1, 2, 3, 4, 5, 6})
    --         -- if test then sys.update(j) end
    --         local pos = check(com.pos[j])
    --         local phys = check(com.phys[j])
    --         sys.update(pos, phys)
    --         -- if test then sys.update(com, j) end
    --     end
    --     -- local com = ecs[com[i]]
    --     -- for j = 1, fill do
    --     --     com.update(com[j - 1])
    --     -- end
    -- end
end

-- print(#{1, 2, 3, nil, 5})
-- for k, v in pairs({1, 2, 3, nil, 5}) do
--     print(v)
-- end

-- local hm = ecs.new()
-- hm = nil
-- collectgarbage()
-- out(list)

return ecs