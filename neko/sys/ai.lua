local max = math.max
local nv = neko.vector
local ne = neko.ecs
local ai = {
    "pos",
    "phys",
    "steer",
    "target"
}

function ai.update(e, dt)
    local pos = ai.pos
    local steer = ai.steer
    local target = ai.target
    local delta = nv()
    if target.uid >= 0 then
        local e = ne.pos[target.uid]
        target.x, target.y = e.x, e.y
    end
    delta:set(nv(target) - nv(pos))
    steer.x, steer.y = (delta:len() > max(target.radius, 1) and delta:norm() or nv()):unpack()
end

return ai