local sub = string.sub
local byte = string.byte
local match = string.match
local lg = love.graphics
local nu = neko.util
local nc = neko.config
local nv = neko.vector
local video = {
    box = nv()
}
local color = {
    black = "#000000",
    white = "#ffffff"
}
local override = {
    "setColor",
    "clear"
}
local base = 16
local len = 6
local shift = 87
local max = 255
local canvas

local rgb = nu.memoize(function(hex)
    local out = {}
    local valid = match(hex, "^#-(%x+)$")
    if valid and #valid == len then
        for i = 1, len, 2 do
            local dec = 0
            local seg = valid:sub(i, i + 1)
            for j = 1, #seg do
                local char = sub(seg, j, j)
                local test = (byte(char) - shift)
                dec = dec + (test > 0 and test or char) * (base ^ (#seg - j))
            end
            out[#out + 1] = dec / max
        end
        return out
    else
        error(hex .. ": invalid hex")
    end
end)

for i = 1, #override do
    local call = override[i]
    local old = lg[call]
    lg[call] = function(hex)
        hex = type(hex) == "string" and hex or color.white
        old(rgb[hex])
    end
end
lg.setLineStyle("rough")
lg.setDefaultFilter("nearest", "nearest")
nu.crawl("res", function(id, path)
    video[id] = lg.newImage(path)
end, "png")

function video.resize(w, h)
    local box = nv(w, h) / nc.video.scale
    nc.video.width = w
    nc.video.height = h
    canvas = lg.newCanvas(w, h)
    video.box:set(box)
    -- ui depends on mouse which depends on video
    -- if we require ui at the file level, we get a fatal loop
    neko.ui.box:set(box)
end

function video.push()
    lg.setCanvas(canvas)
    lg.clear()
    lg.setBlendMode("alpha")
end

function video.pop()
    lg.setCanvas()
    lg.setColor()
    lg.setBlendMode("alpha", "premultiplied")
    lg.draw(canvas, 0, 0, 0, nc.video.scale, nc.video.scale)
end

return video