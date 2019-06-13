local unpack = unpack
local tonumber = tonumber
local floor = math.floor
local format = string.format
local gmatch = string.gmatch
local nv = neko.vector
local nd = neko.video
local nu = neko.util
local nx = neko.axis
local lg = love.graphics
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

function draw:update(dt, pos, tex)
    local file = ffi.string(tex.file)
    local atlas = nd[file]
    local hash = format("%s:%d:%d:%d:%d:%d:%d", file, tex.x, tex.y, tex.w, tex.h, atlas:getDimensions())
    local shift = (nv(tex.w, tex.h) / 2):floor()
    nx.queue(floor(pos.y), lg.draw, atlas, q[hash], pos.x, pos.y, 0, 1, 1, shift:unpack())
end

return draw