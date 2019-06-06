local nc = neko.config
local ne = neko.ecs
local nv = neko.vector
local nu = neko.util
local lg = love.graphics
local camera = {}

function camera:focus(e)
    self.target = e
    self.pos = nv(ne.pos[e])
    self.speed = 10
end

function camera:update(dt)
    self.pos = self.pos + ((nv(ne.pos[self.target]) - self.pos) * self.speed * dt)
end

function camera:push()
    local v = nc.video
    local shift = nv(v.width, v.height) / (v.scale * 2)
    lg.push()
    lg.translate((-self.pos + shift):unpack())
end

function camera:pop()
    lg.pop()
end

return camera