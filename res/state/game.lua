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
local nu = neko.ui
local game = {}
local tests = 999
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
    for i = 0, tests do
        ne.new("m2")
    end
    p1 = ne.new("p1", {
        pos = {
            x = 0,
            y = 200
        },
        target = {status = 0}
    })
    m1 = ne.new("m1", {
        target = {uid = p1}
    })
    na.focus(p1)
    nu.load([[
        <text>
            [ui test]
            <text class:c1>
                %stats.fetch
                <text>
                    top
                    <text>bottom</text>
                </text>
            </text>
        </text>
        <text pin:c(0,0.5)>under</text>
    ]])
    nu.style([[
        text {
            bg:#6a6a6a
            %hover
                bg:#ff0000
            %hover
            %click
                color:#000000
                bg:#ffffff
            %click
        }
        %c1 {
            dir:x
        }
    ]])
end

function game:update(dt)
    local steer = ne.steer[p1]
    local target = ne.target[p1]
    steer.x, steer.y = ni:get("move")
    if nv(steer):len() > 0 then
        ne.off(p1, "target")
    elseif nm.m1.pressed then
        nm.queue(function()
            ne.on(p1, "target")
            target.x, target.y = nm.world:unpack()
        end)
    end
    for i = 0, tests do
        local j = i + 1
        local scale = 10
        local speed = 0.05
        local shift = 100
        ne.pos[i].x = j * scale
        ne.pos[i].y = sin(nr.tick * speed - j) * scale + shift
    end
    if ni:pressed("act") then
        na.shake()
        ne.toggle(m1, "steer")
    end
    if ni:pressed("quit") then le.quit() end
end

function game:draw()
    nd.push()
    lg.push()
    lg.translate((na.shift - na.origin):unpack())
    field()
    nx.draw()
    if ni:down("focus") then
        local mob = nv(ne.pos[m1])
        local delta = mob - nm.world
        local step = 10
        for i = 0, floor(delta:len() / step) do
            local pos = nm.world + delta:norm() * i * step
            lg.circle("fill", pos.x, pos.y, 2)
        end
    end
    lg.pop()
    nu.draw()
    nd.pop()
end

return game