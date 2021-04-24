local GameScreen = require("game.GameScreen")

function love.load()
  love.physics.setMeter(1)

  -- Work-around game hanging while mouse is pressed in LÖVE 11.3
  love.event.pump()

  love.mouse.setRelativeMode(true)

  screen = GameScreen.new()
end

function love.draw()
  screen:draw()
end

function love.resize(w, h)
  screen:resize(w, h)
end

function love.update(dt)
  screen:update(dt)
end

function love.mousemoved(x, y, dx, dy, istouch)
  screen:mousemoved(x, y, dx, dy, istouch)
end
