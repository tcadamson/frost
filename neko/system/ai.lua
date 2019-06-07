local nv = neko.vector
local ai = {
    "pos",
    "phys",
    "control",
    "target"
}
local radius = 35

function ai:update(dt, pos, phys, control, target)
    local delta = self.pos[target.e] - nv(pos)
    control.x, control.y = (delta:len() > radius and delta:norm() or nv()):unpack()
end

return ai