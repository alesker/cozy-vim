return {
  "goolord/alpha-nvim",
  config = function()
    require("alpha.term")
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    local session_parser = require("util.session_parser")

    local header = nil
    local neo = os.execute("command -v neo &>/dev/null")

    if neo == 0 then
      header = {
        type = "terminal",
        command = "neo --defaultbg --async --speed=5 --density=0.5 --message=NEOVIM",
        width = 69,
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
      val = "Do. Or do not. There is no try.",
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
        dashboard.button(".", icons.find_file .. " " .. "Find file", ":Telescope find_files <CR>"),
        dashboard.button(",", icons.recent_files .. " " .. "Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("/", icons.find_text .. " " .. "Find text", ":Telescope live_grep <CR>"),
        dashboard.button("s", icons.restore_session .. " " .. "Restore Session", ":PersistenceLoad <CR>"),
        dashboard.button("g", icons.git .. " " .. "Git", ":Neogit <CR>"),
        dashboard.button("l", icons.lazy .. " " .. "Lazy", ":Lazy <CR>"),
        dashboard.button("m", icons.mason .. " " .. "Mason", ":Mason <CR>"),
        dashboard.button("q", icons.quit .. " " .. "Quit", ":qa <CR>"),
      },
    }

    local session_context = {
      type = "group",
      val = {
        {
          type = "text",
          val = { "[Session]", "" },
          opts = {
            position = "center",
            hl = "Type",
          },
        },
        {
          type = "text",
          val = function()
            local max_session_context = 10
            local max_files = 5

            local tabs = session_parser.parse()
            local tab_numbers = vim.tbl_keys(tabs)
            table.sort(tab_numbers)

            local show_tabs = #tab_numbers > 1
            local lines = {}

            for _, tab_number in ipairs(tab_numbers) do
              if show_tabs then
                if #lines < max_session_context then
                  table.insert(lines, string.format("Tab %d", tab_number))
                else
                  table.insert(lines, "...")
                  break
                end
              end

              for index, file in ipairs(tabs[tab_number]) do
                local prefix = show_tabs and "  " or ""
                local localized_path = vim.fn.fnamemodify(vim.fn.expand(file), ":.")

                if index <= max_files and #lines < max_session_context then
                  table.insert(lines, prefix .. localized_path)
                else
                  table.insert(lines, prefix .. "...")
                  break
                end
              end
            end

            return lines
          end,
          opts = {
            position = "center",
            hl = "Comment",
          },
        },
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
        session_context,
        { type = "padding", val = 2 },
        footer,
      },
      opts = {
        margin = 8,
      },
    })
  end,
}
