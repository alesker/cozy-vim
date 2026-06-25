local Renderer = {}
Renderer.__index = Renderer

function Renderer.new(opts)
  return setmetatable({
    interval = opts.interval,
    spinner = opts.spinner,
    decorate = opts.decorate,
    indicator = opts.indicator,
    on_invalid = opts.on_invalid,
    decorations_namespace = vim.api.nvim_create_namespace(opts.namespace .. "Decorations"),
    anchors_namespace = vim.api.nvim_create_namespace(opts.namespace .. "Anchors"),
    timer = nil,
    tasks = {},
  }, Renderer)
end

function Renderer:_has_tasks()
  return #self.tasks > 0
end

---@param task ClankerWorkTask
function Renderer:_contains(task)
  for _, current_task in ipairs(self.tasks) do
    if current_task == task then
      return true
    end
  end

  return false
end

---@param task ClankerWorkTask
function Renderer:_is_valid(task)
  return task and task.buf and vim.api.nvim_buf_is_valid(task.buf) and task.win and vim.api.nvim_win_is_valid(task.win)
end

---@param task ClankerWorkTask
function Renderer:_make_render_objects(task)
  local start_row = task.range.start_row
  local end_row = task.range.end_row

  local header = {
    type = "header",
    row = start_row,
  }
  local footer = {
    type = "footer",
    row = end_row,
  }

  local objects = { header }

  for row = start_row, end_row do
    objects[#objects + 1] = {
      type = "line",
      row = row,
    }
  end

  objects[#objects + 1] = footer

  return objects
end

---@param task ClankerWorkTask
function Renderer:_set_anchors(task)
  task.mark_anchors = {
    header_anchor = vim.api.nvim_buf_set_extmark(
      task.buf,
      self.anchors_namespace,
      task.range.start_row,
      0,
      { right_gravity = false }
    ),
    footer_anchor = vim.api.nvim_buf_set_extmark(
      task.buf,
      self.anchors_namespace,
      task.range.end_row,
      0,
      { right_gravity = true }
    ),
  }
end

---@param task ClankerWorkTask
function Renderer:_delete_anchors(task)
  if not task.mark_anchors or not task.buf or not vim.api.nvim_buf_is_valid(task.buf) then
    task.mark_anchors = nil
    return
  end

  if task.mark_anchors.header_anchor then
    pcall(vim.api.nvim_buf_del_extmark, task.buf, self.anchors_namespace, task.mark_anchors.header_anchor)
  end
  if task.mark_anchors.footer_anchor then
    pcall(vim.api.nvim_buf_del_extmark, task.buf, self.anchors_namespace, task.mark_anchors.footer_anchor)
  end

  task.mark_anchors = nil
end

---@param task ClankerWorkTask
function Renderer:_sync_anchors(task)
  if not task.mark_anchors then
    return false
  end

  local start_pos =
    vim.api.nvim_buf_get_extmark_by_id(task.buf, self.anchors_namespace, task.mark_anchors.header_anchor, {})
  local end_pos =
    vim.api.nvim_buf_get_extmark_by_id(task.buf, self.anchors_namespace, task.mark_anchors.footer_anchor, {})

  if #start_pos == 0 or #end_pos == 0 then
    return false
  end

  task.range.start_row = start_pos[1]
  task.range.end_row = math.max(start_pos[1], end_pos[1])
  return true
end

---@param tasks ClankerWorkTask[]
function Renderer:_clear_decoration_buffers(tasks)
  local cleared = {}

  for _, task in ipairs(tasks) do
    if task.buf and not cleared[task.buf] and vim.api.nvim_buf_is_valid(task.buf) then
      vim.api.nvim_buf_clear_namespace(task.buf, self.decorations_namespace, 0, -1)
      cleared[task.buf] = true
    end
  end
end

---@param task ClankerWorkTask
---@param indicator string
function Renderer:_draw_task(task, indicator)
  local objects = self:_make_render_objects(task)
  local decorated_objects = self.decorate(objects, indicator, task)

  for _, object in ipairs(decorated_objects) do
    local opts = vim.deepcopy(object.opts or {})
    vim.api.nvim_buf_set_extmark(task.buf, self.decorations_namespace, object.row, 0, opts)
  end
end

---@param task ClankerWorkTask
function Renderer:_remove_from_tasks(task)
  for i, current_task in ipairs(self.tasks) do
    if current_task == task then
      table.remove(self.tasks, i)
      return true
    end
  end

  return false
end

function Renderer:_start_timer()
  if self.timer then
    return true
  end

  local timer = vim.uv.new_timer()
  if not timer then
    return false
  end

  self.timer = timer
  timer:start(
    self.interval,
    self.interval,
    vim.schedule_wrap(function()
      self:_tick()
    end)
  )

  return true
end

function Renderer:_stop_timer()
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end

  self.spinner:reset()
end

function Renderer:_tick()
  if not self:_has_tasks() then
    self:_stop_timer()
    return
  end

  local previous_tasks = self.tasks
  local valid_tasks = {}
  local invalid_tasks = {}

  for _, task in ipairs(previous_tasks) do
    if self:_is_valid(task) and self:_sync_anchors(task) then
      valid_tasks[#valid_tasks + 1] = task
    else
      invalid_tasks[#invalid_tasks + 1] = task
    end
  end

  self.tasks = valid_tasks
  self:_clear_decoration_buffers(previous_tasks)

  local spinner = self.spinner:next()
  for _, task in ipairs(valid_tasks) do
    self:_draw_task(task, self.indicator(task, spinner))
  end

  for _, task in ipairs(invalid_tasks) do
    self:_delete_anchors(task)
    if self.on_invalid then
      self.on_invalid(task)
    end
  end

  if not self:_has_tasks() then
    self:_stop_timer()
  end
end

---@param task ClankerWorkTask
function Renderer:add_task(task)
  if self:_contains(task) then
    self:_tick()
    return true
  end

  self.tasks[#self.tasks + 1] = task
  self:_set_anchors(task)

  if not self:_start_timer() then
    self:remove_task(task)
    return false
  end

  self:_tick()
  return self:_contains(task)
end

---@param task ClankerWorkTask
function Renderer:remove_task(task)
  if not self:_remove_from_tasks(task) then
    return false
  end

  self:_delete_anchors(task)
  self:_clear_decoration_buffers({ task })

  if self:_has_tasks() then
    self:_tick()
  else
    self:_stop_timer()
  end

  return true
end

---@param task ClankerWorkTask
function Renderer:sync_task(task)
  return self:_contains(task) and self:_is_valid(task) and self:_sync_anchors(task)
end

function Renderer:redraw()
  self:_tick()
end

function Renderer:stop()
  self:_stop_timer()

  for _, task in ipairs(self.tasks) do
    if task.buf and vim.api.nvim_buf_is_valid(task.buf) then
      vim.api.nvim_buf_clear_namespace(task.buf, self.decorations_namespace, 0, -1)
    end
    self:_delete_anchors(task)
  end

  self.tasks = {}
end

return Renderer
