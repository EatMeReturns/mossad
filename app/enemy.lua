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

  self.exp = 0
  self.dropChance = 1

  self.lootSpawnTable = WeightedRandom({{0, 0.7}, {1, 0.25}, {2, 0.05}}, 1)

  self.depth = 0
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
  self.room:removeObject(self)
  ovw.collision:unregister(self)
  ovw.view:unregister(self)
end

function Enemy:remove()
  ovw.enemies:remove(self)
end

Enemy.update = f.empty --perform movement, etc. calculations
Enemy.draw = f.empty --hurr durr
Enemy.alert = f.empty --don't poke the sleeping bear

function Enemy:hurt(amount)
  amount = amount * ovw.player.damageMultiplier
  table.each(ovw.buffs.objects, function(buff, key) if buff.enemyName and buff.enemyName == self.name.pluralized then amount = amount * buff.damageMultiplier end end)
  self.health = self.health - amount
  ovw.player.healthRegen = ovw.player.healthRegen + amount * ovw.player.lifeStealMultiplier
  ovw.player.staminaRegen = ovw.player.staminaRegen + amount * ovw.player.energyStealMultiplier
  if self.health <= 0 then
    --local function make(i, orb, amt)
    --  if i == 'Orb' then
    --    ovw.pickups:add(Orb({x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10, orbType = orb, room = self.room, amount = amt}))
    --  else
    --    ovw.pickups:add(Pickup({x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10, itemType = i, room = self.room}))
    --  end
    --end
    if love.math.random() < .1 then pickupTables.makeOrb(self.room, {x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10}, 'health', math.floor(love.math.random() * self.maxHealth / 4 + self.maxHealth / 4)) end
    --make('Orb', 'health', math.floor(love.math.random() * self.maxHealth / 4 + self.maxHealth / 4)) end
    if love.math.random() < .1 then pickupTables.makeOrb(self.room, {x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10}, 'stamina', math.floor(love.math.random() * self.maxHealth / 4 + self.maxHealth / 4)) end
    --make('Orb', 'stamina', math.floor(love.math.random() * self.maxHealth / 4 + self.maxHealth / 4)) end
    pickupTables.makeOrb(self.room, {x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10}, 'experience', self.exp)
    --make('Orb', 'experience', self.exp)
    --local i = self.lootSpawnTable:pick()[1]
    --while i > 0 do
    --  table.each(makeLootTable('Common'), function(v, k) make(v) end)
    --  i = i - 1
    --end
    pickupTables.drop(self)
    self:remove()
  else
    self:alert()
  end
end

function Enemy:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end
