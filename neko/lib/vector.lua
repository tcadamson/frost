local type = type
local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local atan2 = math.atan2
local floor = math.floor
local format = string.format
local nm = neko.mem
local ffi = require("ffi")
local vec = {}
local meta = {
    __index = vec,
    __tostring = function(v)
        return format("(%.3f, %.3f)", v:unpack())
    end,
    __add = function(a, b)
        return vec(a.x + b.x, a.y + b.y)
    end,
    __sub = function(a, b)
        return vec(a.x - b.x, a.y - b.y)
    end,
    __mul = function(a, b)
        if type(a) == "number" then return vec(b.x * a, b.y * a) end
        if type(b) == "cdata" then return a.x * b.x + a.y * b.y end
        return vec(a.x * b, a.y * b)
    end,
    __div = function(a, b)
        return vec(a.x / b, a.y / b)
    end,
    __unm = function(a)
        return vec(-a.x, -a.y)
    end,
    __eq = function(a, b)
        return a.x == b.x and a.y == b.y
    end,
    __lt = function(a, b)
        return a.x < b.x and a.y < b.y
    end,
    __gt = function(a, b)
        return a.x > b.x and a.y > b.y
    end
}
local buf = nm.new([[
    typedef struct {
        double x, y;
    } vec
]])

function vec:len()
    return sqrt(self.x * self.x + self.y * self.y)
end

function vec:theta()
    return atan2(self.y, self.x)
end

function vec:norm()
    local len = self:len()
    return len == 0 and vec(0, 0) or vec(self.x / len, self.y / len)
end

function vec:rot(add)
    local len = self:len()
    local theta = self:theta() + add
    return vec(cos(theta) * len, sin(theta) * len)
end

function vec:set(x, y)
    if type(x) == "cdata" then
        -- using unpack would limit us to vectors only
        self.x, self.y = x.x, x.y
    else
        self.x, self.y = x, y
    end
end

function vec:unpack()
    return self.x, self.y
end

function vec:floor()
    return vec(floor(self.x), floor(self.y))
end

ffi.metatype("vec", meta)
return setmetatable(vec, {
    __call = function(t, x, y)
        local vec = buf:add()
        x = x or 0
        y = y or 0
        if type(x) == "cdata" or type(x) == "table" then
            y = x.y
            x = x.x
        end
        vec:set(x, y)
        return vec
    end
})