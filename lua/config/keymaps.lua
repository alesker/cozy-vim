-- Better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Line start/end shortcuts
vim.keymap.set({ "n", "x" }, "_", "^", { desc = "^" })
vim.keymap.set({ "n", "x" }, "+", "$", { desc = "$" })

-- Jump back/forward shortcuts
vim.keymap.set("n", "<C-->", "<C-o>")
vim.keymap.set("n", "<C-=>", "<C-i>")

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
vim.keymap.set("n", "-", "<C-w>w", { desc = "Go to Next Window", remap = true })

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
vim.keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
vim.keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
vim.keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Last yank pasting
vim.keymap.set("n", "gp", '"0p', { desc = "Paste last yank" })
vim.keymap.set("n", "gP", '"0P', { desc = "Paste last yank before cursor" })
vim.keymap.set("x", "gp", '"_d"0P', { desc = "Replace selection with last yank" })
vim.keymap.set("x", "gP", '"_d"0P', { desc = "Replace selection with last yank" })

-- Better indenting
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- Buffers
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })

-- Tabs
vim.keymap.set("n", "[<Tab>", "<cmd>tabprevious<cr>", { desc = "Prev Tab" })
vim.keymap.set("n", "]<Tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><Tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><Tab>c", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><Tab>c", "<cmd>tabclose<cr>", { desc = "Close Tab" })
for i = 1, 4 do
  vim.keymap.set("n", "<leader><Tab>" .. i, i .. "gt", { desc = "Switch to Tab " .. i })
end

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- Quit
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit All" })

-- Lazy
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Mason
vim.keymap.set("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Mason" })

-- Clear search
vim.keymap.set({ "i", "n", "s" }, "<Esc>", function()
  vim.cmd("nohlsearch")
  return "<Esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end

vim.keymap.set("n", "<leader>cd", function()
  vim.diagnostic.open_float()
end, { desc = "Line Diagnostics" })
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>ur")

Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.indent():map("<leader>ug")

Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")

Snacks.toggle({
  get = function()
    return vim.g.hard_mode
  end,
  set = function(state)
    vim.g.hard_mode = state

    local function toggle_key(key)
      local value = state and "<Nop>" or key
      vim.keymap.set({ "n", "i", "v" }, key, value, { noremap = true, silent = true })
    end

    toggle_key("<Up>")
    toggle_key("<Down>")
    toggle_key("<Left>")
    toggle_key("<Right>")

    toggle_key("<C-w><Up>")
    toggle_key("<C-w><Down>")
    toggle_key("<C-w><Left>")
    toggle_key("<C-w><Right>")

    toggle_key("<LeftMouse>")
    toggle_key("<RightMouse>")
  end,
  name = "Hard Mode",
}):map("<leader>uH")
