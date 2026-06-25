local Task = require("util.clanker_work.clanker_work_task")

local TaskManager = {}
TaskManager.__index = TaskManager

function TaskManager.new()
  return setmetatable({
    active_task = nil,
    queued_tasks = {},
  }, TaskManager)
end

function TaskManager:has_active_task()
  return self.active_task ~= nil
end

function TaskManager:has_tasks()
  return self.active_task ~= nil or #self.queued_tasks > 0
end

---@param task ClankerWorkTask
function TaskManager:is_active_task(task)
  return self.active_task == task
end

---@param task ClankerWorkTask
function TaskManager:queued_position(task)
  for i, queued_task in ipairs(self.queued_tasks) do
    if queued_task == task then
      return i
    end
  end
end

---@param task ClankerWorkTask
function TaskManager:is_tracked_task(task)
  return self:is_active_task(task) or self:queued_position(task) ~= nil
end

---@return ClankerWorkTask[]
function TaskManager:tasks()
  local tasks = {}

  if self.active_task then
    tasks[#tasks + 1] = self.active_task
  end

  for _, task in ipairs(self.queued_tasks) do
    tasks[#tasks + 1] = task
  end

  return tasks
end

---@return ClankerWorkTask
function TaskManager:schedule_task()
  local task = Task.new()
  self.queued_tasks[#self.queued_tasks + 1] = task

  return task
end

---@return ClankerWorkTask?
function TaskManager:activate_next_task()
  if self.active_task then
    return
  end

  local task = self.queued_tasks[1]
  if not task or not task.prompt then
    return
  end

  table.remove(self.queued_tasks, 1)
  self.active_task = task
  task.status = "submitted"

  return task
end

---@return ClankerWorkTask?
function TaskManager:finish_active_task()
  local task = self.active_task
  self.active_task = nil

  return task
end

---@param task ClankerWorkTask
---@return "active"|"queued"|nil
function TaskManager:remove_task(task)
  if self.active_task == task then
    self.active_task = nil
    return "active"
  end

  for i, queued_task in ipairs(self.queued_tasks) do
    if queued_task == task then
      table.remove(self.queued_tasks, i)
      return "queued"
    end
  end
end

---@param buf integer
---@param row integer
---@return ClankerWorkTask?
function TaskManager:task_at(buf, row)
  local active_task = self.active_task
  if
    active_task
    and active_task.buf == buf
    and row >= active_task.range.start_row
    and row <= active_task.range.end_row
  then
    return active_task
  end

  for _, task in ipairs(self.queued_tasks) do
    if task.buf == buf and row >= task.range.start_row and row <= task.range.end_row then
      return task
    end
  end
end

---@param event ClankerWorkClientEvent
---@return ClankerWorkTask?
function TaskManager:handle_event(event)
  if not self.active_task then
    return
  end

  local task = self.active_task

  if event.type == "running" then
    task.status = "running"
    return
  end

  if event.type == "error" then
    return self:finish_active_task()
  end

  if event.type == "done" and task.status == "running" then
    return self:finish_active_task()
  end
end

return TaskManager
