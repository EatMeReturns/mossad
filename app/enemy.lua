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
    end,
    room = function(self, other, dx, dy)
      if math.abs(dx) >= self.radius or math.abs(dy) >= self.radius then
        if other then
          self:setRoom(other)
        end
      end
    end
  }
}

function Enemy:init(x, y, health)
  table.insert(level.enemies, self)
  level.enemyCount = level.enemyCount + 1
  self.name = 'enemy' .. level.enemyCount
  self.x = x
  self.y = y
  self.health = health
  self.angle = 0
  self.radius = 8
  self.sight = 300
  self.target = nil
  self.direction = love.math.random() * 2 * math.pi
  self.runSpeed = 180
  self.walkSpeed = 50
  self.prevX = self.x
  self.prevY = self.y
  self.scanTimer = 0
  
  ovw.collision:register(self)
end

function Enemy:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end

function Enemy:setRoom(room)
  if self.room ~= room then
    if self.room then self.room.contents[self.name] = nil end
    self.room = room
    self.room.contents[self.name] = self
  end
end

function Enemy:destroy()
  self.room = nil
  --level.enemyCount = level.enemyCount - 1
  ovw.collision.hc:remove(self.shape)
end

Enemy.scan = f.empty --perform pathing calculations
Enemy.update = f.empty --perform movement, etc. calculations
Enemy.draw = f.empty --hurr durr

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
