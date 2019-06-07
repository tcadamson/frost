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

function draw:update(dt)
    local sheet = get[self.tex.file]
    local size = nv(self.tex.w, self.tex.h)
    if self.tex.id == 0 then
        local q = lg.newQuad(self.tex.x, self.tex.y, size.x, size.y, sheet:getTexture():getDimensions())
        self.tex.id = nd.test:add(q, 0, 0)
    end
    sheet:set(self.tex.id, self.pos.x, self.pos.y, 0, 1, 1, (size / 2):unpack())
end

return draw