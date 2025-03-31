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
	return vim.loop.fs_stat(file_path) ~= nil
end

---@param file_path string Path to the file to open in editor
function M.open_file_in_editor(file_path)
	vim.cmd("edit " .. vim.fn.fnameescape(file_path))
end

return M
