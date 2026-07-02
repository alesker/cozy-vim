return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "javascript", "typescript", "tsx" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "ts_ls" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      ensure_installed = { "prettier" },
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
      },
      formatters = {},
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      ensure_installed = { "eslint_d" },
      linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      },
      linters = {
        eslint_d = {
          condition = function(ctx)
            return vim.fs.find({
              "eslint.config.js",
              "eslint.config.mjs",
              "eslint.config.cjs",
              "eslint.config.ts",
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.json",
              ".eslintrc.yaml",
              ".eslintrc.yml",
            }, { path = vim.fs.dirname(ctx.filename), upward = true })[1] ~= nil
          end,
        },
      },
    },
  },
}
