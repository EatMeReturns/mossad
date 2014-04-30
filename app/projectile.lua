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

  ovw.collision:register(self)
  self.shape:moveTo(self.x - self.width / 2, self.y - self.height / 2)
end

function Projectile:destroy()
  level.projectiles = table.filter(level.projectiles, function(projectile) if projectile == self then return false else return true end end)
  ovw.collision.hc:remove(self.shape)
end

function Projectile:update()
  self.x = self.x + math.cos(self.direction) * self.speed
  self.y = self.y + math.sin(self.direction) * self.speed
  self.shape:moveTo(self.x - self.width / 2, self.y - self.height / 2)
end

function Projectile:draw()
  love.graphics.setColor(white[1], white[2], white[3], 255)
  self.shape:draw('fill')
end
