local M = {}

local marks = require("marks")

function M.toggle_mark(mark)
  marks.refresh(true)

  local bufnr = vim.api.nvim_get_current_buf()
  local pos = vim.api.nvim_win_get_cursor(0)

  local buffer = marks.mark_state.buffers[bufnr]
  local placed_marks = buffer and buffer.placed_marks or {}
  local placed_mark = placed_marks[mark]

  -- remove all marks currently on the line
  local line_marks = buffer and buffer.marks_by_line[pos[1]] or {}
  for _, line_mark in pairs(line_marks) do
    marks.mark_state:delete_mark(line_mark)
  end

  -- add mark on the line if it wasn't there already
  if placed_mark and placed_mark.line == pos[1] then
    marks.mark_state:delete_mark(mark)
  else
    marks.mark_state:register_mark(mark, pos[1], pos[2], bufnr)
    vim.api.nvim_buf_set_mark(bufnr, mark, pos[1], pos[2], {})
  end
end

function M.toggle_next_mark()
  marks.refresh(true)

  local pos = vim.api.nvim_win_get_cursor(0)
  local bufnr = vim.api.nvim_get_current_buf()

  local next_available_mark = nil
  local toggleable_mark = nil
  for byte = string.byte("A"), string.byte("Z") do
    local mark = string.char(byte)

    local placed_mark = vim.api.nvim_get_mark(mark, {})
    if next_available_mark == nil and vim.deep_equal(placed_mark, { 0, 0, 0, "" }) then
      next_available_mark = mark
    end
    if placed_mark[1] == pos[1] and placed_mark[3] == bufnr then
      toggleable_mark = mark
      break
    end
  end

  if toggleable_mark then
    M.toggle_mark(toggleable_mark)
  elseif next_available_mark then
    M.toggle_mark(next_available_mark)
  end
end

function M.delete_marks()
  marks.refresh(true)
  for byte = string.byte("A"), string.byte("Z") do
    local mark = string.char(byte)
    marks.mark_state:delete_mark(mark)
  end
end

return M
