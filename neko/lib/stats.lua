local loadstring = loadstring
local format = string.format
local match = string.match
local find = string.find
local concat = table.concat
local lg = love.graphics
local nr = neko.run
local nv = neko.vector
local stats = {}
local items = {
    "fps",
    "draw",
    "!mem:%.2f mb"
}
local calls = {
    "lt.getFPS()",
    "lg.getStats().drawcalls",
    "collectgarbage(\"count\") / kb"
}
local step = 50
-- TODO: centralized font system
local font = lg.newFont()

local function fetch()
    for i = 1, #items do
        local item = items[i]
        local id = match(item, "%w+")
        local token = match(item, ":(.+)") or "%d"
        if not stats[i] or not find(item, "!") or nr.tick % step == 0 then
            stats[i] = format("%s ~ " .. token, id, calls[i]())
        end
    end
    return concat(stats, " / ")
end

for i = 1, #calls do
    calls[i] = loadstring(format([[
        local lg = love.graphics
        local lt = love.timer
        local kb = 1024
        return function()
            return %s
        end
    ]], calls[i]))()
end

function stats.draw()
    local out = fetch()
    local box = nv(font:getWidth(out), font:getHeight(out))
    lg.setColor("#6a6a6a")
    lg.rectangle("fill", 0, 0, box:unpack())
    lg.setColor()
    lg.print(out)
end

return stats