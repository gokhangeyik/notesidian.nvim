# Notesidian

A very simple - *maybe not that simple anymore* - Neovim plugin that I developed just for myself.
It helps me create daily notes or to-do lists using Obsidian templates and edit them from within Neovim.

Feel free to use it.

# Features
 - Creates a Todo list using the template you can find below or one you create yourself
 - Enables you to create daily notes. You can also create and edit notes for today, yesterday, and tomorrow.
   - Check the keymaps below, with the day offset feature you have the flexibility to create notes for any specific day
 - With Search, you can search for your notes throughout your entire Obsidian vault and edit them.
 - Provides 3-stage checkbox management for Todo lists (Todo, In progress, Done)
 - Does all this completely independent of Obsidian. In other words, you don't need to install Obsidian for this plugin.
 - Notes and Todo lists open in a floating window by default


## Installation
I'll only be sharing instructions for the Lazy package manager. I'm sure the snippet below will also serve as a guide for other package managers.

```lua
{
  "gokhangeyik/notesidian.nvim",
  lazy = true,
  dependencies = {
    --- pick your favorite markdown plugin, this is my favorite
    "MeanderingProgrammer/render-markdown.nvim",
  }
  opts = {},
}
```

### Default Options
The following lines will be inside `opts = {}` and the plugin provides these defaults

```lua
notes_root = "", -- Path to Obsidian Vault
daily_notes_path = "Notes/Dailies", -- Where daily notes will be saved
template_path = "Templates", -- Where templates are located
date_format = "%Y-%m-%d", -- Date format to replace {{date}} pattern in templates
todo_list_prefix = "Personal", -- Prefix for todo list title and filename, replaces {{title}} string
todo_template = "TodoList.md", -- Todo list template
note_template = "Note.md", -- Daily note template
snacks_picker = false, -- Enable or disable Snacks picker support
win_style = "float", -- float or anything else
```

At minimum, `notes_root` must be defined. Templates should also be created. You can find template examples in the sections below.

## Reminders

Since the plugin doesn't define any keymaps, you can choose ones that suit you. Below you can find the ones I use.

```lua
map("n", "<leader>od", function()
  require("notesidian").create_daily_note()
end, { desc = "Create or edit daily note (Today)" })

map("n", "<leader>oy", function()
  require("notesidian").create_daily_note(-1)
end, { desc = "Create or edit daily note (Yesterday)" })

map("n", "<leader>ot", function()
  require("notesidian").create_daily_note(1)
end, { desc = "Create or edit daily note (Tomorrow)" })

map("n", "<leader>ol", function()
  require("notesidian").create_todo_list()
end, { desc = "Create or edit Todo List" })

map("n", "<leader>oc", function()
  require("notesidian").toggle_checkbox()
end, { desc = "Toggle Checkbox" })

map("n", "<leader>of", function()
  require("notesidian").find_notes()
end, { desc = "Search Notes" })
```

## Note and Todolist Templates

### Daily Note Template
```markdown
---
tags: ["notes"]
date: {{date}}
---

```

### Todo List Template
```markdown
---
tags:
  - todo
date: {{date}}
---
# {{title}}

- [ ] Example Item
```
