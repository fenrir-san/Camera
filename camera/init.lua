local love = require("love")

---@enum StepMode
local StepMode = {
  STICKY = 1,
  LERP = 2,
  EXP_DECAY = 3,
  UNDER_DAMPED_SPRING = 4,
  CRITICAL_DAMPED_SPRING = 5,
  SMOOTH_DAMP = 6
}

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
---@field step_mode StepMode
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
  o.target = nil
  o.transform = love.math.newTransform()
  o.step_mode = StepMode.LERP
  o.damping = 2
  o.threshold = 0.001
  o.velocity_x = 0
  o.velocity_y = 0
  o.stiffness = 20
  o.mass = 1
  return o
end

function Camera:attach(target)
  self.target = target
  self.wx = target.x - self.width / 2
  self.wy = target.y - self.height / 2
end

function Camera:update(dt)
  local target_x, target_y =  self:fromWorldToCamera(self.target.x, self.target.y)

  local delta_x = target_x - self.width / 2
  local delta_y = target_y - self.height / 2

  local x_step, y_step

  x_step, self.velocity_x = self:smoothDamp(0, delta_x, self.velocity_x, 0.3, 75, dt)
  y_step, self.velocity_y = self:smoothDamp(0, delta_y, self.velocity_y, 0.3, 75, dt)

  if math.abs(delta_x) < self.threshold then
    x_step = delta_x
    self.velocity_x = 0
  end

  if math.abs(delta_y) < self.threshold then
    y_step = delta_y
    self.velocity_y = 0
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
  return a + (b - a) * (1 - math.exp(-c * dt))
end

function Camera:underDampedSpring(delta, velocity, dt)
  dt = dt or 1
  local force = self.stiffness * delta
  local damping = self.damping * velocity
  velocity = velocity + ((force - damping) / self.mass) * dt
  return velocity * dt, velocity
end

function Camera:smoothDamp(current, target, velocity, smoothTime, maxSpeed, deltaTime)
  smoothTime = math.max(0.0001, smoothTime)
  local omega = 2.0 / smoothTime

  local x = omega * deltaTime
  local exp = 1.0 / (1.0 + x + 0.48 * x ^ 2 + 0.235 * x ^ 3)

  local change = current - target
  local originalTo = target

  local maxChange = maxSpeed * smoothTime
  change = math.max(-maxChange, math.min(change, maxChange))

  target = current - change

  local temp = (velocity + omega * change) * deltaTime
  velocity = (velocity - omega * temp) * exp

  local output = target + (change + temp) * exp

  if (originalTo - current > 0) == (output > originalTo) then
    output = originalTo
    velocity = (output - originalTo) / deltaTime
  end

  return output, velocity
end

function Camera:calculateStep()
end

---@param mode StepMode
function Camera:setStepMode(mode)
  self.step_mode = mode
end

---@return StepMode
function Camera:getStepMode()
  return self.step_mode
end

function Camera:fromWorldToCamera(x, y)
  return x - self.wx, y - self.wy
end

function Camera:fromCameraToWorld(x, y)
  return x + self.wx, y + self.wy
end

function Camera:setTransform()
  love.graphics.push()
  love.graphics.applyTransform(self.transform)
end

function Camera:unsetTransform()
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
