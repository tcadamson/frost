local nv = neko.vector
local ne = neko.ecs
local ai = {
    "pos",
    "phys",
    "steer",
    "target"
}
local radius = 35

function ai.update(e, dt)
    local pos = ai.pos
    local steer = ai.steer
    local target = ai.target
    local delta = ne.pos[target.e] - nv(pos)
    steer.x, steer.y = (delta:len() > radius and delta:norm() or nv()):unpack()
end

return ai