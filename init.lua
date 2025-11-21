vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true

vim.o.showmode = false

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

vim.o.expandtab = true
vim.o.breakindent = true
vim.o.smartindent = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2

vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = "yes"

vim.o.updatetime = 250

vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.inccommand = "split"

vim.o.confirm = true

-- Cursor, scrolling and wrapping

vim.o.mouse = "a"

vim.o.cursorline = true

vim.o.scrolloff = 0
vim.o.sidescroll = 1
vim.o.sidescrolloff = 1

-- [[ Basic Keymaps ]]
--

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>tr", function()
  ToggleRelativeNumber()
end, { desc = "Toggle [R]elative Number" })
vim.keymap.set("n", "<leader>th", function()
  ToggleHardMode()
end, { desc = "Toggle [H]ard Mode" })

function ToggleRelativeNumber()
  vim.o.relativenumber = not vim.o.relativenumber
end

local hardMode = false
function ToggleHardMode()
  hardMode = not hardMode

  local function toggleKey(key)
    local value = hardMode and "<Nop>" or key
    vim.keymap.set({ "n", "i", "v" }, key, value)
  end

  toggleKey("<Up>")
  toggleKey("<Down>")
  toggleKey("<Left>")
  toggleKey("<Right>")
  toggleKey("<Del>")
  toggleKey("<BS>")
end

-- [[ Basic Autocommands ]]

-- Highlight when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Plugins ]]
--

-- lazy.nvim setup

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "desert" } },
  checker = { enabled = true },
})
