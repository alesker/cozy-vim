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
    require("lualine").setup({
      options = {
        disabled_filetypes = { statusline = { "alpha" } },
        component_separators = "",
        section_separators = { left = Core.icons.statusline.bubble_left, right = Core.icons.statusline.bubble_right },
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
          "diff",
        },
        lualine_x = {
          {
            "diagnostics",
            symbols = {
              info = Core.icons.diagnostics.info .. " ",
              warn = Core.icons.diagnostics.warn .. " ",
              error = Core.icons.diagnostics.error .. " ",
              hint = Core.icons.diagnostics.hint .. " ",
            },
          },
        },
        lualine_y = {
          "progress",
        },
        lualine_z = {
          { "location", separator = { right = Core.icons.statusline.bubble_left } },
        },
      },
      extensions = { "neo-tree", "lazy" },
    })
  end,
}
