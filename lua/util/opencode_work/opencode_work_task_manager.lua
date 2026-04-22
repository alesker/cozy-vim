local Task = require("util.opencode_work.opencode_work_task")

local TaskManager = {}
TaskManager.__index = TaskManager

function TaskManager.new()
  return setmetatable({
    queued_task = nil,
  }, TaskManager)
end

---@class OpencodeWorkTask
function TaskManager:active_task()
  return self.queued_task
end

function TaskManager:has_active_task()
  return self.queued_task ~= nil
end

---@param task OpencodeWorkTask
function TaskManager:is_active_task(task)
  return self.queued_task == task
end

---@class OpencodeWorkTask
function TaskManager:schedule_task()
  if self:has_active_task() then
    return
  end

  local task = Task.new()
  self.queued_task = task

  return task
end

function TaskManager:finish_task()
  if not self:has_active_task() then
    return
  end

  self.queued_task = nil
end

function TaskManager:handle_event(event)
  if not self:has_active_task() then
    return
  end

  local task = self.queued_task

  if self._is_running_event(event) then
    task.status = "running"
    return
  end

  if event.type == "session.error" then
    self:finish_task()
    return
  end

  if self._is_done_event(event) and task.status == "running" then
    self:finish_task()
  end
end

function TaskManager._event_status(event)
  if event.properties == nil or event.properties.status == nil then
    return
  end

  return event.properties.status.type
end

function TaskManager._is_running_event(event)
  return event.type == "message.updated"
    or event.type == "message.part.updated"
    or event.type == "permission.replied"
    or TaskManager._event_status(event) == "busy"
end

function TaskManager._is_done_event(event)
  return TaskManager._event_status(event) == "idle" or event.type == "session.idle"
end

return TaskManager
