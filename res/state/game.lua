local ne = neko.ecs
local ni = neko.input
local nv = neko.vector
local nc = neko.config
local na = neko.camera
local nd = neko.video
local lg = love.graphics
local game = {}

function game:enter()
    -- print("entered")
    -- if ne.pos[player].c then print("hm") end
    -- print(ffi.string(ne.pos[player].c, ))
    -- canvas = lg.newCanvas(nc.size.x, nc.size.y)
    self.player = ne.new({
        "control",
        pos = {
            x = 10,
            y = 200
        },
        phys = {v = 100}
    })
    self.mob = ne.new({
        "control",
        "pos",
        phys = {v = 25},
        target = {e = self.player}
    })
    na:focus(self.player)
    -- na:focus(self.player)
    -- nd.clear = "#ff0000"
    -- for i = 1, 10000 do
    --     ne.new({
    --         pos = {x = i}
    --         -- phys = {v = i * 2}
    --     })
    -- end
    -- print(ne.pos[20000].status)
end

function game:leave()
end

function game:update()
    -- local phys = ne.phys[player]
    -- local control = ne.control[self.player]
    -- control.x, control.y = ni:get("move")
    ne.control[self.player] = nv(ni:get("move")):table()
    if ni:pressed("act") then ne.toggle(self.mob, "control") end
end

function game:draw()
    -- local pos = nv(ni:get("move"))
    -- if test then lg.circle("fill", pos.x, pos.y, 20) end
    local pos = ne.pos[self.player]
    local mob = ne.pos[self.mob]
    nd:push()
    na:push()
    lg.setColor("#ff0000")
    -- lg.circle("fill", na.pos.x, na.pos.y, 2)
    lg.circle("line", mob.x, mob.y, 10)
    lg.setColor("#d3d3d3")
    for i = 1, 10 do
        for j = 1, 10 do
            lg.circle("line", i * 50 - 200, j * 50 - 100, 5)
        end
    end
    lg.setColor("#4d4e4f")
    lg.circle("line", pos.x, pos.y, 10)
    na:pop()
    nd:pop()
end

return game