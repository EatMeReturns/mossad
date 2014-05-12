require 'app/house/room'

BossRoom = extend(Room)

function BossRoom:init()
  Room.init(self)

  self.width = 12
  self.height = 12

  for i = -1, self.width do
    self.walls.north[#self.walls.north + 1] = {x = i, y = -1, direction = 'north'}
    self.walls.south[#self.walls.south + 1] = {x = i, y = self.height, direction = 'south'}
  end

  for i = -1, self.height do
    self.walls.west[#self.walls.west + 1] = {x = -1, y = i, direction = 'west'}
    self.walls.east[#self.walls.east + 1] = {x = self.width, y = i, direction = 'east'}
  end
end
