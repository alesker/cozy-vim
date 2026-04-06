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
      ensure_installed = { "jq", "yamlfmt", "tombi" },
      formatters_by_ft = {
        json = { "jq" },
        yaml = { "yamlfmt" },
        toml = { "tombi" },
      },
      formatters = {
        yamlfmt = {
          prepend_args = { "-formatter", "retain_line_breaks_single=true" },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      ensure_installed = { "jq", "yamllint", "tombi" },
      linters_by_ft = {
        json = { "jq" },
        yaml = { "yamllint" },
        toml = { "tombi" },
      },
      linters = {
        yamllint = {
          prepend_args = {
            "--config-data",
            "{extends: relaxed, rules: {line-length: {max: 120}}}",
          },
        },
      },
    },
  },
}
