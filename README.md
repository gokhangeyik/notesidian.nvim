# Notesidian

A very simple Neovim plugin that I developed just for myself.
It helps me create daily notes or to-do lists using Obsidian templates and edit them from within Neovim.

Feel free to use it.

## Installation
I'll only be sharing instructions for the Lazy package manager. I'm sure the snippet below will also serve as a guide for other package managers.

```lua
{
  "gokhangeyik/notesidian.nvim",
  lazy = true,
  dependencies = {
    "MeanderingProgrammer/render-markdown.nvim",
  }
  opts = {
  },
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
```

At minimum, `notes_root` must be defined. Templates should also be created. You can find template examples in the sections below.

## Reminders

Since the plugin doesn't define any keymaps, you can choose ones that suit you. Below you can find the ones I use.

```lua
map("n", "<leader>od", function()
  require("notesidian").create_daily_note()
end, { desc = "Create or edit daily note" })

map("n", "<leader>ol", function()
  require("notesidian").create_todo_list()
end, { desc = "Create or edit Todo List" })

map("n", "<leader>oc", function()
  require("notesidian").toggle_checkbox()
end, { desc = "Toggle Todo List Checkbox" })
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
