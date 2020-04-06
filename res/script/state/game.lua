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

local function draw()
    lg.push()
    lg.translate((na.shift - na.pos):unpack())
    nx.draw()
    if ni.focus.down then
        local mob = nv(ne.pos[m1])
        local delta = mob - nm.world
        local step = 10
        for i = 0, floor(delta:len() / step) do
            local pos = nm.world + delta:norm() * i * step
            lg.circle("fill", pos.x, pos.y, 2)
        end
    end
    lg.pop()
end

function game:enter()
    p1 = ne.new("p1", {
        pos = {},
        target = {status = 0}
    })
    m1 = ne.new("m1", {
        target = {uid = p1}
    })
    m2 = ne.new({
        pos = {
            x = 70,
            y = -100
        },
        tex = {id = "i9"}
    })
    na.focus(p1)
end

function game:update(dt)
    local steer = ne.steer[p1]
    local target = ne.target[p1]
    steer.x, steer.y = ni.move:unpack()
    if nv(steer):len() > 0 then
        ne.off(p1, "target")
    elseif nm.m1.pressed then
        nm.queue(function()
            ne.on(p1, "target")
            target.x, target.y = nm.world:unpack()
        end)
    end
    if ni.act.pressed then
        na.shake()
        ne.toggle(m1, "steer")
    end
    if ni.quit.pressed then le.quit() end
end

function game:draw()
    nd.draw(draw)
end

return game