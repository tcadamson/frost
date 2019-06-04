local nc = neko.config
local ne = neko.ecs
local nv = neko.vector
local lg = love.graphics
local camera = {}

function camera:focus(e)
    self.focus = e
end

function camera:push()
    self.pos = nv(ne.pos[self.focus]) - nv(nc.video.width, nc.video.height) / (nc.video.scale * 2)
    lg.push()
    lg.translate((-self.pos):unpack())
end

function camera:pop()
    lg.pop()
end

return camera

-- lg.setCanvas(canvas)
-- lg.clear("#ffffff")
-- lg.setBlendMode("alpha")
-- lg.push()
-- lg.translate(nc.size.x / (nc.video.scale * 2) - pos.x, nc.size.y / (nc.video.scale * 2) - pos.y)
-- ---------
-- lg.setColor("#d3d3d3")
-- for i = 1, 10 do
--     for j = 1, 10 do
--         lg.circle("line", i * 50 - 200, j * 50 - 100, 5)
--     end
-- end
-- lg.setColor("#4d4e4f")
-- lg.circle("line", pos.x, pos.y, 10)
-- ---------
-- lg.pop()
-- lg.setCanvas()
-- lg.setColor("#ffffff")
-- lg.setBlendMode("alpha", "premultiplied")
-- lg.draw(canvas, 0, 0, 0, nc.video.scale, nc.video.scale)