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
}
