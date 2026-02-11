return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = {},
    },
    opts_extend = { "ensure_installed" },
    config = function(_, opts)
      local treesitter = require("nvim-treesitter")

      treesitter.setup(opts)

      if #opts.ensure_installed > 0 then
        treesitter.install(opts.ensure_installed)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = Core.create_augroup("treesitter"),
        callback = function(event)
          local ft = vim.bo[event.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft

          local parser_exists = pcall(vim.treesitter.get_parser, event.buf, lang)
          if not parser_exists then
            return
          end

          pcall(vim.treesitter.start, event.buf, lang)

          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"

          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      move = {
        set_jumps = true,
        keys = {
          goto_next_start = {
            ["]]"] = { query = "@block.outer", desc = "Next block start" },
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]c"] = { query = "@class.outer", desc = "Next class start" },
            ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
          },
          goto_next_end = {
            ["]["] = { query = "@block.outer", desc = "Next block end" },
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]C"] = { query = "@class.outer", desc = "Next class end" },
            ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
          },
          goto_previous_start = {
            ["[["] = { query = "@block.outer", desc = "Previous block start" },
            ["[f"] = { query = "@function.outer", desc = "Previous function start" },
            ["[c"] = { query = "@class.outer", desc = "Previous class start" },
            ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
          },
          goto_previous_end = {
            ["[]"] = { query = "@block.outer", desc = "Previous block start" },
            ["[F"] = { query = "@function.outer", desc = "Previous function end" },
            ["[C"] = { query = "@class.outer", desc = "Previous class end" },
            ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
          },
        },
      },
    },
    config = function(_, opts)
      local treesitter = require("nvim-treesitter-textobjects")
      treesitter.setup(opts)

      for method, keymaps in pairs(opts.move.keys) do
        for key, mapping in pairs(keymaps) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            require("nvim-treesitter-textobjects.move")[method](mapping.query, "textobjects")
          end, {
            desc = mapping.desc,
            silent = true,
          })
        end
      end
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>it",
        "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
        desc = "TODO/FIX/FIXME",
      },
    },
  },
}
