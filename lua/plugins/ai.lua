return {
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
              opencode_send = function(picker)
                local items = vim.tbl_map(function(item)
                  return item.file
                      and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
                    or item.text
                end, picker:selected({ fallback = true }))

                require("opencode").prompt(table.concat(items, ", ") .. " ")
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
      local opencode_config = vim.fn.json_encode({
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

      local terminal = require("toggleterm.terminal").Terminal:new({
        cmd = "opencode --port " .. opencode_port,
        display_name = "OpenCode",
        direction = "vertical",
        hidden = true,
      })

      vim.env.OPENCODE_CONFIG_CONTENT = opencode_config
      vim.g.opencode_opts = {
        server = {
          url = "http://localhost:" .. opencode_port,
          start = function()
            terminal:open()
            terminal:close()
          end,
        },
      }

      local clanker_work = require("util.clanker_work.clanker_work")
      clanker_work.setup({
        client = "opencode",
      })

      vim.keymap.set({ "n" }, "<leader>at", function()
        terminal:toggle()
      end, { desc = "Toggle" })
      vim.keymap.set({ "n", "x" }, "<leader>aw", function()
        clanker_work.schedule()
      end, { desc = "Work" })
      vim.keymap.set({ "n", "x" }, "<leader>ax", function()
        clanker_work.stop_current()
      end, { desc = "Stop Work" })
    end,
  },
}
