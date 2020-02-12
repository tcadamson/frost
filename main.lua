require("neko/init")
local le = love.event
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
        quit = function(node)
            le.quit()
        end,
        body = function(node)
            print(node.body)
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
    ne.update(dt)
    na.update(dt)
end

function love.resize(w, h)
    nd.resize(w, h)
end