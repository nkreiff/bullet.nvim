local Component = require("fury.ui.component")

local Line = {}

function Line:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = Component:new(self)
	return o
end

function Line:add(text, style)
	if style == nil then
		table.insert(self, text)
		return
	end
	table.insert(self, { text, style })
end

function Line:content()
	return { self }
end

return Line
