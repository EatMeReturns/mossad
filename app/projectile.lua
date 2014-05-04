Projectile = class()
Projectile.tag = 'projectile'

Projectile.collision = {
  shape = 'rectangle',
  static = false,
  with = {
    wall = function(self, other, dx, dy)
      self:destroy()
    end,
    enemy = function(self, other, dx, dy)
      other:damage(self.damage)
      self:destroy()
    end
  }
}

function Projectile:init(damage, x, y, direction, speed)
  self.x = x
  self.y = y
  self.width = 4
  self.height = 4
  self.damage = damage
  self.direction = direction
  self.speed = speed

  ovw.view:register(self)
  ovw.collision:register(self)
  self.shape:moveTo(self.x - self.width / 2, self.y - self.height / 2)
end

function Projectile:destroy()
  ovw.spells:remove(self)
  ovw.view:unregister(self)
  ovw.collision.hc:remove(self.shape)
end

function Projectile:update()
  self.x = self.x + math.cos(self.direction) * self.speed
  self.y = self.y + math.sin(self.direction) * self.speed
  self.shape:moveTo(self.x - self.width / 2, self.y - self.height / 2)
end

function Projectile:draw()
  love.graphics.setColor(255, 255, 255)
  self.shape:draw('fill')
end
