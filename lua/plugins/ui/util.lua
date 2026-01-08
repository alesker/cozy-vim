return {
  {
    "NStefan002/screenkey.nvim",
    lazy = false,
    config = function(_, opts)
      require("screenkey").setup(opts)

      Snacks.toggle({
        name = "Screenkey",
        get = require("screenkey").is_active,
        set = require("screenkey").toggle,
      }):map("<leader>uS")

      local macro_dispay = require("util.screenkey_macro_display")
      macro_dispay.setup(opts)
    end,
  },
}
