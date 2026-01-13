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
        callback = function(ev)
          local ft = vim.bo[ev.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft

          local parser_exists = pcall(vim.treesitter.get_parser, ev.buf, lang)
          if not parser_exists then
            return
          end

          pcall(vim.treesitter.start, ev.buf, lang)

          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldmethod = "expr"

          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
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
