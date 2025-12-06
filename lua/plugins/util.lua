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
    event = "BufReadPre",
    opts = {},
  },
}
