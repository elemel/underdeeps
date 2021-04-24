local Class = require("game.Class")
local gameMath = require("game.math")

local distance2 = assert(gameMath.distance2)

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
  local density = config.density or 0.2
  self.fixture = love.physics.newFixture(self.body, shape, density)
  self.fixture:setGroupIndex(-self.minecart.groupIndex)

  local friction = config.friction or 2
  self.fixture:setFriction(friction)

  self.maxDistance = config.maxDistance or 5
  self.joints = {}

  for _, anchor in ipairs(config.anchors or {}) do
    local anchorX, anchorY = unpack(anchor)
    local worldAnchorX, worldAnchorY = self.minecart.body:getWorldPoint(anchorX, anchorY)
    local joint = love.physics.newDistanceJoint(self.minecart.body, self.body, worldAnchorX, worldAnchorY, worldX, worldY)
    self.joints[joint] = true
  end

  if self.minecart.drill then
    self.minecart.drill:destroy()
  end

  self.minecart.drill = self

  self.targetX, self.targetY = unpack(config.target or {x, y})
  self:updateJoints()
end

function M:destroy()
  for joint in pairs(self.joints) do
    self.joints[joint] = nil
    joint:destroy()
  end

  self.minecart.drill = nil

  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil

  self.engine = nil
  self.minecart = nil
end

function M:updateJoints()
  local worldTargetX, worldTargetY = self.minecart.body:getWorldPoint(self.targetX, self.targetY)

  for joint in pairs(self.joints) do
    local worldAnchorX, worldAnchorY = joint:getAnchors()
    local distance = distance2(worldAnchorX, worldAnchorY, worldTargetX, worldTargetY)
    joint:setLength(distance)
  end
end

return M
