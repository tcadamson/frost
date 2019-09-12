local type = type
local format = string.format
local match = string.match
local lf = love.filesystem
local util = {}
local meta = {
    grow = {
        __index = function(t, k)
            t[k] = {}
            return t[k]
        end
    }
}

function util.out(t)
    for k, v in pairs(t) do
        print(format("k: %s v: %s", k, v))
    end
end

function util.merge(t1, t2)
    for k, v in pairs(t2) do
        local mirror = t1[k]
        if type(mirror) == "table" and type(v) == "table" then
            util.merge(mirror, v)
        else
            t1[k] = v
        end
    end
end

function util.new(mt, t)
    return setmetatable(t or {}, meta[mt])
end

function util.memoize(f)
    return setmetatable({}, {
        __index = function(t, k)
            t[k] = f(k)
            return t[k]
        end
    })
end

function util.crawl(dir, call, filter)
    filter = filter or ""
    for k, v in pairs(lf.getDirectoryItems(dir)) do
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

function util.poll(down, t)
    t.pressed = not t.down and down
    t.released = not down and t.down
    t.down = down
end

return util