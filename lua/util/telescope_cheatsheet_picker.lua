local M = {}

local motions = {
  {
    group = "Word & Line Navigation",
    items = {
      { key = "w", desc = "Next word start" },
      { key = "b", desc = "Previous word start" },
      { key = "e", desc = "End of word" },
      { key = "W", desc = "Next WORD (space-separated)" },
      { key = "B", desc = "Previous WORD (space-separated)" },
      { key = "^", desc = "First non-blank character" },
      { key = "$", desc = "End of line" },
      { key = "0", desc = "Start of line" },
      { key = "f{c}", desc = "Jump to character forward" },
      { key = "t{c}", desc = "Jump till character forward" },
      { key = "F{c}", desc = "Jump to character backward" },
      { key = "T{c}", desc = "Jump till character backward" },
      { key = ";", desc = "Repeat last f/t/F/T" },
      { key = ",", desc = "Repeat last f/t/F/T backward" },
    },
  },

  {
    group = "Vertical & Block Navigation",
    items = {
      { key = "j / k", desc = "Down / up (short distances)" },
      { key = "{", desc = "Previous paragraph / code block" },
      { key = "}", desc = "Next paragraph / code block" },
      { key = "%", desc = "Jump to matching (), {}, []" },
      { key = "[[", desc = "Previous function / section" },
      { key = "]]", desc = "Next function / section" },
      { key = "H", desc = "Top of screen" },
      { key = "M", desc = "Middle of screen" },
      { key = "L", desc = "Bottom of screen" },
    },
  },

  {
    group = "File-Level Navigation",
    items = {
      { key = "gg", desc = "Top of file" },
      { key = "G", desc = "Bottom of file" },
      { key = "{n}G", desc = "Jump to line number" },
      { key = "Ctrl-d", desc = "Half-page down" },
      { key = "Ctrl-u", desc = "Half-page up" },
      { key = "Ctrl-f", desc = "Page down" },
      { key = "Ctrl-b", desc = "Page up" },
    },
  },

  {
    group = "Text Objects (Core)",
    items = {
      { key = "iw", desc = "Inside word" },
      { key = "aw", desc = "Around word" },
      { key = "ip", desc = "Inside paragraph" },
      { key = "ap", desc = "Around paragraph" },
      { key = "i(", desc = "Inside parentheses" },
      { key = "a(", desc = "Around parentheses" },
      { key = "i{", desc = "Inside braces / block" },
      { key = "a{", desc = "Around braces / block" },
      { key = "i[", desc = "Inside brackets" },
      { key = "a[", desc = "Around brackets" },
      { key = 'i"', desc = "Inside double quotes" },
      { key = 'a"', desc = "Around double quotes" },
      { key = "i'", desc = "Inside single quotes" },
      { key = "a'", desc = "Around single quotes" },
    },
  },

  {
    group = "Operators (Combine with Motions)",
    items = {
      { key = "d", desc = "Delete" },
      { key = "c", desc = "Change" },
      { key = "y", desc = "Yank" },
      { key = ">", desc = "Indent" },
      { key = "<", desc = "Unindent" },
      { key = "=", desc = "Format / reindent" },
      { key = "gU", desc = "Uppercase" },
      { key = "gu", desc = "Lowercase" },
    },
  },

  {
    group = "Change & Jump History",
    items = {
      { key = "u", desc = "Undo" },
      { key = "Ctrl-r", desc = "Redo" },
      { key = "g;", desc = "Jump to previous change" },
      { key = "g,", desc = "Jump to next change" },
      { key = "Ctrl-o", desc = "Jump back" },
      { key = "Ctrl-i", desc = "Jump forward" },
    },
  },

  {
    group = "High-Impact Code Edits",
    items = {
      { key = "ci(", desc = "Change function arguments" },
      { key = "ci{", desc = "Change block contents" },
      { key = "di{", desc = "Delete block contents" },
      { key = "dap", desc = "Delete a paragraph" },
      { key = "yap", desc = "Yank a paragraph" },
      { key = "va{", desc = "Select entire block" },
    },
  },
}

function M.create()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local entry_display = require("telescope.pickers.entry_display")

  local items = {}

  for _, entry in pairs(motions) do
    table.insert(items, {
      group = entry.group,
    })

    for _, item in ipairs(entry.items) do
      table.insert(items, item)
    end
  end

  local group_displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 7 },
      { remaining = true },
    },
  })

  local item_displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 26 },
      { remaining = true },
    },
  })

  local function make_display(entry)
    if entry.group then
      local group = string.format("───── %s ─────", entry.group)
      return group_displayer({
        { "", "" },
        { group, "TelescopeResultsComment" },
      })
    end

    return item_displayer({
      { entry.key, "TelescopeResultsFunction" },
      { entry.desc, "TelescopeResultsIdentifier" },
    })
  end

  return pickers.new({}, {
    prompt_title = "Motions Cheatsheet",
    finder = finders.new_table({
      results = items,
      entry_maker = function(entry)
        return {
          ordinal = entry.group or table.concat({ entry.key, entry.desc }),
          display = make_display,
          key = entry.key,
          desc = entry.desc,
          group = entry.group,
        }
      end,
    }),
    sorting_strategy = "ascending",
    layout_config = { prompt_position = "top" },
    attach_mappings = function(bufnr, _)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(bufnr)

        vim.schedule(function()
          if not entry or not entry.mode or not entry.lhs then
            return
          end
          local keys = vim.api.nvim_replace_termcodes(entry.lhs, true, false, true)
          vim.api.nvim_feedkeys(keys, "", false)
        end)
      end)
      return true
    end,
  })
end

return M
