require("util.clanker_work.client")

local Command = require("opencode.api.command")
local Context = require("opencode.context")
local Discovery = require("opencode.server.discovery")
local Prompt = require("opencode.api.prompt")

---@class ClankerWorkOpencodeClient : ClankerWorkClient
local Client = {}
Client.__index = Client

---@return ClankerWorkOpencodeClient
function Client.new()
  return setmetatable({}, Client)
end

---@return ClankerWorkPromise
function Client:ready()
  return Discovery.get()
end

---@param task ClankerWorkTask
---@param prompt string
---@return ClankerWorkPromise
function Client:submit(task, prompt)
  return Discovery.get():next(function(server)
    local context = Context.new(server, {
      from = { task.range.start_row + 1, 0 },
      to = { task.range.end_row + 1, 0 },
      kind = "line",
    })

    return Prompt.prompt("@this: " .. prompt, context)
  end)
end

---@return ClankerWorkPromise
function Client:interrupt()
  return Discovery.get():next(function(server)
    return Command.command("session.interrupt", server)
  end)
end

---@param event table
---@return string?
local function event_status(event)
  if event.properties == nil or event.properties.status == nil then
    return
  end

  return event.properties.status.type
end

---@param event table
---@return ClankerWorkClientEvent?
local function to_client_event(event)
  if event.type == "session.error" or event_status(event) == "error" then
    return { type = "error" }
  end

  if
    event.type == "message.updated"
    or event.type == "message.part.updated"
    or event.type == "permission.replied"
    or event_status(event) == "busy"
  then
    return { type = "running" }
  end

  if event_status(event) == "idle" or event.type == "session.idle" then
    return { type = "done" }
  end
end

---@param group integer
---@param callback fun(event: ClankerWorkClientEvent)
function Client:on_event(group, callback)
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OpencodeEvent:*",
    callback = function(args)
      local event = to_client_event(args.data.event)
      if event then
        callback(event)
      end
    end,
  })
end

return Client
