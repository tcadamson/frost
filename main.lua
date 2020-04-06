require("neko/init")
local ns = neko.state
local nl = neko.lerp
local ne = neko.ecs
local ni = neko.input
local nd = neko.video
local nx = neko.axis
local nr = neko.run
local nm = neko.mouse
local na = neko.camera
local nu = neko.ui

function love.load()
    ns:hook()
    ns:switch("game")
    nu.load("ui")
    nu.bind({
        stats = function(node)
            print(nu[1].body)
        end
    })
    -- TODO: more sophisticated heuristic
    nr.loaded = true
    -- enable console output
    io.stdout:setvbuf("no")
end

function love.update(dt)
    nx.refresh()
    nm.update(dt)
    ni.update(dt)
    nu.update(dt)
    nl.update(dt)
    na.update(dt)
    ne.update(dt)
end

function love.resize(w, h)
    nd.resize(w, h)
end