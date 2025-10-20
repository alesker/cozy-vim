return {
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      'mason-org/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = {
      ensure_installed = { 'lua_ls', 'ruby_lsp' }
    },
  },
  {
    'mason-org/mason.nvim',
    opts = {}
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      vim.lsp.config('lua_ls', {})
      vim.lsp.enable('lua_ls')

      vim.lsp.config('ruby_lsp', {})
      vim.lsp.enable('ruby_lsp')

      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ctions' })
    end
  },
}
