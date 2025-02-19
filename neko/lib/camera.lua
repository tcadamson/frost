local cos = math.cos
local exp = math.exp
local pi = math.pi
local ne = neko.ecs
local nv = neko.vector
local nd = neko.video
local camera = {
    pos = nv(),
    shift = nv()
}
local v = 15
local t = 0
local amp = 0
local step = 0.04
local grow = 2
local decay = 0.99
local epsilon = 0.1
local target

local function check(vec)
    return vec.x < 0 or vec.y < 0
end

local function delta(e)
    local ds = nv(ne.pos[e]) - camera.pos - (nd.box / 2):floor()
    return nv(ds:len() > epsilon and ds)
end

function camera.focus(e)
    if not target then
        local pos = camera.pos
        pos:set(pos + delta(e))
    end
    target = e
end

function camera.culled(pos, shift)
    local net = nv(pos) - camera.pos
    return check(shift + net) or check(shift - net + nd.box)
end

function camera.shake()
    t = 0
    amp = amp + grow
end

function camera.update(dt)
    local pos = camera.pos
    camera.shift:set(amp > epsilon and amp * nv(exp(-t) * cos(2 * pi * t)))
    pos:set(pos + delta(target) * v * dt)
    t = t + step
    amp = amp * decay
end

return camera