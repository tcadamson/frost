local floor = math.floor
local sin = math.sin
local ne = neko.ecs
local ni = neko.input
local na = neko.camera
local nd = neko.video
local nv = neko.vector
local nm = neko.mouse
local nr = neko.run
local nx = neko.axis
local lg = love.graphics
local le = love.event
local game = {}

local function field(x, y)
    local r = 300
    x = x or 0
    y = y or 0
    lg.setColor("#dfdfdf")
    lg.polygon("fill", x - r, y, x, y - r, x + r, y, x, y + r)
    lg.setColor()
end

function game:enter()
    self.test = 199
    for i = 0, self.test do
        ne.new({
            "pos",
            tex = {
                file = "cursor",
                x = 0,
                y = 0,
                w = 27,
                h = 27
            }
        })
    end
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
    na.focus(self.player)
end

function game:update(dt)
    local steer = ne.steer[self.player]
    steer.x, steer.y = ni:get("move")
    for i = 0, self.test do
        local j = i + 1
        local scale = 10
        local speed = 0.05
        local shift = 100
        ne.pos[i].x = j * scale
        ne.pos[i].y = sin(nr.tick * speed - j) * scale + shift
    end
    if ni:pressed("act") then ne.toggle(self.mob, "steer") end
    if ni:pressed("quit") then le.quit() end
    na.update(dt)
end

function game:draw()
    nd.push()
    lg.push()
    lg.translate((-na.origin()):unpack())
    field(0, 200)
    nx.draw()
    if ni:down("focus") then
        local mob = nv(ne.pos[self.mob])
        local delta = mob - nm.pos()
        local step = 10
        for i = 0, floor(delta:len() / step) do
            local pos = nm.pos() + delta:norm() * i * step
            lg.circle("fill", pos.x, pos.y, 2)
        end
    end
    lg.pop()
    nd.pop()
end

return game