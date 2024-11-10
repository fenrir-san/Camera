local love = require("love")

---@class Camera
---@field transform love.Transform
---@field wx number
---@field wy number
---@field scale_x number
---@field scale_y number
---@field width number
---@field height number
---@field bounds table
---@field threshold number
---@field rotation number
---@field velocity_x number
---@field velocity_y number
---@field stiffness number
---@field mass number
---@field damping number
local Camera = {}
Camera.__index = Camera

function Camera:new()
  local o = setmetatable({}, Camera)
  o.wx = 0
  o.wy = 0
  o.rotation = 0
  o.scale_x = 1
  o.scale_x = 1
  o.width = love.graphics.getPixelWidth()
  o.height = love.graphics.getPixelHeight()
  o.bounds = {
    set = false,
    top_x = nil,
    top_y = nil,
    bottom_x = nil,
    bottom_y = nil,
  }
  o.transform = love.math.newTransform()
  o.target = nil
  o.damping = 10
  o.threshold = 0.01
  return o
end

function Camera:attach(target)
  self.target = target
  self.wx = target.x - self.width / 2
  self.wy = target.y - self.height / 2
end

function Camera:update(dt)
  local target_x, target_y = self:fromWorldToCamera(self.target.x, self.target.y)

  local x_step = self:expDecay(0, target_x - self.width / 2, self.damping, dt)
  local y_step = self:expDecay(0, target_y - self.height / 2, self.damping, dt)

  if math.abs(x_step) < self.threshold then
    x_step = target_x - self.width / 2
  end

  if math.abs(y_step) < self.threshold then
    y_step = target_y - self.height / 2
  end

  local x, y = self:fromCameraToWorld(x_step, y_step)

  if self.bounds.set then
    x = math.max(self.bounds.top_x, math.min(x, self.bounds.bottom_x))
    y = math.max(self.bounds.top_y, math.min(y, self.bounds.bottom_y))
  end

  self.wx = x
  self.wy = y

  self.transform:translate(-self.wx, -self.wy)
end

function Camera:basicUpdate(target, center)
  return target - center
end

function Camera:lerp(a, b, c, dt)
  dt = dt or 1
  return a + (b - a) * c * dt
end

function Camera:expDecay(a, b, c, dt)
  dt = dt or 1
  return a + (b - a) * (1 - math.exp(c * dt))
end

function Camera:fromWorldToCamera(x, y)
  return x - self.wx, y - self.wy
end

function Camera:fromCameraToWorld(x, y)
  return x + self.wx, y + self.wy
end

function Camera:set()
  love.graphics.push()
  love.graphics.applyTransform(self.transform)
end

function Camera:unset()
  self.transform:reset()
  love.graphics.pop()
end

function Camera:setBounds(x, y, width, height)
  self.bounds.set = true
  self.bounds.top_x = x
  self.bounds.top_y = y
  self.bounds.bottom_x = x + width - self.width
  self.bounds.bottom_y = y + height - self.height
end

return Camera
