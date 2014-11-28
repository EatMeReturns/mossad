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
  self.name = 'player'
  self.x = ovw.house:pos(ovw.house.rooms[1].x + ovw.house.rooms[1].width / 2)
  self.y = ovw.house:pos(ovw.house.rooms[1].y + ovw.house.rooms[1].height / 2)
  self.angle = 0
  self.radius = 16
  self.rotation = 0
  
  self.speed = 0
  self.maxSpeed = 100
  self.runSpeed = 225

  self.crippled = false
  self.iNeedHealing = 0
  self.iNeedTooMuchHealing = 10
  self.healRate = 2
  self.lastHit = tick - (1 / tickRate)

  --self.frontImage = love.graphics.newImage('media/graphics/anImage.png')
  --self.backImage = love.graphics.newImage('media/graphics/anImageBack.png')
  self.frontImage = love.graphics.newImage('media/graphics/brute.png')
  self.backImage = love.graphics.newImage('media/graphics/brute.png')
  self.image = self.frontImage

  self.prevX = self.x
  self.prevY = self.y

  self.depth = -1

  self.inventory = Inventory()
  self.inventory:add(Torch())
  self.inventory:add(Torch())

  self.hotbar = Hotbar()
  self.hotbar:add(Glowstick())

  self.arsenal = Arsenal()
  self.arsenal:add(Shotgun())
  self.arsenal:add(Pistol())

  self.firstAid = FirstAid()

  self.light = {
    minDis = 100,
    maxDis = 400,
    intensity = .5,
    falloff = 1,
    posterization = 1
  }

  self.ammo = 64
  self.kits = 1
  
  ovw.collision:register(self)
  ovw.view:register(self)
  ovw.view:setTarget(self)
end

function Player:update()
  self.prevX = self.x
  self.prevY = self.y

  self:move()
  self:turn()
  self:heal()
  self.inventory:update()
  self.hotbar:update()
  if not love.keyboard.isDown('e') then
    self.arsenal:update()
  end

  self.rotation = math.direction(self.x, self.y, love.mouse.getX(), love.mouse.getY())

  self.light.x, self.light.y = self.x, self.y
  ovw.house:applyLight(self.light, 'ambient')

  if not ovw.boss then
    local tx, ty = ovw.house:cell(self.x, self.y)
    local inside = true

    for x = tx - 1, tx + 1 do
      for y = ty - 1, ty + 1 do
        local t = ovw.house.tiles[x] and ovw.house.tiles[x][y]
        if not t or t.type ~= 'boss' or t.tile ~= 'c' then inside = false break end
      end
    end

    if inside then
      ovw.hud.fader:add('caw caw, motherfucker.')
      ovw.house:sealBossRoom()
      ovw.boss = Avian()
    end
  end
end

function Player:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  local tx, ty = ovw.house:cell(self.x, self.y)
  local v = math.clamp(ovw.house.tiles[tx][ty]:brightness() + 50, 0, 255)
  local a = ovw.house.ambientColor
  love.graphics.setColor(v * a[1] / 255, v * a[2] / 255, v * a[3] / 255)
  love.graphics.draw(self.image, x, y + 12, self.angle - math.pi / 2, 1, 1, self.image:getWidth() / 2, self.image:getHeight() / 4)
end

function Player:keypressed(key)
  if not (love.keyboard.isDown('e') or love.keyboard.isDown('tab')) then
    local x = tonumber(key)
    if x and x >= 1 and x <= #self.hotbar.items then
      self.hotbar:activate(x)
    end
    if key == 'q' then
      self.hotbar:drop()
    end
    self.arsenal:keypressed(key)
  end
end

function Player:mousepressed(...)
  self.hotbar:mousepressed(...)
  self.arsenal:mousepressed(...)
end

function Player:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end

function Player:move()
  local tab, e, f = love.keyboard.isDown('tab'), love.keyboard.isDown('e'), love.keyboard.isDown('f')
  local w, a, s, d = love.keyboard.isDown('w'), love.keyboard.isDown('a'), love.keyboard.isDown('s'), love.keyboard.isDown('d')
  local moving = not (tab or e or f) and (w or a or s or d)
  
  local up, down, left, right = 1.5 * math.pi, .5 * math.pi, math.pi, 2.0 * math.pi
  local dx, dy = nil, nil

  if moving then self.speed = (love.keyboard.isDown('lshift') and self.runSpeed) or self.maxSpeed
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

function Player:heal()
  self.iNeedHealing = math.max(self.iNeedHealing - self.healRate * tickRate, 0)
end

function Player:hurt(amount)
  self.iNeedHealing = self.iNeedHealing + amount
  if self.iNeedHealing > self.iNeedTooMuchHealing then
    if self.crippled then
      if ovw.restartTimer == 0 then
        ovw.hud.fader:add('Mossad starts writing my name in his notebook...')
        ovw.house.targetAmbient = {0, 0, 0}
        ovw.restartTimer = 4
      end
      return
    end
    self:cripple()
    self.iNeedHealing = 0
  end
  self.lastHit = tick
  ovw.view.shake = 2
end

function Player:cripple()
  if not self.crippled then
    ovw.hud.fader:add('I need healing...')
  end
  self.maxSpeed = 100
  self.light.maxDis = 150
  self.crippled = true
  ovw.house.targetAmbient = {255, 160, 160}
end

function Player:uncripple()
  self.maxSpeed = 150
  self.light.maxDis = 250
  self.crippled = false
  ovw.house.targetAmbient = {255, 255, 255}
  ovw.restartTimer = 0
end
