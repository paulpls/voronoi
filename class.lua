--
--  Class factory
--
local classMetatable = {}



--
--  Set metatable
--
function classMetatable:__index (key) return self.__baseclass[key] end
Class = setmetatable({__baseclass={}}, classMetatable)



--
--  Factory
--
function Class:new(...)
    local c = {}
    c.__baseclass = self
    setmetatable(c, getmetatable(self))
    if c.init then c:init(...) end
    return c
end



