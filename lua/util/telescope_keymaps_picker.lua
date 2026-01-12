M = {}

local function keymaps(opts)
  local items = {}
  for _, mode in ipairs(opts.modes) do
    for _, keymap in ipairs(vim.api.nvim_get_keymap(mode)) do
      local lhs = keymap.lhs or ""
      local ok = lhs ~= ""
        and (opts.show_plug or not lhs:find("<Plug>", 1, true))
        and (not opts.lhs_filter or opts.lhs_filter(lhs))
        and (not opts.filter or opts.filter(keymap))

      if ok then
        table.insert(items, {
          mode = mode,
          lhs = lhs,
          desc = keymap.desc or "",
          rhs = keymap.rhs or "",
        })
      end
    end
  end

  return items
end

function M.create(opts)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local entry_display = require("telescope.pickers.entry_display")

  local wk_config = require("which-key.config")
  local wk_icons = require("which-key.icons")
  local wk_view = require("which-key.view")

  local items = keymaps(opts)

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 5 },
      { width = 26 },
      { width = 2 },
      { remaining = true },
    },
  })

  local function make_display(entry)
    local mode = string.format("[%s]", entry.mode)
    local keymap = wk_view.format(entry.lhs)
    local show_icons = wk_config.options.icons.mappings
    local icon, hl = wk_icons.get(entry)

    return displayer({
      { mode, "TelescopeResultsComment" },
      { keymap, "TelescopeResultsFunction" },
      { (show_icons and icon or nil) or "", hl },
      { entry.desc, "TelescopeResultsIdentifier" },
    })
  end

  return pickers.new({}, {
    prompt_title = "Keymaps",
    finder = finders.new_table({
      results = items,
      entry_maker = function(entry)
        return {
          ordinal = table.concat({ entry.mode, entry.lhs, entry.desc, entry.rhs }),
          display = make_display,
          mode = entry.mode,
          lhs = entry.lhs,
          rhs = entry.rhs,
          desc = entry.desc,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
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
