return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      presets = {
        lsp_doc_border = true,
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        signature = {
          auto_open = {
            enabled = false,
          },
        },
      },
      cmdline = {
        view = "cmdline",
        format = {
          cmdline = {
            conceal = false,
            icon = Core.icons.cmdline.cmdline,
          },
          search_down = { icon = Core.icons.cmdline.search_down },
          search_up = { icon = Core.icons.cmdline.search_up },
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
