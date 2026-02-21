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
        command = "neo --defaultbg --async --speed=5 --density=0.5 --message=NEOVIM",
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

    local icons = Core.icons.dashboard

    local buttons = {
      type = "group",
      val = {
        dashboard.button("n", icons.new_file .. " " .. "New file", ":enew <BAR> startinsert <CR>"),
        dashboard.button("f", icons.find_file .. " " .. "Find file", ":Telescope find_files <CR>"),
        dashboard.button("r", icons.recent_files .. " " .. "Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", icons.find_text .. " " .. "Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", icons.config .. " " .. "Config", ":e $MYVIMRC <CR>"),
        dashboard.button("s", icons.restore_session .. " " .. "Restore Session", ":PersistenceLoad <CR>"),
        dashboard.button("l", icons.lazy .. " " .. "Lazy", ":Lazy <CR>"),
        dashboard.button("m", icons.mason .. " " .. "Mason", ":Mason <CR>"),
        dashboard.button("q", icons.quit .. " " .. "Quit", ":qa <CR>"),
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
