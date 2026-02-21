return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    opts = {
      toggle = { enabled = true },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      direction = "float",
      float_opts = {
        border = "rounded",
        title_pos = "center",
        width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      local title = "' Terminal '"
      vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm name=" .. title .. "<cr>", { desc = "Terminal" })
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = Core.create_augroup("quit_toggleterm"),
        pattern = { "toggleterm" },
        callback = function(event)
          vim.schedule(function()
            vim.keymap.set("n", "q", "<cmd>close<cr>", {
              buffer = event.buf,
              silent = true,
              desc = "Quit terminal",
            })
            vim.keymap.set("n", "Q", function()
              Snacks.bufdelete()
            end, {
              buffer = event.buf,
              silent = true,
              desc = "Delete terminal buffer",
            })
          end)
        end,
      })
    end,
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
