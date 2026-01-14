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

      vim.keymap.del({ "n", "v" }, "gra")
      vim.keymap.del("n", "gri")
      vim.keymap.del("n", "grn")
      vim.keymap.del("n", "grr")
      vim.keymap.del("n", "grt")
      vim.keymap.del("n", "gO")
      vim.keymap.del({ "i", "v" }, "<C-s>")

      vim.keymap.set("n", "<leader>cl", Snacks.picker.lsp_config, { desc = "Lsp Info" })

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
      vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
      vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })

      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
      vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
      vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

      vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
      vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

      vim.keymap.set({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, { desc = "Run Codelens" })
      vim.keymap.set("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh & Display Codelens" })

      vim.keymap.set("n", "<leader>cR", Snacks.rename.rename_file, { desc = "Rename File" })

      vim.keymap.set("n", "gd", "<cmd>Trouble lsp_definitions toggle<cr>", { desc = "Goto Definition" })
      vim.keymap.set("n", "gD", "<cmd>Trouble lsp_declarations toggle<cr>", { desc = "Goto Declaration" })

      --   {vim.keymap.set(
      --     "]]",
      --     function()
      --       Snacks.words.jump(vim.v.count1)
      --     end,
      --     has = "documentHighlight",
      --     { desc = "Next Reference",
      --     enabled = function()
      --       return Snacks.words.is_enabled()
      --     end,
      --   },
      --   {vim.keymap.set(
      --     "[[",
      --     function()
      --       Snacks.words.jump(-vim.v.count1)
      --     end,
      --     has = "documentHighlight",
      --     { desc = "Prev Reference",
      --     enabled = function()
      --       return Snacks.words.is_enabled()
      --     end,
      --   },
      --   {vim.keymap.set(
      --     "<A-n>",
      --     function()
      --       Snacks.words.jump(vim.v.count1, true)
      --     end,
      --     has = "documentHighlight",
      --     { desc = "Next Reference",
      --     enabled = function()
      --       return Snacks.words.is_enabled()
      --     end,
      --   },
      --   {vim.keymap.set(
      --     "<A-p>",
      --     function()
      --       Snacks.words.jump(-vim.v.count1, true)
      --     end,
      --     has = "documentHighlight",
      --     { desc = "Prev Reference",
      --     enabled = function()
      --       return Snacks.words.is_enabled()
      --     end,
      --   }
      --
    end),
  },
}
