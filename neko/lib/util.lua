local select = select
local type = type
local rawset = rawset
local format = string.format
local match = string.match
local gsub = string.gsub
local lf = love.filesystem
local lw = love.window
local util = {}

function util.tbl_out(t)
    for k, v in pairs(t) do
        print(format("k: %s v: %s", k, v))
    end
end

function util.tbl_copy(t)
    local out = {}
    for k, v in pairs(t) do
        out[k] = type(v) == "table" and util.tbl_copy(v) or v
    end
    return out
end

function util.type(item)
    return {[type(item)] = 1}
end

function util.crawl(dir, call, filter)
    filter = filter or ""
    for _, v in pairs(lf.getDirectoryItems(dir)) do
        local short = format("%s/%s", dir, match(v, "[^.]+"))
        local ext = match(v, "%.%w+$") or ""
        local path = short .. ext
        if lf.getInfo(path, "file") and match(ext, filter) then
            call(match(short, "/(%w+)$"), ext == ".lua" and short or path)
        else
            util.crawl(short, call, filter)
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