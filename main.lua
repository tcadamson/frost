require("neko.init")
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
    -- TODO: more sophisticated heuristic
    nr.loaded = true
    -- enable console output
    io.stdout:setvbuf("no")
end

function love.update(dt)
    nx.refresh()
    nm.update(dt)
    nu.update(dt)
    nl.update(dt)
    ne.update(dt)
    na.update(dt)
    ni:update()
end

function love.resize(w, h)
    nd.resize(w, h)
end