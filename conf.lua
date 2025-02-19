local type = type
local tonumber = tonumber
local tostring = tostring
local select = select
local format = string.format
local match = string.match
local gsub = string.gsub
local lf = love.filesystem
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
local identity = "frost"
local path = "config.ini"
local def = [[
    [video]
    fps=0
    fullscreen=0
    vsync=1
    scale=2
    display=1
    w=1280
    h=720

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

local function sync(...)
    -- first call receives t.window from love.conf
    -- subsequent calls receive values from lw.getMode
    local w, h, flags = ...
    local swap = flags and (w ~= nc.video.w or h ~= nc.video.h)
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
    return (swap or select("#", ...) == 1) and flags
end

function nc.init()
    local lw = love.window
    local lr = love.resize
    local w, h, flags = lw.getMode()
    flags = sync(w, h, flags)
    if flags then lw.setMode(nc.video.w, nc.video.h, flags) end
    neko.run.framerate = nc.video.fps > 0 and nc.video.fps
    neko.video.resize(w, h)
end

function nc.save()
    lf.write(path, clean(def, nc))
end

function love.conf(t)
    local window = sync(t.window)
    window.title = identity
    window.resizable = true
    -- lw.setMode not yet available
    window.width = window.w
    window.height = window.h
end