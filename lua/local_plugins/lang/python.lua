return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "python" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "pyright" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      ensure_installed = { "ruff" },
      formatters_by_ft = { python = { "ruff_format" } },
      formatters = {},
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      ensure_installed = { "ruff" },
      linters_by_ft = { python = { "ruff" } },
      linters = {},
    },
  },
}
