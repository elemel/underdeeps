local Class = require("game.Class")

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)
  config = config or {}

  self.body = love.physics.newBody(self.engine.world)

  local shape = love.physics.newRectangleShape(0, 5, 20, 10)
  self.fixture = love.physics.newFixture(self.body, shape)
end

return M
