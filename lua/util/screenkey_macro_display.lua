M = {}

function M.setup(opts)
  local screenkey = require("screenkey")

  local macro_opts = {
    emit_events = true,
    compress_after = 999999,
    clear_after = 999999,
    win_opts = { title = "Macro" },
    separator = "",
  }

  local function toggle_screenkey(enabled)
    local should_enable = enabled and not screenkey.is_active()
    local should_disable = not enabled and screenkey.is_active()
    if should_enable or should_disable then
      screenkey.toggle()
    end
  end

  vim.api.nvim_create_autocmd("RecordingEnter", {
    group = Core.create_augroup("toggle_macro_screenkey"),
    callback = function()
      screenkey.setup(macro_opts)
      toggle_screenkey(true)
    end,
  })

  vim.api.nvim_create_autocmd("RecordingLeave", {
    group = Core.create_augroup("toggle_macro_screenkey"),
    callback = function()
      toggle_screenkey(false)
      screenkey.setup(opts)

      vim.schedule(function()
        local regname = vim.fn.reg_recorded()
        local keys = vim.fn.getreg(regname)
        vim.notify("Recorded @" .. regname .. " = " .. keys)
      end)
    end,
  })
end

return M
