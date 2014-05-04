Shade = extend(Enemy)

function Shade:init(...)
  Enemy.init(self, ...)

  self.targetAngle = self.angle
end

function Shade:scan()
  self.target = nil
  local dis, dir = math.vector(self.x, self.y, ovw.player.x, ovw.player.y)
  if dis < self.sight and math.anglediff(dir, self.angle) < 90 then
    local blocked = ovw.collision:lineTest(self.x, self.y, ovw.player.x, ovw.player.y, 'wall')
    if not blocked then

      -- Go ham sammy on the player
      self.target = ovw.player
    end
  end

  if not self.target then

    -- Look around some more
    self.targetAngle = self.targetAngle + (love.math.random() * 60 - 30)
  end

  self.scanTimer = 1
end

function Shade:update()
  self.scanTimer = self.scanTimer - tickRate
  if self.scanTimer <= 0 then self:scan() end
  
  self.prevX = self.x
  self.prevY = self.y
  if self.target ~= nil then
    local dis, dir = math.vector(self.x, self.y, self.target.x, self.target.y)
    local minDis = dis - (self.radius + self.target.radius)
    self.targetAngle = dir
    self.x = self.x + math.dx(math.min(self.runSpeed * tickRate, minDis), self.angle)
    self.y = self.y + math.dy(math.min(self.runSpeed * tickRate, minDis), self.angle)
  else
    self.x = self.x + math.dx(self.walkSpeed * tickRate, self.angle)
    self.y = self.y + math.dy(self.walkSpeed * tickRate, self.angle)
  end

  self:setPosition(self.x, self.y)
  self.angle = math.anglerp(self.angle, self.targetAngle, math.clamp(6 * tickRate, 0, 1))
end

function Shade:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  love.graphics.setColor(255, 255, 255, 255)
  if self.target ~= nil then love.graphics.setColor(255, 0, 0, 255) end
  self.shape:draw()
  love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * self.radius, self.y + math.sin(self.angle) * self.radius)
end
