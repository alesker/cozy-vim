return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "go" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "gopls" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      ensure_installed = { "goimports" },
      formatters_by_ft = { go = { "goimports" } },
      formatters = {},
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      ensure_installed = {},
      linters_by_ft = { go = {} },
      linters = {},
    },
  },
}
