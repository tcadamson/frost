local ne = neko.ecs
local nv = neko.vector
local nd = neko.video
local camera = {
    pos = nv(),
    origin = nv()
}
local v = 15
local target

function camera.focus(e)
    if not target then camera.pos:set(nv(ne.pos[e])) end
    target = e
end

function camera.culled(pos, tex)
    local shift = nv(tex.sx, tex.sy)
    local net = nv(pos) - camera.origin
    return (shift + net) < 0 or (shift - net + nd.area) < 0
end

function camera.update(dt)
    local pos = camera.pos
    camera.origin:set(pos - (nd.area / 2):floor())
    pos:set(pos + (nv(ne.pos[target]) - pos) * v * dt)
end

return camera