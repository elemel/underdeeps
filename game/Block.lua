local Class = require("game.Class")
local physics = require("game.physics")
local Polygon = require("game.Polygon")

local toLocalPoints = assert(physics.toLocalPoints)

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)
  config = config or {}

  self.health = config.health or 1

  local vertices = assert(config.vertices)
  local polygon = Polygon.new(vertices)
  self.area = polygon:getArea()
  local x, y = polygon:getCentroid()
  self.body = love.physics.newBody(self.engine.world, x, y)

  local angle = config.angle or 0
  self.body:setAngle(angle)

  local shape = love.physics.newPolygonShape(toLocalPoints(self.body, vertices))
  local density = config.density or 1
  self.fixture = love.physics.newFixture(self.body, shape, density)
  self.fixture:setUserData(self)
end

function M:destroy()
  self.fixture:destroy()
  self.fixture = nil

  self.body:destroy()
  self.body = nil

  self.engine = nil
end

function M:split()
  local angle = love.math.random() * 2 * math.pi

  local vertices = {self.body:getWorldPoints(self.fixture:getShape():getPoints())}
  local polygon = Polygon.new(vertices)

  local x1, y1 = polygon:getCentroid()

  local x2 = x1 + math.cos(angle)
  local y2 = y1 + math.sin(angle)

  local polygonA = polygon:clone()
  polygonA:clip(x1, y1, x2, y2)

  local polygonB = polygon:clone()
  polygonB:clip(x2, y2, x1, y1)

  M.new(self.engine, {
    vertices = polygonA.vertices,
  })

  M.new(self.engine, {
    vertices = polygonB.vertices,
  })

  self:destroy()
end

return M
