return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "html", "css" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "html", "cssls" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      ensure_installed = { "prettier" },
      formatters_by_ft = {
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
      },
      formatters = {},
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      ensure_installed = { "stylelint" },
      linters_by_ft = {
        css = { "stylelint" },
        scss = { "stylelint" },
      },
      linters = {
        stylelint = {
          condition = function(ctx)
            return vim.fs.find({
              ".stylelintrc",
              ".stylelintrc.json",
              ".stylelintrc.yaml",
              ".stylelintrc.yml",
              ".stylelintrc.js",
              ".stylelintrc.cjs",
              "stylelint.config.js",
              "stylelint.config.cjs",
              "stylelint.config.mjs",
            }, { path = vim.fs.dirname(ctx.filename), upward = true })[1] ~= nil
          end,
        },
      },
    },
  },
}
