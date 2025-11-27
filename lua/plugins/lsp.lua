return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "ruby_lsp",
        "stylua",
        "rubocop",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("lua_ls", {})
      vim.lsp.enable("lua_ls")

      vim.lsp.config("ruby_lsp", {})
      vim.lsp.enable("ruby_lsp")

      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "[H]over" })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "[G]oto [D]efinition" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "[G]oto [R]eferences" })
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "[F]ormat" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[R]e[n]ame" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
    end,
  },
}
