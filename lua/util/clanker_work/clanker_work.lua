require("util.clanker_work.clanker_work_task")
require("util.clanker_work.client")

local M = {}

local Renderer = require("util.clanker_work.clanker_work_renderer")
local Spinner = require("util.clanker_work.clanker_work_spinner")
local TaskManager = require("util.clanker_work.clanker_work_task_manager")

local state = {
  task_manager = nil,
  renderer = nil,
  ---@type ClankerWorkClient?
  client = nil,
}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Clanker Work" })
end

local function notify_result(task, status, output, err)
  local path = task.source_path or (vim.api.nvim_buf_is_valid(task.buf) and vim.api.nvim_buf_get_name(task.buf) or "")
  local range = task.source_range or task.range
  local location = string.format("%s:%d-%d", path ~= "" and path or "[buffer]", range.start_row + 1, range.end_row + 1)
  local message = string.format(
    "%s · %s\n\nPrompt\n%s\n\nOutput\n%s",
    status,
    location,
    task.submitted_prompt or task.prompt or "[no prompt]",
    output ~= "" and output or "[no text response]"
  )
  if err then
    message = message .. "\n\nError\n" .. tostring(err)
  end
  notify(message, (err or status == "Failed") and vim.log.levels.ERROR or vim.log.levels.INFO)
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
---@param indicator string
---@param task ClankerWorkTask
local function decorate(render_objects, indicator, task)
  indicator = indicator or ""

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
            { top_prefix, "ClankerWork" },
            { indicator, "ClankerWorkIndicator" },
            { border_fill(win_width, top_prefix, indicator), "ClankerWork" },
          },
        },
        virt_lines_above = true,
      }
    elseif item.type == "footer" then
      decoration = {
        virt_lines = {
          {
            { bottom_prefix, "ClankerWork" },
            { indicator, "ClankerWorkIndicator" },
            { border_fill(win_width, bottom_prefix, indicator), "ClankerWork" },
          },
        },
      }
    else
      decoration = {
        line_hl_group = "ClankerWork",
      }
    end

    item.opts = decoration
    result[i] = item
  end

  return result
end

local dispatch_next_task

dispatch_next_task = function()
  local task = state.task_manager:activate_next_task()
  if not task then
    state.renderer:redraw()
    return
  end

  if not state.renderer:sync_task(task) then
    state.task_manager:remove_task(task)
    state.renderer:remove_task(task)
    dispatch_next_task()
    return
  end

  state.renderer:redraw()

  state.client:submit(task, task.prompt):catch(function(err)
    if state.task_manager:is_active_task(task) then
      state.task_manager:remove_task(task)
      state.renderer:remove_task(task)
      notify_result(
        task,
        "Failed",
        type(err) == "table" and err.output or "",
        type(err) == "table" and err.message or err
      )
      dispatch_next_task()
    end
  end)
end

local function cursor_task()
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1

  return state.task_manager:task_at(buf, row)
end

---@param task ClankerWorkTask
local function cancel_task(task)
  if state.task_manager:is_tracked_task(task) then
    state.task_manager:remove_task(task)
    state.renderer:remove_task(task)
    dispatch_next_task()
  end
end

---@param task ClankerWorkTask
local function prompt_for_task(task)
  vim.ui.input({ prompt = "Clanker Work: " }, function(input)
    if not input then
      cancel_task(task)
      return
    end

    if not state.task_manager:is_tracked_task(task) then
      return
    end

    task.prompt = input
    if task.status == "prompting" then
      task.status = "queued"
    end

    state.renderer:redraw()
    dispatch_next_task()
  end)
end

function M.schedule()
  local task = state.task_manager:schedule_task()
  if not state.renderer:add_task(task) then
    state.task_manager:remove_task(task)
    notify("Failed to start Clanker work renderer", vim.log.levels.ERROR)
    return
  end

  state.client
    :ready()
    :next(function()
      prompt_for_task(task)
    end)
    :catch(function(err)
      state.task_manager:remove_task(task)
      state.renderer:remove_task(task)
      notify(err or "Failed to connect to server", vim.log.levels.ERROR)
    end)
end

function M.stop_current()
  if not state.task_manager:has_tasks() then
    notify("No Clanker work task is active", vim.log.levels.WARN)
    return
  end

  local task = cursor_task()
  if not task then
    notify("Cursor is not inside a Clanker work task", vim.log.levels.WARN)
    return
  end

  local removed = state.task_manager:remove_task(task)
  state.renderer:remove_task(task)

  if removed == "queued" then
    notify_result(task, "Cancelled", "")
    dispatch_next_task()
    return
  end

  state.client
    :interrupt(task)
    :next(function(result)
      notify_result(task, "Cancelled", result.output or "", result.error)
      dispatch_next_task()
    end)
    :catch(function(err)
      notify_result(task, "Failed to cancel", "", err)
    end)
end

---@class ClankerWorkSetupOpts
---@field client ClankerWorkClient

---@param opts ClankerWorkSetupOpts
function M.setup(opts)
  if M._did_setup then
    return
  end

  local folded = vim.api.nvim_get_hl(0, { name = "Folded", link = false })
  local conceal = vim.api.nvim_get_hl(0, { name = "Conceal", link = false })

  vim.api.nvim_set_hl(0, "ClankerWork", { link = "Folded" })
  vim.api.nvim_set_hl(0, "ClankerWorkIndicator", {
    fg = conceal.fg,
    bg = folded.bg,
    italic = conceal.italic,
    bold = conceal.bold,
  })

  state.task_manager = TaskManager.new()
  state.client = opts.client
  state.renderer = Renderer.new({
    spinner = Spinner.new(),
    decorate = decorate,
    indicator = function(task, spinner)
      if state.task_manager:is_active_task(task) then
        return spinner
      end

      local position = state.task_manager:queued_position(task)
      if position then
        return "#" .. position .. " waiting..."
      end

      return ""
    end,
    on_invalid = function(task)
      if state.task_manager:is_active_task(task) then
        return
      end

      local removed = state.task_manager:remove_task(task)
      if removed == "queued" and not state.task_manager:has_active_task() then
        dispatch_next_task()
      end
    end,
    namespace = "ClankerWork",
    interval = 120,
  })

  state.client:on_event(vim.api.nvim_create_augroup("ClankerWork", { clear = true }), function(event)
    local finished_task = state.task_manager:handle_event(event)
    if finished_task then
      state.renderer:remove_task(finished_task)
      notify_result(finished_task, event.type == "done" and "Completed" or "Failed", event.output or "", event.error)
      dispatch_next_task()
    end
  end)

  M._did_setup = true
end

return M
