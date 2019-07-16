local format = string.format
local find = string.find
local gmatch = string.gmatch
local remove = table.remove
local ui = {}

function ui.load(def)
    local stack = {}
    for i = 1, #ui do
        ui[i] = nil
    end
    for id, traits, body in gmatch(def, "<([%a/]+)(.-)>([^<]*)") do
        -- ensure body is nil if it lacks any content
        body = string.match(body, "[^%s]+")
        if find(id, "/") then
            local last = ui.id or id
            if not find(id, last) then error(format("%s: expected /%s", id, last)) end
            ui = remove(stack)
        else
            local node = setmetatable({
                id = id,
                body = body
            }, {
                __index = ui
            })
            for k, v in gmatch(traits, "(%w+)=(%w+)") do
                node[k] = tonumber(v) or v
            end
            stack[#stack + 1] = ui
            ui[#ui + 1] = node
            ui = node
        end
    end
    if ui.id then error(ui.id .. ": no closing tag") end
end

return ui