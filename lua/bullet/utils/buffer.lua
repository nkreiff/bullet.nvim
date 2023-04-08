local Buffer = {}

Buffer.get_or_create_buffer = function(title, scratch)
	-- Check if buffer exists
	local buf = vim.fn.bufnr(title)

	if buf <= 0 then
		-- Create new buffer
		buf = vim.api.nvim_create_buf(true, scratch or true) -- listed = true, scratch = true
		vim.api.nvim_buf_set_name(buf, title or "Unknown")
	end

	local win = nil

	-- Get all windows
	local x = 0
	local windows = vim.api.nvim_list_wins()
	local screen_height = vim.api.nvim_get_option("lines")
	for _, w in ipairs(windows) do
		local win_height = vim.api.nvim_win_get_height(w)
		local position = vim.api.nvim_win_get_position(w)

		if win_height == screen_height - 1 and position[2] > x then
			x = position[2]
			win = w
		end
	end

	if not win then
		-- Split current window horizontally
		win = vim.api.nvim_get_current_win()
		vim.cmd("vsplit")
	end

	-- Bind buffer to window
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_set_current_win(win)
	vim.api.nvim_set_current_buf(buf)

	return buf
end

return Buffer
