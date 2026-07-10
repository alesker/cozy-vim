return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "php" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "intelephense" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      ensure_installed = { "php-cs-fixer" },
      formatters_by_ft = { php = { "php_cs_fixer" } },
      formatters = {},
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      ensure_installed = { "phpstan" },
      linters_by_ft = { php = { "phpstan" } },
      linters = {},
    },
  },
}
