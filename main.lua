require("neko.init")
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
    nu.load([[
        <box>
            <text click:body>%stats.fetch</text>
            <text class:(c1,c2)>
                test
                <text class:c4>
                    top
                    <text click:body>bottom</text>
                </text>
                <text>
                    inquisition
                    <text>hm</text>
                </text>
            </text>
        </box>
        <text pin:c(0,1) click:quit>quit</text>
        <box pin:c(0.5,1) class:(c2,c3)>
            <text>one</text>
            <text>two</text>
            <text>three</text>
        </box>
    ]])
    nu.style([[
        text {
            bg:#6a6a6a
            pad:5
            margin:5
            %hover
                bg:#ff0000
            %hover
            %click
                bg:#ffffff
                color:#000000
            %click
        }
        %c1 {
            frame:(0.5,1)
            margin:(5,0)
        }
        %c2 {
            edge:#000000(5)
            %hover
                bg:#0000ff
                edge:#00ff00(5)
            %hover
        }
        %c3 {
            bg:#6a6a6a
            pad:5
            margin:5
            dir:x
        }
        %c4 {
            frame:(0.7)
            edge:#000000(5)
        }
    ]])
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