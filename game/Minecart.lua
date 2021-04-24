local Class = require("game.Class")
local Drill = require("game.Drill")
local Wheel = require("game.Wheel")

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)

  self.groupIndex = config.groupIndex or self.engine:generateGroupIndex()

  local x, y = unpack(config.position or {0, 0})
  self.body = love.physics.newBody(self.engine.world, x, y, "dynamic")

  local angle = config.angle or 0
  self.body:setAngle(angle)

  local shape = love.physics.newRectangleShape(2, 1)
  self.fixture = love.physics.newFixture(self.body, shape)
  self.fixture:setGroupIndex(-self.groupIndex)

  self.wheels = {}

  Wheel.new(self, {
    position = {-1, 0.5},
  })

  Wheel.new(self, {
    position = {1, 0.5},
  })

  Drill.new(self, {
    anchors = {
      {-1, -0.5},
      {-1, 0.5},

      {1, -0.5},
      {1, 0.5},
    },
  })
end

function M:destroy()
  if self.drill then
    self.drill:destroy()
  end

  for wheel in pairs(self.wheels) do
    wheel:destroy()
  end

  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil

  self.engine = nil
end

return M
