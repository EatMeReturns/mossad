Player = class()
Player.tag = 'player' --for collision

Player.damageShader = love.graphics.newShader(
  [[extern vec2 chroma;

  vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
  {
     vec2 shift = chroma / 60;
     vec2 inverseShift = vec2(shift.y, shift.x);
     return vec4(Texel(tex,tc+shift).r, Texel(tex,tc+inverseShift).g, Texel(tex,tc-shift).b, Texel(tex,tc).a);
  }]])

Player.collision = {
  shape = 'circle',
  static = false,
  with = {
    wall = function(self, other, dx, dy)
      self:setPosition(self.x + dx, self.y + dy)
    end,

    room = function(self, other)
      if self.room ~= other then
        self.lastRoom = self.room
        self.room = other
        self.room.event:triggerEvent()
        if ovw.house.biome ~= self.room.biome then if self.room.biome == 'Gray' then ovw.hud.fader:add('Fear is the mind killer...') elseif self.room.biome == 'Great_Hall' then ovw.hud.fader:add('In this room, I am trivial.') end ovw.house.biome = self.room.biome end
        ovw.house:regenerate(self.room)
      end
    end,

    staircase = function(self, staircase)
      ovw.house:changeFloor(staircase)
    end
  }
}

function Player:init(agility, armor, stamina)
  self.name = 'player'
  self.x = ovw.house:pos(ovw.house.rooms[1].x + ovw.house.rooms[1].width / 2)
  self.y = ovw.house:pos(ovw.house.rooms[1].y + ovw.house.rooms[1].height / 2)
  self.angle = 0
  self.radius = 16
  self.rotation = 0
  self.rolling = false
  self.rollTimer = 0
  self.rollTimerMax = 0.34
  self.rollSpeed = 350
  self.rollDir = 0
  
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

  self.hotbar = Hotbar()
  self.hotbar:add(Glowstick(1))

  self.arsenal = Arsenal()
  self.arsenal:add(Camera())

  self.firstAid = FirstAid()

  self.npc = nil

  self.events = {}

  self.light = {
    minDis = 0,
    maxDis = 100,
    shape = 'circle',
    intensity = 0.5,
    falloff = 0.9,
    posterization = 1,
    flicker = 1,
    color = {255, 255, 255, 0}
  }

  self.flashlight = {
    minDis = 100,
    maxDis = 400,
    shape = 'cone',
    dir = 0,
    angle = math.pi / 5,
    intensity = .7,
    falloff = 1,
    posterization = 1,
    flicker = 0.95,
    color = {255, 175, 100, 0.75} --the fourth value is color intensity, not alpha
  }

  self.ammo = 24
  self.kits = 2
  self.energy = stamina
  self.batteries = 1
  self.battery = 0
  self.batteryMax = 120
  self.flashlightOn = true

  self.agility = agility --reload, heal, and loot faster
  self.armor = armor --take less damage
  self.stamina = stamina --regenerate stamina faster and higher max stamina

  self.exp = 0
  self.drawExp = self.exp
  self.level = 0
  self.drawLevel = self.level
  self.levelPoints = 0

  self.healthRegen = 0
  self.staminaRegen = 0.1

  --Inventory Flags
  self.hasLasersight = false

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

  --inventory-based flags get refreshed before inventory update
  self.hasLaserSight = false

  self.inventory:update()
  self.hotbar:update()
  if not (love.keyboard.isDown('e') or love.keyboard.isDown('tab')) then
    self.arsenal:update()
  end

  self.rotation = math.anglerp(self.rotation, math.direction(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, love.mouse.getX(), love.mouse.getY()), math.clamp(tickRate * 12, 0, 1))
  if self.rotation > math.pi then self.rotation = self.rotation - math.pi * 2 end
  if self.rotation < -math.pi then self.rotation = self.rotation + math.pi * 2 end

  self.light.x, self.light.y = self.x, self.y
  ovw.house:applyLight(self.light, 'ambient')

  if self.flashlightOn then
    self.flashlight.x, self.flashlight.y, self.flashlight.dir = self.x, self.y, self.rotation
    local head = self.firstAid.bodyParts[1]
    if self.battery > 0 then
      self.battery = self.battery - tickRate
      if self.battery < self.batteryMax / 10 then Tile.lightingShader:send('range', 10000 * self.battery / self.batteryMax) self.flashlight.flicker = 0.75 * (self.battery / (self.batteryMax / 10)) else Tile.lightingShader:send('range', 1000) self.flashlight.flicker = 0.95 end
      ovw.house:applyLight(self.flashlight, 'dynamic')
    elseif self.batteries > 0 then
      self.battery = self.batteryMax
      self.batteries = self.batteries - 1
      self.flashlight.flicker = 0.95
      ovw.house:applyLight(self.flashlight, 'dynamic')
    else
      self.battery = 0
      self.flashlightOn = false
      ovw.hud.fader:add('No batteries, no flashlight, no prayers...')
    end
  end

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

  self.firstAid:update()

  table.with(self.events, 'updateEvent')

  Player.damageShader:send('chroma', {ovw.view.shake, 0})
end

function Player:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  local tx, ty = ovw.house:cell(self.x, self.y)
  local v = 255--math.clamp((ovw.house.tiles[tx] and ovw.house.tiles[tx][ty]) and ovw.house.tiles[tx][ty]:brightness() or 0 + 50, 0, 255)
  local a = ovw.house.ambientColor
  love.graphics.setColor(v * a[1] / 255, v * a[2] / 255, v * a[3] / 255)
  love.graphics.setShader(Player.damageShader)
  love.graphics.draw(self.image, x, y, self.angle - math.pi / 2, 1, 1, self.image:getWidth() / 2, self.image:getHeight() / 4)
  --love.graphics.push()
  --love.graphics.scale(1, -1)
  --love.graphics.translate(0, -y * 2 - 50)
  --love.graphics.draw(self.image, x, y, self.angle - math.pi / 2, 1, 1, self.image:getWidth() / 2, self.image:getHeight() / 4)
  --love.graphics.pop()
  love.graphics.setShader()

  local weapon = self.arsenal.weapons[self.arsenal.selected]
  if weapon and not self.hasLaserSight then
    local x, y = self.x + weapon.tipOffset.getX(), self.y + weapon.tipOffset.getY()
    local dis = math.distance(x, y, ovw.view:mouseX(), ovw.view:mouseY())
    local x2, y2 = x + math.dx(dis, self.angle), y + math.dy(dis, self.angle)
    --x, y = x + math.dx(dis, self.angle), y + math.dy(dis, self.angle)
    love.graphics.setColor(150, 0, 0, 255)
    love.graphics.circle('fill', x2, y2, 2)
  end

  self.inventory:draw()
end

function Player:keypressed(key)
  if key == 'u' then Tile.useShader = not Tile.useShader end
  if not (love.keyboard.isDown('e') or love.keyboard.isDown('tab')) then
    local x = tonumber(key)
    if x and x >= 1 and x <= #self.hotbar.items then
      self.hotbar:activate(x, love.keyboard.isDown('lalt'))
    end
    if love.keyboard.isDown('lalt') and key == 'f' then
      self.flashlightOn = not self.flashlightOn
    end
    if key == 'q' then
      self.hotbar:drop()
    end
    if key == ' ' then
      self:roll()
    end
    self.arsenal:keypressed(key)
  elseif love.keyboard.isDown('tab') then
    local x = tonumber(key)
    if x and x >= 1 and x <= 4 then
      self.firstAid:setHeal(x)
    end
    if ovw.player.levelPoints > 0 then
      if key == 'z' then
        ovw.player.levelPoints = ovw.player.levelPoints - 1
        ovw.player.agility = ovw.player.agility + 1
      elseif key == 'x' then
        ovw.player.levelPoints = ovw.player.levelPoints - 1
        ovw.player.armor = ovw.player.armor + 1
      elseif key == 'c' then
        ovw.player.levelPoints = ovw.player.levelPoints - 1
        ovw.player.stamina = ovw.player.stamina + 1
      end
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
  local dir = 0

  if moving then self.speed = self.maxSpeed
    if running then
      self.speed = self.speed + self.runModifier
      self.energy = self.energy - tickRate
    end
  else self.speed = 0 end
    
  if not (moving or self.rolling) then return end
  
  if a and not d then dx = left elseif d then dx = right end
  if w and not s then dy = up elseif s then dy = down end

  if dy then
    self.image = (dy == down) and self.frontImage or self.backImage
  end

  if dx or dy then
    if not dx then dx = dy end
    if not dy then dy = dx end
    if dx == right and dy == down then dx = 0 end
    
    dir = (dx + dy) / 2
  end

  if self.rolling then
    if self.rollTimer == self.rollTimerMax then
      self.rollDir = dir
    end

    self.speed = self.rollSpeed
    self.rollTimer = self.rollTimer - tickRate
    dir = self.rollDir

    if self.rollTimer <= 0 then
      self.rolling = false
    end
  end

  self.x, self.y = self.x + math.cos(dir) * (self.speed * tickRate), self.y + math.sin(dir) * (self.speed * tickRate)
  self:setPosition(self.x, self.y)
end

function Player:turn()
  local weapon = self.arsenal.weapons[self.arsenal.selected]
  local tipDirection = love.mouse.scaleDirection()
  if weapon then
    local distance = 2.5 * math.distance(love.graphics.unscaleX(self.x), love.graphics.unscaleY(self.y), love.graphics.unscaleX(self.x + weapon.tipOffset.getX()), love.graphics.unscaleY(self.y + weapon.tipOffset.getY()))
    if distance < love.mouse.distance() then
      tipDirection = math.direction(800 / 2 + weapon.tipOffset.getX(), 600 / 2 + weapon.tipOffset.getY(), love.mouse.scaleX(), love.mouse.scaleY())
    else
      tipDirection = tipDirection - math.pi / 60
    end
  end
  --local tipDirection = weapon and math.direction(800 / 2 + weapon.tipOffset.getX(), 600 / 2 + weapon.tipOffset.getY(), love.mouse.scaleX(), love.mouse.scaleY()) or direction
  self.angle = tipDirection--love.mouse.distance() > 75 and tipDirection or direction - math.pi / 60
  --self.angle = math.pi * (math.sin(direction * 2) / 20 - 2 / math.distance(self.x, self.y, ovw.view:mouseX(), ovw.view:mouseY())) + direction
  --Player.mirrorShader:send('rotation', self.angle)
end

function Player:roll()
  if self.speed > 0 then
    if not self.rolling then
      if self.energy >= 1 then
        self.rollTimer = self.rollTimerMax
        self.energy = self.energy - 1
        self.rolling = true;
      end
    end
  end
end

function Player:hurt(amount)
  ovw.view.shake = ovw.view.shake + math.sqrt(amount) ^ 3
  
  amount = amount * ovw.house.getDifficulty(true)

  --smack a random body part
  local x = love.math.random() * 4
  x = math.max(1, math.ceil(x))
  self.firstAid.bodyParts[x]:damage(amount)

  self.lastHit = tick
end

function Player:learn(amount)
  self.exp = self.exp + amount
  local reqExp = 50 + self.level * 20
  while self.exp >= reqExp do
    self.level = self.level + 1
    self.levelPoints = self.levelPoints + 1
    self.exp = self.exp - reqExp
    reqExp = 50 + self.level * 20
    ovw.hud.fader:add('My efforts have improved my skills.')
    ovw.house:increaseDifficulty()
  end
end