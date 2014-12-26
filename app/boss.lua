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

function Boss:init()
  self.x = ovw.house:pos(ovw.player.room.x + ovw.player.room.width / 2)
  self.y = ovw.house:pos(ovw.player.room.y + ovw.player.room.height / 2) - 100

  self.exp = 50
  self.lootSpawnTable = WeightedRandom({{3, 0.7}, {4, 0.25}, {5, 0.05}}, 1)

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
    local function make(i) ovw.pickups:add(Pickup({x = self.x + love.math.random() * 20 - 10, y = self.y + love.math.random() * 20 - 10, itemType = i, room = self.room})) end
    ovw.player:learn(self.exp)
    local i = self.lootSpawnTable:pick()[1]
    while i > 0 do
      table.each(makeLootTable('Common'), function(v, k) make(v) end)
      i = i - 1
    end
    make(makeLootTable('Rare')[1])
    self:remove()
  end
end

function Boss:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end
