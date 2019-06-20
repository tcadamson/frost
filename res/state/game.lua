local floor = math.floor
local lg = love.graphics
local le = love.event
local ne = neko.ecs
local ni = neko.input
local na = neko.camera
local nd = neko.video
local nv = neko.vector
local nm = neko.mouse
local nx = neko.axis
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
    p1 = ne.new({
        "steer",
        pos = {
            x = 0,
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
    m1 = ne.new({
        "steer",
        "pos",
        phys = {v = 50},
        target = {e = p1},
        tex = ne.tex[p1]
    })
    na.focus(p1)
end

function game:update(dt)
    local steer = ne.steer[p1]
    steer.x, steer.y = ni:get("move")
    if ni:pressed("act") then ne.toggle(m1, "steer") end
    if ni:pressed("quit") then le.quit() end
    na.update(dt)
end

function game:draw()
    nd.push()
    lg.push()
    lg.translate((-na.origin()):unpack())
    field()
    nx.draw()
    -- local v = na.origin()
    -- local v2 = na.origin() + nd.area()
    -- lg.circle("fill", v.x, v.y, 10)
    -- lg.circle("fill", v2.x, v2.y, 10)
    if ni:down("focus") then
        local mob = nv(ne.pos[m1])
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