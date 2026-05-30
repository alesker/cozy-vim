local M = {}

local sources = {
  {
    name = "vscode-go",
    url = "https://raw.githubusercontent.com/golang/vscode-go/master/extension/snippets/go.json",
    output = "go/remote.json",
    transform = function(data)
      return data[".source.go"]
    end,
  },
}

local function script_dir()
  local source = debug.getinfo(1, "S").source:sub(2)
  return vim.fs.dirname(vim.fs.normalize(source))
end

local function fetch(url)
  if vim.fn.executable("curl") ~= 1 then
    error("curl is required to update remote snippets")
  end

  local result = vim.system({ "curl", "-fsSL", url }, { text = true }):wait()
  if result.code ~= 0 then
    error(("failed to fetch %s: %s"):format(url, vim.trim(result.stderr or "")))
  end

  return result.stdout
end

local function encode_json(value)
  if vim.fn.executable("jq") ~= 1 then
    error("jq is required to format remote snippets")
  end

  local result = vim.system({ "jq", "-S", "." }, { text = true, stdin = vim.json.encode(value) }):wait()
  if result.code ~= 0 then
    error(("failed to format snippets with jq: %s"):format(vim.trim(result.stderr or "")))
  end

  return result.stdout
end

local function find_placeholder_end(body, start)
  local depth = 1
  local index = start + 2

  while index <= #body do
    local char = body:sub(index, index)
    local next_char = body:sub(index + 1, index + 1)

    if char == "\\" then
      index = index + 2
    elseif char == "$" and next_char == "{" then
      depth = depth + 1
      index = index + 2
    elseif char == "}" then
      depth = depth - 1
      if depth == 0 then
        return index
      end
      index = index + 1
    else
      index = index + 1
    end
  end
end

local function flatten_nested_placeholder_defaults(body)
  local output = {}
  local index = 1

  while index <= #body do
    local placeholder_start, tabstop_end = body:find("%${%d+:", index)
    if not placeholder_start then
      table.insert(output, body:sub(index))
      break
    end

    table.insert(output, body:sub(index, placeholder_start - 1))

    local placeholder_end = find_placeholder_end(body, placeholder_start)
    if not placeholder_end then
      table.insert(output, body:sub(placeholder_start))
      break
    end

    local prefix = body:sub(placeholder_start, tabstop_end)
    local default = body:sub(tabstop_end + 1, placeholder_end - 1)
    default = flatten_nested_placeholder_defaults(default)
    default = default:gsub("%${%d+:([^{}]*)}", "%1")
    default = default:gsub("%${%d+}", "")
    default = default:gsub("%$%d+", "")

    table.insert(output, prefix .. default .. "}")
    index = placeholder_end + 1
  end

  return table.concat(output)
end

local function sanitize_snippet_if_needed(name, snippet)
  local body = type(snippet.body) == "table" and table.concat(snippet.body, "\n") or snippet.body
  if type(body) ~= "string" or pcall(vim.lsp._snippet_grammar.parse, body) then
    return
  end

  snippet.body = flatten_nested_placeholder_defaults(body)

  if not pcall(vim.lsp._snippet_grammar.parse, snippet.body) then
    error(("snippet %q is still invalid after sanitizing"):format(name))
  end
end

local function write_file(path, contents)
  vim.fn.mkdir(vim.fs.dirname(path), "p")

  local file = assert(io.open(path, "w"))
  file:write(vim.trim(contents))
  file:write("\n")
  file:close()
end

function M.update()
  local root = script_dir()

  for _, source in ipairs(sources) do
    local decoded = vim.json.decode(fetch(source.url))
    local snippets = source.transform(decoded)
    if type(snippets) ~= "table" then
      error(("%s did not produce a snippets table"):format(source.name))
    end
    for name, snippet in pairs(snippets) do
      sanitize_snippet_if_needed(name, snippet)
    end

    local output = vim.fs.joinpath(root, source.output)
    write_file(output, encode_json(snippets))
    vim.notify(("Updated snippets: %s -> %s"):format(source.name, output), vim.log.levels.INFO)
  end
end

if ... == nil then
  M.update()
end

return M
