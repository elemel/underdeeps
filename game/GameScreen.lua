local Class = require("game.Class")
local Engine = require("game.Engine")

local M = Class.new()

function M:init()
  self.engine = Engine.new({})
end

function M:draw()
  self.engine:draw()
end

function M:resize(w, h)
  self.engine:resize(w, h)
end

function M:update(dt)
  self.engine:update(dt)
end

function M:mousemoved(x, y, dx, dy, istouch)
  self.engine:mousemoved(x, y, dx, dy, istouch)
end

return M
