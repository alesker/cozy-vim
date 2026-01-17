return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope-ui-select.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-file-browser.nvim",
      "LukasPietzschmann/telescope-tabs",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      local function open_trouble_qf(prompt_bufnr)
        actions.smart_send_to_qflist(prompt_bufnr)
        require("trouble").open({ mode = "qflist", focus = true })
      end

      local function open_trouble_loc(prompt_bufnr)
        actions.smart_send_to_loclist(prompt_bufnr)
        require("trouble").open({ mode = "loclist", focus = true })
      end

      telescope.setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
        defaults = {
          file_ignore_patterns = {
            "%.DS_Store$",
          },
          prompt_prefix = Core.icons.telescope.prompt_prefix,
          selection_caret = Core.icons.telescope.selection_caret,
          mappings = {
            i = {
              ["<C-q>"] = open_trouble_qf,
              ["<C-l>"] = open_trouble_loc,
            },
            n = {
              ["<C-q>"] = open_trouble_qf,
              ["<C-l>"] = open_trouble_loc,
            },
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("file_browser")
      telescope.load_extension("noice")
      telescope.load_extension("telescope-tabs")

      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader><leader>", builtin.resume, { desc = "Resume Telescope" })

      -- shortcuts

      vim.keymap.set("n", "<leader>.", "<leader>ff", { desc = "Find Files", remap = true })
      vim.keymap.set("n", "<leader>,", "<leader>fb", { desc = "Find Buffers", remap = true })
      vim.keymap.set("n", "<leader>*", "<leader>fw", { desc = "Find Word", remap = true })
      vim.keymap.set("n", "<leader>/", "<leader>sf", { desc = "Search Files", remap = true })
      vim.keymap.set("n", "<leader>?", "<leader>sb", { desc = "Search Buffers", remap = true })

      -- find

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Files" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Files (Recent)" })
      vim.keymap.set("n", "<leader>fb", function()
        builtin.buffers({ sort_mru = true, sort_lastused = true })
      end, { desc = "Buffers" })
      vim.keymap.set({ "n", "x" }, "<leader>fw", builtin.grep_string, { desc = "Word/Selection" })
      vim.keymap.set("n", "<leader>ft", require("telescope-tabs").list_tabs, { desc = "Tabs" })

      -- search

      vim.keymap.set("n", "<leader>sf", builtin.live_grep, { desc = "Files" })
      vim.keymap.set("n", "<leader>sb", function()
        builtin.live_grep({ grep_open_files = true })
      end, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>sc", builtin.current_buffer_fuzzy_find, { desc = "Current Buffer" })
      vim.keymap.set("n", "<leader>sh", builtin.command_history, { desc = "Command History" })
      vim.keymap.set("n", "<leader>s?", builtin.help_tags, { desc = "Help Pages" })
      vim.keymap.set("n", "<leader>sr", builtin.registers, { desc = "Registers" })
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

      -- file explorer
      vim.keymap.set("n", "<leader>e", function()
        telescope.extensions.file_browser.file_browser({
          path = vim.fn.expand("%:p:h"),
          grouped = true,
          hidden = true,
          respect_gitignore = true,
          sorting_strategy = "ascending",
          layout_config = { prompt_position = "top" },
          prompt_title = "File Explorer",
        })
      end, { desc = "File Explorer", remap = true })

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
