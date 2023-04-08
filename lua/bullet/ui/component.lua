local Component = {}

function Component:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Component:content()
	return { { { "<empty>", "Error" } } }
end

return Component
