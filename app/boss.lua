Boss = class()

Boss.tag = 'enemy'
Boss.collision = {}
Boss.collision.with = {}

function Boss.collision.with.wall(self, other, dx, dy)
  self:setPosition(self.x + dx, self.y + dy)
end

function Boss.collision.with.player(self, other, dx, dy)
  --other:setPosition(other.x + dx, other.y + dy)
end

function Boss.collision.with.room(self, other, dx, dy)
  if self.room then
    if self.room ~= other then
      self.room:removeObject(self)
      other:addObject(self)
    end
  else
    other:addObject(self)
  end
end

Boss.title = 'Nameless Boss is a Bug'

Boss.name = {}
Boss.name.singular = 'The Boss'
Boss.name.pluralized = 'The Boss'

Boss.spawnMessage = 'How\'d you do that? Congratulations, you\'ve found a bug!'

function Boss:init()
  self.x = ovw.house:pos(ovw.player.room.x + ovw.player.room.width / 2)
  self.y = ovw.house:pos(ovw.player.room.y + ovw.player.room.height / 2) - 100

  self.exp = 50
  self.dropChance = 1

  self.depth = DrawDepths.movers

  ovw.hud.fader:add(self.spawnMessage)

  ovw.view:register(self)
  ovw.collision:register(self)
end

Boss.update = f.empty
Boss.draw = f.empty

function Boss:destroy()
  self.room.event:endEvent()
  self.room:removeObject(self)
  ovw.collision:unregister(self)
  ovw.view:unregister(self)
  ovw.hud.fader:add('An evil has been thwarted... for now.')
end

function Boss:remove()
  ovw.enemies:remove(self)
end

function Boss:hurt(amount)
  self.health = self.health - amount
  if self.health <= 0 then
    pickupTables.makeOrb(self.room, {x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10}, 'health', math.floor(love.math.random() * self.maxHealth / 4 + self.maxHealth / 4))
    pickupTables.makeOrb(self.room, {x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10}, 'stamina', math.floor(love.math.random() * self.maxHealth / 4 + self.maxHealth / 4))
    pickupTables.makeOrb(self.room, {x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10}, 'experience', self.exp)
    pickupTables.drop(self)
    pickupTables.drop(self)
    --drop unique item
    self:remove()
  end
end

function Boss:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end
