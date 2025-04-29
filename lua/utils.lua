local M = {}

---@param path string Path to check/create
---@return boolean success Whether the directory exists or was created
function M.ensure_directory_exists(path)
	local stat = vim.loop.fs_stat(path)
	if stat and stat.type == "directory" then
		return true
	end

	local success = vim.fn.mkdir(path, "p") == 1
	if not success then
		vim.notify("Failed to create directory: " .. path, vim.log.levels.ERROR)
	end
	return success
end

---@param file_path string Path to the file to read
---@return string|nil content File content or nil if file couldn't be read
function M.read_file(file_path)
	local f = io.open(file_path, "r")
	if not f then
		vim.notify("File inaccessible: " .. file_path, vim.log.levels.ERROR)
		return nil
	end

	local content = f:read("*all")
	f:close()
	return content
end

---@param file_path string Path to the file to write
---@param content string Content to write to the file
---@return boolean success Whether the file was written successfully
function M.write_file(file_path, content)
	local f = io.open(file_path, "w")
	if not f then
		vim.notify("Can't write to file: " .. file_path, vim.log.levels.ERROR)
		return false
	end

	f:write(content)
	f:close()
	return true
end

---@param file_path string Path to check
---@return boolean exists Whether the file exists
function M.file_exists(file_path)
	return vim.uv.fs_stat(file_path) ~= nil
end

---@param file_path string Path to the file to open in editor
function M.open_file_in_editor(file_path)
	vim.cmd("edit " .. vim.fn.fnameescape(file_path))
end

---@param file_path string Path to the file to open in editor
function M.open_file_in_float(file_path)
	local buf = vim.fn.bufadd(file_path)
	vim.fn.bufload(buf)

	local width = vim.o.columns
	local height = vim.o.lines

	local win_width = math.floor(width * 0.9) -- 90% of screen width
	local win_height = math.floor(height * 0.8) -- 80% of screen height

	local row = math.floor((height - win_height) / 2)
	local col = math.floor((width - win_width) / 2)

	local opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = "Notesidian - " .. vim.fn.fnamemodify(file_path, ":t"),
		title_pos = "center",
	}
	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_set_current_win(win)

	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", {
		noremap = true,
		silent = true,
		desc = "Close Notesidian Window",
	})
	vim.api.nvim_buf_set_keymap(buf, "n", "<esc>", "<cmd>close<CR>", {
		noremap = true,
		silent = true,
		desc = "Close Notesidian Window",
	})
end

return M
