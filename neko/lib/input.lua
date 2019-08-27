local lk = love.keyboard
local nu = neko.util
local nc = neko.config
local nv = neko.vector
local axes = {}
local keys = nu.new("grow")
local dirs = {
    -1,
    1,
    1,
    -1
}

function keys.init(def)
    -- axis maps (controls are pulled directly from config)
    for k, v in pairs(def) do
        local axis = k
        if #dirs ~= #v then error(axis .. ": expected four dirs") end
        axes[axis] = v
    end
end

function keys.update(dt)
    for k, v in pairs(nc.controls) do
        nu.poll(lk.isDown(v), keys[k])
    end
    for k, v in pairs(axes) do
        local axis = nv()
        for i = 1, #v do
            local dir = i % 2 == 0 and "x" or "y"
            if keys[v[i]].down then axis[dir] = axis[dir] + dirs[i] end
        end
        keys[k] = axis:norm()
    end
end

return keys