local nc = neko.config
local ne = neko.ecs
local nv = neko.vector
local nu = neko.util
local nm = neko.mouse
local lg = love.graphics
local camera = {}
local pos = nv()
local v = 15
local area
local origin
local target

function camera.focus(e)
    target = e
    pos:set(nv(ne.pos[e]))
end

function camera.culled(pos, shift)
    local net = nv(pos) - nv(shift)
    return (net + origin) < 0 or (area - net) < 0
end

function camera.update(dt)
    if target then pos:set(pos + (nv(ne.pos[target]) - pos) * v * dt) end
    area = nv(nc.video.width, nc.video.height) / nc.video.scale
    origin = pos - (area / 2):floor()
    nm.pos = nm.pos + origin
end

function camera.push()
    lg.push()
    lg.translate((-origin):unpack())
end

function camera.pop()
    lg.pop()
end

return camera