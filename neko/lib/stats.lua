local lt = love.timer
local lg = love.graphics
local stats = {}
-- TODO: centralized font system
local font = lg.newFont()

function stats.draw()
    local fps = "fps ~ " .. lt.getFPS()
    lg.setColor("#6a6a6a")
    lg.rectangle("fill", 0, 0, font:getWidth(fps), font:getHeight(fps))
    lg.setColor()
    lg.print(fps)
end

return stats