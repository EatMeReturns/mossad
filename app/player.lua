Player = class()
Player.tag = 'player' --for collision

Player.collision = {
  shape = 'circle',
  static = false,
  with = {
    wall = function(self, other, dx, dy)
      self:setPosition(self.x + dx, self.y + dy)
    end
  }
}

function Player:init()
  self.x = 400
  self.y = 300
  self.angle = 0
  self.radius = 8
  self.node = {x = self.x, y = self.y}
  
  self.room = level.baseRoom
  self.lastRoom = level.baseRoom
  self.speed = 0
  self.maxSpeed = 200
  self.dx = 0
  self.dy = 0

  self.weapon = Weapon(self)

  self.frontImage = love.graphics.newImage('media/anImage.png')
  self.backImage = love.graphics.newImage('media/anImageBack.png')
  self.image = self.frontImage

  self.prevX = self.x
  self.prevY = self.y

  self.depth = 0
  
  ovw.collision:register(self)
  ovw.view:register(self)
  ovw.view:setTarget(self)
end

function Player:update()
  self.prevX = self.x
  self.prevY = self.y
  if math.distance(self.x, self.y, self.node.x, self.node.y) > 20 then
    self.node = {x = self.x, y = self.y}
    level.rooms = table.filter(level.rooms, function(room) if math.distance(self.x, self.y, room.x, room.y) > 550 then room:destroy() return false else return true end end)
    table.with(level.rooms, 'spawnRooms')
    table.each(level.newRooms, function(room) table.insert(level.rooms, room) end)
    level.newRooms = {}
  end
  self:move()
  self.angle = math.direction(400, 300, love.mouse.getX(), love.mouse.getY())
  self.weapon:update()

  if love.mouse.isDown('l') then self.weapon:fire() end
end

function Player:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(self.image, x - 13, y - 85, 0, 0.67, 0.67)
end

function Player:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end

function Player:move()
  local w, a, s, d = love.keyboard.isDown('w'), love.keyboard.isDown('a'), love.keyboard.isDown('s'), love.keyboard.isDown('d')
  local moving = w or a or s or d
  
  local up, down, left, right = 1.5 * math.pi, .5 * math.pi, math.pi, 2.0 * math.pi
  self.dx, self.dy = nil, nil

  if moving then self.speed = self.maxSpeed
  else self.speed = 0 end
    
  if not moving then return end
  
  if a and not d then self.dx = left elseif d then self.dx = right end
  if w and not s then self.dy = up elseif s then self.dy = down end

  if self.dx or self.dy then
    if not self.dx then self.dx = self.dy end
    if not self.dy then self.dy = self.dx end
    if self.dx == right and self.dy == down then self.dx = 0 end
    
    local dir = (self.dx + self.dy) / 2
    if dir == 1.5 * math.pi then self.image = self.backImage
    elseif dir == 0.5 * math.pi then self.image = self.frontImage
    end
    self.x, self.y = self.x + math.cos(dir) * (self.speed * tickRate), self.y + math.sin(dir) * (self.speed * tickRate)
    
    self:setPosition(self.x, self.y)
  end
end
