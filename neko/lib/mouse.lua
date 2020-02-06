local match = string.match
local lg = love.graphics
local lm = love.mouse
local nc = neko.config
local nv = neko.vector
local na = neko.camera
local nu = neko.util
local nr = neko.res
local queue = nu.new("grow")
local mouse = nu.new("grow", {
    pos = nv(),
    world = nv(),
    wheel = nv()
})
local order = {
    "!ui",
    "world"
}
local buttons = 3
local space

function mouse.init()
    local img = nr.cursor
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
        nu.poll(lm.isDown(i), mouse["m" .. i])
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
    space = to or order[#order]
end

function love.wheelmoved(x, y)
    local wheel = mouse.wheel
    wheel:set(wheel + nv(x, y))
end

mouse.space()
return mouse