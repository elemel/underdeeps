local Block = require("game.Block")
local Class = require("game.Class")
local Minecart = require("game.Minecart")
local physics = require("game.physics")
local Player = require("game.Player")
local Terrain = require("game.Terrain")
local View = require("game.View")

local M = Class.new()

function M:init(config)
  config = config or {}

  local gravityX = config.gravityX or 0
  local gravityY = config.gravityY or 20

  self.fixedDt = config.fixedDt or 1 / 60
  self.accumulatedDt = 0
  self.tick = 0

  self.accumulatedMouseDx = 0
  self.accumulatedMouseDy = 0

  self.players = {}
  self.drills = {}

  self.world = love.physics.newWorld(gravityX, gravityY)
  self.nextGroupIndex = 1
  -- self.terrain = Terrain.new(self, {})

  -- for _ = 1, 10 do
  --   self:generateBlock()
  -- end

  Block.new(self, {
    vertices = {
      -10, 0,
      10, 0,
      10, 10,
      -10, 10,
    },

    angle = love.math.random() * 2 * math.pi,
  })

  self.view = View.new(self)
  Player.new(self, self.view)
end

function M:generateBlock()
  local vertices = {}
  local radius = 1 + love.math.random() * 4
  local vertexCount = 8
  local originAngle = love.math.random() * 2 * math.pi

  local centerX = love.math.random() * 20 - 10
  local centerY = 5 + (love.math.random() * 2 - 1) * (5 - radius)

  for i = 1, vertexCount do
    local vertexAngle = originAngle + (i - 1 + love.math.random()) / vertexCount * 2 * math.pi

    local vertexX = centerX + math.cos(vertexAngle) * radius
    local vertexY = centerY + math.sin(vertexAngle) * radius

    table.insert(vertices, vertexX)
    table.insert(vertices, vertexY)
  end

  Block.new(self, {
    vertices = vertices,
    angle = love.math.random() * 2 * math.pi,
  })
end

function M:generateGroupIndex()
  local groupIndex = self.nextGroupIndex
  self.nextGroupIndex = self.nextGroupIndex + 1
  return groupIndex
end

function M:fixedUpdate(dt)
  self.view.camera:updatePreviousTransform()
  self:fixedUpdateInput(dt)
  self:fixedUpdateControl(dt)
  self.world:update(dt)

  for player in pairs(self.players) do
    player:updateView()
  end
end

function M:fixedUpdateInput(dt)
  for player in pairs(self.players) do
    player:fixedUpdateInput(dt)
  end
end

function M:fixedUpdateControl(dt)
  for drill in pairs(self.drills) do
    drill:fixedUpdateControl(dt)
  end
end

function M:draw()
  self:debugDraw()
end

function M:debugDraw()
  love.graphics.push("all")

  local width, height = love.graphics.getDimensions()
  love.graphics.translate(0.5 * width, 0.5 * height)
  local scale = 0.05 * height
  love.graphics.scale(scale)
  love.graphics.setLineWidth(1 / scale)

  love.graphics.translate(-self.view.camera.x, -self.view.camera.y)

  physics.debugDrawFixtures(self.world)
  physics.debugDrawJoints(self.world)

  love.graphics.pop()
end

function M:mousemoved(x, y, dx, dy, istouch)
  self.accumulatedMouseDx = self.accumulatedMouseDx + dx
  self.accumulatedMouseDy = self.accumulatedMouseDy + dy
end

function M:resize(w, h)
end

function M:update(dt)
  self.accumulatedDt = self.accumulatedDt + dt

  while self.accumulatedDt >= self.fixedDt do
    self.accumulatedDt = self.accumulatedDt - self.fixedDt
    self.tick = self.tick + 1
    self:fixedUpdate(self.fixedDt)
  end

  self.view.camera:updateInterpolatedTransform()
end

return M
