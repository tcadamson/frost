local nv = neko.vector
local ai = {
    "pos",
    "phys",
    "steer",
    "target"
}
local radius = 35

function ai:update(dt, pos, phys, steer, target)
    local ne = neko.ecs
    local delta = ne.pos[target.e] - nv(pos)
    steer.x, steer.y = (delta:len() > radius and delta:norm() or nv()):unpack()
end

return ai