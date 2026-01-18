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
          { pattern = "oil", icon = Core.icons.oil, color = "orange" },
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
        harpoon.ui:toggle_quick_menu(tab_list(), {
          title = " Harpoon ",
          border = "rounded",
          title_pos = "center",
        })
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

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "harpoon",
        callback = function()
          vim.wo.winhighlight = table.concat({
            "Normal:Normal",
            "FloatBorder:Normal",
            "FloatTitle:Normal",
          }, ",")
        end,
      })
    end,
  },
  {
    "stevearc/oil.nvim",
    opts = {
      float = {
        padding = 2,
        max_width = 0.75,
        max_height = 0.75,
        border = "rounded",
        win_options = {
          winblend = 0,
          winhighlight = table.concat({
            "Normal:Normal",
            "FloatBorder:Normal",
            "FloatTitle:Normal",
          }, ","),
        },
        get_win_title = function()
          local title = "Oil"
          local dir = require("oil").get_current_dir()
          if dir then
            title = vim.fn.fnamemodify(dir, ":~:.")
            title = title == "" and "./" or title
          end
          return string.format(" %s ", title)
        end,
        override = function(conf)
          conf.title = ""
          conf.title_pos = "center"
          return conf
        end,
      },
      confirmation = {
        border = "rounded",
        title_pos = "center",
        max_width = 0.25,
        max_height = 0.25,
        win_options = {
          winblend = 0,
          winhighlight = table.concat({
            "Normal:Normal",
            "FloatBorder:Normal",
            "FloatTitle:Normal",
          }, ","),
        },
      },
      preview_win = {
        win_options = {
          winhighlight = table.concat({
            "Normal:Normal",
            "FloatBorder:Normal",
            "FloatTitle:Normal",
          }, ","),
        },
      },
    },
    config = function(_, opts)
      local oil = require("oil")

      oil.setup(opts)

      vim.api.nvim_create_autocmd("User", {
        group = Core.create_augroup("oil_autopreview"),
        pattern = "OilEnter",
        callback = vim.schedule_wrap(function(args)
          if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
            oil.open_preview()
          end
        end),
      })

      vim.keymap.set("n", "<leader>o", function()
        oil.toggle_float()
      end, { desc = "Oil" })
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

      vim.keymap.set("n", "<C-`>", function()
        require("neo-tree.command").execute({ toggle = true })
      end, { desc = "Toggle File Tree" })

      Snacks.toggle({
        get = function()
          return vim.g.readonly_neotree
        end,
        set = function(state)
          vim.g.readonly_neotree = state
          local group = Core.create_augroup("readonly_neotree")
          if state then
            vim.api.nvim_create_autocmd("WinEnter", {
              group = group,
              callback = function()
                if vim.bo.filetype == "neo-tree" then
                  if not vim.w._allow_neotree_focus then
                    vim.cmd("wincmd p")
                  end
                end
              end,
            })
          else
            vim.api.nvim_del_autocmd(group)
          end
        end,
        name = "Readonly Neotree",
      }):map("<leader>uN")

      Snacks.toggle.get("readonly_neotree"):set(true)
    end,
  },
}
