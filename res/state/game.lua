local floor = math.floor
local ne = neko.ecs
local ni = neko.input
local na = neko.camera
local nd = neko.video
local nv = neko.vector
local nm = neko.mouse
local lg = love.graphics
local game = {}

local function field(x, y)
    local r = 300
    x = x or 0
    y = y or 0
    lg.setColor("#dfdfdf")
    lg.polygon("fill", x - r, y, x, y - r, x + r, y, x, y + r)
end

function game:enter()
    self.player = ne.new({
        "steer",
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
        "steer",
        "pos",
        phys = {v = 50},
        target = {e = self.player},
        tex = ne.tex[self.player]
    })
    na:focus(self.player)
end

function game:update(dt)
    local steer = ne.steer[self.player]
    steer.x, steer.y = ni:get("move")
    if ni:pressed("act") then ne.toggle(self.mob, "steer") end
    na:update(dt)
end

function game:draw()
    nd:push()
    na:push()
    field(0, 200)
    lg.setColor()
    lg.draw(nd.test)
    if ni:down("focus") then
        local mob = nv(ne.pos[self.mob])
        local delta = mob - nm.pos
        local step = 10
        for i = 0, floor(delta:len() / step) do
            local pos = nm.pos + delta:norm() * i * step
            lg.circle("fill", pos.x, pos.y, 2)
        end
    end
    na:pop()
    nd:pop()
end

return game