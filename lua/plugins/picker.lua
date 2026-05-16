return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope-ui-select.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "neovim/nvim-lspconfig",
      "LukasPietzschmann/telescope-tabs",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      local function open_trouble_quickfix(prompt_bufnr)
        actions.smart_send_to_qflist(prompt_bufnr)
        require("trouble").open({ mode = "quickfix", focus = true })
      end

      telescope.setup({
        pickers = {
          find_files = { hidden = true },
          oldfiles = { only_cwd = true },
          buffers = { sort_mru = true, sort_lastused = true },
        },
        defaults = {
          file_ignore_patterns = {
            "%.DS_Store$",
            "^%.git/",
          },
          prompt_prefix = Core.icons.telescope.prompt_prefix,
          selection_caret = Core.icons.telescope.selection_caret,
          mappings = {
            i = {
              ["<C-q>"] = open_trouble_quickfix,
            },
            n = {
              ["<C-q>"] = open_trouble_quickfix,
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("noice")
      telescope.load_extension("telescope-tabs")

      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader><leader>", builtin.resume, { desc = "Resume Telescope" })

      -- shortcuts

      vim.keymap.set("n", "<leader>.", "<leader>ff", { desc = "Find Files", remap = true })
      vim.keymap.set("n", "<leader>,", "<leader>fr", { desc = "Find Files (Recent)", remap = true })
      vim.keymap.set("n", "<leader>/", "<leader>sf", { desc = "Search Files", remap = true })

      vim.keymap.set("n", "<leader>;", "<leader>fb", { desc = "Find Buffers", remap = true })
      vim.keymap.set("n", "<leader>'", "<leader>sb", { desc = "Search Buffers", remap = true })

      vim.keymap.set("n", "<leader>?", "<leader>fw", { desc = "Find Word", remap = true })

      -- find

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Files" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Files (Recent)" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set({ "n", "x" }, "<leader>fw", builtin.grep_string, { desc = "Word/Selection" })
      vim.keymap.set("n", "<leader>ft", require("telescope-tabs").list_tabs, { desc = "Tabs" })

      -- search

      vim.keymap.set("n", "<leader>sf", function()
        builtin.live_grep()
      end, { desc = "Files" })
      vim.keymap.set("n", "<leader>sb", function()
        builtin.live_grep({ grep_open_files = true })
      end, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>sc", builtin.current_buffer_fuzzy_find, { desc = "Current Buffer" })
      vim.keymap.set("n", "<leader>sh", builtin.command_history, { desc = "Command History" })
      vim.keymap.set("n", "<leader>s?", builtin.help_tags, { desc = "Help Pages" })
      vim.keymap.set("n", "<leader>sr", builtin.registers, { desc = "Registers" })
      vim.keymap.set("n", "<leader>sm", builtin.marks, { desc = "Marks" })
      vim.keymap.set("n", "<leader>sk", function()
        local opts = {
          modes = { "n", "v", "x", "o", "i", "c", "t" },
          show_plug = false,
          lhs_filter = nil,
          filter = function(keymap)
            return keymap.desc and keymap.desc ~= ""
          end,
        }
        local picker = require("util.telescope_keymaps_picker")
        picker.create(opts):find()
      end, { desc = "Keymaps" })

      -- lsp

      vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "Goto Definitions" })
      vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "Goto References" })
      vim.keymap.set("n", "gi", builtin.lsp_implementations, { desc = "Goto Implementations" })
      vim.keymap.set("n", "gy", builtin.lsp_type_definitions, { desc = "Goto Type Definitions" })

      -- pickers

      vim.keymap.set("n", "<leader>pc", builtin.commands, { desc = "Commands" })
      vim.keymap.set("n", "<leader>pt", builtin.builtin, { desc = "Telescope" })
      vim.keymap.set("n", "<leader>po", builtin.vim_options, { desc = "Options" })
      vim.keymap.set("n", "<leader>ps", function()
        builtin.colorscheme({ enable_preview = true })
      end, { desc = "Colorschemes" })
      vim.keymap.set("n", "<leader>p?", function()
        local picker = require("util.telescope_cheatsheet_picker")
        picker.create():find()
      end, { desc = "Motions Cheatsheet" })
    end,
  },
}
