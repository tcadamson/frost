local cos = math.cos
local exp = math.exp
local pi = math.pi
local ne = neko.ecs
local nv = neko.vector
local nd = neko.video
local nc = neko.config
local camera = {
    pos = nv(),
    origin = nv(),
    shift = nv()
}
local v = 15
local t = 0
local amp = 0
local step = 0.04
local grow = 2
local decay = 0.99
local target

local function check(vec)
    return vec.x < 0 or vec.y < 0
end

function camera.focus(e)
    if not target then camera.pos:set(ne.pos[e]) end
    target = e
end

function camera.culled(pos, tex)
    local shift = nv(tex.sx, tex.sy)
    local net = nv(pos) - camera.origin
    return check(shift + net) or check(shift - net + nd.box)
end

function camera.shake()
    t = 0
    amp = amp + grow
end

function camera.update(dt)
    local pos = camera.pos
    local origin = camera.origin
    if amp > 0 then camera.shift:set(amp * nv(exp(-t) * cos(2 * pi * t))) end
    pos:set(pos + (nv(ne.pos[target]) - pos) * v * dt)
    origin:set(pos - (nd.box / 2):floor())
    t = t + step
    amp = amp * decay
end

return camera