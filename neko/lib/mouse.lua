local lg = love.graphics
local lm = love.mouse
local nc = neko.config
local nv = neko.vector
local nd = neko.video
local na = neko.camera
local mouse = setmetatable({
    pos = nv(),
    world = nv(),
    wheel = nv()
}, {
    __index = function(t, k)
        t[k] = {}
        return t[k]
    end
})
local buttons = 3

function mouse.init()
    local img = nd.cursor
    local canvas = lg.newCanvas(img:getDimensions() * nc.video.scale)
    canvas:renderTo(function()
        lg.draw(img, 0, 0, 0, nc.video.scale, nc.video.scale)
    end)
    lm.setCursor(lm.newCursor(canvas:newImageData()))
end

function mouse.update(dt)
    local pos = mouse.pos
    pos:set(nv(lm.getPosition()) / nc.video.scale)
    mouse.world:set(pos + na.origin)
    for i = 1, buttons do
        local b = mouse["m" .. i]
        local down = lm.isDown(i)
        b.pressed = not b.down and down
        b.released = not down and b.down
        b.down = down
    end
end

function love.wheelmoved(x, y)
    local wheel = mouse.wheel
    wheel:set(wheel + nv(x, y))
end

return mouse