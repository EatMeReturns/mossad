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
        if ovw.house.biome ~= self.room.biome then
          ovw.house.biomeCounter = 1
          if biomeFaderMessages[self.room.biome].enter then
            ovw.hud.fader:add(biomeFaderMessages[self.room.biome].enter)
          end
          ovw.house.biome = self.room.biome
        else
          ovw.house.biomeCounter = ovw.house.biomeCounter + 1
        end
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
  self.maxSpeed = 150
  self.runModifier = 100
  self.lastStep = tick - (1 / tickRate)

  self.lastHit = tick - (1 / tickRate)

  --Non-Stat-Related Flags
  self.mouseOverUI = false
  self.backpackOpen = false
  self.inCombat = false
  self.combatants = {}
  self.combatTimer = 0
  self.combatTime = 8
  self.heartbeatTimer = .67
  self.heartbeatTime = .67
  self.safety = true
  self.footprintTimer = 0
  self.footprintTime = 4
  self.lastFootprintTimer = 0
  self.lastFootprintTime = .45
  self.footprintReverse = 1
  self.footprintColor = {0, 0, 0}
  self.footprint = 'player'
  self.footprintAngle = 0

  --self.frontImage = love.graphics.newImage('media/graphics/anImage.png')
  --self.backImage = love.graphics.newImage('media/graphics/anImageBack.png')
  self.frontImage = love.graphics.newImage('media/graphics/brute.png')
  self.backImage = love.graphics.newImage('media/graphics/brute.png')
  self.image = self.frontImage

  self.prevX = self.x
  self.prevY = self.y

  self.depth = DrawDepths.player

  self.inventory = Inventory()

  self.hotbar = Hotbar()
  self.hotbar:add(Glowstick(1))

  self.arsenal = Arsenal()

  self.firstAid = FirstAid()

  self.npc = nil

  self.events = {}
  self.followers = {}

  self.light = {
    minDis = 0,
    maxDis = 100,
    shape = 'circle',
    intensity = 0.5,
    falloff = 0.9,
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

  --Stats with Modifiers, Modifiers, Multipliers, and Flags that are reset on each update
  self.healthRegen = .05
  self.staminaRegen = 0.1
  --- Multipliers
  self.damageMultiplier = 1
  self.ammoMultiplier = 1
  self.experienceMultiplier = 1
  self.lifeStealMultiplier = 0
  self.energyStealMultiplier = 0
  --- Modifiers
  self.speedModifier = 0
  self.agilityModifier = 0
  self.armorModifier = 0
  self.staminaModifier = 0
  self.lightMaxRangeModifier = 0
  --- Flags
  self.hasLaserSight = false
  self.hasChargeMelee = false
  self.hasFreeRun = false

  --Orb Pools
  self.orbs = {}
  self.orbs.health = 0
  self.orbs.stamina = 0

  self.firstAid.debuffs = {
    {val = 'lightMaxRangeModifier', modifier = 50},
    {val = 'agilityModifier', modifier = 1},
    {val = 'staminaModifier', modifier = 1},
    {val = 'speedModifier', modifier = 50} 
  }
  
  ovw.collision:register(self)
  ovw.view:register(self)
  ovw.view:setTarget(self)
end

function Player:getStat(stat, useModifier)
  assert(stat == 'stamina' or stat == 'armor' or stat == 'agility', 'Not a valid stat. Must be stamina or armor or agility.')
  return self[stat] + (useModifier and self[stat .. 'Modifier'] or 0)
end

function Player:update()
  --SOUND EFFECTS -----------------------
  if self.backpackOpen then
    if not --[[(love.keyboard.isDown('e') or ]]love.keyboard.isDown('tab') then
      self.backpackOpen = false
      local closeSound = ovw.sound:play('backpack_zipper_close.wav')
      closeSound:setVolume(ovw.sound.volumes.fx)
    end
  end

  if self.inCombat then
    if table.count(self.combatants) <= 0 then
      self.combatTimer = self.combatTimer - tickRate
      if self.combatTimer <= 0 then
        self.inCombat = false
        self.combatTimer = 0
      end
    else
      self.combatTimer = math.min(self.combatTime, self.combatTimer + tickRate * 4)
    end
  else
    if table.count(self.combatants) > 0 then
      self.inCombat = true
      local violin = ovw.sound:play('violin_screech_modified.wav')
      violin:setVolume(ovw.sound.volumes.ambience)
    end
  end

  self.heartbeatTimer = self.heartbeatTimer - tickRate
  if self.heartbeatTimer <= 0 then
    local heartSound = ovw.sound:play('heartbeat_modified.wav')
    self.heartbeatTimer = self.heartbeatTime + ((self.combatTime - self.combatTimer) / 16)
    heartSound:setVolume((1 - (((self.combatTime - self.combatTimer) / 16) ^ .5)) * ovw.sound.volumes.ambience)
  end

  --STAT RESETS -------------------------
  self.healthRegen = .05
  self.staminaRegen = 0.1
  --- Multipliers
  self.damageMultiplier = 1
  self.ammoMultiplier = 1
  self.experienceMultiplier = 1
  self.lifeStealMultiplier = 0
  self.energyStealMultiplier = 0
  --- Modifiers
  self.speedModifier = 0
  self.agilityModifier = 0
  self.armorModifier = 0
  self.staminaModifier = 0
  self.lightMaxRangeModifier = 0
  --- Flags
  self.hasLaserSight = false
  self.hasChargeMelee = false
  self.hasFreeRun = false

  --CRIPPLING DEBUFFS -------------------
  for i = 1, 4 do
    if self.firstAid.bodyParts[i].crippled then
      local debuff = self.firstAid.debuffs[i]
      self[debuff.val] = self[debuff.val] - debuff.modifier
    end
  end

  --STAT MODS AND ITEMS -----------------
  self.inventory:update()
  self.hotbar:update()
  if not love.keyboard.isDown('tab') then
    self.arsenal:update()
  end
  self:regen()

  --POSITIONING -------------------------
  self.prevX = self.x
  self.prevY = self.y

  self:move()
  self:turn()

  self.rotation = math.anglerp(self.rotation, math.direction(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, love.mouse.getX(), love.mouse.getY()), math.clamp(tickRate * 12, 0, 1))
  if self.rotation > math.pi then self.rotation = self.rotation - math.pi * 2 end
  if self.rotation < -math.pi then self.rotation = self.rotation + math.pi * 2 end

  --CURSOR AND UI -----------------------
  if (self.mouseOverUI and (self.safety or love.keyboard.isDown('e'))) or paused or love.keyboard.isDown('tab') then
    love.mouse.setCursor(cursors.pointer)
  else
    love.mouse.setCursor(cursors.target)
  end

  --LIGHTING ----------------------------
  self.light.x, self.light.y = self.x, self.y
  self.light.maxDis = 100 + self.lightMaxRangeModifier
  ovw.house:applyLight(self.light, 'ambient')

  if self.flashlightOn then
    self.flashlight.x, self.flashlight.y, self.flashlight.dir = self.x, self.y, self.rotation
    local head = self.firstAid.bodyParts[1]
    if self.battery > 0 then
      self.battery = self.battery - tickRate
      if self.battery < self.batteryMax / 30 and love.math.random() < .02 then local woosh = ovw.sound:play('electric_woosh.wav') woosh:setVolume(ovw.sound.volumes.fx) end
      if self.battery < self.batteryMax / 10 then self.flashlight.flicker = 0.75 * (self.battery / (self.batteryMax / 10)) else self.flashlight.flicker = 0.95 end
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

  --ROOM AND EVENTS --------------------
  table.with(self.events, 'updateEvent')

  --GRAPHICS ---------------------------
  Player.damageShader:send('chroma', {ovw.view.shake, 0})

  self.footprintTimer = self.footprintTimer - tickRate
  if self.footprintTimer > 0 then
    self.lastFootprintTimer = self.lastFootprintTimer - tickRate
    if self.lastFootprintTimer <= 0 then
      if self.footprint ~= 'playerRoll' then self.footprintAngle = self.angle end
      ovw.particles:add(Footprint({x = self.x, y = self.y}, self.footprintAngle, self.footprintReverse, self.footprintColor, self.room, self.footprint))
      self.footprintReverse = self.footprintReverse * -1
      self.lastFootprintTimer = self.lastFootprintTime
    end
  end

  --FIRST AID -------------------------- [CAN'T END THE GAME IN THE MIDDLE OF AN UPDATE]
  self.firstAid:update()
end

function Player:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  local tx, ty = ovw.house:cell(self.x, self.y)
  local v = 255--math.clamp((ovw.house.tiles[tx] and ovw.house.tiles[tx][ty]) and ovw.house.tiles[tx][ty]:brightness() or 0 + 50, 0, 255)
  local a = ovw.house.ambientColor
  love.graphics.setColor(v * a[1] / 255, v * a[2] / 255, v * a[3] / 255)
  if useShader then love.graphics.setShader(Player.damageShader) end
  love.graphics.draw(self.image, x, y, self.angle - math.pi / 2, 1, 1, self.image:getWidth() / 2, self.image:getHeight() / 4)
  --love.graphics.push()
  --love.graphics.scale(1, -1)
  --love.graphics.translate(0, -y * 2 - 50)
  --love.graphics.draw(self.image, x, y, self.angle - math.pi / 2, 1, 1, self.image:getWidth() / 2, self.image:getHeight() / 4)
  --love.graphics.pop()
  love.graphics.setShader()

  local weapon = self.arsenal.weapons[self.arsenal.selected]
  if weapon and not self.hasLaserSight and not (self.mouseOverUI and (self.safety or love.keyboard.isDown('e'))) and not love.keyboard.isDown('tab') then
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
  if --[[key == 'e' or]] key == 'tab' and not self.backpackOpen then
    self.backpackOpen = true
    local openSound = ovw.sound:play('backpack_zipper_open.wav')
    openSound:setVolume(ovw.sound.volumes.fx)
  end
  if key == 'u' then useShader = not useShader end --move to options menu
  if key == 'v' then self.safety = not self.safety end --toggle weapon safety
  if key == 'f' then --just f
    self.flashlightOn = not self.flashlightOn
    local lightSound = nil
    if self.flashlightOn then
      lightSound = ovw.sound:play('flashlight_on.wav')
    else
      lightSound = ovw.sound:play('flashlight_off.wav')
    end
    lightSound:setVolume(ovw.sound.volumes.fx)
  end
  if not love.keyboard.isDown('tab') then --just tab
    local x = tonumber(key)
    if x and x >= 1 and x <= 5 then
      self.hotbar:activate(x, love.keyboard.isDown('lshift')) --shift uses?
    end
    if key == 'q' then --not implemented yet
      self.hotbar:drop()
    end
    if key == ' ' then
      self:roll()
    end
    self.arsenal:keypressed(key)
  else --include 'e' functionality if nec.
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
  --orbs
  local orbHealthRegen = self.orbs.health * tickRate
  self.orbs.health = self.orbs.health - orbHealthRegen
  self.healthRegen = self.healthRegen + orbHealthRegen

  local orbStaminaRegen = self.orbs.stamina * tickRate
  self.orbs.stamina = self.orbs.stamina - orbStaminaRegen
  self.staminaRegen = self.staminaRegen + orbStaminaRegen

  --apply regeneration
  table.with(self.firstAid.bodyParts, 'regen')
  if self.energy < self:getStat('stamina', true) then
    self.energy = self.energy + self:getStat('stamina', true) * self.staminaRegen * tickRate
  end
  if self.energy > self:getStat('stamina', true) then
    self.energy = self:getStat('stamina', true)
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

  if moving then self.speed = self.maxSpeed + self.speedModifier
    if running then
      self.speed = self.speed + self.runModifier
      self.energy = self.energy - tickRate
    end
  else self.speed = 0 end
    
  if not (moving or self.rolling) then return
  elseif self.rolling then
    --roll sound
    self.footprint = 'playerRoll'
    self.lastFootprintTime = .001
  elseif running then
    --fast steps
    self.footprint = 'player'
    self.lastFootprintTime = .25
    if tick - (1 / tickRate) - self.lastStep > 13 then--.35 then
      local step = ovw.sound:play('wood_step.wav')
      step:setVolume(ovw.sound.volumes.ambience / 2)
      self.lastStep = tick - (1 / tickRate)
    end
  else
    --slow steps
    self.footprint = 'player'
    self.lastFootprintTime = .45
    if tick - (1 / tickRate) - self.lastStep > 25 then--.67 then
      local step = ovw.sound:play('wood_step.wav')
      step:setVolume(ovw.sound.volumes.ambience / 5)
      self.lastStep = tick - (1 / tickRate)
    end
  end
  
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
      self.footprintAngle = self.rollDir
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
  ovw.particles:add(BloodParticle({x = self.x - 10 + love.math.random() * 20, y = self.y - 10 + love.math.random() * 20}, {50, 0, 0}))
  ovw.particles:add(BloodSplat({x = self.x - 10 + love.math.random() * 20, y = self.y - 10 + love.math.random() * 20}, {50, 0, 0}, self.room))
  ovw.particles:add(BloodSplat({x = self.x - 10 + love.math.random() * 20, y = self.y - 10 + love.math.random() * 20}, {50, 0, 0}, self.room))
  ovw.particles:add(BloodSplat({x = self.x - 10 + love.math.random() * 20, y = self.y - 10 + love.math.random() * 20}, {50, 0, 0}, self.room))
  

  amount = amount * ovw.house.getDifficulty(true)

  --smack a random body part
  local x = love.math.random() * 4
  x = math.max(1, math.ceil(x))
  self.firstAid.bodyParts[x]:damage(amount)
  local hit = ovw.sound:play('get_hit_scrub_modified.wav')
  hit:setVolume(math.min(ovw.sound.volumes.fx, (amount / 15) * ovw.sound.volumes.fx))

  self.lastHit = tick
end

function Player:learn(amount)
  amount = amount * self.experienceMultiplier
  self.exp = self.exp + amount
  local reqExp = 50 + self.level * 20
  while self.exp >= reqExp do
    self.level = self.level + 1
    self.levelPoints = self.levelPoints + 1
    self.exp = self.exp - reqExp
    reqExp = 50 + self.level * 20
    ovw.hud.fader:add('My efforts have improved my skills.')
    ovw.house:increaseDifficulty()
    local levelSound = ovw.sound:play('level_up.wav')
    levelSound:setVolume(ovw.sound.volumes.fx)
  end
end

function Player:loot(item)
  if item.name == 'Ammo' then
    self.ammo = self.ammo + math.round(math.clamp(House.getDifficulty(true) * love.math.randomNormal(3, 2), 1, 5) * self.ammoMultiplier)
    return true
  elseif item.name == 'Battery' then
    ovw.player.batteries = ovw.player.batteries + 1
    return true
  elseif item.name == 'First Aid Kit' then
    ovw.player.kits = ovw.player.kits + 1
    return true
  else
    if ovw.player.hotbar:add(item) then
      ovw.hud.fader:add(item.pickupMessage)
      return true
    elseif ovw.player.arsenal:add(item) then
      ovw.hud.fader:add(item.pickupMessage)
      return true
    elseif ovw.player.inventory:add(item) then
      ovw.hud.fader:add(item.pickupMessage)
      return true
    end
  end

  ovw.hud.fader:add('I am carrying too much...')
  return false
end