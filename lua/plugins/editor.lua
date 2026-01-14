return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      preset = "helix",
      spec = {
        mode = { "n", "x" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>dp", group = "profiler" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "harpoon", icon = { icon = Core.icons.harpoon, color = "orange" } },
        { "<leader>i", group = "insights", icon = { icon = Core.icons.insights, color = "purple" } },
        { "<leader>n", group = "notifications" },
        { "<leader>p", group = "picker", icon = { icon = Core.icons.list, color = "green" } },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "tab" },
        { "<leader>u", group = "ui" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "z", group = "fold" },
      },
      icons = {
        mappings = true,
        rules = {
          { pattern = "throw harpoon", icon = Core.icons.target, color = "orange" },
          { pattern = "lazy", icon = Core.icons.lazy, color = "yellow" },
          { pattern = "mason", icon = Core.icons.mason, color = "cyan" },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    opts = {
      dim = { enabled = true },
      indent = { enabled = true },
      words = { enabled = true },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    config = function(_, opts)
      local harpoon = require("harpoon")

      harpoon.setup(opts)

      local function tab_list(id)
        return harpoon:list(Core.tab_key(id))
      end

      vim.keymap.set("n", "<leader>hx", function()
        local matcher = require("util.harpoon_item_matcher")
        if matcher.match(0) then
          tab_list():remove()
        else
          tab_list():add()
        end
        vim.cmd("redrawtabline")
      end, { desc = "Harpoon File" })
      vim.keymap.set("n", "<leader>hh", function()
        harpoon.ui:toggle_quick_menu(tab_list())
      end, { desc = "Harpooned Files" })

      vim.keymap.set("n", "<leader>x", "<leader>hx", { desc = "Throw Harpoon", remap = true })
      vim.keymap.set("n", "<M-`>", "<leader>hh", { desc = "Harpooned Files", remap = true })

      for i = 1, 4 do
        vim.keymap.set("n", "<leader>h" .. i, function()
          tab_list():select(i)
        end, { desc = "Harpoon to File " .. i })
        vim.keymap.set("n", "<M-" .. i .. ">", "<leader>h" .. i, { desc = "Harpoon to File " .. i, remap = true })
      end

      vim.api.nvim_create_autocmd("TabClosed", {
        callback = function(event)
          local id = event.file
          pcall(function()
            tab_list(id):clear()
          end)
        end,
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          never_show = {
            ".DS_Store",
          },
        },
      },
      window = {
        width = 0.2,
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ["P"] = { "toggle_preview", config = { use_float = true } },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = Core.icons.explorer.dir_collapsed,
          expander_expanded = Core.icons.explorer.dir_expanded,
          expander_highlight = "NeoTreeExpander",
        },
      },
      keys = {},
    },
    config = function(_, opts)
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })

      require("neo-tree").setup(opts)

      vim.keymap.set("n", "<leader>e", function()
        require("neo-tree.command").execute({ toggle = true })
      end, { desc = "Toggle Explorer" })
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
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end

        map("n", "<leader>gb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>gB", function()
          gs.blame()
        end, "Blame Buffer")
      end,
    },
  },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    event = "VeryLazy",
    opts = {
      warn_no_results = false,
      open_no_results = true,
      win = { size = 0.25 },
      modes = {
        symbols = {
          preview = {
            type = "float",
            border = "rounded",
            relative = "editor",
            position = { 0.5, 0.5 },
            size = { width = 0.5, height = 0.5 },
          },
        },
      },
    },

    keys = {
      { "<leader>cs", "<cmd>Trouble lsp toggle<cr>", desc = "Symbols" },
      { "<leader>co", "<cmd>Trouble symbols toggle<cr>", desc = "Outline" },

      { "<leader>id", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>ix", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Current Buffer Diagnostics" },
      { "<leader>iq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
      { "<leader>il", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
    },
    config = function(_, opts)
      local trouble = require("trouble")
      trouble.setup(opts)

      local function jump(command, fallback)
        if trouble.is_open() then
          pcall(command)
        elseif fallback then
          local ok, err = pcall(fallback)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end

      local function next(fallback)
        ---@diagnostic disable-next-line: missing-parameter, missing-fields
        jump(trouble.next({ skip_groups = true, jump = true }), fallback)
      end
      local function prev(fallback)
        ---@diagnostic disable-next-line: missing-parameter, missing-fields
        jump(trouble.prev({ skip_groups = true, jump = true }), fallback)
      end

      vim.keymap.set("n", "[i", prev, { desc = "Previous Insight" })
      vim.keymap.set("n", "]i", next, { desc = "Next Insight" })

      vim.keymap.set("n", "[q", function()
        prev(vim.cmd.cprev)
      end, { desc = "Previous Quickfix" })
      vim.keymap.set("n", "]q", function()
        next(vim.cmd.cnext)
      end, { desc = "Next Quickfix" })

      vim.keymap.set("n", "[l", function()
        prev(vim.cmd.lprev)
      end, { desc = "Previous Location" })
      vim.keymap.set("n", "]l", function()
        next(vim.cmd.lnext)
      end, { desc = "Next Location" })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "nvim-telescope/telescope-ui-select.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "LukasPietzschmann/telescope-tabs",
    },
    config = function()
      local actions = require("telescope.actions")

      local function open_trouble_qf(prompt_bufnr)
        actions.smart_send_to_qflist(prompt_bufnr)
        require("trouble").open({ mode = "qflist", focus = true })
      end

      local function open_trouble_loc(prompt_bufnr)
        actions.smart_send_to_loclist(prompt_bufnr)
        require("trouble").open({ mode = "loclist", focus = true })
      end

      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
        defaults = {
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

      require("telescope").load_extension("fzf")
      require("telescope").load_extension("ui-select")
      require("telescope").load_extension("noice")
      require("telescope").load_extension("telescope-tabs")

      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader><leader>", builtin.resume, { desc = "Resume Telescope" })

      -- shortcuts

      vim.keymap.set("n", "<leader>.", "<leader>ff", { desc = "Find Files", remap = true })
      vim.keymap.set("n", "<leader>,", "<leader>fb", { desc = "Find Buffers", remap = true })
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

      -- pickers

      vim.keymap.set("n", "<leader>pc", builtin.commands, { desc = "Commands" })
      vim.keymap.set("n", "<leader>pt", builtin.builtin, { desc = "Telescope" })
      vim.keymap.set("n", "<leader>po", builtin.vim_options, { desc = "Options" })
      vim.keymap.set("n", "<leader>ps", function()
        builtin.colorscheme({ enable_preview = true })
      end, { desc = "Colorschemes" })
    end,
  },
}
