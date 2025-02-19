local type = type
local rawget = rawget
local format = string.format
local match = string.match
local gsub = string.gsub
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
local escape = {
    "^",
    "$",
    "(",
    ")",
    "[",
    "]",
    "%",
    ".",
    "*",
    "+",
    "-",
    "?"
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

function util.iter(t, call)
    for k, v in pairs(t) do
        if type(v) == "table" then
            util.iter(v, call)
        else
            call(t, k, v)
        end
    end
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
        local path = format("%s/%s", dir, v)
        local ext = match(v, "%w+$")
        if lf.getInfo(path, "file") and match(ext, filter) then
            call(gsub(path, ".lua", ""), match(v, "%w+"), ext)
        else
            util.crawl(path, call, filter)
        end
    end
end

function util.poll(down, t)
    t.pressed = not t.down and down
    t.released = not down and t.down
    t.down = down
end

function util.escape(str)
    for i = 1, #escape do
        str = gsub(str, "%" .. escape[i], "%%%1")
    end
    return str
end

return util