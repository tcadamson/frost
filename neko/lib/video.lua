local sub = string.sub
local byte = string.byte
local match = string.match
local lg = love.graphics
local nu = neko.util
local nc = neko.config
local nv = neko.vector
local video = {}
local color = {
    black = "#000000",
    white = "#ffffff"
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

for k, v in pairs(lg) do
    -- TODO: more sophisticated heuristic
    lg[k] = k == "setColor" and function(hex)
        hex = hex or color.white
        v(rgb[hex])
    end or v
end
lg.setLineStyle("rough")
lg.setDefaultFilter("nearest", "nearest")
nu.crawl("res", function(id, path)
    video[id] = lg.newImage(path)
end, "png")

function video.area()
    return nv(canvas:getDimensions()) / nc.video.scale
end

function video.resize(w, h)
    nc.video.width = w
    nc.video.height = h
    canvas = lg.newCanvas(w, h)
end

function video.push()
    lg.setCanvas(canvas)
    lg.clear(rgb[color.white])
    lg.setBlendMode("alpha")
end

function video.pop()
    lg.setCanvas()
    lg.setColor()
    lg.setBlendMode("alpha", "premultiplied")
    lg.draw(canvas, 0, 0, 0, nc.video.scale, nc.video.scale)
end

return video