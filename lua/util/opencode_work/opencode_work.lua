require("util.opencode_work.opencode_work_task")

local M = {}

local Renderer = require("util.opencode_work.opencode_work_renderer")
local Spinner = require("util.opencode_work.opencode_work_spinner")
local TaskManager = require("util.opencode_work.opencode_work_task_manager")

local state = {
  task_manager = nil,
  renderer = nil,
}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "OpenCode Work" })
end

local function border_fill(width, ...)
  local used = 0
  for i = 1, select("#", ...) do
    local text = select(i, ...)
    used = used + vim.fn.strdisplaywidth(text)
  end
  return string.rep("─", math.max(0, width - used))
end

---@param render_objects table[]
---@param spinner string
---@param task OpencodeWorkTask
local function decorate(render_objects, spinner, task)
  local win_width = vim.api.nvim_win_get_width(task.win)

  local top_prefix = "╭─ "
  local bottom_prefix = "╰─ "

  local result = {}
  for i, item in ipairs(render_objects) do
    local decoration
    if item.type == "header" then
      decoration = {
        virt_lines = {
          {
            { top_prefix, "OpencodeWork" },
            { spinner, "OpencodeWorkIndicator" },
            { border_fill(win_width, top_prefix, spinner), "OpencodeWork" },
          },
        },
        virt_lines_above = true,
      }
    elseif item.type == "footer" then
      decoration = {
        virt_lines = {
          {
            { bottom_prefix, "OpencodeWork" },
            { spinner, "OpencodeWorkIndicator" },
            { border_fill(win_width, bottom_prefix, spinner), "OpencodeWork" },
          },
        },
      }
    else
      decoration = {
        line_hl_group = "OpencodeWork",
      }
    end

    item.opts = decoration
    result[i] = item
  end

  return result
end

---@param task OpencodeWorkTask
local function make_opencode_context(task)
  return require("opencode.context").new({
    from = { task.range.start_row + 1, 0 },
    to = { task.range.end_row + 1, 0 },
    kind = "line",
  })
end

---@param task OpencodeWorkTask
local function cursor_in_task(task)
  if vim.api.nvim_get_current_buf() ~= task.buf then
    return false
  end

  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  return row >= task.range.start_row and row <= task.range.end_row
end

function M.schedule()
  if state.task_manager:has_active_task() then
    notify("OpenCode work task already active", vim.log.levels.ERROR)
    return
  end

  local task = state.task_manager:schedule_task()
  local context = make_opencode_context(task)

  require("opencode.ui.ask")
    .ask("@this: ", context)
    :next(function(input)
      if not state.task_manager:is_active_task(task) then
        return
      end

      if task.status == "prompting" then
        task.status = "submitted"
      end

      if not state.renderer:matches(task) then
        state.renderer:start(task)
      end

      context:clear()
      return require("opencode.api.prompt").prompt(input, {
        context = context,
        submit = true,
      })
    end)
    :catch(function(err)
      if state.task_manager:is_active_task(task) then
        state.task_manager:finish_task()
        state.renderer:stop()
      end

      if err then
        notify(err, vim.log.levels.ERROR)
      end
    end)
end

function M.stop_current()
  local task = state.task_manager:active_task()
  if not task then
    notify("No OpenCode work task is active", vim.log.levels.WARN)
    return
  end

  if not cursor_in_task(task) then
    notify("Cursor is not inside the active OpenCode work task", vim.log.levels.WARN)
    return
  end

  state.task_manager:finish_task()
  state.renderer:stop()
  require("opencode.api.command")
    .command("session.interrupt")
    :next(function()
      return require("opencode.api.command").command("session.interrupt")
    end)
    :catch(function(err)
      if err then
        notify("Failed to interrupt OpenCode task: " .. tostring(err), vim.log.levels.ERROR)
      end
    end)
end

function M.setup()
  if M._did_setup then
    return
  end

  local folded = vim.api.nvim_get_hl(0, { name = "Folded", link = false })
  local conceal = vim.api.nvim_get_hl(0, { name = "Conceal", link = false })

  vim.api.nvim_set_hl(0, "OpencodeWork", { link = "Folded" })
  vim.api.nvim_set_hl(0, "OpencodeWorkIndicator", {
    fg = conceal.fg,
    bg = folded.bg,
    italic = conceal.italic,
    bold = conceal.bold,
  })

  state.renderer = Renderer.new({
    spinner = Spinner.new(),
    decorate = decorate,
    namespace = "OpencodeWork",
    interval = 120,
  })

  state.task_manager = TaskManager.new()

  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("OpencodeWork", { clear = true }),
    pattern = "OpencodeEvent:*",
    callback = function(args)
      state.task_manager:handle_event(args.data.event)
      if not state.task_manager:has_active_task() then
        state.renderer:stop()
      end
    end,
  })

  M._did_setup = true
end

return M
