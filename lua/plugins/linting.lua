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

      for name, linter in pairs(opts.linters) do
        local default_linter = lint.linters[name]
        if type(linter) == "table" and type(default_linter) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", default_linter, linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = vim.list_extend(default_linter.args or {}, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end

      lint.linters_by_ft = opts.linters_by_ft

      vim.api.nvim_create_autocmd(opts.events, {
        group = Core.create_augroup("nvim-lint"),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
