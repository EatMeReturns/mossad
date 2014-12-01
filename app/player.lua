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
  self.runModifier = 125

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
  self.arsenal:add(Crossbow())
  self.arsenal:add(Pistol())

  self.firstAid = FirstAid()

  self.light = {
    minDis = 0,
    maxDis = 100,
    intensity = 0.5,
    falloff = 0.9,
    posterization = 1
  }

  self.flashlight = {
    minDis = 100,
    maxDis = 400,
    shape = 'cone',
    dir = 0,
    angle = math.pi / 3,
    intensity = .7,
    falloff = 1,
    posterization = 1
  }

  self.ammo = 24
  self.kits = 2
  self.energy = 2

  self.agility = 1 --reload, heal, and loot faster
  self.armor = 0 --take less damage
  self.stamina = 2 --regenerate stamina faster and higher max stamina

  self.exp = 0
  self.level = 0
  self.levelPoints = 0

  self.healthRegen = 0
  self.staminaRegen = 0.1

  self.firstAid.debuffs = {
  {val = self.light.maxDis, modifier = 100},
  {val = self.agility, modifier = 1},
  {val = self.stamina, modifier = 1},
  {val = self.maxSpeed, modifier = 50}
  }
  
  ovw.collision:register(self)
  ovw.view:register(self)
  ovw.view:setTarget(self)
end

function Player:update()
  self.prevX = self.x
  self.prevY = self.y

  self:regen()
  self:move()
  self:turn()
  self.inventory:update()
  self.hotbar:update()
  if not (love.keyboard.isDown('e') or love.keyboard.isDown('tab')) then
    self.arsenal:update()
  end
  self.firstAid:update()

  self.rotation = math.direction(400, 300, love.mouse.getX(), love.mouse.getY())
  --if self.rotation < 0 then self.rotation = self.rotation + math.pi * 2 end

  self.light.x, self.light.y = self.x, self.y
  ovw.house:applyLight(self.light, 'ambient')

  self.flashlight.x, self.flashlight.y, self.flashlight.dir = self.x, self.y, self.rotation
  ovw.house:applyLight(self.flashlight, 'dynamic')

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
  elseif love.keyboard.isDown('tab') then
    local x = tonumber(key)
    if x and x >= 1 and x <= 4 then
      self.firstAid:setHeal(x)
    end
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

function Player:regen()
  table.with(self.firstAid.bodyParts, 'regen')
  if self.energy < self.stamina then
    self.energy = self.energy + self.stamina * self.staminaRegen * tickRate
    if self.energy > self.stamina then self.energy = self.stamina end
  end
end

function Player:move()
  local tab, e, f = love.keyboard.isDown('tab'), love.keyboard.isDown('e'), love.keyboard.isDown('f')
  local w, a, s, d = love.keyboard.isDown('w'), love.keyboard.isDown('a'), love.keyboard.isDown('s'), love.keyboard.isDown('d')
  local moving = not (tab or e or f) and (w or a or s or d)
  local running = self.energy >= 0.2 * tickRate and love.keyboard.isDown('lshift')
  
  local up, down, left, right = 1.5 * math.pi, .5 * math.pi, math.pi, 2.0 * math.pi
  local dx, dy = nil, nil

  if moving then self.speed = self.maxSpeed
    if running then
      self.speed = self.speed + self.runModifier
      self.energy = self.energy - tickRate
    end
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

function Player:hurt(amount)
  --smack a random body part
  local x = love.math.random() * 4
  x = math.max(1, math.ceil(x))
  self.firstAid.bodyParts[x]:damage(amount)

  self.lastHit = tick
  ovw.view.shake = 2
end

function Player:learn(amount)
  self.exp = self.exp + amount
  local reqExp = 50 + self.level * 20
  while self.exp >= reqExp do
    self.level = self.level + 1
    self.levelPoints = self.levelPoints + 1
    self.exp = self.exp - reqExp
    reqExp = 50 + self.level * 20
    ovw.hud.fader:add('My efforts have improved my skills...')
  end
end