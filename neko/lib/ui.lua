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
local text = {}
local ui = {
    box = nv()
}
-- TODO: centralized font system
local font = lg.newFont()

local draw = setmetatable({
    text = function(node)
        lg.print(text[node], node.pos:unpack())
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
    local str = props
    local props = {status = 1}
    for k in gmatch(str, "(%a+):") do
        props[k] = gsub(match(str, k .. ":([^:]+)"), "%s+%a+$", "")
    end
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

function ui.draw()
    iter(ui, function(node)
        local body = node.body
        local dir = node.dir or "y"
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
            text[node] = body
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
        local pos = node.pos
        pos:set(nv(node.root.pos) + pos)
        lg.setColor("#6a6a6a")
        lg.rectangle("fill", pos.x, pos.y, node.box:unpack())
        lg.setColor()
        draw[node.tag](node)
    end)
end

return ui