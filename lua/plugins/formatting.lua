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
      ensure_installed = {},
    },
    opts_extend = { "ensure_installed" },
    config = function(_, opts)
      local util = require("util")
      util.ensure_installed(opts.ensure_installed)

      require("conform").setup(opts)
    end,
  },
  {
    { "NMAC427/guess-indent.nvim" },
  },
}
