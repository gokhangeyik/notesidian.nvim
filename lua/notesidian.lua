local M = {}

local utils = require("utils")

---@class NotesidianConfig
---@field notes_root string Root directory for all notes
---@field daily_notes_path string Path to daily notes relative to notes_root
---@field template_path string Path to templates relative to notes_root
---@field date_format string Format string for dates
---@field todo_list_prefix string Title prefix for todo lists
---@field todo_template string Filename of todo list template
---@field note_template string Filename of note template

-- Default configuration
---@class NotesidianConfig
local _config = {
	notes_root = "",
	daily_notes_path = "Notes/Dailies",
	template_path = "Templates",
	date_format = "%Y-%m-%d",
	todo_list_prefix = "Personal",
	todo_template = "TodoList.md",
	note_template = "Note.md",
}

---@param template_path string Path to the template file
---@param target_path string Path where the new file should be created
---@param replacements table<string, string> Table of template replacements
---@return boolean success Whether the operation was successful
local function create_file_from_template(template_path, target_path, replacements)
	if not template_path then
		vim.notify("Template path not specified", vim.log.levels.ERROR)
		return false
	end

	local content = utils.read_file(template_path)
	if not content then
		return false
	end

	for pattern, replacement in pairs(replacements) do
		content = string.gsub(content, pattern, replacement)
	end

	if utils.file_exists(target_path) then
		utils.open_file_in_editor(target_path)
		return true
	end

	local parent_dir = vim.fn.fnamemodify(target_path, ":h")
	if not utils.ensure_directory_exists(parent_dir) then
		return false
	end

	if not utils.write_file(target_path, content) then
		return false
	end

	utils.open_file_in_editor(target_path)
	return true
end

---@param opts table|nil User configuration options
function M.setup(opts)
	-- Merge user config with defaults
	_config = vim.tbl_deep_extend("force", _config, opts or {})

	-- Expand all paths
	_config.notes_root = vim.fn.expand(_config.notes_root)

	-- Join paths with notes_root
	_config.template_path = vim.fs.joinpath(_config.notes_root, _config.template_path)
	_config.daily_notes_path = vim.fs.joinpath(_config.notes_root, _config.daily_notes_path)

	-- Set template file paths
	_config.note_template_file = vim.fs.joinpath(_config.template_path, _config.note_template)
	_config.todo_template_file = vim.fs.joinpath(_config.template_path, _config.todo_template)
end

---@doc
--- Creates a daily note file using the configured template
--- The note will be created in the daily notes directory with the current date
--- as filename using the configured date format.
function M.create_daily_note()
	local current_date = os.date(_config.date_format)
	local target_filename = current_date .. ".md"
	local target_file = vim.fs.joinpath(_config.daily_notes_path, target_filename)

	local replacements = {
		["{{date}}"] = current_date,
	}

	create_file_from_template(_config.note_template_file, target_file, replacements)
end

---@doc
--- Creates a todo list file using the configured template
--- The file will be created in the notes root directory with the configured
--- todo_list_title as part of the filename. The template will have date and
--- title placeholders replaced with current values.
function M.create_todo_list()
	local current_date = os.date(_config.date_format)
	local target_filename = _config.todo_list_prefix .. " - TodoList.md"
	local target_file = vim.fs.joinpath(_config.notes_root, target_filename)

	local replacements = {
		["{{date}}"] = current_date,
		["{{title}}"] = _config.todo_list_prefix .. " Todo List",
	}

	create_file_from_template(_config.todo_template_file, target_file, replacements)
end

---@doc
--- Toggles the checkbox state on the current line
--- The checkbox cycles through three states:
--- [ ] (unchecked) -> [-] (in progress) -> [x] (completed) -> [ ] (unchecked)
--- Works with Markdown checkbox syntax: "- [ ]", "* [ ]" or "+ [ ]"
function M.toggle_checkbox()
	local line = vim.fn.getline(".")
	local cursor_line = vim.fn.line(".")
	local checkbox_pattern = "^%s*[-*+]%s*%[([%s%-%*xX])%]"
	local _, _, state = string.find(line, checkbox_pattern)
	local new_line
	if state then
		if state == " " then
			new_line = string.gsub(line, "%[%s%]", "[-]", 1)
		elseif state == "-" then
			new_line = string.gsub(line, "%[%-]", "[x]", 1)
		else
			new_line = string.gsub(line, "%[[xX%*]%]", "[ ]", 1)
		end
		vim.api.nvim_buf_set_lines(0, cursor_line - 1, cursor_line, false, { new_line })
		local cursor_pos = vim.api.nvim_win_get_cursor(0)
		vim.api.nvim_win_set_cursor(0, cursor_pos)
	end
end

return M
