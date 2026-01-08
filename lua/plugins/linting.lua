return {
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    opts = {
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {},
      ensure_installed = {},
    },
    opts_extend = { "ensure_installed" },
    config = function(_, opts)
      local installer = require("util.mason_package_installer")
      installer.ensure_installed(opts.ensure_installed)

      local lint = require("lint")

      lint.linters_by_ft = opts.linters_by_ft

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
