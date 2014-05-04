Enemy = class()

Enemy.tag = 'enemy' --for collision
Enemy.collision = {}

Enemy.collision.with = {}

Enemy.collision.with.wall = function(self, other, dx, dy)
  self:setPosition(self.x + dx, self.y + dy)
end

Enemy.collision.with.enemy = function(self, other, dx, dy)
  self:setPosition(self.x + dx / 2, self.y + dy / 2)
  other:setPosition(other.x - dx / 2, other.y - dy / 2)
end

Enemy.collision.with.player = function(self, other, dx, dy)
  self:setPosition(self.x + dx, self.y + dy)
end

function Enemy:init(x, y, health)
  self.x = x
  self.y = y
  self.prevX = self.x
  self.prevY = self.y

  self.angle = 0
  self.targetAngle = self.angle

  self.speed = 0
  self.targetSpeed = 0

  self.health = health
  self.maxHealth = self.health
  
  self.depth = 0
  ovw.view:register(self)
  ovw.collision:register(self)
end

function Enemy:destroy()
  ovw.view:unregister(self)
  ovw.collision.hc:remove(self.shape)
  ovw.enemies:remove(self)
end

Enemy.update = f.empty --perform movement, etc. calculations
Enemy.draw = f.empty --hurr durr

function Enemy:damage(amount)
  self.health = self.health - amount
  if self.health <= 0 then
    self:destroy()
  end
end

function Enemy:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end
