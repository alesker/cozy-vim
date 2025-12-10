return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  config = function()
    require("gruvbox").setup({
      overrides = {
        -- fix wonky sign background in neo-tree
        DiagnosticSignError = { link = "GruvboxRed" },
        DiagnosticSignWarn = { link = "GruvboxYellow" },
        DiagnosticSignInfo = { link = "GruvboxBlue" },
        DiagnosticSignHint = { link = "GruvboxAqua" },
        DiagnosticSignOk = { link = "GruvboxGreen" },
      },
    })
    vim.cmd.colorscheme("gruvbox")
  end,
}
