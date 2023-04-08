local Navigator = require("bullet.ui.navigator")
local Buffer = require("bullet.utils.buffer")

local Plugin = {
	buffer = -1,
	ns = -1,
}

function Plugin:new(delegate)
	o = {}

	setmetatable(o, self)
	self.__index = Navigator:new(self)

	o.delegate = delegate

	return o
end

local function bind(buffer, bindings)
	for _, binding in ipairs(bindings) do
		vim.keymap.set(binding.mode, binding.key, binding.cmd, { noremap = true, silent = true, buffer = buffer })
	end
end

local function unbind(buffer, bindings)
	for _, binding in ipairs(bindings) do
		vim.keymap.del(binding.mode, binding.key, { noremap = true, silent = true, buffer = buffer })
	end
end

function Plugin:setup(opts)
	opts = opts or {}

	self.ns = vim.api.nvim_create_namespace(self.delegate:name())
	vim.api.nvim_set_hl_ns(self.ns)

	self.delegate:on_setup(opts)
end

function Plugin:navigate(page_name, params)
	self.buffer = Buffer:get_or_create(self.delegate:title(), true)

	if not self.page then
		vim.api.nvim_create_autocmd("BufWinLeave", {
			buffer = self.buffer,
			once = true,
			callback = function()
				if self.page then
					unbind(self.buffer, self.page:bindings())
					self.page:on_destroy()
					self.page = nil
				end
			end,
		})
	end

	if self.page then
		unbind(self.buffer, self.page:bindings())
		self.page:on_destroy()
	end

	local page_type = self.delegate:require(page_name)

	if not page_type then
		return
	end

	self.page = page_type:new(params, self)

	bind(self.buffer, self.page:bindings())
	self:refresh()
end

local function get_text(content)
	local text = {}

	for _, line in ipairs(content) do
		if type(line) == "string" then
			table.insert(text, line)
		elseif type(line) == "table" then
			local str = ""
			for _, word in ipairs(line) do
				if type(word) == "string" then
					str = str .. word
				elseif type(word) == "table" then
					str = str .. word[1]
				end
			end
			table.insert(text, str)
		end
	end

	return text
end

local function get_highlights(content)
	local highlights = {}

	for row, line in ipairs(content) do
		if type(line) == "table" then
			local col = 0
			for _, word in ipairs(line) do
				if type(word) == "string" then
					col = col + #word
				elseif type(word) == "table" then
					local style = word[2]

					if style then
						table.insert(highlights, {
							style = word[2],
							line = row - 1,
							col_start = col,
							col_end = col + #word[1],
						})
					end

					col = col + #word[1]
				end
			end
		end
	end

	return highlights
end

function Plugin:refresh()
	local content = self.page:content()

	local text = get_text(content)
	local highlights = get_highlights(content)

	vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, text)

	for _, h in ipairs(highlights) do
		vim.api.nvim_buf_add_highlight(self.buffer, self.ns, h.style, h.line, h.col_start, h.col_end)
	end

	return content
end

return Plugin
