require 'app/house/room'

RoomRectangle = extend(Room)

function RoomRectangle:init()
  Room.init(self)

  self.width = love.math.randomNormal(4, 10)
  self.height = love.math.randomNormal(4, 10)
  self.width = math.round(math.clamp(self.width, 4, 50))
  self.height = math.round(math.clamp(self.height, 4, 50))

  for i = -1, self.width do
    self.walls.north[#self.walls.north + 1] = {x = i, y = -1, direction = 'north'}
    self.walls.south[#self.walls.south + 1] = {x = i, y = self.height, direction = 'south'}
  end

  for i = -1, self.height do
    self.walls.west[#self.walls.west + 1] = {x = -1, y = i, direction = 'west'}
    self.walls.east[#self.walls.east + 1] = {x = self.width, y = i, direction = 'east'}
  end
end
