return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "markdown" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "marksman" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      ensure_installed = {},
      formatters_by_ft = { markdown = {} },
      formatters = {},
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      ensure_installed = {},
      linters_by_ft = { markdown = {} },
      linters = {},
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      sign = { enabled = false },
      code = {
        width = "block",
        left_pad = 2,
        right_pad = 2,
      },
      heading = {
        width = "block",
      },
      pipe_table = {
        -- stylua: ignore
        border = {
            "╭", "┬", "╮",
            "├", "┼", "┤",
            "╰", "┴", "╯",
            "│", "─",
        },
        alignment_indicator = "═",
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Snacks.toggle({
        name = "Render Markdown",
        get = require("render-markdown").get,
        set = require("render-markdown").set,
      }):map("<leader>um")
    end,
  },
}
