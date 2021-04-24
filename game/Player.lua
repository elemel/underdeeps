local Class = require("game.Class")
local Minecart = require("game.Minecart")

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)
  self.engine.players[self] = true

  self.minecart = Minecart.new(self.engine, {
    position = {0, -1},
  })
end

function M:destroy()
  self.engine.players[self] = nil
  self.engine = nil
end

function M:fixedUpdateInput(dt)
  local leftInput = love.keyboard.isDown("a")
  local rightInput = love.keyboard.isDown("d")
  local inputX = (rightInput and 1 or 0) - (leftInput and 1 or 0)
  local speed = inputX * 10

  for wheel in pairs(self.minecart.wheels) do
    local motorSpeed = speed / wheel.radius
    wheel.joint:setMotorSpeed(motorSpeed)
  end
end

return M
