local nc = neko.config
local nv = neko.vector
local nd = neko.video
local na = neko.camera
local lg = love.graphics
local lm = love.mouse
local mouse = {}

function mouse:init()
    local img = nd.cursor
    local canvas = lg.newCanvas(img:getDimensions() * nc.video.scale)
    canvas:renderTo(function()
        lg.draw(img, 0, 0, 0, nc.video.scale, nc.video.scale)
    end)
    lm.setCursor(lm.newCursor(canvas:newImageData()))
end

function mouse:update()
    self.pos = (nv(lm.getPosition()) / nc.video.scale) + (na.origin or nv())
end

return mouse