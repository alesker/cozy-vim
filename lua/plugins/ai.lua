return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {
      provider = "openai",

      request_timeout = 2,
      throttle = 1200,
      debounce = 300,

      context_window = 2048,

      stream = true,

      n_completions = 1,
      add_single_line_entry = true,

      after_cursor_filter_length = 15,

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

      provider_options = {
        openai = {
          api_key = "OPENAI_NEOVIM_MINUET_KEY",
          model = "gpt-4.1-mini",
          stream = true,
          optional = {
            max_completion_tokens = 64,
            temperature = 0.2,
            top_p = 1,
          },
        },
      },
    },
  },
}
