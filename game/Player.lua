local Class = require("game.Class")
local gameMath = require("game.math")
local Minecart = require("game.Minecart")

local length2 = assert(gameMath.length2)
local normalize2 = assert(gameMath.normalize2)

local M = Class.new()

function M:init(engine, view, config)
  self.engine = assert(engine)
  self.view = assert(view)
  config = config or {}
  self.mouseSensitivity = config.mouseSensitivity or 0.002
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

  local mouseDx = self.engine.accumulatedMouseDx
  local mouseDy = self.engine.accumulatedMouseDy

  self.engine.accumulatedMouseDx = 0
  self.engine.accumulatedMouseDy = 0

  if self.minecart.drill then
    local targetDx, targetDy = self.minecart.body:getLocalVector(mouseDx * self.mouseSensitivity, mouseDy * self.mouseSensitivity)

    self.minecart.drill.targetX = self.minecart.drill.targetX + targetDx
    self.minecart.drill.targetY = self.minecart.drill.targetY + targetDy

    if length2(self.minecart.drill.targetX, self.minecart.drill.targetY) > self.minecart.drill.maxDistance then
      self.minecart.drill.targetX, self.minecart.drill.targetY = normalize2(self.minecart.drill.targetX, self.minecart.drill.targetY)

      self.minecart.drill.targetX = self.minecart.drill.targetX * self.minecart.drill.maxDistance
      self.minecart.drill.targetY = self.minecart.drill.targetY * self.minecart.drill.maxDistance
    end

    self.minecart.drill.drilling = love.mouse.isDown(1)
  end
end

function M:updateView()
  self.view.camera.x, self.view.camera.y = self.minecart.body:getPosition()
end

return M
