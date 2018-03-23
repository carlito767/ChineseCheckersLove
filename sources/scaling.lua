--[[
  Inspiré de : https://love2d.org/forums/viewtopic.php?f=4&t=78317&p=170558#p170558

  local Scaling = require "scaling"

  function love.draw()
    Scaling.preRender(gameWidth, gameHeight)
    ...
    Scaling.postRender()
  end
]]

local function scaling(gameWidth, gameHeight)
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  local gameAspectRatio = gameWidth / gameHeight
  local screenAspectRatio = width / height
  local scaleHorizontal = width / gameWidth
  local scaleVertical = height / gameHeight

  local scale = (gameAspectRatio > screenAspectRatio) and scaleHorizontal or scaleVertical
  local dx = (width - (gameWidth * scale)) / 2
  local dy = (height - (gameHeight * scale)) / 2

  return scale, dx, dy
end

local function preRender(gameWidth, gameHeight)
  local scale, dx, dy = scaling(gameWidth, gameHeight)
  love.graphics.push()
  love.graphics.setScissor(dx, dy, gameWidth * scale, gameHeight * scale)
  love.graphics.translate(dx, dy)
  love.graphics.scale(scale)
end

local function postRender()
  love.graphics.setScissor()
  love.graphics.pop()
end

local function position(gameWidth, gameHeight, x, y)
  local scale, dx, dy = scaling(gameWidth, gameHeight)
  return (x - dx) / scale, (y - dy) / scale
end

return {
  preRender = preRender;
  postRender = postRender;
  position = position;
}