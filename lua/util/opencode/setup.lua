local M = {}
local client
local terminal

function M.setup()
  client = require("util.opencode.client").new()

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if terminal then
        terminal:shutdown()
      end
      client:shutdown()
    end,
  })
  return client
end

function M.toggle()
  client
    :conversation()
    :next(function(session)
      if terminal and terminal:is_open() then
        terminal:close()
        return
      end
      if not terminal then
        terminal = require("toggleterm.terminal").Terminal:new({
          cmd = "opencode mini --server " .. vim.fn.shellescape(client.url) .. " --session " .. vim.fn.shellescape(
            session.id
          ) .. " --replay",
          env = { OPENCODE_PASSWORD = client.password },
          display_name = "OpenCode",
          direction = "vertical",
          hidden = true,
          on_open = function(term)
            vim.cmd("stopinsert")
            if term.readonly_buf ~= term.bufnr then
              term.readonly_buf = term.bufnr
              term.readonly_group = vim.api.nvim_create_augroup("OpenCodeReadOnly", { clear = true })
              for _, key in ipairs({ "i", "I", "a", "A", "o", "O", "s", "S", "c", "C", "r", "R" }) do
                vim.keymap.set("n", key, "<Nop>", { buffer = term.bufnr, desc = "OpenCode view only" })
              end
              vim.keymap.set("t", "<CR>", "<Nop>", { buffer = term.bufnr, desc = "OpenCode view only" })
              vim.api.nvim_create_autocmd("TermEnter", {
                group = term.readonly_group,
                buffer = term.bufnr,
                callback = function()
                  vim.schedule(function()
                    if vim.api.nvim_get_current_buf() == term.bufnr then
                      vim.cmd("stopinsert")
                    end
                  end)
                end,
              })
            end
          end,
        })
      end
      terminal:open()
    end)
    :catch(function(err)
      vim.notify(tostring(err), vim.log.levels.ERROR, { title = "OpenCode" })
    end)
end

return M
