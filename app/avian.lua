require 'app/boss'

Avian = extend(Boss)

Avian.radius = 20
Avian.collision.shape = 'circle'

-- States:
--   derp: just moving around/repositioning
--   gust: blowing the player backwards
--   swoop: swooping at the player

function Avian:init()
  Boss.init(self)
  
  self.prevX = self.x
  self.prevY = self.y

  self.state = 'derp' --derp, gust, swoop?

  self.health = 115

  self.walkSpeed = 60
  self.gustStrength = 300
  self.gustMaxDis = 600
  self.gustAngle = math.rad(40)

  self.derpTimer = 1
  self.direction = love.math.random() * 2 * math.pi -- direction we're moving in
  self.gustTimer = 0

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
end

function Avian:derp()
  self.targetAngle = math.direction(self.x, self.y, ovw.player.x, ovw.player.y)
  self.x = self.x + math.dx(self.walkSpeed * tickRate, self.direction)
  self.y = self.y + math.dy(self.walkSpeed * tickRate, self.direction)
  self.derpTimer = timer.rot(self.derpTimer, function()
    self.state = 'gust'
    self.gustTimer = 1 + love.math.random() * .35
  end)
  
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
    self.derpTimer = 1 + love.math.random()
    self.direction = dir + math.pi + love.math.randomNormal(math.pi / 2, 0)
  end)
end

function Avian:swoop()
  --
end
