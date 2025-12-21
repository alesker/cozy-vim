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
}
