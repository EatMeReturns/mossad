require 'app/boss'

Avian = extend(Boss)

Avian.radius = 20
Avian.collision.shape = 'circle'

function Avian.collision.with.player(self, other, dx, dy)
  if self.state == 'swoop' then
    other:hurt(self.damage)
    self.state = 'derp'
  end
end

Avian.title = 'Avian Flies'

-- States:
--   derp: just moving around/repositioning
--   gust: blowing the player backwards
--   swoop: swooping at the player

function Avian:init()
  Boss.init(self)
  
  self.prevX = self.x
  self.prevY = self.y

  self.title = 'Avian Flies'

  self.state = 'derp' --derp, gust, swoop?
  self.stateTable = WeightedRandom({{'derp', .5}, {'swoop', .1}, {'gust', .15}, {'summon', .25}}, 1)

  self.health = 200
  self.maxHealth = self.health

  self.direction = love.math.random() * 2 * math.pi -- direction we're moving in
  self.walkSpeed = 60
  self.swoopSpeed = 500

  self.damage = 12

  self.gustStrength = 400
  self.gustMaxDis = 2000
  self.gustAngle = math.rad(30)

  self.derpTimer = 1
  self.gustTimer = 0
  self.swoopTimer = 0

  self.angle = 0
  self.targetAngle = 0
end

function Avian:update()
  self.prevX = self.x
  self.prevY = self.y

  self[self.state](self)

  self:setPosition(self.x, self.y)
end

function Avian:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle('line', x, y, self.radius)
  if self.state == 'gust' then
    local xx, yy
    xx = math.dx(self.gustMaxDis, self.angle - self.gustAngle)
    yy = math.dy(self.gustMaxDis, self.angle - self.gustAngle)
    love.graphics.line(x, y, x + xx, y + yy)
    xx = math.dx(self.gustMaxDis, self.angle + self.gustAngle)
    yy = math.dy(self.gustMaxDis, self.angle + self.gustAngle)
    love.graphics.line(x, y, x + xx, y + yy)
  end

  love.graphics.line(x, y, x + math.dx(self.radius, self.angle), y + math.dy(self.radius, self.angle))

  --health bar
  local val = self:val()
  love.graphics.setColor(255, math.min(255, 255 * val * 2), math.max(0, 510 * (val - 0.5)), 255)
  love.graphics.drawBar(x - 50, y - 50, 100, 10, val, 10, false)
end

function Avian:summon()
  local x, y = self.x + love.math.random() * 100 - 50, self.y + love.math.random() * 100 - 50
  ovw.enemies:add(InkRaven(x, y, self.room))
  self.state = 'derp'
end

----------------
-- States
----------------
function Avian:derp()
  self.targetAngle = math.direction(self.x, self.y, ovw.player.x, ovw.player.y)
  self.x = self.x + math.dx(self.walkSpeed * tickRate, self.targetAngle * -1)
  self.y = self.y + math.dy(self.walkSpeed * tickRate, self.targetAngle * -1)
  self.derpTimer = self.derpTimer - tickRate
  if self.derpTimer <= 0 then
    self.state = self.stateTable:pick()[1]
    if self.state == 'gust' then
      self.gustTimer = .5
    elseif self.state == 'swoop' then
      self.swoopTargetX = ovw.player.x
      self.swoopTargetY = ovw.player.y
      self.swoopTimer = .8
    elseif self.state == 'summon' then
      self:summon()
      self.derpTimer = 1
    else
      self.derpTimer = .34
    end
  end
  
  self.angle = math.anglerp(self.angle, self.targetAngle, math.clamp(3 * tickRate, 0, 1))
end

function Avian:gust()
  local dis, dir = math.vector(self.x, self.y, ovw.player.x, ovw.player.y)

  if math.abs(math.anglediff(self.angle, dir)) < self.gustAngle then
    dis = math.max(self.gustMaxDis - dis, 0) / self.gustMaxDis
    local px = ovw.player.x + math.dx(self.gustStrength * dis * tickRate, dir)
    local py = ovw.player.y + math.dy(self.gustStrength * dis * tickRate, dir)
    ovw.player:setPosition(px, py)
  end

  self.gustTimer = timer.rot(self.gustTimer, function()
    self.state = 'derp'
    self.derpTimer = 1.25
    self.direction = dir + math.pi + love.math.randomNormal(math.pi / 2, 0)
  end)
end

function Avian:swoop()
  self.targetAngle = math.direction(self.x, self.y, ovw.player.x, ovw.player.y)
  local dis, dir = math.vector(self.x, self.y, self.swoopTargetX, self.swoopTargetY)
  local speed = self.swoopSpeed * tickRate
  self.x = self.x + math.dx(speed, self.angle)
  self.y = self.y + math.dy(speed, self.angle)

  self.swoopTimer = timer.rot(self.swoopTimer, function()
    self.state = 'derp'
    self.derpTimer = 2
    self.direction = dir + math.pi + love.math.randomNormal(math.pi / 2, 0)
  end)

  self.angle = math.anglerp(self.angle, self.targetAngle, math.clamp(4 * tickRate, 0, 1))
end

function Avian:val()
  return self.health / self.maxHealth
end

function Avian:maxVal()
  return self.maxHealth
end