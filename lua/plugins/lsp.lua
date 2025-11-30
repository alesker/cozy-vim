return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {},
    },
    opts_extend = { "ensure_installed" },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {},
    },
    config = vim.schedule_wrap(function(_, opts)
      for server, server_opts in pairs(opts.servers) do
        vim.lsp.config(server, server_opts)
      end
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "[H]over" })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "[G]oto [D]efinition" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "[G]oto [R]eferences" })
      vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "[F]ormat" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[R]e[n]ame" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
    end),
  },
}
