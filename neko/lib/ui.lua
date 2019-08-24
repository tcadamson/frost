local type = type
local tonumber = tonumber
local rawset = rawset
local min = math.min
local max = math.max
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
        return t[k.class or k.tag]
    end
})
local draw = setmetatable({
    text = function(node)
        lg.print(node.text, node.pos:unpack())
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

local function iter(level, call, rev)
    local i = rev and #level or 1
    local node = level[i]
    while node do
        if node.status > 0 then
            if not rev then
                call(node)
                iter(node, call)
            else
                iter(node, call, rev)
                call(node)
            end
        end
        i = i + (rev and -1 or 1)
        node = level[i]
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

function ui.toggle(node)
    node.status = node.status > 0 and 0 or 1
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
            out[call] = process(override)
        end
        style[gsub(target, "%%", "")] = process(body, out)
    end
    iter(ui, function(node)
        local base = style[node]
        if base and node.class then
            local root = style[node.tag]
            setmetatable(base, {
                __index = root
            })
            for i = 1, #calls do
                local call = calls[i]
                setmetatable(base[call], {
                    __index = root[call]
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
        local dir = style[node].dir or "y"
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
        end
        for i = 1, #node do
            local sub = node[i]
            local temp = sub.box
            sub.pos[dir] = box[dir]
            if dir == "y" then
                box:set(max(box.x, temp.x), box.y + temp.y)
            else
                box:set(box.x + temp.x, max(box.y, temp.y))
            end
        end
        node.box = box
        node.pos = pos
    end, true)
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
        node.hover = nm.pos > pos and nm.pos < pos + box
        if node.hover then
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
        local index = node.hover and (nm.m1.down and "click" or "hover")
        local style = style[node]
        if style then
            if index then style = style[index] end
            lg.setColor(style.bg)
            lg.rectangle("fill", pos.x, pos.y, box:unpack())
            lg.setColor(style.color)
        end
        draw[node.tag](node)
    end)
end

return ui