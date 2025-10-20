return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require('neo-tree').setup {
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          never_show = {
            ".DS_Store",
          },
        },
      },
    }
    vim.keymap.set('n', '-', ':Neotree toggle<CR>')
  end
}
