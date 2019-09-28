local type = type
local rawget = rawget
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

function util.merge(t1, t2, diff)
    setmetatable(t1, getmetatable(t2))
    for k, v in pairs(t2) do
        local mirror = rawget(t1, k)
        if type(v) == "table" then
            if type(mirror) == "table" then
                util.merge(mirror, v, diff)
            else
                t1[k] = util.merge({}, v)
            end
        elseif diff then
            -- testing for not mirror gives false positive if mirror is false
            if mirror == nil then t1[k] = v end
        else
            t1[k] = v
        end
    end
    return t1
end

function util.new(id, t)
    return setmetatable(t or {}, meta[id])
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