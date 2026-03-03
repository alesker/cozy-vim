local function theme(colors)
  local b = { bg = colors.lightgray, fg = colors.light }
  local c = { bg = colors.darkgray, fg = colors.gray }
  local modes = {
    normal = {
      a = { bg = colors.gray, fg = colors.dark, gui = "bold" },
      b = b,
      c = c,
    },
    insert = {
      a = { bg = colors.blue, fg = colors.dark, gui = "bold" },
      b = b,
      c = c,
    },
    visual = {
      a = { bg = colors.yellow, fg = colors.dark, gui = "bold" },
      b = b,
      c = c,
    },
    replace = {
      a = { bg = colors.red, fg = colors.dark, gui = "bold" },
      b = b,
      c = c,
    },
    command = {
      a = { bg = colors.green, fg = colors.dark, gui = "bold" },
      b = b,
      c = c,
    },
    inactive = {
      a = { bg = colors.darkgray, fg = colors.lightgray, gui = "bold" },
      b = b,
      c = c,
    },
  }
  modes.terminal = modes.command
  return modes
end

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
          local background = vim.opt.background:get()
          local gruvbox = require("gruvbox")
          local palette = gruvbox.palette

          return theme({
            light = background == "dark" and palette.light0 or palette.dark0,
            dark = background == "dark" and palette.dark0 or palette.light0,
            gray = palette.gray,
            lightgray = background == "dark" and palette.dark3 or palette.light3,
            darkgray = background == "dark" and palette.dark1 or palette.light1,
            blue = palette.neutral_blue,
            yellow = palette.neutral_orange,
            red = palette.neutral_red,
            green = palette.neutral_aqua,
          })
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
