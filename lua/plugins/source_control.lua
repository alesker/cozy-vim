return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      kind = "floating",
      graph_style = "unicode",
      process_spinner = true,
      disable_line_numbers = true,
      disable_relative_line_numbers = true,
      notification_icon = Core.icons.git.branch,
      commit_editor = {
        kind = "floating",
      },
      preview_buffer = {
        kind = "floating",
      },
      floating = {
        relative = "editor",
        width = 0.8,
        height = 0.8,
        style = "minimal",
        border = "rounded",
      },
      integrations = {
        telescope = true,
      },
      signs = {
        hunk = { "", "" },
        item = { Core.icons.explorer.dir_collapsed, Core.icons.explorer.dir_expanded },
        section = { Core.icons.explorer.dir_collapsed, Core.icons.explorer.dir_expanded },
      },
      mappings = {
        status = {
          ["<tab>"] = "NextSection",
          ["<s-tab>"] = "PreviousSection",
          ["<space>"] = "Toggle",
          ["za"] = false,
        },
      },
    },
    config = function(_, opts)
      local neogit = require("neogit")
      local pending_file

      neogit.setup(opts)

      vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight", { link = "NeogitDiffAdd" })
      vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", { link = "NeogitDiffDelete" })
      local function focus_pending_file()
        local status = require("neogit.buffers.status").instance(vim.fn.getcwd())
        local item_index = vim.tbl_get(status or {}, "buffer", "ui", "item_index") or {}

        for _, section in ipairs(item_index) do
          for _, item in ipairs(section.items or {}) do
            if item.absolute_path == pending_file then
              status.buffer:move_cursor(item.first)
              return
            end
          end
        end
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "NeogitStatusRefreshed",
        callback = function()
          if not pending_file then
            return
          end
          vim.schedule(function()
            focus_pending_file()
            pending_file = nil
          end)
        end,
      })

      vim.keymap.set("n", "<leader>gg", function()
        local current_file = vim.api.nvim_buf_get_name(0)
        local open_opts

        if current_file ~= "" then
          pending_file = current_file
          open_opts = { cwd = vim.fn.expand("%:p:h") }
        end

        neogit.open(open_opts)
      end, { desc = "Open Git status" })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = Core.icons.git.diff.add },
        change = { text = Core.icons.git.diff.change },
        delete = { text = Core.icons.git.diff.delete },
        topdelete = { text = Core.icons.git.diff.topdelete },
        changedelete = { text = Core.icons.git.diff.changedelete },
      },
      preview_config = {
        border = "rounded",
      },
      on_attach = function(buffer)
        local gitsigns = package.loaded.gitsigns

        vim.keymap.set("n", "<leader>gb", function()
          gitsigns.blame_line({ full = true })
        end, { buffer = buffer, desc = "Blame Line", silent = true })
        vim.keymap.set("n", "<leader>gB", function()
          gitsigns.blame()
        end, { buffer = buffer, desc = "Blame Buffer", silent = true })
        vim.keymap.set("n", "<leader>gt", function()
          gitsigns.toggle_current_line_blame()
        end, { buffer = buffer, desc = "Toggle current line blame", silent = true })

        vim.keymap.set("n", "]g", gitsigns.next_hunk, { buffer = buffer, desc = "Next Git hunk", silent = true })
        vim.keymap.set("n", "[g", gitsigns.prev_hunk, { buffer = buffer, desc = "Previous Git hunk", silent = true })

        vim.keymap.set(
          "n",
          "<leader>gp",
          gitsigns.preview_hunk,
          { buffer = buffer, desc = "Preview hunk", silent = true }
        )

        vim.keymap.set("v", "<leader>gs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { buffer = buffer, desc = "Stage/unstage selected lines", silent = true })
        vim.keymap.set("v", "<leader>gr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { buffer = buffer, desc = "Reset selected lines", silent = true })

        vim.keymap.set(
          { "o", "x" },
          "ih",
          ":<C-U>Gitsigns select_hunk<CR>",
          { buffer = buffer, desc = "Select hunk", silent = true }
        )
      end,
    },
  },
}
