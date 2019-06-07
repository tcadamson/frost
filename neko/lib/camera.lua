local nc = neko.config
local ne = neko.ecs
local nv = neko.vector
local nu = neko.util
local lg = love.graphics
local camera = {
    speed = 15
}

function camera:focus(e)
    self.target = e
    if not self.pos then self.pos = nv(ne.pos[e]) end
end

function camera:update(dt)
    local shift = nv(nc.video.width, nc.video.height) / (nc.video.scale * 2)
    self.pos = self.pos + (nv(ne.pos[self.target]) - self.pos) * self.speed * dt
    self.origin = self.pos - shift
end

function camera:push()
    lg.push()
    lg.translate((-self.origin):unpack())
end

function camera:pop()
    lg.pop()
end

return camera