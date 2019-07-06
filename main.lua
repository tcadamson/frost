require("neko.init")
local lm = love.mouse
local ns = neko.state
local nl = neko.lerp
local ne = neko.ecs
local ni = neko.input
local nv = neko.video
local nx = neko.axis
local nr = neko.run
local nm = neko.mouse

function love.load()
    ns:hook()
    ns:switch("game")
    -- TODO: more sophisticated heuristic
    nr.loaded = true
    -- enable console output
    io.stdout:setvbuf("no")
end

function love.update(dt)
    nm.pos:set(lm.getPosition())
    nx.refresh()
    nl.update(dt)
    ne.update(dt)
    ni:update()
end

function love.resize(w, h)
    nv.resize(w, h)
end