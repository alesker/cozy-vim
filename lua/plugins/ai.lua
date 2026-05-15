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
      local pair_programmer = {
        agent = "pair-programmer",
        model = "openai/gpt-5.5",
        reasoning = "low",
        verbosity = "low",
      }

      local function get_free_port()
        local tcp = assert(vim.uv.new_tcp())
        assert(tcp:bind("127.0.0.1", 0))
        local port = assert(tcp:getsockname()).port
        tcp:close()
        return port
      end

      local opencode_port = get_free_port()

      local function opencode_command()
        local config = vim.fn.json_encode({
          default_agent = pair_programmer.agent,
          agent = {
            [pair_programmer.agent] = {
              hidden = false,
              model = pair_programmer.model,
              reasoningEffort = pair_programmer.reasoning,
              textVerbosity = pair_programmer.verbosity,
            },
          },
        })

        return table.concat({
          "OPENCODE_CONFIG_CONTENT=" .. vim.fn.shellescape(config),
          "opencode",
          "--port",
          tostring(opencode_port),
        }, " ")
      end

      vim.g.opencode_opts = {
        server = {
          port = opencode_port,
          start = function()
            require("opencode.terminal").open(opencode_command())
          end,
          stop = function()
            require("opencode.terminal").close()
          end,
          toggle = function()
            require("opencode.terminal").toggle(opencode_command())
          end,
        },
      }

      local opencode_work = require("util.opencode_work.opencode_work")
      opencode_work.setup()

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
      vim.keymap.set({ "n", "x" }, "<leader>ow", function()
        opencode_work.schedule()
      end, { desc = "OpenCode Work" })
      vim.keymap.set("n", "<leader>ox", function()
        opencode_work.stop_current()
      end, { desc = "OpenCode Work Stop" })
    end,
  },
}
