local nv = neko.vector
local move = {
    "pos",
    "phys",
    "steer"
}

function move.update(e, dt)
    local pos = move.pos
    local phys = move.phys
    local steer = move.steer
    pos.x, pos.y = (nv(pos) + nv(steer) * phys.v * dt):unpack()
end

return move