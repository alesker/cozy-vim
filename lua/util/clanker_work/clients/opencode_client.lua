require("util.clanker_work.client")

local Client = {}
Client.__index = Client

function Client.new(opencode)
  return setmetatable({ opencode = opencode }, Client)
end

function Client:ready()
  return self.opencode:ready()
end

local function output_from(messages)
  local parts = {}
  for _, message in ipairs(messages) do
    for _, content in ipairs(message.content or {}) do
      if content.type == "text" and content.text and content.text ~= "" then
        parts[#parts + 1] = content.text
      end
    end
  end
  return table.concat(parts, "\n\n")
end

-- Walk the newest messages back to this task's user message. Never include
-- output from earlier tasks in the same conversation.
function Client:output(state)
  local result = self.opencode.promise()
  if not state.sent then
    result:resolve("")
    return result
  end
  local messages = {}
  local found = false
  local intervening = false
  local function page(cursor)
    local query = cursor and ("cursor=" .. vim.uri_encode(cursor)) or "order=desc"
    self.opencode
      :request("GET", "/api/session/" .. state.id .. "/message?" .. query)
      :next(function(response)
        for _, message in ipairs(response.data or {}) do
          if message.id == state.message_id then
            found = true
            break
          end
          if message.type == "user" then
            intervening = true
          elseif message.type == "assistant" then
            table.insert(messages, 1, message)
          end
        end
        if found then
          if intervening then
            result:reject("Another prompt entered the shared conversation before this task finished")
          else
            result:resolve(output_from(messages))
          end
        elseif response.cursor and type(response.cursor.next) == "string" and response.cursor.next ~= "" then
          page(response.cursor.next)
        else
          result:reject("Could not find this task's prompt in the shared conversation")
        end
      end)
      :catch(function(err)
        result:reject(err)
      end)
  end
  page()
  return result
end

function Client:release(state)
  if state.finishing then
    return state.outcome
  end
  state.finishing = true
  state.outcome = self.opencode.promise()
  self
    :output(state)
    :next(function(output)
      state.outcome:resolve({ output = output })
    end)
    :catch(function(err)
      state.outcome:resolve({ output = "", error = "Could not retrieve output: " .. tostring(err) })
    end)
  return state.outcome
end

function Client:submit(task, prompt)
  local result = self.opencode.promise()
  if self.blocked then
    result:reject(self.blocked)
    return result
  end
  local state = {
    task = task,
    admission = result,
    message_id = "msg_nvim_" .. vim.fn.sha256(tostring(vim.uv.hrtime()) .. tostring(vim.fn.getpid())):sub(1, 24),
  }
  task.client_state = state
  local path = vim.api.nvim_buf_get_name(task.buf)
  task.source_path = path
  task.source_range = { start_row = task.range.start_row, end_row = task.range.end_row }
  local lines = vim.api.nvim_buf_get_lines(task.buf, task.range.start_row, task.range.end_row + 1, false)
  local context = string.format(
    "File: %s\nLines %d-%d:\n%s\n\n",
    path,
    task.range.start_row + 1,
    task.range.end_row + 1,
    table.concat(lines, "\n")
  )
  task.submitted_prompt = context .. prompt

  self.opencode
    :conversation()
    :next(function(session)
      state.id = session.id
      if state.cancelled then
        result:resolve()
        return
      end
      self.active = state
      state.sent = true
      self.opencode
        :request("POST", "/api/session/" .. session.id .. "/prompt", {
          id = state.message_id,
          text = task.submitted_prompt,
          delivery = "queue",
        })
        :next(function()
          result:resolve()
        end)
        :catch(function(err)
          if state.cancelled then
            result:reject(err)
            return
          end
          self:release(state):next(function(outcome)
            if self.active == state then
              self.active = nil
            end
            result:reject({ message = err, output = outcome.output })
          end)
        end)
    end)
    :catch(function(err)
      result:reject(err)
    end)
  return result
end

function Client:interrupt(task)
  local result = self.opencode.promise()
  local state = task.client_state
  if not state then
    result:resolve({ output = "" })
    return result
  end
  state.cancelled = true
  local function finish()
    if not state.id or not state.sent then
      result:resolve({ output = "" })
      return
    end
    local function collect(err)
      self:release(state):next(function(outcome)
        if self.active == state then
          self.active = nil
        end
        result:resolve({ output = outcome.output, error = err or outcome.error })
      end)
    end
    if state.finishing then
      collect()
      return
    end
    local function wait_for_idle(interrupt_error)
      self.opencode
        :request("POST", "/api/experimental/session/" .. state.id .. "/wait")
        :next(function()
          collect(interrupt_error)
        end)
        :catch(function(err)
          self.blocked = "Could not confirm the shared conversation is idle: " .. tostring(err)
          result:reject(self.blocked)
        end)
    end
    self.opencode
      :request("POST", "/api/session/" .. state.id .. "/interrupt?resume=false")
      :next(function()
        wait_for_idle()
      end)
      :catch(function(err)
        wait_for_idle("Could not interrupt: " .. tostring(err))
      end)
  end
  state.admission:next(finish):catch(finish)
  return result
end

function Client:on_event(_, callback)
  self.opencode:on_event(function(event)
    if event.type == "server.disconnected" then
      self.disconnected = true
      return
    end
    local state = self.active
    if event.type == "server.connected" then
      if not self.disconnected or not state or state.finishing or state.cancelled then
        return
      end
      self.disconnected = false
      state.admission:next(function()
        self.opencode:request("POST", "/api/experimental/session/" .. state.id .. "/wait"):next(function()
          self.opencode:request("GET", "/api/session/" .. state.id):next(function(response)
            local outcome = response.data and response.data.outcome
            if not outcome or state.finishing or state.cancelled or self.active ~= state then
              return
            end
            self:release(state):next(function(result)
              self.active = nil
              callback({
                type = outcome == "succeeded" and not result.error and "done" or "error",
                task = state.task,
                output = result.output,
                error = result.error or (outcome ~= "succeeded" and "Execution " .. outcome or nil),
              })
            end)
          end)
        end)
      end)
      return
    end
    local data = event.data or {}
    if not state or state.id ~= data.sessionID or state.cancelled or state.finishing then
      return
    end
    if event.type == "session.inbox.delivered" and data.inboxID == state.message_id then
      state.delivered = true
      callback({ type = "running", task = state.task })
    elseif
      event.type == "session.execution.succeeded"
      or event.type == "session.execution.failed"
      or event.type == "session.execution.interrupted"
    then
      if not state.delivered then
        return
      end
      local failure = event.type ~= "session.execution.succeeded"
      local failure_message
      if failure then
        failure_message = data.error and (data.error.message or vim.inspect(data.error))
          or "Execution " .. event.type:match("[^.]+$")
      end
      self:release(state):next(function(outcome)
        if self.active ~= state or state.cancelled then
          return
        end
        self.active = nil
        callback({
          type = (failure or outcome.error) and "error" or "done",
          task = state.task,
          output = outcome.output,
          error = outcome.error or failure_message,
        })
      end)
    end
  end)
end

return Client
