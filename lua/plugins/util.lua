return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    opts = {
      toggle = { enabled = true },
    },
  },
  {
    "folke/persistence.nvim",
    opts = {},
    config = function(_, opts)
      require("persistence").setup(opts)

      vim.api.nvim_create_user_command("PersistenceLoad", function(_)
        require("persistence").load()
      end, { desc = "Restore most recent session" })
    end,
  },
}
