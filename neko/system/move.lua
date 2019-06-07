local nv = neko.vector
local move = {
    "pos",
    "phys",
    "control"
}

function move:update(dt, pos, phys, control)
    pos.x, pos.y = (nv(pos) + phys.v * dt * nv(control)):unpack()
end

return move