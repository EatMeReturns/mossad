Enemy = class()

Enemy.tag = 'enemy' --for collision
Enemy.collision = {
  shape = 'circle',
  static = false,
  with = {
    wall = function(self, other, dx, dy)
      self:setPosition(self.x + dx, self.y + dy)
    end,
    enemy = function(self, other, dx, dy)
      self:setPosition(self.x + dx / 2, self.y + dy / 2)
      other:setPosition(other.x - dx / 2, other.y - dy / 2)
    end,
    player = function(self, other, dx, dy)
      other:setPosition(other.x - dx, other.y - dy)
    end
  }
}

function Enemy:init(x, y, health)
  table.insert(level.enemies, self)
  level.enemyCount = level.enemyCount + 1
  
  ovw.collision:register(self)
end

function Enemy:setRoom(room)
  self.room = room
end

function Enemy:destroy()
  self.room = nil
  level.enemyCount = level.enemyCount - 1
  ovw.collision.hc:remove(self.shape)
end

Enemy.update = f.empty
Enemy.draw = f.empty

function Enemy:damage(amount)
  self.health = self.health - amount
  if self.health <= 0 then
    level.enemies = table.filter(level.enemies, function(enemy) if enemy == self then return false else return true end end)
    self:destroy()
  end
end

function Enemy:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end
