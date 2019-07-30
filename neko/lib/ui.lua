local type = type
local tonumber = tonumber
local rawset = rawset
local max = math.max
local format = string.format
local match = string.match
local gmatch = string.gmatch
local gsub = string.gsub
local remove = table.remove
local lg = love.graphics
local nv = neko.vector
local ui = {}
-- TODO: centralized font system
local font = lg.newFont()

local draw = setmetatable({
    item = function(node)
        lg.print(node.text, node.pos:unpack())
    end
}, {
    __index = function(t, k)
        error(k .. ": not drawable")
    end
})

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

local function node(tag, props, body)
    -- props can exist locally or be inherited
    local data = {status = 1}
    for k, v in gmatch(props, "(%w+):(%w+)") do
        data[k] = tonumber(v) or v
    end
    props = setmetatable(data, {
        __index = ui.props
    })
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
    if #ui > 1 then
        error("root: nodes > 1")
    elseif ui.tag then
        error(ui.tag .. ": no closing tag")
    end
end

function ui.draw()
    iter(ui, function(node)
        local body = node.body
        local box = nv()
        if body then
            for token in gmatch(body, "%%([^%s]+)") do
                local depth = neko
                for sub in gmatch(token, "%w+") do
                    depth = depth[sub]
                end
                body = gsub(body, format("%%%%%s", token), depth())
            end
            box:set(font:getWidth(body), font:getHeight(body))
        end
        for i = 1, #node do
            local sub = node[i]
            local p = sub.pos
            local b = sub.box
            if node.dir == "x" then
                p.x = box.x
                box:set(box.x + b.x, max(box.y, b.y))
            else
                p.y = box.y
                box:set(max(box.x, b.x), box.y + b.y)
            end
        end
        node.box = box
        node.pos = nv()
        node.text = body
    end, true)
    iter(ui, function(node)
        local pos = node.pos
        pos:set(nv(node.root.pos) + pos)
        lg.setColor("#6a6a6a")
        lg.rectangle("fill", pos.x, pos.y, node.box:unpack())
        lg.setColor()
        draw[node.tag](node)
    end)
end

return ui