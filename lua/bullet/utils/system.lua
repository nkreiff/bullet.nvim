local System = {}

System.os = function()
	return package.config:sub(1, 1) == "\\" and "windows" or "unix"
end

System.open = function(url)
	local os_name = List.os()
	if os_name == "unix" then
		os.execute("open " .. url)
	elseif os_name == "windows" then
		os.execute("start " .. url)
	end
end

return System
