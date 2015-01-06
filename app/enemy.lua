Enemy = class()

Enemy.tag = 'enemy' --for collision
Enemy.collision = {}
Enemy.collision.with = {
  wall = function(self, other, dx, dy)
    self:setPosition(self.x + dx, self.y + dy)
  end,

  enemy = function(self, other, dx, dy)
    self:setPosition(self.x + dx / 2, self.y + dy / 2)
    other:setPosition(other.x - dx / 2, other.y - dy / 2)
  end,

  player = function(self, other, dx, dy)
    self:setPosition(self.x + dx, self.y + dy)
  end,

  room = function(self, other, dx, dy)
    if self.room then
      if self.room ~= other then
        self.room:removeObject(self)
        other:addObject(self)
      end
    else
      other:addObject(self)
    end
  end
}

Enemy.name = {}
Enemy.name.singular = {'Enemy'}
Enemy.name.pluralized = {'Enemies'}

Enemy.footprintTimer = 0 --footprints require self.angle and self.room
Enemy.footprintTime = 4
Enemy.lastFootprintTimer = 0
Enemy.lastFootprintTime = .2 --change for each type of enemy
Enemy.footprintReverse = 1
Enemy.footprintColor = {0, 0, 0}
Enemy.footprint = 'player' --change for each type of enemy
Enemy.makeFootprints = true --disable when flying or underground or whatever

function Enemy:init(x, y, room)
  self.x = x
  self.y = y
  self.prevX = self.x
  self.prevY = self.y

  self.room = room
  self.id = 0
  self.room:addObject(self)

  self.angle = 0
  self.targetAngle = self.angle

  self.speed = 0
  self.targetSpeed = 0

  self.target = nil

  self.exp = 0
  self.dropChance = 1

  self.lootSpawnTable = WeightedRandom({{0, 0.7}, {1, 0.25}, {2, 0.05}}, 1)

  self.depth = DrawDepths.movers
  ovw.collision:register(self)
  ovw.view:register(self)
end

function Enemy:drawHealth()
  --health bar
  local val = self:val()
  love.graphics.setColor(255, math.min(255, 255 * val * 2), math.max(0, 510 * (val - 0.5)), 255)
  love.graphics.drawBar(self.x - 20, self.y - 20, 40, 5, val, self:maxVal(), false)
end

function Enemy:val()
  return self.health / self.maxHealth
end

function Enemy:maxVal()
  return self.maxHealth >= 10 and (self.maxHealth / 10) or 1
end

function Enemy:destroy()
  ovw.player.combatants[self] = nil
  self.room:removeObject(self)
  ovw.collision:unregister(self)
  ovw.view:unregister(self)
end

function Enemy:remove()
  ovw.enemies:remove(self)
end

function Enemy:update()
  if self.target then
    ovw.player.combatants[self] = self
  else
    ovw.player.combatants[self] = nil
  end

  if self.makeFootprints then
    self.footprintTimer = self.footprintTimer - tickRate
  else
    self.footprintTimer = 0
  end
  if self.footprintTimer > 0 then
    self.lastFootprintTimer = self.lastFootprintTimer - tickRate
    if self.lastFootprintTimer <= 0 then
      ovw.particles:add(Footprint({x = self.x, y = self.y}, self.angle, self.footprintReverse, self.footprintColor, self.room, self.footprint))
      self.footprintReverse = self.footprintReverse * -1
      self.lastFootprintTimer = self.lastFootprintTime
    end
  end
end

Enemy.draw = f.empty --hurr durr
Enemy.alert = f.empty --don't poke the sleeping bear

function Enemy:hurt(amount)
  amount = amount * ovw.player.damageMultiplier
  table.each(ovw.buffs.objects, function(buff, key) if buff.enemyName and buff.enemyName == self.name.pluralized then amount = amount * buff.damageMultiplier end end)
  self.health = self.health - amount
  ovw.player.healthRegen = ovw.player.healthRegen + amount * ovw.player.lifeStealMultiplier
  ovw.player.staminaRegen = ovw.player.staminaRegen + amount * ovw.player.energyStealMultiplier

  ovw.particles:add(BloodParticle({x = self.x - 10 + love.math.random() * 20, y = self.y - 10 + love.math.random() * 20}, {10, 10, 10}))
  ovw.particles:add(BloodSplat({x = self.x - 10 + love.math.random() * 20, y = self.y - 10 + love.math.random() * 20}, {10, 10, 10}, self.room))
  ovw.particles:add(BloodSplat({x = self.x - 10 + love.math.random() * 20, y = self.y - 10 + love.math.random() * 20}, {10, 10, 10}, self.room))
  ovw.particles:add(BloodSplat({x = self.x - 10 + love.math.random() * 20, y = self.y - 10 + love.math.random() * 20}, {10, 10, 10}, self.room))

  if self.health <= 0 then
    if love.math.random() < .1 then pickupTables.makeOrb(self.room, {x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10}, 'health', math.floor(love.math.random() * self.maxHealth / 4 + self.maxHealth / 4)) end
    if love.math.random() < .1 then pickupTables.makeOrb(self.room, {x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10}, 'stamina', math.floor(love.math.random() * self.maxHealth / 4 + self.maxHealth / 4)) end
    pickupTables.makeOrb(self.room, {x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10}, 'experience', self.exp)
    pickupTables.drop(self)
    if self.deathCry then
      cry = ovw.sound:play(self.deathCry)
      cry:setVolume(ovw.sound.volumes.fx)
    end
    if self.deathMessage then
      ovw.hud.fader:add(self.deathMessage)
    end

    ovw.particles:add(BloodSplat({x = self.x - 50 + love.math.random() * 100, y = self.y - 50 + love.math.random() * 100}, {10, 10, 10}, self.room))
    ovw.particles:add(BloodSplat({x = self.x - 50 + love.math.random() * 100, y = self.y - 50 + love.math.random() * 100}, {10, 10, 10}, self.room))
    ovw.particles:add(BloodSplat({x = self.x - 50 + love.math.random() * 100, y = self.y - 50 + love.math.random() * 100}, {10, 10, 10}, self.room))
    ovw.particles:add(BloodSplat({x = self.x - 50 + love.math.random() * 100, y = self.y - 50 + love.math.random() * 100}, {10, 10, 10}, self.room))
    ovw.particles:add(BloodSplat({x = self.x - 50 + love.math.random() * 100, y = self.y - 50 + love.math.random() * 100}, {10, 10, 10}, self.room))

    self:remove()
  else
    self:alert()
  end
end

function Enemy:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end
