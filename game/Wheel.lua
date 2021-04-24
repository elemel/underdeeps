local Class = require("game.Class")

local M = Class.new()

function M:init(minecart, config)
  self.minecart = assert(minecart)
  self.engine = assert(self.minecart.engine)

  local x, y = unpack(config.position or {0, 0})
  local worldX, worldY = self.minecart.body:getWorldPoint(x, y)
  self.body = love.physics.newBody(self.engine.world, worldX, worldY, "dynamic")

  local angle = config.angle or 0
  local worldAngle = angle + self.minecart.body:getAngle()
  self.body:setAngle(worldAngle)

  self.radius = config.radius or 0.5
  local shape = love.physics.newCircleShape(self.radius)
  local density = config.density or 0.5
  self.fixture = love.physics.newFixture(self.body, shape, density)
  self.fixture:setGroupIndex(-self.minecart.groupIndex)

  local friction = config.friction or 5
  self.fixture:setFriction(friction)

  local axisX, axisY = unpack(config.axis or {0, -1})
  local worldAxisX, worldAxisY = self.minecart.body:getWorldVector(axisX, axisY)

  self.joint = love.physics.newWheelJoint(self.minecart.body, self.body, worldX, worldY, worldAxisX, worldAxisY)
  self.joint:setMotorEnabled(true)
  self.joint:setMaxMotorTorque(20)

  self.joint:setSpringFrequency(10)
  self.joint:setSpringDampingRatio(1)

  self.minecart.wheels[self] = true
end

function M:destroy()
  self.minecart.wheels[self] = nil

  self.joint:destroy()
  self.joint = nil

  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil

  self.engine = nil
  self.minecart = nil
end

return M
