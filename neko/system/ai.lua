local nv = neko.vector
local ai = {
    "pos",
    "phys",
    "control",
    "target"
}
local radius = 100

function ai:update(dt)
    -- print(hm[ffi.string(self.behavior.id)])
    local delta = neko.ecs.pos[self.target.e] - nv(self.pos)
    delta = delta:len() > radius and delta:norm() or nv()
    self.control.x, self.control.y = delta:unpack()
end

return ai