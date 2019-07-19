local tonumber = tonumber
local format = string.format
local match = string.match
local find = string.find
local gmatch = string.gmatch
local remove = table.remove
local ui = {}

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

function ui.load(def)
    local stack = {}
    for tag, props, body in gmatch(def, "<([%a/]+)(.-)>([^<]*)") do
        -- ensure body is nil if it lacks any content
        body = match(body, "[^%s]+")
        if match(tag, "/.+") then
            local last = ui.tag
            if not last then
                error(tag .. ": no opening tag")
            else
                if not find(tag, last) then error(format("%s: expected /%s", tag, last)) end
                ui = remove(stack)
            end
        else
            -- context restricts access to key-based parent props
            -- using ui as __index would allow infinite number-based indexing
            local context = setmetatable({}, {
                __index = ui.context
            })
            local node = setmetatable({
                tag = tag,
                body = body,
                context = context
            }, {
                __index = context
            })
            for k, v in gmatch(props, "(%w+)=(%w+)") do
                context[k] = tonumber(v) or v
            end
            stack[#stack + 1] = ui
            ui[#ui + 1] = node
            ui = node
        end
    end
    if ui.tag then error(ui.tag .. ": no closing tag") end
end

function ui.draw()
    iter(ui, function(node)
        -- print(node.tag)
    end)
end

return ui