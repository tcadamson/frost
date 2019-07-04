local unpack = unpack
local tonumber = tonumber
local floor = math.floor
local gmatch = string.gmatch
local lg = love.graphics
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
        params[#params + 1] = tonumber(str) or str
    end
    local img = nd[table.remove(params, 1)]
    params[#params - 1] = img:getWidth()
    params[#params] = img:getHeight()
    return {
        img = img,
        q = lg.newQuad(unpack(params))
    }
end)

function draw.update(dt, pos, tex)
    if not nc.culled(pos, tex) then
        local data = q[ffi.string(tex.hash)]
        nx.queue(floor(pos.y), lg.draw, data.img, data.q, pos.x, pos.y, 0, 1, 1, tex.sx, tex.sy)
    end
end

return draw