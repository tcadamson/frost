local lg = love.graphics
local nu = neko.util
local res = {}
local loader = {
    fnt = lg.newFont,
    png = lg.newImage
}

nu.crawl("res", function(path, id, ext)
    local loader = loader[ext]
    local item = res[id]
    -- font takes precedence over tex
    if not (item and item.hasGlyphs) and loader then res[id] = loader(path) end
end)

return res