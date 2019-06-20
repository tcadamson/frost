local nv = neko.vector
local move = {
    "pos",
    "phys",
    "steer"
}

function move.update(dt, pos, phys, steer)
    pos.x, pos.y = (nv(pos) + phys.v * dt * nv(steer)):unpack()
end

return move