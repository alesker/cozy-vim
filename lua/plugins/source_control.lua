return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "esmuellert/codediff.nvim",
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
      diff_viewer = "codediff",
      integrations = {
        telescope = true,
        codediff = true,
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
          ["za"] = false,
          ["<space>"] = "Toggle",
        },
      },
    },
    config = function(_, opts)
      local neogit = require("neogit")
      local pending_file

      neogit.setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "NeogitStatusRefreshed",
        callback = function()
          if not pending_file then
            return
          end

          vim.schedule(function()
            local status = require("neogit.buffers.status").instance(vim.fn.getcwd())
            local item_index = status and status.buffer and status.buffer.ui and status.buffer.ui.item_index or {}

            for _, section in ipairs(item_index) do
              for _, item in ipairs(section.items or {}) do
                if item.absolute_path == pending_file then
                  status.buffer:move_cursor(item.first)
                  pending_file = nil
                  return
                end
              end
            end

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
  {
    "esmuellert/codediff.nvim",
    opts = {
      keymaps = {
        view = {
          quit = "q",
          next_hunk = "]]",
          prev_hunk = "[[",
          stage_hunk = "gs",
          unstage_hunk = "gu",
          discard_hunk = "gr",
          toggle_layout = "l",
          toggle_explorer = ".",
          show_help = "?",
          next_file = "}}",
          prev_file = "{{",
          hunk_textobject = "ih",
          align_move = false,
          open_in_prev_tab = false,
          diff_get = false,
          diff_put = false,
          focus_explorer = false,
          toggle_stage = false,
        },
        explorer = {
          select = "<CR>",
          toggle_view_mode = "t",
          hover = false,
          refresh = false,
          stage_all = false,
          unstage_all = false,
          restore = false,
          toggle_changes = false,
          toggle_staged = false,
          fold_open = false,
          fold_open_recursive = false,
          fold_close = false,
          fold_close_recursive = false,
          fold_toggle = false,
          fold_toggle_recursive = false,
          fold_open_all = false,
          fold_close_all = false,
        },
        history = {
          select = false,
          toggle_view_mode = false,
          refresh = false,
          fold_open = false,
          fold_open_recursive = false,
          fold_close = false,
          fold_close_recursive = false,
          fold_toggle = false,
          fold_toggle_recursive = false,
          fold_open_all = false,
          fold_close_all = false,
        },
        conflict = {
          accept_incoming = false,
          accept_current = false,
          accept_both = false,
          discard = false,
          accept_all_incoming = false,
          accept_all_current = false,
          accept_all_both = false,
          discard_all = false,
          next_conflict = false,
          prev_conflict = false,
          diffget_incoming = false,
          diffget_current = false,
        },
      },
    },
  },
}
