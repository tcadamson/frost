local type = type
local tonumber = tonumber
local tostring = tostring
local format = string.format
local match = string.match
local gmatch = string.gmatch
local gsub = string.gsub
local lf = love.filesystem
local lg = love.graphics
neko = setmetatable({
    config = {}
}, {
    -- remove need for manual lib loading in init
    __index = function(t, k)
        local path = format("neko/lib/%s.lua", k)
        local dir = lf.getInfo(path) and "" or "/import"
        t[k] = require(gsub(path, "(/%w+)%..+$", dir .. "%1"))
        return t[k]
    end
})
local nu = neko.util
local nc = nu.new("grow", neko.config)
local identity = "neko"
local path = "config.ini"
local def = [[
    [video]
    fps=144
    fullscreen=0
    vsync=0
    scale=2
    display=1
    width=1280
    height=720

    [controls]
    quit=q
    act=e
    focus=lctrl
    n=w
    e=d
    s=s
    w=a
]]

local function clean(str, override)
    local cat
    return match(gsub(str, "[^%c]+", function(seg)
        local k = match(seg, "(%w+)=")
        if k and override then
            return format(k .. "=%s", override[cat][k])
        else
            cat = match(seg, "%[(%a+)%]")
            return gsub(seg, "^%s+", "")
        end
    end), "(.+)%s+$")
end

local function sync(w, h, flags)
    -- first call receives t.window from love.conf
    -- subsequent calls receive values from lw.getMode()
    local swap = flags and (w ~= nc.video.width or h ~= nc.video.height)
    if not flags then
        local cat
        lf.setIdentity(identity)
        if not lf.getInfo(path) then lf.write(path, clean(def)) end
        for line in lf.lines(path) do
            if line ~= "" and not match(line, "^%s*;.*$") then
                local test = match(line, "%[%s*(.*)%s*%]")
                if test then
                    cat = test
                else
                    local k, v = match(line, "^%s*(.*)%s*=%s*(.+)%s*$")
                    if k and v then nc[cat][k] = tonumber(v) or v end
                end
            end
        end
        flags = nu.merge(w, nc.video, true)
    end
    for k, v in pairs(flags) do
        local old = v
        local new = nc.video[k]
        if new then
            if type(old) == "boolean" then new = new == 1 end
            swap = swap or old ~= new
            flags[k] = new
        end
    end
    return (swap or not lg) and flags
end

function love.conf(t)
    local w = sync(t.window)
    w.title = identity
    w.resizable = true
    w.icon = nil
    setmetatable(nc, {
        __index = {
            init = function()
                local lw = love.window
                local lr = love.resize
                local flags = sync(lw.getMode())
                if flags then
                    lw.setMode(nc.video.width, nc.video.height, flags)
                    -- lw.setMode doesn't trigger the resize call
                    -- lr not available in fullscreen
                    if lr then lr(lw.getMode()) end
                end
                neko.run.framerate = nc.video.fps > 0 and nc.video.fps
            end,
            save = function()
                lf.write(path, tostring(nc))
            end
        },
        __tostring = function(t)
            return clean(def, t)
        end
    })
end