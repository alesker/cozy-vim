return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "ruby" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "ruby_lsp", "rubocop" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { ruby = { "rubocop" } },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = { ruby = { "codespell" } },
      linters = {},
    },
  },
}
