require("config.core")
require("config.options")

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

local specs = {
  { import = "plugins" },
  { import = "plugins.ui" },
  { import = "plugins.lang" },
}

if (vim.uv or vim.loop).fs_stat(vim.fn.stdpath("config") .. "/lua/plugins/local") then
  table.insert(specs, { import = "plugins.local" })
end

require("lazy").setup({
  spec = specs,
  install = { colorscheme = { "desert" } },
  checker = { enabled = true },
})

require("config.keymaps")
require("config.autocmds")

-- Remove training wheels
Snacks.toggle.get("hard_mode"):set(true)
