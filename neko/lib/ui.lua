local type = type
local unpack = unpack
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
local nr = neko.res
local queue = {}
local bundle = setmetatable({
    dirs = function(k)
        -- directions start clockwise from left side
        return nv(k and k[1]), nv(k and k[2])
    end
}, {
    __index = function(t, k)
        local body = tonumber(k) and k or match(k, "%((.+)%)")
        local out = k
        if body then
            out = nu.new("grow")
            out.arg = match(k, "^[%x#]+")
            if match(body, "%a") then
                for token in gmatch(k, "[(,](%w+)") do
                    out[#out + 1] = token
                end
            else
                local query = "[%d.-]+"
                local max = 4
                while select(2, gsub(body, query, "")) < max do
                    body = gsub(body, body, "%1,%1")
                end
                for i = 1, max do
                    out[ceil(i / 2)][i % 2 == 1 and "x" or "y"] = tonumber(match(body, query))
                    body = gsub(body, query .. ",*", "", 1)
                end
                if #body > 0 then out[#out].y = 0 end
            end
        end
        t[k] = out
        return out
    end
})
local styles = setmetatable({
    dir = "y",
    font = "unscii"
}, {
    __index = function(styles, node)
        local id = node.class
        local class = rawget(styles, id)
        if not class and type(id) == "table" then
            class = nu.merge({}, rawget(styles, id[#id]))
            for i = #id - 1, 1, -1 do
                nu.merge(class, rawget(styles, id[i]), true)
            end
            for k, v in pairs(class) do
                -- update __index on calls to point to class amalgam instead of class being merged
                local meta = getmetatable(v)
                if meta and type(v) == "table" and type(meta.__index) == "table" then
                    setmetatable(v, {
                        __index = class
                    })
                end
            end
        end
        local tag = rawget(styles, node.tag)
        local out = setmetatable({}, {
            __index = function(t, k)
                id = node.hovered and (node.focused and nm.m1.down and "click" or "hover")
                return class and class[id][k] or tag and tag[id][k] or rawget(styles, k)
            end
        })
        styles[node] = out
        return out
    end
})
local bodies = setmetatable({}, {
    __index = function(t, k)
        t[k] = k.body
        -- rawget to prevent fatal loop if body is nil
        return rawget(t, k)
    end
})
local tags = setmetatable({
    text = {
        size = function(node)
            local font = nr[styles[node].font]
            local body = node.body
            return font:getWidth(body), font:getHeight(body)
        end,
        draw = function(node, pos)
            lg.print(node.body, pos:unpack())
        end
    },
    q = {
        size = function(node)
            return nr[node.id].size
        end,
        draw = function(node, pos)
            local data = nr[node.id]
            lg.draw(data.tex, data.q, pos:unpack())
        end
    }
}, {
    __index = function(t, k)
        return rawget(t, k.tag)
    end
})
local opps = setmetatable({
    "x:y"
}, {
    __index = function(t, k)
        for i = 1, #t do
            local str = t[i]
            local query = format(":*%s:*", k)
            local opp, subs = gsub(str, query, "")
            if subs > 0 then
                t[k] = opp
                return opp
            end
        end
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
local focus

local bounds = nu.memoize(function(hash)
    local out = {}
    for str in gmatch(hash, "[^:]+") do
        out[#out + 1] = tonumber(str)
    end
    return out
end)

local function iter(level, call, steps)
    steps = steps or huge
    for i = 1, #level do
        local node = level[i]
        if node.status > 0 then
            if steps > 0 then
                call(node)
                iter(node, call, steps - 1)
            elseif steps < 0 then
                iter(node, call, steps + 1)
                call(node)
            end
        end
    end
end

local function node(tag, props, body)
    local temp = props
    local node = {
        tag = tag,
        body = body,
        root = ui,
        frames = {}
    }
    props = {
        pos = nv(),
        box = nv(),
        status = 1
    }
    for k in gmatch(temp, "(%a+):") do
        props[k] = bundle[gsub(match(temp, k .. ":([^%c:]+)"), "%s+%a+$", "")]
    end
    node.props = props
    setmetatable(node, {
        __index = props,
        __newindex = function(t, k, v)
            t = type(k) == "number" and t or props
            rawset(t, k, v)
        end
    })
    return node
end

local function encode(pos, box)
    return format("%d:%d:%d:%d", pos.x, pos.y, box:unpack())
end

function ui.load(id)
    local stack = {}
    for tag, props, body in gmatch(nr[id].markup, "<([%a/]+)(.-)>([^<]*)") do
        body = match(body, "%w") and gsub(match(body, "%s*(.-)%s*$"), "(%c)%s+", "%1")
        if match(tag, "/%a+") then
            local last = ui.tag
            if not last then error(tag .. ": no opening tag") end
            if not match(tag, last) then error(format("%s: expected /%s", tag, last)) end
            ui = remove(stack)
        else
            local closed = match(props, "(.+)/")
            local node = node(tag, closed or props, body)
            ui[#ui + 1] = node
            if not closed then
                stack[#stack + 1] = ui
                ui = node
            end
        end
    end
    if ui.tag then error(ui.tag .. ": no closing tag") end
    ui.style(id)
end

function ui.style(id)
    for k, v in pairs(nr[id].style) do
        local out = nu.merge({}, v)
        for i = 1, #calls do
            local call = calls[i]
            out[call] = setmetatable(out[call] or {}, {
                __index = out
            })
        end
        styles[k] = setmetatable(out, {
            __index = function(t, k)
                -- index by state test and return root table if it fails
                return not k and t
            end
        })
        nu.iter(out, function(t, k, v)
            t[k] = bundle[gsub(v, "0x%((%x+)%)", "#%1")]
        end)
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
        local frames = node.frames
        local root = node.root
        for i = 1, #frames do
            frames[i] = nil
        end
        while root do
            if styles[root].frame then
                local b1 = pos + box
                local b2 = root.pos + root.box
                local b3 = b2 - pos
                box:set(b1.x > b2.x and b3.x, b1.y > b2.y and b3.y)
                frames[#frames + 1] = root
            end
            root = root.root
        end
        node.hovered = nm.pos > pos and nm.pos < pos + box
        if node.hovered then
            for i = 1, node.root == ui and #queue or 0 do
                local queued = queue[i]
                queued.hovered = queued == node
            end
            queue[#queue + 1] = node
        end
    end)
    iter(ui, function(node)
        local tag = tags[node]
        local body = bodies[node]
        local style = styles[node]
        local dir = style.dir
        local frame = bundle.dirs(style.frame)
        local e1, e2 = bundle.dirs(style.edge)
        local p1, p2 = bundle.dirs(style.pad)
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
        end
        if tag then box:set(tag.size(node)) end
        iter(node, function(node)
            local m1, m2 = bundle.dirs(styles[node].margin)
            local pos = node.pos
            local sub = node.box + m1 + m2
            local opp = opps[dir]
            pos:set(pos + e1 + m1 + p1)
            pos[dir] = box[dir] + e1[dir] + m1[dir] + p1[dir]
            box[dir] = box[dir] + sub[dir]
            box[opp] = max(box[opp], sub[opp])
        end, 1)
        node.pos = pos
        node.box = (frame.zero and box or box:hadamard(frame)) + e1 + e2 + p1 + p2
    end, -huge)
    iter(ui, function(node)
        local style = styles[node]
        local inherit = styles[node.root]
        local pos = node.pos
        local box = node.box
        local pin = node.pin
        local root = node.root
        local m1, m2 = bundle.dirs(style.margin)
        local e1, e2 = bundle.dirs(inherit.edge)
        local align = bundle.dirs(inherit.align)
        local cropped = root.box - e1 - e2
        if not align.zero then
            local p1, p2 = bundle.dirs(inherit.pad)
            local opp = opps[inherit.dir]
            pos[opp] = (pos + (cropped - box - m1 - m2 - p1 - p2):hadamard(align))[opp]
        end
        if pin then
            local shift = nv(pin.arg and box / 2)
            local bound = cropped - box - m2
            pos:set(bundle.dirs(pin):hadamard(cropped) - shift)
            pos:set(min(max(pos.x, m1.x), bound.x), min(max(pos.y, m1.y), bound.y))
            pos:set(pos + e1)
        end
        pos:set(root.pos + pos + bundle.dirs(style.shift))
        if node.hovered then
            if tags[node] or style.bg then nm.space("ui") end
            nm.queue(function()
                local call = ui[node.click]
                if call and node.focused and nm.m1.released then call(node) end
            end)
        end
    end)
    local top = queue[#queue]
    focus = nm.m1.pressed and top or top == focus and focus
    for i = 1, #queue do
        local queued = queue[i]
        queued.focused = queued == focus
        queue[i] = nil
    end
    nm.space()
end

function ui.draw()
    iter(ui, function(node)
        local tag = tags[node]
        local style = styles[node]
        local bg = style.bg
        local edge = style.edge
        local pos = node.pos:floor()
        local box = node.box
        local frames = node.frames
        for i = #frames, 1, -1 do
            local frame = frames[i]
            local e1, e2 = bundle.dirs(styles[frame].edge)
            lg.intersectScissor(unpack(bounds[encode(frame.pos + e1, frame.box - e1 - e2)]))
        end
        if style.frame then lg.intersectScissor(unpack(bounds[encode(pos, box)])) end
        if edge then
            -- lg.rectangle limited to uniform edge length
            local e1 = bundle.dirs(edge)
            local shift = (e1 / 2):floor()
            pos = pos + shift
            box = box - e1
            lg.setLineWidth(e1:unpack())
            lg.setColor(edge.arg)
            lg.rectangle("line", pos.x, pos.y, box.x, box.y, bundle.dirs(style.r):unpack())
            pos = pos + shift
            box = box - e1
        end
        if bg then
            lg.setColor(bg)
            lg.rectangle("fill", pos.x, pos.y, box:unpack())
        end
        lg.setFont(nr[style.font])
        lg.setColor(style.color)
        if tag then tag.draw(node, pos + bundle.dirs(style.pad)) end
        lg.setScissor()
    end)
end

return ui