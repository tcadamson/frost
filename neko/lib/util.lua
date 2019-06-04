local select = select
local type = type
local rawset = rawset
local format = string.format
local match = string.match
local gsub = string.gsub
local lf = love.filesystem
local lw = love.window
local util = {}

-- function util.tbl_keys(tbl)
--     local out = {}
--     for k in pairs(tbl) do
--         out[#out + 1] = k
--     end
--     return out
-- end

function util.tbl_out(t)
    for k, v in pairs(t) do
        print(format("k: %s v: %s", k, v))
    end
end

-- function util.tbl_join(to, ...)
--     for i = 1, select("#", ...) do
--         for k, v in pairs(select(i, ...)) do
--             if util.type(k).number then
--                 to[#to + 1] = v
--             else
--                 to[k] = v
--             end
--         end
--     end
--     return to
-- end

function util.type(item)
    return {[type(item)] = 1}
end

function util.crawl(dir, call)
    for _, v in pairs(lf.getDirectoryItems(dir)) do
        local path = format("%s/%s", dir, v)
        if lf.getInfo(path, "file") then
            call(match(path, "/(%a+)%."), gsub(path, ".lua", ""))
        else
            util.crawl(path, call)
        end
    end
end

function util.memoize(f)
    return setmetatable({}, {
        __index = function(t, k)
            local v = f(k)
            t[k] = v
            return v
        end
    })
end

return util