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
  self.lastHit = tick - (1 / tickRate)

  self.frontImage = love.graphics.newImage('media/graphics/anImage.png')
  self.backImage = love.graphics.newImage('media/graphics/anImageBack.png')
  self.image = self.frontImage

  self.prevX = self.x
  self.prevY = self.y

  self.depth = -1

  self.itemSelect = 1
  self.items = {Pistol()}
  self.items[1].index = 1
  self:selectItem(1)

  self.light = {
    minDis = 50,
    maxDis = 250,
    intensity = .75,
    falloff = 1,
    posterization = 1
  }
  
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
  ovw.house:applyLight(self.light)
end

function Player:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  local tx, ty = self.x - ovw.house.cellSize / 2, self.y - ovw.house.cellSize / 2
  tx, ty = math.round(tx / ovw.house.cellSize), math.round(ty / ovw.house.cellSize)
  local v = math.clamp(ovw.house.tileAlpha[tx][ty] + 50, 0, 255)
  love.graphics.setColor(v, v, v)
  love.graphics.draw(self.image, x, y + 12, 0, .5, .5, self.image:getWidth() / 2, self.image:getHeight())
end

function Player:keypressed(key)
  local x = tonumber(key)
  if x and x >= 1 and x <= #self.items then
    self:selectItem(x)
  end
end

function Player:mousepressed(...)
  table.with(self.items, 'mousepressed', ...)
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
  table.with(self.items, 'update')
end

function Player:selectItem(index)
  local old, new = self.items[self.itemSelect], self.items[index]
  self.itemSelect = index
  if old then
    old.selected = false
    f.exe(old.deselect, old)
  end

  if new then
    new.selected = true
    f.exe(new.select, new)
  end
end

function Player:removeItem(index)
  local item = self.items[index]
  if item then
    item:destroy()
    table.remove(self.items, index)
    while not self.items[self.itemSelect] do
      self.itemSelect = self.itemSelect - 1
    end
    self:selectItem(self.itemSelect)
  end
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
