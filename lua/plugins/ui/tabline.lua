return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
          {
            filetype = "snacks_layout_box",
          },
        },
      },
    },
    config = function(_, opts)
      local matcher = require("util.harpoon_item_matcher")

      opts.options.groups = {
        options = {
          toggle_hidden_on_enter = true,
        },
        items = {
          {
            name = "Harpooned",
            priority = 1,
            separator = {
              style = require("bufferline.groups").separator.none,
            },
            matcher = function(buf)
              return matcher.match(buf.id)
            end,
          },
        },
      }

      opts.options.sort_by = function(a, b)
        local a_index = matcher.match(a.id)
        local b_index = matcher.match(b.id)

        if a_index and b_index then
          return a_index < b_index
        elseif a_index then
          return true
        elseif b_index then
          return false
        end

        return a.id < b.id
      end

      opts.options.numbers = function(buf)
        local index = matcher.match(buf.id)
        if index then
          return Core.icons.target .. buf.raise(index)
        else
          return nil
        end
      end

      require("bufferline").setup(opts)

      vim.opt.showtabline = 0

      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        group = Core.create_augroup("tabline_toggle"),
        callback = function(event)
          local ft = vim.bo[event.buf].filetype

          if ft ~= "alpha" then
            vim.opt.showtabline = 2
          else
            vim.opt.showtabline = 0
          end
        end,
      })
    end,
  },
  { "tiagovla/scope.nvim", config = true },
}
