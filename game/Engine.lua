local Class = require("game.Class")
local Minecart = require("game.Minecart")
local physics = require("game.physics")
local Player = require("game.Player")
local Terrain = require("game.Terrain")

local M = Class.new()

function M:init(config)
  local gravityX = config.gravityX or 0
  local gravityY = config.gravityY or 10

  self.fixedDt = config.fixedDt or 1 / 60
  self.accumulatedDt = 0
  self.tick = 0

  self.players = {}

  self.world = love.physics.newWorld(gravityX, gravityY)
  self.terrain = Terrain.new(self, {})

  Player.new(self, {})
end

function M:fixedUpdate(dt)
  self:fixedUpdateInput(dt)
  self:fixedUpdateControl(dt)
  self.world:update(dt)
end

function M:fixedUpdateInput(dt)
  for player in pairs(self.players) do
    player:fixedUpdateInput(dt)
  end
end

function M:fixedUpdateControl(dt)
end

function M:draw()
  local width, height = love.graphics.getDimensions()
  love.graphics.translate(0.5 * width, 0.5 * height)
  local scale = 0.05 * height
  love.graphics.scale(scale)
  love.graphics.setLineWidth(1 / scale)
  physics.debugDrawFixtures(self.world)
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
end

return M
