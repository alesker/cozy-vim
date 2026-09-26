local M = {}
local client
local terminal
local terminal_session

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
  if not terminal_session then
    terminal_session = client:create_session({
      title = "OpenCode (Neovim)",
      agent = "pair-programmer",
      model = { providerID = "openai", id = "gpt-5.5", variant = "low" },
    })
  end
  terminal_session
    :next(function(session)
      if terminal and terminal:is_open() then
        terminal:close()
        return
      end
      if not terminal then
        terminal = require("toggleterm.terminal").Terminal:new({
          cmd = "opencode --server " .. vim.fn.shellescape(client.url) .. " --session " .. vim.fn.shellescape(
            session.id
          ),
          env = { OPENCODE_PASSWORD = client.password },
          display_name = "OpenCode",
          direction = "vertical",
          hidden = true,
        })
      end
      terminal:open()
    end)
    :catch(function(err)
      vim.notify(tostring(err), vim.log.levels.ERROR, { title = "OpenCode" })
    end)
end

return M
