local ne = neko.ecs
local ni = neko.input
local na = neko.camera
local nd = neko.video
local lg = love.graphics
local game = {}

local function field(x, y)
    local r = 300
    x = x or 0
    y = y or 0
    lg.setColor("#e7e7e7")
    lg.polygon("fill", x - r, y, x, y - r, x + r, y, x, y + r)
end

function game:enter()
    self.player = ne.new({
        "control",
        pos = {
            x = 10,
            y = 200
        },
        phys = {v = 100},
        tex = {
            file = "test",
            x = 0,
            y = 0,
            w = 26,
            h = 26
        }
    })
    self.mob = ne.new({
        "control",
        "pos",
        phys = {v = 50},
        target = {e = self.player},
        tex = ne.tex[self.player]
    })
    na:focus(self.mob)
end

function game:leave()
end

function game:update(dt)
    local control = ne.control[self.player]
    control.x, control.y = ni:get("move")
    na:update(dt)
    if ni:pressed("act") then ne.toggle(self.mob, "control") end
end

function game:draw()
    nd:push()
    na:push()
    field(0, 200)
    lg.setColor()
    lg.draw(nd.test)
    na:pop()
    nd:pop()
end

return game