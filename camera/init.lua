local love = require("love")

local Camera = {}
Camera.__index = Camera

function Camera:new()
  local o = setmetatable({}, Camera)
  o._x = 0
  o._y = 0
  o.width = love.graphics.getPixelWidth()
  o.height = love.graphics.getPixelHeight()
  o.transform = love.math.newTransform()
  o.target = nil
  o.threshold = 0.01
  o.rotation = 0.1
  o.velocity_x = 0                            -- Initialize velocity for X
  o.velocity_y = 0                            -- Initialize velocity for Y
  o.stiffness = 10                            -- Spring stiffness (k)
  o.mass = 1                                  -- Mass of the spring (m)
  o.damping = math.sqrt(o.stiffness * o.mass) -- Damping coefficient (c)
  return o
end

function Camera:attach(target)
  self.target = target
end

function Camera:basicUpdate()
  self._x = self.target.x - self.width / 2
  self._y = self.target.y - self.height / 2
end

function Camera:lerpUpdate(dt)
  local x = self.target.x - self.width / 2
  local y = self.target.y - self.height / 2

  local dx = (x - self._x) * self.damping * dt
  local dy = (y - self._y) * self.damping * dt

  if dx < 0.01 then
    self._x = x
  else
    self._x = self._x + dx
  end
  if dy < 0.01 then
    self._y = y
  else
    self._y = self._y + dy
  end
end

function Camera:expDecayUpdate(dt)
  local x = self.target.x - self.width / 2
  local y = self.target.y - self.height / 2

  local dx = x - self._x
  local dy = y - self._y

  local factor = 1 - math.exp(-self.damping * dt)

  if (dx * factor) < self.threshold then
    self._x = x
  else
    self._x = self._x + dx * factor
  end

  if (dy * factor) < self.threshold then
    self._y = y
  else
    self._y = self._y + dy * factor
  end
end

function Camera:springUpdate(dt)
  local x = self.target.x - self.width / 2
  local y = self.target.y - self.height / 2

  local dx = self._x - x
  local dy = self._y - y

  if math.abs(dx) > self.threshold then
    -- Spring-damping update for X-axis
    local force_x = -self.stiffness * dx
    local damping_x = -self.damping * self.velocity_x
    self.velocity_x = self.velocity_x + ((force_x + damping_x) / self.mass) * dt
    self._x = self._x + self.velocity_x * dt
  else
    self._x = x
    self.velocity_x = 0
  end

  if math.abs(dx) > self.threshold then
    -- Spring-damping update for Y-axis
    local force_y = -self.stiffness * dy
    local damping_y = -self.damping * self.velocity_y
    self.velocity_y = self.velocity_y + ((force_y + damping_y) / self.mass) * dt
    self._y = self._y + self.velocity_y * dt
  else
    self._y = y
    self.velocity_y = 0
  end
end

local function smoothDamp(current, target, velocity, smoothTime, maxSpeed, deltaTime)
  -- Ensure smoothTime is not too small
  smoothTime = math.max(0.0001, smoothTime)
  local omega = 2.0 / smoothTime

  -- Calculate the exponential decay factor
  local x = omega * deltaTime
  local exp = 1.0 / (1.0 + x + 0.48 * x ^ 2 + 0.235 * x ^ 3)

  -- Calculate the difference between current and target
  local change = current - target
  local originalTo = target

  -- Clamp the maximum speed (maxChange)
  local maxChange = maxSpeed * smoothTime
  change = math.max(-maxChange, math.min(change, maxChange))

  -- Update target based on the clamped change
  target = current - change

  -- Calculate the new velocity
  local temp = (velocity + omega * change) * deltaTime
  velocity = (velocity - omega * temp) * exp

  -- Calculate the new position
  local output = target + (change + temp) * exp

  -- Prevent overshooting the target
  if (originalTo - current > 0) == (output > originalTo) then
    output = originalTo
    velocity = (output - originalTo) / deltaTime
  end

  -- Return the updated position and velocity
  return output, velocity
end

function Camera:smoothDampUpdate(dt)
  self._x, self.velocity_x = smoothDamp(
    self._x,
    self.target.x - self.width / 2,
    self.velocity_x,
    0.3,
    75,
    dt
  )
  self._y, self.velocity_y = smoothDamp(
    self._y,
    self.target.x - self.height / 2,
    self.velocity_y,
    0.3,
    50,
    dt
  )
end

function Camera:set()
  love.graphics.push()
  self.transform:translate(-self._x, -self._y)
  love.graphics.applyTransform(self.transform)
end

function Camera:unset()
  self.transform:reset()
  love.graphics.pop()
end

return Camera
