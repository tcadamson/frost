local type = type
local tonumber = tonumber
local rawset = rawset
local rawget = rawget
local min = math.min
local max = math.max
local huge = math.huge
local format = string.format
local match = string.match
local gmatch = string.gmatch
local gsub = string.gsub
local remove = table.remove
local lg = love.graphics
local nv = neko.vector
local nm = neko.mouse
local style = setmetatable({}, {
    __index = function(t, k)
        if k then
            -- k.box and k.pos are nil on first update
            local box = nv(k.box)
            local pos = nv(k.pos)
            k.hovered = nm.pos > pos and nm.pos < pos + box
            k.clicked = nm.m1.down and k.hovered
            t = t[k.class or k.tag]
            return t[k.hovered and (k.clicked and "click" or "hover")] or t
        end
    end
})
local draw = setmetatable({
    text = function(node, style)
        local pad = style.pad
        local pos = node.pos + nv(pad, pad)
        lg.print(node.text, pos:unpack())
    end
}, {
    __index = function(t, k)
        error(k .. ": not drawable")
    end
})
local ui = {
    box = nv(),
    pos = nv()
}
local calls = {
    "hover",
    "click"
}
-- TODO: centralized font system
local font = lg.newFont()

local function iter(level, call, dir)
    dir = dir or huge
    for i = 1, #level do
        local node = level[i]
        if node.status > 0 then
            if dir > 0 then
                call(node)
                iter(node, call, dir - 1)
            elseif dir < 0 then
                iter(node, call, dir + 1)
                call(node)
            end
        end
    end
end

local function process(str, props)
    props = props or {status = 1}
    for k in gmatch(str, "(%a+):") do
        local v = gsub(match(str, k .. ":([^%c:]+)"), "%s+%a+$", "")
        props[k] = tonumber(v) or v
    end
    return props
end

local function node(tag, props, body)
    local props = process(props)
    return setmetatable({
        tag = tag,
        body = body,
        props = props,
        root = ui
    }, {
        __index = props,
        __newindex = function(t, k, v)
            t = type(k) == "number" and t or props
            rawset(t, k, v)
        end
    })
end

function ui.load(def)
    local stack = {}
    for tag, props, body in gmatch(def, "<([%a/]+)(.-)>([^<]*)") do
        body = match(body, "%w") and gsub(match(body, "%s*(.-)%s*$"), "(%c)%s+", "%1")
        if match(tag, "/%a+") then
            local last = ui.tag
            if not last then
                error(tag .. ": no opening tag")
            else
                if not match(tag, last) then error(format("%s: expected /%s", tag, last)) end
                ui = remove(stack)
            end
        else
            local new = node(tag, props, body)
            stack[#stack + 1] = ui
            ui[#ui + 1] = new
            ui = new
        end
    end
    if ui.tag then
        error(ui.tag .. ": no closing tag")
    end
end

function ui.style(def)
    for target, body in gmatch(def, "([%%%w]+)%s*{([^}]*)") do
        -- TODO: justify prefixing classes with %
        -- identify class using target, class = gsub(target, "%%", "")
        local out = {}
        for i = 1, #calls do
            out[calls[i]] = setmetatable({}, {
                __index = out
            })
        end
        for call, override in gmatch(body, "%%(%a+)(.-)%%") do
            body = gsub(body, call .. ".-%%", "")
            out[call] = process(override, out[call])
        end
        style[gsub(target, "%%", "")] = process(body, out)
    end
    iter(ui, function(node)
        local class = style[node.class]
        local tag = style[node.tag]
        if class and tag then
            setmetatable(class, {
                __index = tag
            })
            for i = 1, #calls do
                local call = calls[i]
                setmetatable(class[call], {
                    __index = function(t, k)
                        return rawget(tag[call], k) or class[k]
                    end
                })
            end
        end
    end)
end

function ui.bind(fs)
    setmetatable(ui, {
        __index = fs
    })
end

function ui.update(dt)
    iter(ui, function(node)
        local body = node.body
        local style = style[node]
        local dir = style.dir or "y"
        local pad = style.pad
        local box = nv()
        local pos = nv()
        if body then
            for token in gmatch(body, "%%([^%s]+)") do
                local zone = neko
                for sub in gmatch(token, "%w+") do
                    zone = zone[sub]
                end
                if type(zone) == "function" then zone = zone() end
                body = gsub(body, format("%%%%%s", token), zone)
            end
            node.text = body
            box:set(font:getWidth(body), font:getHeight(body))
            box:set(box + nv(pad, pad) * 2)
        end
        iter(node, function(node)
            local temp = node.box
            node.pos[dir] = box[dir]
            if dir == "y" then
                box:set(max(box.x, temp.x), box.y + temp.y)
            else
                box:set(box.x + temp.x, max(box.y, temp.y))
            end
        end, 1)
        node.box = box
        node.pos = pos
    end, -huge)
    iter(ui, function(node)
        local box = node.box
        local pos = node.pos
        local pin = node.pin
        local root = node.root
        if pin then
            local anchor, x, y = match(pin, "(c-)%((.+),%s*(.+)%)")
            local shift = nv(#anchor > 0 and box / 2)
            local edge = root.box - box
            pos:set(nv(x * root.box.x, y * root.box.y) - shift)
            pos:set(min(max(pos.x, 0), edge.x), min(max(pos.y, 0), edge.y))
        end
        pos:set(root.pos + pos)
        if node.hovered then
            nm.space("ui")
            nm.queue(function()
                local call = ui[node.click]
                if call and nm.m1.released then call(node) end
            end)
        end
    end)
    nm.space()
end

function ui.draw()
    iter(ui, function(node)
        local box = node.box
        local pos = node.pos
        local style = style[node]
        if style then
            lg.setColor(style.bg)
            lg.rectangle("fill", pos.x, pos.y, box:unpack())
            lg.setColor(style.color)
        end
        draw[node.tag](node, style)
    end)
end

return ui