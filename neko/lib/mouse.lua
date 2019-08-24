local match = string.match
local lg = love.graphics
local lm = love.mouse
local nc = neko.config
local nv = neko.vector
local nd = neko.video
local na = neko.camera
local meta = {
    __index = function(t, k)
        t[k] = {}
        return t[k]
    end
}
local queue = setmetatable({}, meta)
local mouse = setmetatable({
    pos = nv(),
    world = nv(),
    wheel = nv()
}, meta)
local order = {
    "!ui",
    "world"
}
local buttons = 3
local space

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
    local abort
    pos:set(nv(lm.getPosition()) / nc.video.scale)
    mouse.world:set(pos + na.origin)
    for i = 1, buttons do
        local b = mouse["m" .. i]
        local down = lm.isDown(i)
        b.pressed = not b.down and down
        b.released = not down and b.down
        b.down = down
    end
    for i = 1, #order do
        local order = order[i]
        local queue = queue[match(order, "%w+")]
        local call = queue[#queue]
        for j = 1, #queue do
            queue[j] = nil
        end
        if call and not abort then
            abort = match(order, "!")
            call()
        end
    end
end

function mouse.queue(f)
    local queue = queue[space]
    queue[#queue + 1] = f
end

function mouse.space(to)
    to = to or "world"
    space = to
end

function love.wheelmoved(x, y)
    local wheel = mouse.wheel
    wheel:set(wheel + nv(x, y))
end

return mouse