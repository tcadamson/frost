local unpack = unpack
local tonumber = tonumber
local floor = math.floor
local gmatch = string.gmatch
local gsub = string.gsub
local lg = love.graphics
local nu = neko.util
local nr = neko.res
local nx = neko.axis
local nc = neko.camera
local ffi = require("ffi")
local draw = {
    "pos",
    "tex"
}

local q = nu.memoize(function(hash)
    local params = {}
    local to
    for str in gmatch(gsub(hash, "%d+:%d+$", "fw:fh"), "[^:]+") do
        local img = nr[str]
        if img then
            to = {
                fw = img:getWidth(),
                fh = img:getHeight()
            }
        end
        params[#params + 1] = to[str] or tonumber(str)
    end
    return lg.newQuad(unpack(params))
end)

function draw.update(e, dt)
    local pos = draw.pos
    local tex = draw.tex
    if not nc.culled(pos, tex) then
        local f = nr[ffi.string(tex.file)]
        local q = q[ffi.string(tex.hash)]
        nx.queue(floor(pos.y), lg.draw, f, q, pos.x, pos.y, 0, 1, 1, tex.sx, tex.sy)
    end
end

return draw