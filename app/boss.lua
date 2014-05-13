Boss = class()

Boss.tag = 'boss'
Boss.collision = {}
Boss.collision.with = {}

function Boss.collision.with.wall(self, other, dx, dy)
  self:setPosition(self.x + dx, self.y + dy)
end

function Boss.collision.with.player(self, player, dx, dy)
  player:setPosition(player.x + dx, player.y + dy)
end

function Boss:init()
  self.x = ovw.house:pos(ovw.house.bossRoom.x + ovw.house.bossRoom.width / 2)
  self.y = ovw.house:pos(ovw.house.bossRoom.y + ovw.house.bossRoom.height / 2)
  ovw.view:register(self)
  ovw.collision:register(self)
end

function Boss:destroy()
  ovw.boss = nil
  ovw.enemies:clear()
  ovw.house:destroy()
  ovw.house:increaseDifficulty()
  ovw.house = House()
  ovw.player.x = ovw.house:pos(ovw.house.rooms[1].x + ovw.house.rooms[1].width / 2)
  ovw.player.y = ovw.house:pos(ovw.house.rooms[1].y + ovw.house.rooms[1].height / 2)
  ovw.house:spawnEnemies()
  ovw.collision:unregister(self)
  ovw.view:unregister(self)
  ovw.hud.fader:add('the house twists and creaks around you, and before long you find yourself enveloped in darkness once again...')
end

function Boss:hurt(amount)
  self.health = self.health - amount
  if self.health <= 0 then self:destroy() end
end

function Boss:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end
