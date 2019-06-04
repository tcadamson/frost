local nu = neko.util
local nc = neko.config
local nv = neko.video
local lg = love.graphics
local lm = love.mouse

local function convert(controls)
    for k, v in pairs(controls) do
        controls[k] = {"key:" .. v}
    end
    return controls
end

lg.setDefaultFilter("nearest", "nearest")

-- cursor
-- local img = lg.newImage("res/cursor.png")
-- local canvas = lg.newCanvas(img:getDimensions() * 2)
-- canvas:renderTo(function()
--     lg.draw(img, 0, 0, 0, nc.video.scale, nc.video.scale)
-- end)
-- local data = canvas:newImageData()
-- data:mapPixel(function(x, y, r, g, b, a)
--     return r, g, b, (r + g + b > 0) and a or 0
-- end)
-- lm.setCursor(lm.newCursor(data))
-- cursor

nu.crawl("neko/lib", function(id, path)
    neko[id] = require(path)
end)
nc.apply()
nv:resize(nc.video.width, nc.video.height)
-- post-load operations
local ns = neko.state.new()
local ni = neko.input.new({
    controls = convert(nc.controls),
    pairs = {
        move = {
            "w",
            "e",
            "n",
            "s"
        }
    }
})
-- nc:apply()
-- neko.config = nc
neko.state = ns
neko.input = ni
nu.crawl("res/state", function(id, path)
    ns[id] = require(path)
end)
local switch = ns.switch
function ns:switch(id)
    switch(self, self[id])
end