local nv = neko.vector
local move = {
    "pos",
    "phys",
    "control"
}

function move:update(dt)
    -- print(e)
    -- local pos = com.pos[e]
    -- local phys = com.phys[e]
    -- -- print(e)
    -- -- if pos.x == 1000 then print(phys.v) end
    -- local ug = pos.x * phys.v
    -- print(e)
    -- print(pos.x)
    -- local gain = self.phys.v * dt
    -- self.pos.x = self.pos.x + gain * self.control.x
    -- self.pos.y = self.pos.y + gain * self.control.y
    self.pos.x, self.pos.y = (nv(self.pos) + self.phys.v * dt * nv(self.control)):unpack()
    -- self.pos = {x = 0, y = 0}
end

return move