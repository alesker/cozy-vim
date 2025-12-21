return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "zsh" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {},
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {},
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      ensure_installed = { "shfmt" },
      formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      ensure_installed = { "shellcheck" },
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        zsh = { "shellcheck" },
      },
      linters = {},
    },
  },
}
