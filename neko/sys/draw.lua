local unpack = unpack
local tonumber = tonumber
local floor = math.floor
local format = string.format
local gmatch = string.gmatch
local lg = love.graphics
local nv = neko.vector
local nd = neko.video
local nu = neko.util
local nx = neko.axis
local nc = neko.camera
local ffi = require("ffi")
local draw = {
    "pos",
    "tex"
}

local q = nu.memoize(function(hash)
    local params = {}
    for str in gmatch(hash, "[^:]+") do
        params[#params + 1] = tonumber(str)
    end
    return lg.newQuad(unpack(params))
end)

function draw.update(dt, pos, tex)
    local img = nd[ffi.string(tex.file)]
    local hash = format("%d:%d:%d:%d:%d:%d", tex.x, tex.y, tex.w, tex.h, img:getDimensions())
    local shift = (nv(tex.w, tex.h) / 2):floor()
    if not nc.culled(pos, shift) then
        nx.queue(floor(pos.y), lg.draw, img, q[hash], pos.x, pos.y, 0, 1, 1, shift:unpack())
    end
end

return draw