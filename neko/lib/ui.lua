local type = type
local tonumber = tonumber
local rawset = rawset
local rawget = rawget
local select = select
local min = math.min
local max = math.max
local huge = math.huge
local ceil = math.ceil
local format = string.format
local match = string.match
local gmatch = string.gmatch
local gsub = string.gsub
local remove = table.remove
local lg = love.graphics
local nv = neko.vector
local nm = neko.mouse
local nu = neko.util
local bundle = setmetatable({
    dirs = function(t, k)
        return nv(k and k[1]), nv(k and k[2])
    end
}, {
    __index = function(t, k)
        local body = tonumber(k) and k or match(k, "%((.+)%)")
        local out = k
        if body then
            out = nu.new("grow")
            out.arg = match(k, "^[%x#]+")
            if not match(body, "%a") then
                local query = "[%d.]+"
                local i = 1
                while select(2, gsub(body, query, "")) < 4 do
                    body = gsub(body, format("(%s)$", query), "%1,%1")
                end
                for token in gmatch(body, query) do
                    out[ceil(i / 2)][i % 2 == 1 and "x" or "y"] = tonumber(token)
                    i = i + 1
                end
            else
                for token in gmatch(k, "[(,](%w+)") do
                    out[#out + 1] = token
                end
            end
        end
        t[k] = out
        return out
    end
})
local styles = setmetatable({
    dir = "y"
}, {
    __index = function(styles, node)
        local id = node.class
        local class = rawget(styles, id)
        if not class and type(id) == "table" then
            class = rawget(styles, remove(id, 1))
            for i = 1, #id do
                nu.merge(class, rawget(styles, id[i]))
            end
        end
        local tag = rawget(styles, node.tag)
        local out = setmetatable({}, {
            __index = function(t, k)
                id = node.hovered and (nm.m1.down and "click" or "hover")
                return class and class[id][k] or tag and tag[id][k] or rawget(styles, k)
            end
        })
        styles[node] = out
        return out
    end
})
local body = setmetatable({}, {
    __index = function(t, k)
        t[k] = k.body
        -- rawget to prevent fatal loop if body is nil
        return rawget(t, k)
    end
})
local draw = setmetatable({
    text = function(node, style)
        lg.print(node.body, (node.pos + bundle:dirs(style.pad) + bundle:dirs(style.edge)):unpack())
    end
}, {
    __index = function(t, k)
        return rawget(t, k.tag)
    end
})
local ui = {
    pos = nv(),
    box = nv()
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
    props = props or {
        status = 1,
        pos = nv(),
        box = nv()
    }
    for k in gmatch(str, "(%a+):") do
        local v = gsub(match(str, k .. ":([^%c:]+)"), "%s+%a+$", "")
        props[k] = bundle[v]
    end
    return props
end

local function node(tag, props, body)
    local props = process(props)
    local node = setmetatable({
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
    return node
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
        styles[gsub(target, "%%", "")] = setmetatable(process(body, out), {
            __index = function(t, k)
                -- index by state test and return root table if it fails
                return not k and t
            end
        })
    end
end

function ui.bind(fs)
    setmetatable(ui, {
        __index = fs
    })
end

function ui.update(dt)
    iter(ui, function(node)
        local pos = node.pos
        local box = node.box
        node.hovered = nm.pos > pos and nm.pos < pos + box
    end)
    iter(ui, function(node)
        local body = body[node]
        local style = styles[node]
        local dir = style.dir
        local pa, pb = bundle:dirs(style.pad)
        local ea, eb = bundle:dirs(style.edge)
        local pos = nv()
        local box = nv()
        if body then
            for token in gmatch(body, "%%([^%s]+)") do
                local zone = neko
                for sub in gmatch(token, "%w+") do
                    zone = zone[sub]
                end
                body = gsub(body, format("%%%%%s", token), type(zone) == "function" and zone() or zone)
            end
            node.body = body
            box:set(font:getWidth(body), font:getHeight(body))
        end
        box:set(box + pa + pb)
        iter(node, function(node)
            local ma, mb = bundle:dirs(styles[node].margin)
            local pos = node.pos
            local sub = node.box + ma + mb
            pos:set(pos + ea + ma)
            pos[dir] = box[dir] + ea[dir] + ma[dir]
            if dir == "y" then
                box:set(max(box.x, sub.x), box.y + sub.y)
            else
                box:set(box.x + sub.x, max(box.y, sub.y))
            end
        end, 1)
        node.pos = pos
        node.box = box + ea + eb
    end, -huge)
    iter(ui, function(node)
        local pos = node.pos
        local box = node.box
        local pin = node.pin
        local root = node.root
        if pin then
            local ma, mb = bundle:dirs(styles[node].margin)
            local shift = nv(pin.arg and box / 2)
            local edge = root.box - box - mb
            pin = bundle:dirs(pin)
            pos:set(nv(pin.x * root.box.x, pin.y * root.box.y) - shift)
            pos:set(min(max(pos.x, ma.x), edge.x), min(max(pos.y, ma.y), edge.y))
        end
        pos:set(root.pos + pos)
        if node.hovered then
            if draw[node] then nm.space("ui") end
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
        local draw = draw[node]
        local style = styles[node]
        local bg = style.bg
        local edge = style.edge
        if bg then
            local pos = node.pos
            local box = node.box
            if edge then
                local ea, eb = bundle:dirs(edge)
                lg.setColor(edge.arg)
                lg.rectangle("fill", pos.x, pos.y, box:unpack())
                pos = pos + ea
                box = box - ea - eb
            end
            lg.setColor(bg)
            lg.rectangle("fill", pos.x, pos.y, box:unpack())
            lg.setColor(style.color)
        end
        return draw and draw(node, style)
    end)
end

return ui