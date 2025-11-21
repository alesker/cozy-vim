return {
  "stevearc/conform.nvim",

  dependencies = { "mason.nvim" },
  opts = {

    default_format_opts = {
      timeout_ms = 1000,
      async = false,
      quiet = false,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      ruby = { "rubocop" },
    },
    format_on_save = {},
  },
}
