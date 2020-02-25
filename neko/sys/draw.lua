local floor = math.floor
local lg = love.graphics
local nr = neko.res
local nx = neko.axis
local nc = neko.camera
local ffi = require("ffi")
local draw = {
    "pos",
    "tex"
}

function draw.update(e, dt)
    local pos = draw.pos
    local data = nr[ffi.string(draw.tex.id)]
    local shift = (data.size / 2):floor()
    if not nc.culled(pos, shift) then
        nx.queue(floor(pos.y), lg.draw, data.tex, data.q, pos.x, pos.y, 0, 1, 1, shift:unpack())
    end
end

return draw