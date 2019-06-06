local nv = neko.vector
local move = {
    "pos",
    "phys",
    "control"
}

function move:update(dt)
    self.pos.x, self.pos.y = (nv(self.pos) + self.phys.v * dt * nv(self.control)):unpack()
end

return move