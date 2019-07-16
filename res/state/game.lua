local floor = math.floor
local sin = math.sin
local lg = love.graphics
local le = love.event
local ne = neko.ecs
local ni = neko.input
local na = neko.camera
local nd = neko.video
local nv = neko.vector
local nm = neko.mouse
local nr = neko.run
local nx = neko.axis
local nt = neko.stats
local nu = neko.ui
local game = {}
local p1
local m1

local function field(x, y)
    local r = 300
    x = x or 0
    y = y or 0
    lg.setColor("#dfdfdf")
    lg.polygon("fill", x - r, y, x, y - r, x + r, y, x, y + r)
    lg.setColor()
end

function game:enter()
    self.test = 999
    for i = 0, self.test do
        ne.new({
            "pos",
            tex = {hash = "cursor:0:0:27:27:13:13"}
        })
    end
    p1 = ne.new({
        "steer",
        pos = {
            x = 0,
            y = 200
        },
        phys = {v = 100},
        tex = {hash = "test:0:0:26:26:13:13"}
    })
    m1 = ne.new({
        "steer",
        "pos",
        phys = {v = 50},
        target = {e = p1},
        tex = {hash = "test:0:0:26:26:13:13"}
    })
    na.focus(p1)
    nu.load([[
        <bar>
            <item>
                <item>...</item>
            </item>
            <item>...</item>
        </bar>
        <bar>
            <item>...</item>
        </bar>
    ]])
end

function game:update(dt)
    local steer = ne.steer[p1]
    steer.x, steer.y = ni:get("move")
    for i = 0, self.test do
        local j = i + 1
        local scale = 10
        local speed = 0.05
        local shift = 100
        ne.pos[i].x = j * scale
        ne.pos[i].y = sin(nr.tick * speed - j) * scale + shift
    end
    if ni:pressed("act") then ne.toggle(m1, "steer") end
    if ni:pressed("quit") then le.quit() end
    na.update(dt)
end

function game:draw()
    nd.push()
    lg.push()
    lg.translate((-na.origin):unpack())
    field()
    nx.draw()
    if ni:down("focus") then
        local mob = nv(ne.pos[m1])
        local delta = mob - nm.pos
        local step = 10
        for i = 0, floor(delta:len() / step) do
            local pos = nm.pos + delta:norm() * i * step
            lg.circle("fill", pos.x, pos.y, 2)
        end
    end
    lg.pop()
    nt.draw()
    nd.pop()
end

return game