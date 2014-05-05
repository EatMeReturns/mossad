Player = class()
Player.tag = 'player' --for collision

Player.collision = {
  shape = 'circle',
  static = false,
  with = {
    wall = function(self, other, dx, dy)
      self:setPosition(self.x + dx, self.y + dy)
    end,
    enemy = function(self, other, dx, dy)
      other:setPosition(other.x - dx, other.y - dy)
    end
  }
}

function Player:init()
  self.name = 'player'
  self.x = ovw.house:cell(ovw.house.rooms[1].x + ovw.house.rooms[1].width / 2)
  self.y = ovw.house:cell(ovw.house.rooms[1].y + ovw.house.rooms[1].height / 2)
  self.angle = 0
  self.radius = 16
  
  self.speed = 0
  self.maxSpeed = 150

  self.iNeedHealing = 0
  self.iNeedTooMuchHealing = 50
  self.healRate = 2
  self.lastHit = tick

  self.frontImage = love.graphics.newImage('media/graphics/anImage.png')
  self.backImage = love.graphics.newImage('media/graphics/anImageBack.png')
  self.image = self.frontImage

  self.prevX = self.x
  self.prevY = self.y

  self.depth = -1

  self.itemSelect = 1
  self.items = {}
  local pistol = Pistol() -- created from pickup
  table.insert(self.items, pistol)
  pistol:activate()
  
  ovw.collision:register(self)
  ovw.view:register(self)
  ovw.view:setTarget(self)
end

function Player:update()
  self.prevX = self.x
  self.prevY = self.y

  self:move()
  self:turn()
  self:item()
  self:heal()
end

function Player:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(self.image, x, y, 0, .5, .5, self.image:getWidth() / 2, self.image:getHeight())
end

function Player:keypressed(key)
  local x = tonumber(key)
  if x == 7 then
    House.lightMinDis = 80
    House.lightMaxDis = 110
    House.lightIntensity = 0.5
    House.lightFalloff = 0.7
    House.lightFollowSpeed = 1
    House.lightPosterization = 1
  end
  if x == 8 then
    House.lightMinDis = 50
    House.lightMaxDis = 400
    House.lightIntensity = 1
    House.lightFalloff = 1
    House.lightFollowSpeed = 1
    House.lightPosterization = 1
  end

  if x and x >= 1 and x <= #self.items then
    self.itemSelect = x
  end
end

function Player:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end

function Player:move()
  local w, a, s, d = love.keyboard.isDown('w'), love.keyboard.isDown('a'), love.keyboard.isDown('s'), love.keyboard.isDown('d')
  local moving = w or a or s or d
  
  local up, down, left, right = 1.5 * math.pi, .5 * math.pi, math.pi, 2.0 * math.pi
  local dx, dy = nil, nil

  if moving then self.speed = self.maxSpeed
  else self.speed = 0 end
    
  if not moving then return end
  
  if a and not d then dx = left elseif d then dx = right end
  if w and not s then dy = up elseif s then dy = down end

  if dy then
    self.image = (dy == down) and self.frontImage or self.backImage
  end

  if dx or dy then
    if not dx then dx = dy end
    if not dy then dy = dx end
    if dx == right and dy == down then dx = 0 end
    
    local dir = (dx + dy) / 2
    self.x, self.y = self.x + math.cos(dir) * (self.speed * tickRate), self.y + math.sin(dir) * (self.speed * tickRate)

    self:setPosition(self.x, self.y)
  end
end

function Player:turn()
  self.angle = math.direction(400, 300, love.mouse.getX(), love.mouse.getY())
end

function Player:item()
  local item = self.items[self.itemSelect]
  item:update()
  if love.mouse.isDown('l') then item:use() end
end

function Player:heal()
  if tick - self.lastHit > 5 / tickRate then
    self.iNeedHealing = math.max(self.iNeedHealing - 2 * tickRate, 0)
  end
end

function Player:hurt(amount)
  self.iNeedHealing = self.iNeedHealing + amount
  if self.iNeedHealing > self.iNeedTooMuchHealing then love.event.quit() end
  self.lastHit = tick
end
