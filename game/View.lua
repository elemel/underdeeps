local Camera = require("game.Camera")
local Class = require("game.Class")

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)
  config = config or {}

  self.camera = Camera.new(self.engine, config.camera)
  local viewportConfig = config.viewport or {}

  self.viewport = {
    x = viewportConfig.x or 0,
    y = viewportConfig.y or 0,

    width = viewportConfig.width or 800,
    height = viewportConfig.height or 600,
  }
end

return M
