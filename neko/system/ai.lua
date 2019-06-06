local nv = neko.vector
local ai = {
    "pos",
    "phys",
    "control",
    "target"
}
local radius = 100

function ai:update(dt)
    local delta = neko.ecs.pos[self.target.e] - nv(self.pos)
    self.control.x, self.control.y = (delta:len() > radius and delta:norm() or nv()):unpack()
end

return ai