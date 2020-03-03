local lg = love.graphics
local nu = neko.util
local nc = neko.config
local nv = neko.vector
local video = {
    box = nv(),
    shift = nv()
}
local canvas

function video.resize(w, h)
    local box = video.box
    local shift = video.shift
    shift:set(w % 2, h % 2)
    box:set((nv(w, h) + shift) / nc.video.scale)
    nc.video.w = box.x
    nc.video.h = box.y
    canvas = lg.newCanvas(box:unpack())
    -- ui depends on mouse which depends on video
    -- if we require ui at the file level, we get a fatal loop
    neko.ui.box:set(box)
end

function video.draw(draw)
    lg.setCanvas(canvas)
    lg.clear()
    if draw then draw() end
    neko.ui.draw()
    lg.setCanvas()
    lg.setColor()
    lg.setBlendMode("alpha", "premultiplied")
    lg.draw(canvas, 0, 0, 0, nc.video.scale, nc.video.scale)
    lg.setBlendMode("alpha")
    -- store stats before they are reset at the end of draw
    nu.merge(video, lg.getStats())
end

return video