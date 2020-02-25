local sub = string.sub
local byte = string.byte
local match = string.match
local lg = love.graphics
local nu = neko.util
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

lg.setLineStyle("rough")
lg.setDefaultFilter("nearest", "nearest")
for i = 1, #override do
    local call = override[i]
    local old = lg[call]
    lg[call] = function(hex)
        hex = type(hex) == "string" and hex or color.white
        old(rgb[hex])
    end
end

function color.rgb(hex)
    -- TODO: alternative hex formats
    return rgb[hex]
end

function color.eq(hex, ...)
    hex = rgb[hex]
    for k, v in pairs({...}) do
        if hex[k] ~= v then return false end
    end
    return true
end

return color