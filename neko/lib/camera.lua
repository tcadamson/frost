local nc = neko.config
local ne = neko.ecs
local nv = neko.vector
local nu = neko.util
local nm = neko.mouse
local lg = love.graphics
local camera = {}
local pos = nv()
local size = nv()
local origin = nv()
local speed = 15
local target

function camera.focus(e)
    target = e
    pos = nv(ne.pos[e])
end

function camera.culled(pos, shift)
    local net = nv(pos) - nv(shift)
    return (net + origin) < 0 or (size - net) < 0
end

function camera.update(dt)
    if target then pos = pos + (nv(ne.pos[target]) - pos) * speed * dt end
    size = nv(nc.video.width, nc.video.height) / nc.video.scale
    origin = pos - (size / 2):floor()
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