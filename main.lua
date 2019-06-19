require("neko.init")
local ns = neko.state
local nl = neko.lerp
local ne = neko.ecs
local ni = neko.input
local nv = neko.video
local nx = neko.axis
local lw = love.window
local lt = love.timer

function love.load()
    ns:hook()
    ns:switch("game")
    -- enable console output
    io.stdout:setvbuf("no")
end

function love.update(dt)
    lw.setTitle("fps ~ " .. lt.getFPS())
    nx.refresh()
    nl.update(dt)
    ne.update(dt)
    ni:update()
end

function love.resize(w, h)
    nv.resize(w, h)
end