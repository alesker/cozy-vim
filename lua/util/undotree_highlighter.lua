local M = {}

function M.highlight(buf)
  vim.api.nvim_set_hl(0, "UndotreeNode", { link = "Statement" })
  vim.api.nvim_set_hl(0, "UndotreeSeq", { link = "Identifier" })
  vim.api.nvim_set_hl(0, "UndotreeTimestamp", { link = "Comment" })

  local undotree_highlights = vim.api.nvim_create_namespace("undotree_highlights")

  vim.api.nvim_buf_clear_namespace(buf, undotree_highlights, 0, -1)

  for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local line_index = row - 1

    local node_start, node_end = line:find("%*")
    if node_start then
      vim.api.nvim_buf_set_extmark(buf, undotree_highlights, line_index, node_start - 1, {
        end_col = node_end,
        hl_group = "UndotreeNode",
      })
    end

    local seq_start, seq_end = line:find("%s%d+%s")
    if seq_start then
      vim.api.nvim_buf_set_extmark(buf, undotree_highlights, line_index, seq_start, {
        end_col = seq_end - 1,
        hl_group = "UndotreeSeq",
      })
    end

    local timestamp_start = line:find("%([^()]*%)$")
    if timestamp_start then
      vim.api.nvim_buf_set_extmark(buf, undotree_highlights, line_index, timestamp_start - 1, {
        end_col = #line,
        hl_group = "UndotreeTimestamp",
      })
    end
  end
end

return M
