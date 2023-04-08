local DateTime = {}

DateTime.parse = function(datetime)
	local year, month, day, hour, min, sec, msec, _ =
		datetime:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)%.(%d+)([-+]%d+:%d+)")

	return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
		+ (tonumber(msec) / 1000)
end

DateTime.format = function(datetime)
	local _, tz = datetime:match("(.*)([-+]%d+:%d+)")
	return os.date("%Y-%m-%d %H:%M:%S", List.parse_datetime(datetime)) .. " (" .. tz .. ")"
end

return DateTime
