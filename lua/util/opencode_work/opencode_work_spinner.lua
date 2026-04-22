local Spinner = {}
Spinner.__index = Spinner

local default_frames = {
  "⠋",
  "⠙",
  "⠹",
  "⠸",
  "⠼",
  "⠴",
  "⠦",
  "⠧",
  "⠇",
  "⠏",
}

function Spinner.new(frames)
  return setmetatable({
    frames = frames or default_frames,
    index = 1,
  }, Spinner)
end

function Spinner:next()
  local frame = self.frames[self.index]
  self.index = (self.index % #self.frames) + 1
  return frame .. " thinking... "
end

function Spinner:reset()
  self.index = 1
end

return Spinner
