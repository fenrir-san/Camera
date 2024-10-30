---@class love
local love = require("love")
local Camera = require("camera")

local camera = Camera:new()
function love.load()
  player = {
    x = 100,
    y = 100,
    speed = 100
  }
  camera:attach(player)
end

function love.update(dt)
  if love.keyboard.isDown("left") then
    player.x = player.x - (player.speed * dt)
  elseif love.keyboard.isDown("right") then
    player.x = player.x + (player.speed * dt)
  end

  if love.keyboard.isDown("up") then
    player.y = player.y - (player.speed * dt)
  elseif love.keyboard.isDown("down") then
    player.y = player.y + (player.speed * dt)
  end

  camera:lerpUpdate(dt)
end

function love.draw()
  camera:set()
  love.graphics.rectangle(
    "line",
    0,
    0,
    love.graphics.getPixelWidth(),
    love.graphics.getPixelHeight()
  )
  love.graphics.rectangle("fill", player.x, player.y, 30, 30)
  camera:unset()
end
