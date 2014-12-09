require 'app/house/room'

BossRoom = extend(Room)

function BossRoom:init(boss)
  Room.init(self)

  self.boss = boss
end

function BossRoom:spawnBoss()
	ovw.enemies:add((self.boss)())
end