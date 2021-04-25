local Class = require("game.Class")
local gameMath = require("game.math")

local mix = assert(gameMath.mix)
local mix2 = assert(gameMath.mix2)
local mixAngles = assert(gameMath.mixAngles)

local M = Class.new()

function M:init(engine, config)
  self.engine = assert(engine)
  config = config or {}

  self.x, self.y = unpack(config.position or {0, 0})
  self.angle = config.angle or 0
  self.scale = config.scale or 1

  self.previousX = self.x
  self.previousY = self.y

  self.previousAngle = self.angle
  self.previousScale = self.scale

  self.interpolatedX = self.x
  self.interpolatedY = self.y

  self.interpolatedAngle = self.angle
  self.interpolatedScale = self.scale
end

function M:updatePreviousTransform()
  self.previousX = self.x
  self.previousY = self.y

  self.previousAngle = self.angle
  self.previousScale = self.scale
end

function M:updateInterpolatedTransform()
  local t = self.engine.accumulatedDt / self.engine.fixedDt

  self.interpolatedX, self.interpolatedY = mix2(self.previousX, self.previousY, self.x, self.y, t)
  self.interpolatedAngle = mixAngles(self.previousAngle, self.angle, t)
  self.interpolatedScale = mix(self.previousScale, self.scale, t)
end

return M
