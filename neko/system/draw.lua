local nv = neko.vector
local nd = neko.video
local nu = neko.util
local lg = love.graphics
local draw = {
    "pos",
    "tex"
}
local ffi = require("ffi")

local get = nu.memoize(function(file)
    return nd[ffi.string(file)]
end)

function draw:update(dt, pos, tex)
    local sheet = get[tex.file]
    local size = nv(tex.w, tex.h)
    if tex.id == 0 then
        local q = lg.newQuad(tex.x, tex.y, size.x, size.y, sheet:getTexture():getDimensions())
        tex.id = sheet:add(q, 0, 0)
    end
    sheet:set(tex.id, pos.x, pos.y, 0, 1, 1, (size / 2):unpack())
end

return draw