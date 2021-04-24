local Class = require("game.Class")
local gameMath = require("game.math")

local distance2 = assert(gameMath.distance2)

local M = Class.new()

function M:init(minecart, config)
  self.minecart = assert(minecart)
  self.engine = assert(self.minecart.engine)

  self.drilling = false

  local x, y = unpack(config.position or {0, 0})
  local worldX, worldY = self.minecart.body:getWorldPoint(x, y)
  self.body = love.physics.newBody(self.engine.world, worldX, worldY, "dynamic")

  self.body:setLinearDamping(0.1)
  self.body:setAngularDamping(0.1)

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

  local minecartX, minecartY = self.minecart.body:getPosition()
  self.frictionJoint = love.physics.newFrictionJoint(self.minecart.body, self.body, minecartX, minecartY, worldX, worldY)
  local maxTorque = self.body:getInertia() * 10

  self.frictionJoint:setMaxTorque(maxTorque)

  self.sensorRadius = config.sensorRadius or 1.5 * self.radius

  local sensorShape = love.physics.newCircleShape(self.sensorRadius)
  self.sensorFixture = love.physics.newFixture(self.body, sensorShape, 0)
  self.sensorFixture:setSensor(true)
  self.sensorFixture:setGroupIndex(-self.minecart.groupIndex)

  if self.minecart.drill then
    self.minecart.drill:destroy()
  end

  self.minecart.drill = self
  self.engine.drills[self] = true

  self.targetX, self.targetY = unpack(config.target or {x, y})
end

function M:destroy()
  self.engine.drills[self] = nil
  self.minecart.drill = nil

  self.sensorFixture:destroy()
  self.sensorFixture = nil

  self.frictionJoint:destroy()
  self.frictionJoint = nil

  for joint in pairs(self.joints) do
    self.joints[joint] = nil
    joint:destroy()
  end

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

function M:fixedUpdateControl(dt)
  self:updateJoints()

  if self.drilling then
    for _, contact in ipairs(self.body:getContacts()) do
      if not contact:isDestroyed() and contact:isTouching() then
        local fixtureA, fixtureB = contact:getFixtures()
        local targetFixture

        if fixtureA == self.sensorFixture then
          targetFixture = fixtureB
        elseif fixtureB == self.sensorFixture then
          targetFixture = fixtureA
        end

        if targetFixture and targetFixture:getBody():getType() == "static" then
          local userData = targetFixture:getUserData()

          if userData then
            if userData.area < 0.1 then
              userData.health = userData.health - 0.5 * dt / userData.area

              if userData.health < 0 then
                userData.body:setType("dynamic")
                userData.fixture:setSensor(true)
              end

              local impulse = love.math.random()
              local impulseAngle = love.math.random() * 2 * math.pi

              local impulseX = math.cos(impulseAngle) * impulse
              local impulseY = math.sin(impulseAngle) * impulse

              local angularImpulse = 0.01 * (love.math.random() * 2 - 1)

              userData.body:applyLinearImpulse(impulseX, impulseY)
              self.body:applyLinearImpulse(-impulseX, -impulseY, userData.body:getPosition())

              userData.body:applyAngularImpulse(angularImpulse)
              self.body:applyAngularImpulse(-angularImpulse)
            else
              userData:split()
            end
          end
        end
      end
    end
  end
end

return M
