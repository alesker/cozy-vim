local Renderer = {}
Renderer.__index = Renderer

function Renderer.new(opts)
  return setmetatable({
    interval = opts.interval,
    spinner = opts.spinner,
    decorate = opts.decorate,
    decorations_namespace = vim.api.nvim_create_namespace(opts.namespace .. "Decorations"),
    anchors_namespace = vim.api.nvim_create_namespace(opts.namespace .. "Anchors"),
    timer = nil,
    task = nil,
  }, Renderer)
end

function Renderer:_is_active()
  return self.task ~= nil
end

function Renderer:_is_valid()
  local task = self.task
  return task and task.buf and vim.api.nvim_buf_is_valid(task.buf) and task.win and vim.api.nvim_win_is_valid(task.win)
end

function Renderer:_same_task(task)
  local current = self.task
  return current
    and current.buf == task.buf
    and current.win == task.win
    and current.range.start_row == task.range.start_row
    and current.range.end_row == task.range.end_row
end

function Renderer:_make_render_objects()
  local start_row = self.task.range.start_row
  local end_row = self.task.range.end_row

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

function Renderer:_set_anchors()
  local task = self.task

  local new_header_anchor =
    vim.api.nvim_buf_set_extmark(task.buf, self.anchors_namespace, task.range.start_row, 0, { right_gravity = false })
  local new_footer_anchor =
    vim.api.nvim_buf_set_extmark(task.buf, self.anchors_namespace, task.range.end_row, 0, { right_gravity = true })

  task.mark_anchors = task.mark_anchors or {}
  task.mark_anchors.header_anchor = task.mark_anchors.header_anchor or new_header_anchor
  task.mark_anchors.footer_anchor = task.mark_anchors.footer_anchor or new_footer_anchor
end

function Renderer:_sync_anchors()
  local task = self.task

  local start_pos =
    vim.api.nvim_buf_get_extmark_by_id(task.buf, self.anchors_namespace, task.mark_anchors.header_anchor, {})
  local end_pos =
    vim.api.nvim_buf_get_extmark_by_id(task.buf, self.anchors_namespace, task.mark_anchors.footer_anchor, {})

  if #start_pos == 0 or #end_pos == 0 then
    self:stop()
    return false
  end

  task.range.start_row = start_pos[1]
  task.range.end_row = math.max(start_pos[1], end_pos[1])
  return true
end

function Renderer:_tick()
  if not self:_is_active() then
    return
  end

  if not self:_is_valid() then
    self:stop()
    return
  end

  if not self:_sync_anchors() then
    return
  end

  local objects = self:_make_render_objects()
  local spinner = self.spinner:next()

  local decorated_objects = self.decorate(objects, spinner, self.task)

  vim.api.nvim_buf_clear_namespace(self.task.buf, self.decorations_namespace, 0, -1)

  for _, object in ipairs(decorated_objects) do
    local opts = vim.deepcopy(object.opts or {})
    vim.api.nvim_buf_set_extmark(self.task.buf, self.decorations_namespace, object.row, 0, opts)
  end
end

function Renderer:start(task)
  self:stop()

  self.task = task
  self:_set_anchors()

  self:_tick()

  if not self:_is_active() then
    return false
  end

  local timer = vim.uv.new_timer()
  if not timer then
    self:stop()
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

function Renderer:stop()
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end

  if self.task and self.task.buf and vim.api.nvim_buf_is_valid(self.task.buf) then
    vim.api.nvim_buf_clear_namespace(self.task.buf, self.decorations_namespace, 0, -1)
    vim.api.nvim_buf_clear_namespace(self.task.buf, self.anchors_namespace, 0, -1)
  end

  self.task = nil
  self.spinner:reset()
end

function Renderer:matches(task)
  return self:_same_task(task)
end

return Renderer
