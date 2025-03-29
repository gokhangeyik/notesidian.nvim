local M = {}
local _config = {
	notes_root = "",
	daily_notes_path = "Notes/Dailies",
	template_path = "Templates",
	date_format = "%Y-%m-%d",
	todo_scope = "Personal",
	todo_template = "TodoList.md",
	note_template = "Note.md",
}

function M.setup(opts)
	_config = vim.tbl_deep_extend("force", _config, opts or {})
	_config.notes_root = vim.fn.expand(_config.notes_root)
	_config.template_path = vim.fs.joinpath(_config.notes_root, _config.template_path)
	_config.daily_notes_path = vim.fs.joinpath(_config.notes_root, _config.daily_notes_path)
	_config.note_template_file = vim.fs.joinpath(_config.template_path, _config.note_template)
	_config.todo_template_file = vim.fs.joinpath(_config.template_path, _config.todo_template)
end

local new_note_from_template = function(template)
	if not template then
		return
	end

	local template_file = template

	local file_content = ""
	local f = io.open(template_file, "r")
	if f then
		file_content = f:read("*all")
		f:close()
	else
		vim.notify("Template file inaccessible: " .. template_file, vim.log.levels.ERROR)
		return
	end

	local current_date = os.date(_config.date_format)

	file_content = string.gsub(file_content, "{{date}}", current_date)

	local target_filename = os.date(_config.date_format) .. ".md"
	local target_file = vim.fs.joinpath(_config.daily_notes_path, target_filename)

	local file_exists = vim.loop.fs_stat(target_file) ~= nil

	if file_exists then
		vim.cmd("edit " .. target_file)
		return
	end

	local daily_dir_stat = vim.loop.fs_stat(_config.daily_notes_path)
	if not daily_dir_stat then
		vim.fn.mkdir(_config.daily_notes_path, "p")
	end

	local new_file = io.open(target_file, "w")
	if new_file then
		new_file:write(file_content)
		new_file:close()

		vim.cmd("edit " .. target_file)
	else
		vim.notify("Can't create new note: " .. target_file, vim.log.levels.ERROR)
	end
end

function M.create_daily_note()
	new_note_from_template(_config.note_template_file)
end

function M.create_todo_list()
	if not _config.todo_template_file then
		return
	end

	local template_file = _config.todo_template_file

	local file_content = ""
	local f = io.open(template_file, "r")
	if f then
		file_content = f:read("*all")
		f:close()
	else
		vim.notify("Template file inaccessible: " .. template_file, vim.log.levels.ERROR)
		return
	end

	local current_date = os.date(_config.date_format)

	file_content = string.gsub(file_content, "{{date}}", current_date)
	file_content = string.gsub(file_content, "{{title}}", _config.todo_scope .. " Todo List")

	local target_filename = _config.todo_scope .. " - TodoList.md"
	local target_file = vim.fs.joinpath(_config.notes_root, target_filename)

	local file_exists = vim.loop.fs_stat(target_file) ~= nil

	if file_exists then
		vim.cmd("edit " .. target_file)
		return
	end

	local new_file = io.open(target_file, "w")
	if new_file then
		new_file:write(file_content)
		new_file:close()

		vim.cmd("edit " .. target_file)
	else
		vim.notify("Can't create todo list: " .. target_file, vim.log.levels.ERROR)
	end
end
return M
