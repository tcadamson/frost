local type = type
local tonumber = tonumber
local rawset = rawset
local format = string.format
local match = string.match
local find = string.find
local gmatch = string.gmatch
local gsub = string.gsub
local remove = table.remove
local lg = love.graphics
local nv = neko.vector
local ui = {}
-- TODO: centralized font system
local font = lg.newFont()

local draw = setmetatable({
    item = function(body)
        local box = nv(font:getWidth(body), font:getHeight(body))
        lg.setColor("#6a6a6a")
        lg.rectangle("fill", 0, 0, box:unpack())
        lg.setColor()
        lg.print(body)
    end
}, {
    __index = function(t, k)
        error(k .. ": not drawable")
    end
})

local function iter(level, call)
    local i = 1
    local node = level[i]
    while node do
        call(node)
        if #node > 0 then iter(node, call) end
        i = i + 1
        node = level[i]
    end
end

local function node(tag, props, body)
    -- context restricts access to key-based parent props
    -- using ui as __index would allow infinite number-based indexing
    local context = setmetatable({status = 1}, {
        __index = ui.context
    })
    for k, v in gmatch(props, "(%w+):(%w+)") do
        context[k] = tonumber(v) or v
    end
    return setmetatable({
        tag = tag,
        body = body,
        context = context
    }, {
        __index = context,
        __newindex = function(t, k, v)
            t = type(k) == "number" and t or context
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
        -- ensure body is nil if it lacks any content
        body = find(body, "%w") and gsub(match(body, "%s*(.-)%s*$"), "(%c)%s+", "%1")
        if match(tag, "/%a+") then
            local last = ui.tag
            if not last then
                error(tag .. ": no opening tag")
            else
                if not find(tag, last) then error(format("%s: expected /%s", tag, last)) end
                ui = remove(stack)
            end
        else
            local new = node(tag, props, body)
            stack[#stack + 1] = ui
            ui[#ui + 1] = new
            ui = new
        end
    end
    if ui.tag then error(ui.tag .. ": no closing tag") end
end

function ui.draw()
    iter(ui, function(node)
        local body = node.body
        if body and node.status > 0 then
            for token in gmatch(body, "%%([^%s]+)") do
                local level = neko
                for sub in gmatch(token, "%w+") do
                    level = level[sub]
                end
                body = gsub(body, format("%%%%%s", token), level())
            end
            draw[node.tag](body)
        end
    end)
end

return ui