local Sequence = require("fury.ui.sequence")
local Line = require("fury.ui.line")

local Component = require("fury.ui.component")

local separator = "  "

local Table = {
	headers = {},
	table = {},
}

function Table:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = Component:new(self)
	return o
end

function Table:set_header_style(style)
	for col, _ in ipairs(self.headers) do
		self.headers[col].style = style
	end
end

function Table:set_column_style(col, style)
	if col <= 0 or col > #self.headers then
		return
	end

	self.headers[col].colstyle = style
end

function Table:set_cell_style(row, col, style)
	if col <= 0 or col > #self.headers then
		return
	end

	if row <= 0 or row > #self.table then
		return
	end

	self.table[row][col].style = style
end

function Table:set_object_list(list, fields)
	local h = {}

	for col, field in ipairs(fields) do
		if type(field) == "string" then
			h[col] = { text = field }
		elseif type(field) == "table" then
			h[col] = { text = field.name }
		end
	end

	local c = {}

	for row, o in ipairs(list) do
		c[row] = {}

		for col, field in ipairs(fields) do
			if type(field) == "string" then
				c[row][col] = { value = o[field] }
			elseif type(field) == "table" then
				c[row][col] = { value = field.get(o) }
			end
		end
	end

	self.headers = h
	self.table = c
end

function Table:set_header(col, text)
	if col <= 0 or col > #self.headers then
		return
	end

	self.headers[col].text = text
end

function Table:transform_column(col, transformer)
	for row, cell in ipairs(self.table) do
		cell[col].value = transformer(row, col, cell[col].value)
	end
end

function Table:reduce_table(reducer, initial)
	local acc = initial
	for row, cell in ipairs(self.table) do
		acc = reducer(row, cell.value, acc)
	end
	return acc
end

function Table:reduce_column(col, reducer, initial)
	local acc = initial
	for row, cell in ipairs(self.table) do
		acc = reducer(row, col, cell[col].value, acc)
	end
	return acc
end

function Table:sort(col, reverse)
	local function compare(a, b)
		local ra = ""
		local rb = ""

		if type(col) == "table" then
			for _, c in ipairs(col) do
				ra = ra .. tostring(a[c].value) .. "-"
				rb = rb .. tostring(b[c].value) .. "-"
			end
		else
			ra = tostring(a[col].value)
			rb = tostring(b[col].value)
		end

		if reverse then
			return ra > rb
		else
			return ra < rb
		end
	end

	table.sort(self.table, compare)
end

function Table:filter(col, f)
	local filtered_table = {}

	for _, rowline in ipairs(self.table) do
		local value = rowline[col].value
		if f(value) then
			table.insert(filtered_table, rowline)
		end
	end

	self.table = filtered_table
end

function Table:slice(row_start, row_end)
	if row_start < 1 or row_start > #self.table then
		return {}
	end

	if row_end < 1 or row_end > #self.table then
		return {}
	end

	if row_start > row_end then
		return {}
	end

	local slice = {}
	for row = row_start, row_end do
		table.insert(slice, self.table[row])
	end

	self.table = slice
end

function Table:get_style(row, col)
	local style = self.table[row][col].style or self.headers[col].colstyle or "Text"

	if type(style) == "function" then
		return style(self.table[row][col].value)
	end

	return style
end

function Table:content()
	local s = Sequence:new()

	-- Calculate maximum column lengths
	local max_length_reducer = function(_, _, value, acc)
		local str_value = tostring(value)
		if #str_value > acc then
			return #str_value
		end
		return acc
	end

	local max_lengths = {}
	for col, _ in ipairs(self.headers) do
		max_lengths[col] = self:reduce_column(col, max_length_reducer, #self.headers[col].text)
	end

	-- Add headers
	local h = Line:new()
	for col, header in ipairs(self.headers) do
		h:add(string.upper(header.text) .. string.rep(" ", max_lengths[col] - #header.text) .. separator, header.style)
	end
	s:add(h)

	-- Add content
	for row, rowline in ipairs(self.table) do
		local line = Line:new()

		for col, cell in ipairs(rowline) do
			local style = self:get_style(row, col)
			local str_value = tostring(cell.value)
			line:add(str_value .. string.rep(" ", max_lengths[col] - #str_value) .. separator, style)
		end

		s:add(line)
	end

	return s:content()
end

return Table
