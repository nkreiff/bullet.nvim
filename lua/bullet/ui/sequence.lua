local Component = require("fury.ui.component")

local Utils = require("fury.utils")

local Sequence = {}

function Sequence:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = Component:new(self)
	return o
end

function Sequence:add(component)
	local component_content = component
	if type(component_content) ~= "string" then
		component_content = component:content()
	end

	table.insert(self, {
		length = #component_content,
		content = component_content,
	})
end

function Sequence:get_length(index)
	local c = self[index]
	if c then
		return c.length
	end
	return 0
end

function Sequence:count()
	return #self
end

function Sequence:content()
	local content = {}

	for _, c in ipairs(self) do
		if type(c.content) == "string" then
			table.insert(content, c.content)
		else
			Utils.append(content, c.content)
		end
	end

	return content
end

return Sequence
