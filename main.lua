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
  world = {
    top_x = 0,
    top_y = 0,
    bottom_x = love.graphics.getPixelWidth() + 100,
    bottom_y = love.graphics.getPixelHeight() + 100,
  }
  camera:attach(player)
  local extra_boundary = 50
  camera:setBounds(
    -extra_boundary,
    -extra_boundary,
    love.graphics.getPixelWidth() + 2 * extra_boundary,
    love.graphics.getPixelHeight() + 2 * extra_boundary
  )
end

function love.update(dt)
  if love.keyboard.isDown("left") then
    player.x = player.x - (player.speed * dt)
  elseif love.keyboard.isDown("right") then
    player.x = player.x + (player.speed * dt)
  end
  player.x = math.max(world.top_x, math.min(player.x, world.bottom_x - 30))


  if love.keyboard.isDown("up") then
    player.y = player.y - (player.speed * dt)
  elseif love.keyboard.isDown("down") then
    player.y = player.y + (player.speed * dt)
  end
  player.y = math.max(world.top_y, math.min(player.y, world.bottom_y - 30))

  camera:update(dt)
end

function love.draw()
  camera:setTransform()
  love.graphics.rectangle("fill", player.x, player.y, 30, 30)
  love.graphics.rectangle(
    "line",
    0,
    0,
    love.graphics.getPixelWidth(),
    love.graphics.getPixelHeight()
  )
  camera:unsetTransform()
end
