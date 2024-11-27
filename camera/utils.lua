local utils = {}

utils.lerp = function(a, b, c, dt)
  dt = dt or 1
  return a + (b - a) * c * dt
end

utils.expDecay = function(a, b, c, dt)
  dt = dt or 1
  return a + (b - a) * (1 - math.exp(-c * dt))
end

utils.underDampedSpring = function(delta, mass, stiffness, damping, velocity, dt)
  dt = dt or 1
  local force = stiffness * delta
  local d = damping * velocity
  velocity = velocity + ((force - d) / mass) * dt
  return velocity * dt, velocity
end

utils.smoothDamp = function(current, target, velocity, smoothTime, maxSpeed, dt)
  smoothTime = math.max(0.0001, smoothTime)
  local omega = 2.0 / smoothTime

  local x = omega * dt
  local exp = 1.0 / (1.0 + x + 0.48 * x ^ 2 + 0.235 * x ^ 3)

  local change = current - target
  local originalTo = target

  local maxChange = maxSpeed * smoothTime
  change = math.max(-maxChange, math.min(change, maxChange))

  target = current - change

  local temp = (velocity + omega * change) * dt
  velocity = (velocity - omega * temp) * exp

  local output = target + (change + temp) * exp

  if (originalTo - current > 0) == (output > originalTo) then
    output = originalTo
    velocity = (output - originalTo) / dt
  end

  return output, velocity
end

return utils
