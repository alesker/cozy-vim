vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.autowrite = true
vim.o.confirm = true
vim.o.undofile = true
vim.o.updatetime = 250

vim.opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "skiprtp",
  "folds",
}

vim.o.undolevels = 10000

vim.o.number = true
vim.o.relativenumber = true

vim.o.timeoutlen = 300

vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

vim.o.jumpoptions = "view"

vim.o.ruler = false

vim.o.signcolumn = "yes"

vim.o.spelllang = "en"

vim.opt.shortmess:append({
  W = true,
  I = true,
  c = true,
  C = true,
})

-- Indenting

vim.o.expandtab = true
vim.o.breakindent = true
vim.o.smartindent = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftround = true

vim.o.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- Folds

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = "indent"
vim.o.foldtext = ""

-- Search and replace

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.inccommand = "nosplit"

-- Completion

vim.o.completeopt = "menu,menuone,noselect"
vim.o.wildmode = "longest:full,full"

-- Windows, popups and splits

vim.o.splitright = true
vim.o.splitbelow = true
vim.o.splitkeep = "screen"

vim.o.termguicolors = true
vim.o.pumblend = 10
vim.o.pumheight = 10

vim.o.winminwidth = 5

-- Statusline

vim.o.laststatus = 3

vim.o.showmode = false

-- Cursor, scrolling and wrapping

vim.o.mouse = "a"

vim.o.cursorline = true
vim.o.virtualedit = "block"

vim.o.scrolloff = 0
vim.o.scrolloff = 4
vim.o.sidescroll = 1
vim.o.sidescrolloff = 1
vim.o.sidescrolloff = 8

vim.o.smoothscroll = true

vim.o.linebreak = true
vim.o.wrap = false
