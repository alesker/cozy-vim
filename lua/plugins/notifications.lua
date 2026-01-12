return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      commands = {
        history = {
          view = "popup",
        },
        last = {
          view = "notify",
        },
      },
    },
    keys = {
      {
        "<leader>nl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Last Message",
      },
      {
        "<leader>nh",
        function()
          require("noice").cmd("history")
        end,
        desc = "History",
      },

      {
        "<leader>sn",
        "<cmd>Telescope noice results_title=Notifications prompt_title=Search<cr>",
        desc = "Notifications",
      },
    },
  },
}
