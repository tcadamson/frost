neko = setmetatable({
    config = {
        video = {
            fps = 144,
            fullscreen = 0,
            vsync = 0,
            scale = 2,
            display = 1,
            width = 1280,
            height = 720
        },
        controls = {
            quit = "q",
            act = "e",
            focus = "lctrl",
            n = "w",
            e = "d",
            s = "s",
            w = "a"
        }
    }
}, {
    -- access some libs before they're all loaded, e.g. util, vector
    __index = function(t, k)
        local status, out = pcall(function() return require("neko/lib/" .. k) end)
        t[k] = status and out or require("neko/lib/import/" .. k)
        return t[k]
    end
})
local tonumber = tonumber
local format = string.format
local match = string.match
local gsub = string.gsub
local nu = neko.util
local nc = neko.config
local lf = love.filesystem
local path = "config.ini"

local function sync(...)
    local w, h, flags = ...
    local swap
    flags = flags or w
    -- wiki incorrect; vsync from getMode is number
    flags.vsync = flags.vsync == 1
    for k, v in pairs(flags) do
        local old = v
        local new = nc.video[k]
        if new then
            if type(old) == "boolean" then new = new == 1 end
            swap = swap or w ~= nc.video.width or h ~= nc.video.height or old ~= new
            flags[k] = new
        end
    end
    return swap and flags
end

function love.conf(t)
    setmetatable(nc, {
        __index = {
            def = nu.tbl_copy(nc),
            init = function()
                local nr = neko.run
                local lw = love.window
                local fps = nc.video.fps > 0 and nc.video.fps
                local flags = sync(lw.getMode())
                if flags then lw.setMode(nc.video.width, nc.video.height, flags) end
                -- apply relevant config settings to libs
                nr.framerate = fps
                nr.rate = 1 / (fps or nc.def.video.fps)
            end,
            save = function()
                local out = ""
                for id, section in pairs(nc) do
                    out = gsub(out .. format("[%s]\n", id), "\n%[", "\n%1")
                    for k, v in pairs(section) do
                        out = out .. format("%s=%s\n", k, v)
                    end
                    lf.write(p or path, out)
                end
            end
        }
    })
    lf.setIdentity("frost")
    if lf.getInfo(path, "file") then
        local section = "def"
        for line in lf.lines(path) do
            if line ~= "" and not match(line, "^%s*;.*$") then
                local test = match(line, "%[%s*(.*)%s*%]")
                if test then
                    section = test
                    nc[test] = {}
                else
                    local k, v = match(line, "^%s*(.*)%s*=%s*(.+)%s*$")
                    if k and v then nc[section][k] = tonumber(v) or v end
                end
            end
        end
    else
        nc.save()
    end
    local w = sync(t.window)
    w.resizable = true
    w.icon = nil
end