return {
  "goolord/alpha-nvim",
  config = function()
    require("alpha.term")
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    local header = nil
    local neo = os.execute("command -v neo &>/dev/null")

    if neo == 0 then
      header = {
        type = "terminal",
        command = "neo --speed=5 -a -d 0.5 -D -m NEOVIM",
        width = 42,
        height = 12,
        opts = {
          redraw = true,
          window_config = {},
        },
      }
    else
      header = {
        type = "text",
        val = {
          [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
          [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
          [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
          [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
          [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
          [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
        },
        opts = { position = "center", hl = "DashboardHeader" },
      }
    end

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

    local buttons = {
      type = "group",
      val = {
        dashboard.button("n", " " .. " " .. "New file", ":enew <BAR> startinsert <CR>"),
        dashboard.button("f", " " .. " " .. "Find file", ":Telescope find_files <CR>"),
        dashboard.button("r", " " .. " " .. "Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", " " .. " " .. "Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", " " .. " " .. "Config", ":e $MYVIMRC <CR>"),
        dashboard.button("s", " " .. " " .. "Restore Session", ":lua require('persistence').load() <CR>"),
        dashboard.button("l", "󰒲 " .. " " .. "Lazy", ":Lazy <CR>"),
        dashboard.button("m", " " .. " " .. "Mason", ":Mason <CR>"),
        dashboard.button("q", " " .. " " .. "Quit", ":qa <CR>"),
      },
    }

    alpha.setup({
      layout = {
        header,
        { type = "padding", val = 2 },
        title,
        { type = "padding", val = 2 },
        buttons,
        { type = "padding", val = 2 },
        footer,
      },
      opts = {
        margin = 8,
      },
    })
  end,
}
