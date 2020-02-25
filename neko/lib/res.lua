local tonumber = tonumber
local match = string.match
local gmatch = string.gmatch
local gsub = string.gsub
local lf = love.filesystem
local lg = love.graphics
local li = love.image
local nu = neko.util
local ny = neko.yaml
local nv = neko.vector
local no = neko.color
local res = {}
local loader = {
    fnt = lg.newFont,
    png = function(path)
        local data = li.newImageData(path)
        data:mapPixel(function(x, y, r, g, b, a)
            return r, g, b, no.eq(no.black, r, g, b) and 0 or a
        end)
        return lg.newImage(data)
    end,
    yml = function(path)
        return ny.eval(lf.read(path))
    end
}
local qs = {
    "atlas:i1:2:2:20:20",
    "atlas:i2:24:2:20:20",
    "atlas:i3:46:2:20:20",
    "atlas:i4:68:2:20:20",
    "atlas:i5:2:24:27:27",
    "atlas:i6:2:53:26:26"
}

local q = nu.memoize(function(hash)
    local params = {}
    local to
    for str in gmatch(hash .. ":w:h", "[^:]+") do
        local tex = res[str]
        if tex then
            to = {
                w = tex:getWidth(),
                h = tex:getHeight()
            }
        end
        params[#params + 1] = to[str] or tonumber(str)
    end
    return lg.newQuad(unpack(params))
end)

nu.crawl("res", function(path, id, ext)
    local loader = loader[ext]
    local item = res[id]
    -- font takes precedence over tex
    if not (item and item.hasGlyphs) and loader then res[id] = loader(path) end
end)
-- TODO: load from file
for i = 1, #qs do
    local hash = qs[i]
    local query = ":(%w+)"
    res[match(hash, query)] = {
        q = q[gsub(hash, query, "", 1)],
        tex = res[match(hash, "%w+")],
        size = nv(match(hash, "(%d+):(%d+)$"))
    }
end

return res