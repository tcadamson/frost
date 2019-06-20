local nu = neko.util
local nc = neko.config
local nv = neko.video
local nm = neko.mouse
local ne = neko.ecs

local function convert(controls)
    for k, v in pairs(controls) do
        controls[k] = {"key:" .. v}
    end
    return controls
end

nu.crawl("neko/sys", function(id, path)
    local sys = require(path)
    sys.buf = {}
    ne[#ne + 1] = sys
end)
nc.init()
nm.init()
nv.resize(nc.video.width, nc.video.height)
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
local switch = ns.switch
ns.switch = function(ns, id)
    switch(ns, ns[id])
end
neko.state = ns
neko.input = ni
nu.crawl("res/state", function(id, path)
    ns[id] = require(path)
end)