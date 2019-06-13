local floor = math.floor
local nv = neko.vector
local nd = neko.video
local nu = neko.util
local nx = neko.axis
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
    -- local sheet = get[tex.file]
    -- local size = nv(tex.w, tex.h)
    -- if tex.id == 0 then
    --     local q = lg.newQuad(tex.x, tex.y, size.x, size.y, sheet:getTexture():getDimensions())
    --     tex.id = sheet:add(q, 0, 0)
    -- end
    -- sheet:set(tex.id, pos.x, pos.y, 0, 1, 1, (size / 2):unpack())
    -- for i = 1, ffi.len(tex.file) do print(tex.file[i]) end
    local shift = (nv(tex.w, tex.h) / 2):floor()
    nx.queue(floor(pos.y), lg.draw, nd[ffi.string(tex.file)], pos.x, pos.y, 0, 1, 1, shift:unpack())
    -- nl:queue(z, {
    --     f = nd[ffi.string(tex.file)],
    --     pos = pos
    -- })
    -- neko.list:test(self.e, {
    --     f = nd[ffi.string(tex.file)],
    --     pos = pos
    -- })
end

return draw