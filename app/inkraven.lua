require 'app/enemy'

InkRaven = extend(Enemy)

InkRaven.collision = setmetatable({}, {__index = Enemy.collision})
InkRaven.collision.shape = 'circle'
InkRaven.collision.with = {
  wall = Enemy.collision.with.wall,
  enemy = Enemy.collision.with.enemy,
  player = function(self, player, dx, dy)
    if self.state == 'swoop' then
      player:hurt(self.damage)
      self.state = 'fatigue'
    end
    return Enemy.collision.with.player(self, player, dx, dy)
  end
}
InkRaven.radius = 16

-- States:
--   lurk - waiting for the player to gets let in range
--   glide - hovering around player, getting ready to attack
--   swoop - rushing at the player, dealing damage
--   fatigue - tired

function InkRaven:init(...)
  Enemy.init(self, ...)

  self.state = 'lurk'
  self.glideTargetX = self.x
  self.glideTargetY = self.y

  self.sight = 250
  
  self.swoopSpeed = 500
  self.glideSpeed = 100

  self.damage = 6
  self.exp = 9 + math.ceil(love.math.random() * 5)

  self.scanTimer = 1
  self.glideTimer = 0
  self.swoopTimer = 0

  self.health = love.math.random(11, 28)
  self.targetAngle = love.math.random() * 2 * math.pi
end

function InkRaven:update()
  self.prevX = self.x
  self.prevY = self.y

  self[self.state](self)

  self:setPosition(self.x, self.y)
  self.angle = math.anglerp(self.angle, self.targetAngle, math.clamp(6 * tickRate, 0, 1))
end

function InkRaven:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  local tx, ty = ovw.house:cell(self.x, self.y)
  local v = ovw.house.tiles[tx][ty] and ovw.house.tiles[tx][ty]:brightness() or 1
  if self.state == 'swoop' then
    love.graphics.setColor(255, 0, 0, v)
  elseif self.state ~= 'lurk' then
    love.graphics.setColor(255, 255, 0, v)
  else
    love.graphics.setColor(255, 255, 255, v)
  end
  local p23 = math.pi * 2 / 3
  local x1, y1 = self.x + math.dx(self.radius, self.angle), self.y + math.dy(self.radius, self.angle)
  local x2, y2 = self.x + math.dx(self.radius, self.angle - p23), self.y + math.dy(self.radius, self.angle - p23)
  local x3, y3 = self.x + math.dx(self.radius, self.angle + p23), self.y + math.dy(self.radius, self.angle + p23)
  love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3)
end

function InkRaven:scan()
  local dis, dir = math.vector(self.x, self.y, ovw.player.x, ovw.player.y)

  self.scanTimer = .8

  local target = nil
  if dis < self.sight and math.abs(math.anglediff(dir, self.angle)) < (math.pi * 1.6) then
    target = ovw.player
    self.state = 'swoop'
  end

  if not target then
    self.state = 'lurk'
  end
end

function InkRaven:startGlide()
  if self.state ~= 'glide' then
    self.glideTimer = 1 + love.math.random()
    self.scanTimer = 2
  end
  self.state = 'glide'
  local d = math.direction(self.x, self.y, ovw.player.x, ovw.player.y) + math.pi - .5 + love.math.random() * 1
  self.glideTargetX = ovw.player.x + math.dx(100, d)
  self.glideTargetY = ovw.player.y + math.dy(100, d)
end

----------------
-- States
----------------
function InkRaven:lurk()
  self.scanTimer = self.scanTimer - tickRate
  
  if self.scanTimer <= 0 then
    self:scan()
  end
end

function InkRaven:glide()
  self.scanTimer = self.scanTimer - tickRate
  
  if self.scanTimer <= 0 then
    self:scan()
  end

  self.targetAngle = math.direction(self.x, self.y, ovw.player.x, ovw.player.y)

  local tx, ty = self.glideTargetX, self.glideTargetY
  local dis, dir = math.vector(self.x, self.y, tx, ty)
  local speed = math.clamp(self.glideSpeed * tickRate * (dis / 20), dis * tickRate, self.glideSpeed * tickRate)
  self.x = self.x + math.dx(speed, dir)
  self.y = self.y + math.dy(speed, dir)

  self.glideTimer = self.glideTimer - tickRate
  local d = math.distance(self.x, self.y, ovw.player.x, ovw.player.y)
  if ((self.glideTimer <= 0 and d < 200) or self.glideTimer < -.5) and not ovw.collision:lineTest(self.x, self.y, ovw.player.x, ovw.player.y, 'wall') then
    self.state = 'swoop'
    self.swoopTimer = .8
  end
end

function InkRaven:swoop()
  local dis, dir = math.vector(self.x, self.y, ovw.player.x, ovw.player.y)
  local speed = self.swoopSpeed * tickRate
  self.x = self.x + math.dx(speed, self.angle)
  self.y = self.y + math.dy(speed, self.angle)
 
  self.swoopTimer = timer.rot(self.swoopTimer, function()
    self:startGlide()
  end)

  -- Let it change its direction slightly while swooping
  self.targetAngle = math.anglerp(self.targetAngle, dir, 50 * tickRate)
end

function InkRaven:fatigue()
  self.x = math.lerp(self.x, self.glideTargetX, 4 * tickRate)
  self.y = math.lerp(self.y, self.glideTargetY, 4 * tickRate)
  if math.distance(self.x, self.y, self.glideTargetX, self.glideTargetY) < 10 then
    self:startGlide()
  end
end
