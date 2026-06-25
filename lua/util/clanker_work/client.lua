require("util.clanker_work.clanker_work_task")

---@alias ClankerWorkClientName "opencode"

---@class ClankerWorkPromise
---@field next fun(self: ClankerWorkPromise, callback: fun(...): any): ClankerWorkPromise
---@field catch fun(self: ClankerWorkPromise, callback: fun(err?: any): any): ClankerWorkPromise

---@alias ClankerWorkClientEventType "running"|"done"|"error"

---@class ClankerWorkClientEvent
---@field type ClankerWorkClientEventType

---@class ClankerWorkClient
---@field ready fun(self: ClankerWorkClient): ClankerWorkPromise
---@field submit fun(self: ClankerWorkClient, task: ClankerWorkTask, prompt: string): ClankerWorkPromise
---@field interrupt fun(self: ClankerWorkClient): ClankerWorkPromise
---@field on_event fun(self: ClankerWorkClient, group: integer, callback: fun(event: ClankerWorkClientEvent))

return {}
