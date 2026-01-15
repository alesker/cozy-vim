local M = {}

local harpoon = require("harpoon")
local path = require("plenary.path")

function M.match(id)
  local bufname = vim.api.nvim_buf_get_name(id)
  if bufname == "" then
    return nil
  end

  local list = harpoon:list(Core.tab_key())
  local root = list.config.get_root_dir()
  local value = path:new(bufname):make_relative(root)

  for index, item in pairs(list.items) do
    if value == item.value then
      return index
    end
  end

  return nil
end

return M
