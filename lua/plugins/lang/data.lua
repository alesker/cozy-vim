return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "json", "yaml", "toml" } },
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
      ensure_installed = { "jq", "yamlfmt" },
      formatters_by_ft = {
        json = { "jq" },
        yaml = { "yamlfmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      ensure_installed = { "jq", "yamllint" },
      linters_by_ft = {
        json = { "jq" },
        yaml = { "yamllint" },
      },
      linters = {},
    },
  },
}
