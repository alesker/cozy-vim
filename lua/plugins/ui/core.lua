return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      cmdline = {
        view = "cmdline",
        format = {
          cmdline = { conceal = false },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    opts = {
      input = { enabled = true },
      notifier = { enabled = true },
      scroll = { enabled = true },
    },
  },
}
