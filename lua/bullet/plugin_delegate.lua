local PluginDelegate = {}

function PluginDelegate:new(o)
	o = o or {}

	setmetatable(o, self)
	self.__index = self

	return o
end

function PluginDelegate:name()
	vim.notify("you must override the 'name' method of the plugin delegate", vim.log.levels.ERROR)
	return "bullet-plugin"
end

function PluginDelegate:title()
	vim.notify(
		"probably you want to override the 'title' method of the plugin delegate in order to set the appropiate title",
		vim.log.levels.WARN
	)
	return "bullet-plugin"
end

function PluginDelegate:on_setup(opts)
	vim.notify(
		"probably you want to override the 'on_setup' method of the plugin delegate in order to initialize the plugin",
		vim.log.levels.WARN
	)
end

function PluginDelegate:require(page_name)
	vim.notify("you must implement the 'require' method of the plugin delegate", vim.log.levels.ERROR)
	-- require("your.pages.package." .. page_name)
end

return PluginDelegate
