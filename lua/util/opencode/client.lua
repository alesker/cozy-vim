local Client = {}
Client.__index = Client

local function promise()
  local p = { value = nil, error = nil, settled = false, success = {}, failure = {} }
  function p:next(fn)
    if self.settled and not self.error then
      fn(self.value)
    else
      table.insert(self.success, fn)
    end
    return self
  end
  function p:catch(fn)
    if self.settled and self.error then
      fn(self.error)
    else
      table.insert(self.failure, fn)
    end
    return self
  end
  function p:resolve(value)
    if self.settled then
      return
    end
    self.settled, self.value = true, value
    for _, fn in ipairs(self.success) do
      fn(value)
    end
  end
  function p:reject(err)
    if self.settled then
      return
    end
    self.settled, self.error = true, err
    for _, fn in ipairs(self.failure) do
      fn(err)
    end
  end
  return p
end

local function decode(text)
  local ok, value = pcall(vim.json.decode, text)
  return ok and value or nil
end

function Client.new()
  return setmetatable({
    password = vim.fn.sha256(tostring(vim.uv.hrtime()) .. tostring(vim.fn.getpid())),
    listeners = {},
    sessions = {},
    creating = 0,
    closing = false,
  }, Client)
end

Client.promise = promise

function Client:request(method, path, body)
  local result = promise()
  if self.closing then
    result:reject("OpenCode is shutting down")
    return result
  end
  local args = {
    "curl",
    "--silent",
    "--show-error",
    "--max-time",
    "30",
    "--user",
    "opencode:" .. self.password,
    "--request",
    method,
    "--header",
    "Content-Type: application/json",
    "--write-out",
    "\n%{http_code}",
    self.url .. path,
  }
  if body then
    table.insert(args, "--data-binary")
    table.insert(args, vim.json.encode(body))
  end
  vim.system(args, { text = true }, function(response)
    vim.schedule(function()
      local content, status = (response.stdout or ""):match("^(.*)\n(%d%d%d)$")
      if response.code ~= 0 or not status or tonumber(status) >= 400 then
        result:reject((decode(content or "") or {}).message or response.stderr or "OpenCode request failed")
      else
        result:resolve(decode(content or "") or {})
      end
    end)
  end)
  return result
end

function Client:emit(event)
  for _, listener in ipairs(self.listeners) do
    listener(event)
  end
end

function Client:handle_event(event)
  local data = event.data or {}
  if not self.sessions[data.sessionID] or self.closing then
    return
  end
  if event.type == "permission.asked" then
    vim.ui.select({ "Allow once", "Always allow", "Reject" }, {
      prompt = data.message or ("OpenCode " .. data.action .. ": " .. table.concat(data.resources or {}, ", ")),
    }, function(choice, index)
      if self.closing then
        return
      end
      local decision = ({ "once", "always", "reject" })[index or 3]
      self:request("POST", "/api/session/" .. data.sessionID .. "/permission/" .. data.id .. "/reply", {
        decision = decision,
      })
    end)
  elseif
    event.type == "session.execution.succeeded"
    or event.type == "session.execution.failed"
    or event.type == "session.execution.interrupted"
  then
    vim.cmd("checktime")
  end
  self:emit(event)
end

function Client:events()
  if self.events_job or self.closing then
    return
  end
  local partial = ""
  local headers = true
  self.events_job = vim.fn.jobstart({
    "curl",
    "--silent",
    "--show-error",
    "--no-buffer",
    "--include",
    "--user",
    "opencode:" .. self.password,
    self.url .. "/api/event",
  }, {
    on_stdout = function(_, lines)
      for i, line in ipairs(lines) do
        local text = (i == 1 and partial or "") .. line
        if i == #lines then
          partial = text
          break
        end
        if headers then
          if text == "" or text == "\r" then
            headers = false
            if self.server_ready and not self.server_ready.settled then
              self.server_ready:resolve(self.url)
            end
          end
        elseif text:sub(1, 6) == "data: " then
          local event = decode(text:sub(7))
          if event then
            self:handle_event(event)
          end
        end
      end
    end,
    on_exit = function()
      self.events_job = nil
      if not self.closing then
        self:emit({ type = "server.disconnected" })
        vim.defer_fn(function()
          self:events()
        end, 500)
      end
    end,
  })
end

function Client:ready()
  if self.closing then
    local result = promise()
    result:reject("OpenCode is shutting down")
    return result
  end
  if self.server_ready then
    return self.server_ready
  end
  local result = promise()
  self.server_ready = result
  local partial = ""
  self.job = vim.fn.jobstart({ "opencode", "serve", "--stdio", "--hostname", "127.0.0.1", "--port", "0" }, {
    env = { OPENCODE_PASSWORD = self.password },
    on_stdout = function(_, lines)
      for i, line in ipairs(lines) do
        local text = (i == 1 and partial or "") .. line
        if i == #lines then
          partial = text
          break
        end
        local info = decode(text)
        if info and info.url and not self.url then
          self.url = info.url
          self:events()
        end
      end
    end,
    on_exit = function(_, code)
      if not self.url then
        result:reject("OpenCode server exited: " .. code)
      end
      self.job = nil
    end,
  })
  if self.job <= 0 then
    result:reject("Could not start OpenCode server")
  else
    vim.defer_fn(function()
      if not result.settled then
        result:reject("Timed out starting OpenCode server")
        if self.job then
          vim.fn.jobstop(self.job)
        end
      end
    end, 10000)
  end
  return result
end

function Client:create_session(opts)
  local result = promise()
  if self.closing then
    result:reject("OpenCode is shutting down")
    return result
  end
  local id = "ses_nvim_" .. vim.fn.sha256(tostring(vim.uv.hrtime()) .. tostring(vim.fn.getpid())):sub(1, 24)
  local directory = opts.directory or vim.fn.getcwd()
  self.sessions[id] = true
  self.creating = self.creating + 1
  local function finished()
    self.creating = self.creating - 1
  end
  result:next(finished):catch(finished)
  self
    :ready()
    :next(function()
      if self.closing then
        result:reject("OpenCode is shutting down")
        return
      end
      self
        :request("POST", "/api/session", {
          id = id,
          title = opts.title,
          metadata = { nvim_owner = id },
          location = { directory = directory },
          agent = opts.agent,
          model = opts.model,
        })
        :next(function(response)
          result:resolve(response.data)
        end)
        :catch(function(err)
          result:reject(err)
        end)
    end)
    :catch(function(err)
      result:reject(err)
    end)
  return result
end

function Client:on_event(callback)
  table.insert(self.listeners, callback)
end

function Client:shutdown()
  if self.closing then
    return
  end
  self.closing = true
  local deadline = vim.uv.hrtime() + 2000000000
  if self.events_job then
    vim.fn.jobstop(self.events_job)
  end
  if self.url then
    if self.creating > 0 then
      vim.wait(300, function()
        return self.creating == 0
      end, 10)
    end
    for id in pairs(self.sessions) do
      local seconds = (deadline - vim.uv.hrtime()) / 1e9 - 0.25
      if seconds <= 0 then
        break
      end
      vim.fn.system({
        "curl",
        "--silent",
        "--max-time",
        tostring(seconds),
        "--user",
        "opencode:" .. self.password,
        "--request",
        "DELETE",
        self.url .. "/api/session/" .. id,
      })
    end
  end
  if self.job then
    pcall(vim.fn.chanclose, self.job, "stdin")
    local remaining = math.max(0, math.floor((deadline - vim.uv.hrtime()) / 1e6))
    if vim.fn.jobwait({ self.job }, remaining)[1] == -1 then
      vim.fn.jobstop(self.job)
    end
  end
end

return Client
