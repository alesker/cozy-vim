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
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

vim.o.inccommand = "split"

vim.o.confirm = true

-- Cursor, scrolling and wrapping

vim.o.mouse = "a"

vim.o.cursorline = true

vim.o.scrolloff = 0
vim.o.sidescroll = 1
vim.o.sidescrolloff = 1
