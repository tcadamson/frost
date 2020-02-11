local nu = neko.util
local nc = neko.config
local nv = neko.video
local nm = neko.mouse
local ne = neko.ecs
local nr = neko.run
local ni = neko.input

-- load here to prevent fatal loop when referencing ecs in systems
nu.crawl("neko/sys", function(path)
    ne[#ne + 1] = require(path)
end)
nc.init()
nm.init()
ni.init({
    move = {
        "n",
        "e",
        "s",
        "w"
    }
})
nv.resize(nc.video.w, nc.video.h)
nr.rate = 1 / 144
-- post-load operations
local ns = neko.state.new()
local switch = ns.switch
ns.switch = function(ns, id)
    switch(ns, ns[id])
end
neko.state = ns
nu.crawl("res/script/state", function(path, id)
    ns[id] = require(path)
end)