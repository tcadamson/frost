require("neko.init")
local ns = neko.state
local nl = neko.lerp
local ne = neko.ecs
local ni = neko.input
local nc = neko.config
local nv = neko.video
local lw = love.window
local lt = love.timer
local le = love.event

function love.load()
    ns:hook()
    ns:switch("game")
    -- enable console output
    io.stdout:setvbuf("no")
end

function love.update(dt)
    lw.setTitle("fps ~ " .. lt.getFPS())
    nl.update(dt)
    ne.update(dt)
    ni:update()
    if ni:pressed("quit") then le.quit() end
end

function love.resize(w, h)
    nc.video.width = w
    nc.video.height = h
    nv:resize(w, h)
end