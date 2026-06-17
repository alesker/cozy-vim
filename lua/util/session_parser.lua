local M = {}

local function session_file()
  local persistence = require("persistence")
  local file = persistence.current()
  if vim.fn.filereadable(file) == 0 then
    file = persistence.current({ branch = false })
  end

  if vim.fn.filereadable(file) == 0 then
    return nil
  end

  return file
end

local function badd_files(lines)
  local files = {}
  local seen = {}

  for _, line in ipairs(lines) do
    local file = line:match("^badd%s+%+%d+%s+(.+)$") or line:match("^badd%s+(.+)$")

    if not file or seen[file] then
      return
    end

    seen[file] = true
    table.insert(files, file)
  end

  return files
end

local function scope_state_tabs(lines)
  for _, line in ipairs(lines) do
    local value = line:match("^let%s+ScopeState%s*=%s*(.+)$") or line:match("^let%s+g:ScopeState%s*=%s*(.+)$")
    if value then
      local state = vim.fn.eval(value)
      if not state then
        return nil
      end

      local decoded = vim.json.decode(state)
      if not decoded.cache then
        return nil
      end

      local tabs = {}
      for index, files in ipairs(decoded.cache) do
        if #files > 0 then
          tabs[index] = files
        end
      end

      return next(tabs) and tabs or nil
    end
  end

  return nil
end

function M.parse()
  local file = session_file()
  if not file then
    return {}
  end

  local lines = vim.fn.readfile(file)
  local scope_tabs = scope_state_tabs(lines)
  if scope_tabs then
    return scope_tabs
  end

  return { [1] = badd_files(lines) }
end

return M
