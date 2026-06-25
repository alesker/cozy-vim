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
      size = function(term)
        if term.direction == "horizontal" then
          return vim.o.columns * 0.2
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      direction = "float",
      persist_mode = false,
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

      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        callback = function()
          local scope_core = require("scope.core")

          scope_core.on_tab_leave()
          scope_core.on_tab_enter()
          require("scope.session").save_state()
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceLoadPost",
        callback = function()
          require("scope.session").load_state()
        end,
      })

      vim.api.nvim_create_user_command("PersistenceLoad", function(_)
        require("persistence").load()
      end, { desc = "Restore most recent session" })
    end,
  },
}
