local Component = require("fury.ui.component")
local Navigator = require("fury.ui.navigator")

local Page = {}

function Page:new(o, navigator)
	o = o or {}

	setmetatable(o, self)
	self.__index = Component:new(self)

	self._navigator = navigator or Navigator:new()

	return o
end

function Page:on_destroy() end

function Page:bindings()
	return {}
end

function Page:navigate(page, params)
	self._navigator:navigate(page, params)
end

function Page:refresh()
	self._navigator:refresh()
end

return Page
