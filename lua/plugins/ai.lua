return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {
      request_timeout = 2,
      throttle = 1000,
      debounce = 200,

      context_window = 1024,

      stream = true,

      n_completions = 1,
      add_single_line_entry = true,

      after_cursor_filter_length = 16,

      virtualtext = {
        auto_trigger_ft = {},
        show_on_completion_menu = false,
        keymap = {
          accept = "<A-A>",
          accept_line = "<A-a>",
          accept_n_lines = "<A-z>",
          prev = "<A-[>",
          next = "<A-]>",
          dismiss = "<A-e>",
        },
      },

      provider = "openai",
      provider_options = {
        openai = {
          api_key = "OPENAI_NEOVIM_MINUET_KEY",
          model = "gpt-5.4-mini",
          end_point = "https://api.openai.com/v1/chat/completions",
          optional = {
            max_completion_tokens = 64,
            reasoning_effort = "none",
          },
        },
      },
    },
    config = function(_, opts)
      require("minuet").setup(opts)
      vim.api.nvim_set_hl(0, "MinuetVirtualText", {
        link = "Comment",
      })
    end,
  },
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    dependencies = {
      {
        "folke/snacks.nvim",
        optional = true,
        opts = {
          input = {},
          picker = {
            actions = {
              opencode_send = function(...)
                return require("opencode").snacks_picker_send(...)
              end,
            },
          },
        },
      },
    },
    config = function()
      vim.g.opencode_opts = {}
      vim.o.autoread = true

      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "OpenCode Ask" })
      vim.keymap.set({ "n", "x" }, "<leader>oo", function()
        require("opencode").select()
      end, { desc = "OpenCode Select" })
      vim.keymap.set("n", "<leader>os", function()
        require("opencode").select_session()
      end, { desc = "OpenCode Sessions" })
      vim.keymap.set({ "n", "t" }, "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "OpenCode Toggle" })
    end,
  },
}
