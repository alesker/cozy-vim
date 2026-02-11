return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  config = function()
    local gruvbox = require("gruvbox")
    local palette = gruvbox.palette

    gruvbox.setup({
      overrides = {
        TreesitterContextBottom = { underline = true, italic = true, sp = palette.gray },
        TreesitterContextLineNumberBottom = { underline = true, italic = true, sp = palette.gray },

        OilGitUntracked = { fg = palette.neutral_aqua, bold = true },
        OilGitAdded = { fg = palette.neutral_aqua, bold = true },
        OilGitModified = { fg = palette.neutral_yellow, bold = true },
        OilGitRenamed = { fg = palette.neutral_purple, bold = true },
        OilGitIgnored = { fg = palette.gray, bold = false },

        NeoTreeGitUntracked = { fg = palette.neutral_aqua, bold = true },
        NeoTreeGitAdded = { fg = palette.neutral_aqua, bold = true },
        NeoTreeGitModified = { fg = palette.neutral_yellow, bold = true },
        NeoTreeGitRenamed = { fg = palette.neutral_purple, bold = true },
        NeoTreeGitDeleted = { fg = palette.neutral_red, bold = true },
        NeoTreeGitIgnored = { fg = palette.gray, bold = false },
        NeoTreeGitConflict = { fg = palette.neutral_orange, bold = true, italic = true },

        RenderMarkdownH1 = { fg = palette.neutral_orange },
        RenderMarkdownH2 = { fg = palette.neutral_yellow },
        RenderMarkdownH3 = { fg = palette.neutral_purple },
        RenderMarkdownH4 = { fg = palette.neutral_blue },
        RenderMarkdownH5 = { fg = palette.neutral_aqua },
        RenderMarkdownH6 = { fg = palette.neutral_green },

        RenderMarkdownH1Bg = { bg = palette.neutral_orange, fg = palette.light0 },
        RenderMarkdownH2Bg = { bg = palette.neutral_yellow, fg = palette.light0 },
        RenderMarkdownH3Bg = { bg = palette.neutral_purple, fg = palette.light0 },
        RenderMarkdownH4Bg = { bg = palette.neutral_blue, fg = palette.light0 },
        RenderMarkdownH5Bg = { bg = palette.neutral_aqua, fg = palette.light0 },
        RenderMarkdownH6Bg = { bg = palette.neutral_green, fg = palette.light0 },

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
