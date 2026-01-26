return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { "codebook" },
    },
    opts_extend = { "ensure_installed" },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        codebook = {},
      },
    },
    config = vim.schedule_wrap(function(_, opts)
      for server, server_opts in pairs(opts.servers) do
        vim.lsp.config(server, server_opts)
        vim.lsp.enable(server)
      end

      vim.keymap.del({ "n", "v" }, "gra")
      vim.keymap.del("n", "gri")
      vim.keymap.del("n", "grn")
      vim.keymap.del("n", "grr")
      vim.keymap.del("n", "grt")
      vim.keymap.del("n", "gO")
      vim.keymap.del({ "i", "v" }, "<C-s>")

      vim.keymap.set("n", "<leader>cl", Snacks.picker.lsp_config, { desc = "Lsp Info" })

      vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
      end, { desc = "Goto Definition" })
      vim.keymap.set("n", "gD", function()
        vim.lsp.buf.declaration()
      end, { desc = "Goto Declaration" })
      vim.keymap.set("n", "gI", function()
        vim.lsp.buf.implementation()
      end, { desc = "Goto Implementation" })
      vim.keymap.set("n", "gy", function()
        vim.lsp.buf.type_definition()
      end, { desc = "Goto Type Definition" })

      vim.keymap.set("n", "K", function()
        vim.lsp.buf.hover()
      end, { desc = "Hover" })
      vim.keymap.set("n", "<leader>ch", function()
        vim.lsp.buf.hover()
      end, { desc = "Hover" })

      vim.keymap.set({ "n", "x" }, "<leader>ca", function()
        vim.lsp.buf.code_action()
      end, { desc = "Code Action" })
      vim.keymap.set("n", "<leader>cr", function()
        vim.lsp.buf.rename()
      end, { desc = "Rename" })

      vim.keymap.set({ "n", "x" }, "<leader>cc", function()
        vim.lsp.codelens.run()
      end, { desc = "Run Codelens" })
      vim.keymap.set("n", "<leader>cC", function()
        vim.lsp.codelens.refresh()
      end, { desc = "Refresh & Display Codelens" })

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
