local List = {}

List.append = function(list, other)
	for _, v in ipairs(other) do
		table.insert(list, v)
	end
end

List.slice = function(list, s, e)
	local slice = {}
	for i = s or 1, e or #list do
		table.insert(slice, list[i])
	end
	return slice
end

return List
