return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      default_format_opts = {
        timeout_ms = 1000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters_by_ft = {},
      format_on_save = {},
    },
  },
  {
    { "NMAC427/guess-indent.nvim" },
  },
}
