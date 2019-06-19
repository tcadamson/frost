local ne = neko.ecs
local nv = neko.vector
local nd = neko.video
local camera = {}
local pos = nv()
local v = 15
local target

function camera.focus(e)
    target = e
    pos:set(nv(ne.pos[e]))
end

function camera.culled(pos, shift)
    local net = nv(pos) - nv(shift)
    return (net + origin) < 0 or (nd.area() - net) < 0
end

function camera.update(dt)
    if target then pos:set(pos + (nv(ne.pos[target]) - pos) * v * dt) end
end

function camera.origin()
    return pos - (nd.area() / 2):floor()
end

return camera