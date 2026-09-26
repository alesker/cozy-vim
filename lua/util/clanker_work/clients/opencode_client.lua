require("util.clanker_work.client")

local Client = {}
Client.__index = Client

function Client.new(opencode)
  return setmetatable({ opencode = opencode }, Client)
end

function Client:session()
  if not self.session_ready then
    self.session_ready = self.opencode:create_session({
      title = "Clanker Work (Neovim)",
      agent = "pair-programmer",
      model = { providerID = "openai", id = "gpt-5.5", variant = "low" },
    })
    self.session_ready:next(function(session)
      self.session_id = session.id
    end)
  end
  return self.session_ready
end

function Client:ready()
  return self.opencode:ready()
end

function Client:submit(task, prompt)
  local result = self.opencode.promise()
  self.pending_prompt = result
  local path = vim.api.nvim_buf_get_name(task.buf)
  local lines = vim.api.nvim_buf_get_lines(task.buf, task.range.start_row, task.range.end_row + 1, false)
  local context = string.format(
    "File: %s\nLines %d-%d:\n%s\n\n",
    path,
    task.range.start_row + 1,
    task.range.end_row + 1,
    table.concat(lines, "\n")
  )
  local function complete(value, err)
    if self.pending_prompt == result then
      self.pending_prompt = nil
    end
    if err then
      result:reject(err)
    else
      result:resolve(value)
    end
  end
  self
    :session()
    :next(function(session)
      self.opencode
        :request("POST", "/api/session/" .. session.id .. "/prompt", { text = context .. prompt })
        :next(function(response)
          complete(response)
        end)
        :catch(function(err)
          complete(nil, err)
        end)
    end)
    :catch(function(err)
      complete(nil, err)
    end)
  return result
end

function Client:interrupt()
  local result = self.opencode.promise()
  local function interrupt()
    if not self.session_ready then
      result:resolve()
      return
    end
    self
      :session()
      :next(function(session)
        self.opencode
          :request("POST", "/api/session/" .. session.id .. "/interrupt?resume=false")
          :next(function()
            result:resolve()
          end)
          :catch(function(err)
            result:reject(err)
          end)
      end)
      :catch(function(err)
        result:reject(err)
      end)
  end
  if self.pending_prompt then
    self.pending_prompt:next(interrupt):catch(interrupt)
  else
    interrupt()
  end
  return result
end

function Client:on_event(_, callback)
  self.opencode:on_event(function(event)
    if event.type == "server.disconnected" then
      callback({ type = "error" })
      return
    end
    if not self.session_id or not event.data or event.data.sessionID ~= self.session_id then
      return
    end
    local types = {
      ["session.execution.started"] = "running",
      ["session.execution.succeeded"] = "done",
      ["session.execution.failed"] = "error",
      ["session.execution.interrupted"] = "error",
    }
    if types[event.type] then
      callback({ type = types[event.type] })
    end
  end)
end

return Client
