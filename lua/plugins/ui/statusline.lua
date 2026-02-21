return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,

  config = function()
    vim.o.laststatus = vim.g.lualine_laststatus

    local function registry_recording()
      local regname = vim.fn.reg_recording()
      return " recording @" .. regname
    end

    local function should_show_registry_recording()
      return vim.fn.reg_recording() ~= ""
    end

    local function location()
      local line = vim.fn.line(".")
      local col = vim.fn.charcol(".")
      return string.format("%3d:%-2d", line, col)
    end

    local function total_lines()
      local lines = vim.fn.line("$")
      return string.format("[%d]", lines)
    end

    require("lualine").setup({
      options = {
        disabled_filetypes = { statusline = { "alpha" } },
        component_separators = "",
        section_separators = {
          left = Core.icons.statusline.bubble_left,
          right = Core.icons.statusline.bubble_right,
        },
        theme = function()
          -- need to do this because of the bug where section_separators disappear if b and c section bg colors are the same
          local background = vim.opt.background:get()
          local gruvbox_patched = require("lualine.themes.gruvbox_" .. background)

          gruvbox_patched.insert.c.bg = gruvbox_patched.normal.c.bg
          gruvbox_patched.insert.c.fg = gruvbox_patched.normal.c.fg
          gruvbox_patched.visual.c.bg = gruvbox_patched.normal.c.bg
          gruvbox_patched.visual.c.fg = gruvbox_patched.normal.c.fg
          gruvbox_patched.replace.c.bg = gruvbox_patched.normal.c.bg
          gruvbox_patched.replace.c.fg = gruvbox_patched.normal.c.fg
          gruvbox_patched.command.c.bg = gruvbox_patched.normal.c.bg
          gruvbox_patched.command.c.fg = gruvbox_patched.normal.c.fg
          gruvbox_patched.inactive.c.bg = gruvbox_patched.normal.c.bg
          gruvbox_patched.inactive.c.fg = gruvbox_patched.normal.c.fg

          gruvbox_patched.terminal = gruvbox_patched.command

          return gruvbox_patched
        end,
      },

      sections = {
        lualine_a = {
          { "mode", separator = { left = Core.icons.statusline.bubble_right } },
        },
        lualine_b = {
          "filename",
          { "filetype", icon_only = true, padding = {} },
        },
        lualine_c = {
          { "branch", icon = Core.icons.git.branch },
          { "diff", padding = {} },

          {
            registry_recording,
            color = { fg = "Red", gui = "italic,bold" },
            cond = should_show_registry_recording,
          },
        },
        lualine_x = {
          {
            "diagnostics",
            symbols = {
              info = Core.icons.diagnostics.info,
              warn = Core.icons.diagnostics.warn,
              error = Core.icons.diagnostics.error,
              hint = Core.icons.diagnostics.hint,
            },
          },
        },
        lualine_y = {
          { "lsp_status", symbols = { separator = " " .. Core.icons.statusline.separator .. " " } },
        },
        lualine_z = {
          { location, color = { gui = "italic,bold" }, padding = {} },
          { total_lines, color = { gui = "bold" }, separator = { right = Core.icons.statusline.bubble_left } },
        },
      },

      extensions = {
        "lazy",
        "mason",
        "neo-tree",
        "trouble",
      },
    })
  end,
}
