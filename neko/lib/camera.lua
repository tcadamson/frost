local ne = neko.ecs
local nv = neko.vector
local nd = neko.video
local camera = {}
local pos = nv()
local v = 15
local target

function camera.focus(e)
    if not target then pos:set(nv(ne.pos[e])) end
    target = e
end

function camera.culled(pos, shift)
    local net = nv(pos) - nv(shift)
    return (net + camera.origin()) < 0 or (nd.area() - net) < 0
end

function camera.update(dt)
    pos:set(pos + (nv(ne.pos[target]) - pos) * v * dt)
end

function camera.origin()
    return pos - (nd.area() / 2):floor()
end

return camera