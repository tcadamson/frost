require("neko.init")
local lm = love.mouse
local ns = neko.state
local nl = neko.lerp
local ne = neko.ecs
local ni = neko.input
local nd = neko.video
local nx = neko.axis
local nr = neko.run
local nm = neko.mouse
local nc = neko.config
local nv = neko.vector
local na = neko.camera

function love.load()
    ns:hook()
    ns:switch("game")
    -- TODO: more sophisticated heuristic
    nr.loaded = true
    -- enable console output
    io.stdout:setvbuf("no")
end

function love.update(dt)
    nm.pos:set(nv(lm.getPosition()) / nc.video.scale)
    nm.world:set(nm.pos + na.origin)
    nx.refresh()
    nl.update(dt)
    ne.update(dt)
    na.update(dt)
    ni:update()
end

function love.resize(w, h)
    nd.resize(w, h)
end