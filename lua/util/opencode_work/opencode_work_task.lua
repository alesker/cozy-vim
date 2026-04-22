---@class OpencodeWorkRange
---@field start_row integer
---@field end_row integer

---@class OpencodeWorkTaskMarks
---@field header_anchor? integer
---@field footer_anchor? integer

---@class OpencodeWorkTask
---@field buf integer
---@field win integer
---@field range OpencodeWorkRange
---@field mark_anchors? OpencodeWorkTaskMarks
---@field status "prompting"|"submitted"|"running"
---

local Task = {}
Task.__index = Task

---@class OpencodeWorkTask
function Task.new()
  local buf = vim.api.nvim_get_current_buf()

  return {
    buf = buf,
    win = vim.api.nvim_get_current_win(),
    range = Task._get_visual_range(buf),
    status = "prompting",
  }
end

function Task._get_visual_range(buf)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local current_line_range = {
    start_row = row,
    end_row = row,
  }

  local mode = vim.fn.mode()
  if not mode:match("[vV\22]") then
    return current_line_range
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)

  local from = vim.api.nvim_buf_get_mark(buf, "<")
  local to = vim.api.nvim_buf_get_mark(buf, ">")
  if from[1] == 0 or to[1] == 0 then
    return current_line_range
  end

  if from[1] > to[1] or (from[1] == to[1] and from[2] > to[2]) then
    from, to = to, from
  end

  return {
    start_row = from[1] - 1,
    end_row = to[1] - 1,
  }
end

return Task
