local Navigator = {}

function Navigator:new(o)
	o = o or {}

	setmetatable(o, self)
	self.__index = self

	return o
end

---@diagnostic disable-next-line: unused-local
function Navigator:navigate(page_name, params)
	-- Do nothing
end

function Navigator:refresh()
	-- Do nothing
end

return Navigator
