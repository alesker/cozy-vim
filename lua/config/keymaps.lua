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
