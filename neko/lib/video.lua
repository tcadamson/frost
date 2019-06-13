local sub = string.sub
local byte = string.byte
local find = string.find
local nu = neko.util
local nc = neko.config
local lg = love.graphics
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
    local a, b = find(hex, "^#%x+$")
    if a and (b - a) == len then
        for i = a + 1, b, 2 do
            local dec = 0
            local seg = hex:sub(i, i + 1)
            for j = 1, #seg do
                local char = sub(seg, j, j)
                local test = (byte(char) - shift)
                dec = dec + (test > 0 and test or char) * (base ^ (#seg - j))
            end
            out[#out + 1] = dec / max
        end
        return out
    end
end)

for k, v in pairs(lg) do
    -- TODO: more sophisticated heuristic
    local test = k == "clear" or k == "setColor"
    lg[k] = test and function(hex)
        hex = hex or color.white
        v(rgb[hex])
    end or v
end
lg.setLineStyle("rough")
lg.setDefaultFilter("nearest", "nearest")
nu.crawl("res", function(id, path)
    video[id] = lg.newImage(path)
end, "png")

function video.resize(w, h)
    canvas = lg.newCanvas(w, h)
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