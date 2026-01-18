Core = {}

Core.augroup_prefix = "neovim_"

Core.create_augroup = function(name)
  return vim.api.nvim_create_augroup(Core.augroup_prefix .. name, { clear = true })
end

Core.tab_key = function(id)
  return "tab:" .. tostring(id or vim.api.nvim_get_current_tabpage())
end

Core.icons = {
  file = " ",
  files = " ",
  search = " ",
  list = " ",
  settings = " ",
  prompt = "",
  git = {
    branch = "",
    diff = {
      add = "+",
      change = "~",
      delete = "_",
      topdelete = "‾",
      changedelete = "~",
    },
  },
  diagnostics = {
    info = " ",
    warn = " ",
    error = " ",
    hint = " ",
  },
  statusline = {
    separator = "|",
    bubble_left = "",
    bubble_right = "",
  },
  explorer = {
    dir_collapsed = "",
    dir_expanded = "",
  },
  harpoon = "󱡅 ",
  target = "󰣉 ",
  insights = "󰉹 ",
  lazy = "󰒲 ",
  mason = " ",
  oil = " ",
}

Core.icons.dashboard = {
  new_file = Core.icons.file,
  find_file = Core.icons.search,
  recent_files = Core.icons.files,
  find_text = Core.icons.search,
  config = Core.icons.settings,
  restore_session = " ",
  lazy = Core.icons.lazy,
  mason = Core.icons.mason,
  quit = " ",
}

Core.icons.telescope = {
  prompt_prefix = Core.icons.prompt .. " ",
  selection_caret = " ",
}

Core.icons.cmdline = {
  cmdline = Core.icons.prompt,
  search_down = Core.icons.search .. "",
  search_up = Core.icons.search .. "",
}

vim.diagnostic.config({
  underline = true,
  update_in_insert = false,

  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.INFO] = Core.icons.diagnostics.info,
      [vim.diagnostic.severity.WARN] = Core.icons.diagnostics.warn,
      [vim.diagnostic.severity.ERROR] = Core.icons.diagnostics.error,
      [vim.diagnostic.severity.HINT] = Core.icons.diagnostics.hint,
    },
  },
})
