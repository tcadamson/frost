local type = type
local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local atan2 = math.atan2
local floor = math.floor
local format = string.format
local nu = neko.util
local nm = neko.mem
local ffi = require("ffi")
local vec = {}
local buf = nm.new([[
    typedef struct {
        double x, y;
    } vec
]], true)

local meta = {
    __unm = function(a) return vec(-a.x, -a.y) end,
    __add = function(a, b) return vec(a.x + b.x, a.y + b.y) end,
    __sub = function(a, b) return vec(a.x - b.x, a.y - b.y) end,
    __div = function(a, b) return vec(a.x / b, a.y / b) end,
    __eq = function(a, b) return a.x == b.x and a.y == b.y end,
    __lt = function(a, b) return a.x < b and a.y < b end,
    __mul = function(a, b)
        if type(a) == "number" then return vec(b.x * a, b.y * a) end
        if type(b) == "cdata" then
            return a.x * b.x + a.y * b.y
        else
            return vec(a.x * b, a.y * b)
        end
    end,
    __index = vec,
    __tostring = function(v) return format("(%.3f, %.3f)", v.x, v.y) end,
    __call = function(t, x, y)
        local vec = buf:get()
        x = x or 0
        y = y or 0
        if type(x) == "cdata" then
            y = x.y
            x = x.x
        end
        vec.x, vec.y = x, y
        return vec
    end
}

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

function vec:rot()
    local len = self:len()
    local theta = self:theta() + add
    return vec(cos(theta) * len, sin(theta) * len)
end

function vec:copy()
    return vec(self.x, self.y)
end

function vec:unpack()
    return self.x, self.y
end

function vec:floor()
    return vec(floor(self.x), floor(self.y))
end

ffi.metatype("vec", meta)
return setmetatable(vec, meta)