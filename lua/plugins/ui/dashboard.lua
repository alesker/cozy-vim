return {
  "goolord/alpha-nvim",
  config = function()
    require("alpha.term")
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    local term_width = 42
    local term_height = 12
    local header = nil
    local neo = os.execute("command -v neo &>/dev/null")

    if neo == 0 then
      header = {
        type = "terminal",
        command = "neo --speed=5 -a -d 0.5 -D -m NEOVIM",
        width = term_width,
        height = term_height,
        opts = {
          redraw = true,
          window_config = {},
        },
      }
    else
      header = {
        type = "text",
        val = {
          [[                                __                 ]],
          [[   ___     ___    ___   __  __ /\_\    ___ ___     ]],
          [[  / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\   ]],
          [[ /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \  ]],
          [[ \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\ ]],
          [[  \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/ ]],
        },
        opts = { position = "center", hl = "DashboardHeader" },
      }
    end

    local section = {
      terminal = dashboard.section.default_terminal,
      header = header,
    }

    local title = {
      type = "text",
      val = "Do. Or do not. There is no try",
      opts = {
        position = "center",
        hl = "Number",
      },
    }

    local footer = {
      type = "text",
      val = "May the Force be with you",
      opts = {
        position = "center",
      },
    }

    alpha.setup({
      layout = {
        header,
        { type = "padding", val = 2 },
        title,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        footer,
      },
      opts = {
        margin = 8,
      },
    })
  end,
}
