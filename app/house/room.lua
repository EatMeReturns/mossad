Room = class()

Room.tag = 'room' --for collision
Room.collision = {}
Room.collision.shape = 'rectangle'
Room.collision.static = true
Room.collision.with = {
  --
}

Room.spawnDoors = 2
Room.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
Room.pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
Room.floorType = 'main' --determines tileset data

local function randomFrom(t)
  if #t == 0 then return end
  return t[love.math.random(1, #t)]
end

local dirs = {'north', 'south', 'east', 'west'}

function Room:init()
  local eventTable = self.eventSpawnTable:pick()[1]
  self.event = eventTable[1](self, eventTable[2])
  
  self.walls = {
    north = {},
    south = {},
    east = {},
    west = {}
  }

  self.objects = {}
  self.idCounter = 1

  self.tiles = {}
  self.doors = {}

  self.id = 0

  self.x, self.y = 0, 0
  self.width, self.height = 0, 0
  self.radius = 0
end

Room.spawnDoors = f.empty
Room.carveRoom = f.empty
Room.spawnFurniture = f.empty

function Room:destroy()
  ovw.house:removeRoom(self)
  if self.sealShapes then table.each(self.sealShapes, function(shape, key) ovw.collision.hc:remove(shape) end) self.sealShapes = nil end
  ovw.collision.hc:remove(self.shape)
  table.with(self.objects, 'remove')
  table.each(self.doors, function(door, side)
    door.rooms[side] = nil
    door:disconnect()
  end)
  table.with(self.tiles, 'destroy')
  table.insert(ovw.house.roomsToCompute, self)
end

function Room:randomWall(dir)
  dir = dir or randomFrom(dirs)
  return self.walls[dir][love.math.random(3, #self.walls[dir] - 2)]
end

function Room:move(dx, dy)
  self.x, self.y = self.x + dx, self.y + dy
end

function Room:moveTo(x, y)
  self.x, self.y = x, y
end

function Room:hasTile(x, y)
  for i = 1, #self.tiles do
    if self.tiles[i] then
      if self.tiles[i].x == x and self.tiles[i].y == y then return true end
    end
  end
  return false
end

function Room:addObject(obj)
  table.insert(self.objects, self.idCounter, obj)
  obj.id = self.idCounter
  self.idCounter = self.idCounter + 1
  obj.room = self
end

function Room:removeObject(obj)
  self.objects[obj.id] = nil
end

function Room:computeCollision()
  if self.buildShape == 'circle' then
    self.shape = ovw.collision.hc:addCircle(House.pos(nil, self.x + self.radius, self.y + self.radius, self.radius))
    ovw.collision.hc:setPassive(self.shape)
    self.shape.owner = self
  elseif self.buildShape == 'diamond' then
    self.shape = ovw.collision:addDiamond(House.pos(nil, self.x + 1, self.y + 1, self.width - 2, self.height - 2))
    ovw.collision.hc:setPassive(self.shape)
    self.shape.owner = self
  else
    self.shape = ovw.collision.hc:addRectangle(House.pos(nil, self.x, self.y, self.width, self.height))
    ovw.collision.hc:setPassive(self.shape)
    self.shape.owner = self
  end
end

function Room:addDoor(door, side)
  self.doors[side] = door
end

function Room:createStaircase(x, y, direction)
  ovw.furniture:add(Staircase(self, x * House.cellSize, y * House.cellSize, direction))
end

-------------------------------------------------------------------------------------

Door = class()

function Door:init(rooms)
  self.connected = #rooms > 1
  self.rooms = rooms
  self.tiles = {}
end

function Door:connect()
  local room = nil
  if self.rooms.west and not self.rooms.east then
    self.connected, room = ovw.house:createRoom(self.rooms.west, 'west')
  elseif self.rooms.east and not self.rooms.west then
    self.connected, room = ovw.house:createRoom(self.rooms.east, 'east')
  elseif self.rooms.north and not self.rooms.south then
    self.connected, room = ovw.house:createRoom(self.rooms.north, 'north')
  elseif self.rooms.south and not self.rooms.north then
    self.connected, room = ovw.house:createRoom(self.rooms.south, 'south')
  else
    self.connected = false
  end
  return room
end

function Door:disconnect()
  table.each(self.tiles, function(tile, key)
    table.with(self.tiles, 'destroy')
  end)
  table.each(self.rooms, function(room, key) ovw.house:computeTilesInRoom(room) end)
  self.connected = false
end

-------------------------------------------------------------------------------------

Staircase = class()

Staircase.tag = 'staircase'
Staircase.collision = {
  shape = 'rectangle',
  with = {}
}

function Staircase:init(room, x, y, direction)
  self.room = room
  self.x = x
  self.y = y
  self.direction = direction --up, down, or an integer

  self.width = 32
  self.height = 32

  self.room:addObject(self)
  ovw.collision:register(self)
  ovw.view:register(self)
end

function Staircase:destroy()
  self.room:removeObject(self)
  ovw.collision:unregister(self)
  ovw.view:unregister(self)
end

function Staircase:remove()
  ovw.furniture:remove(self)
end

function Staircase:draw()
  local tx, ty = ovw.house:cell(self.x, self.y)
  local v = ovw.house.tiles[tx] and ovw.house.tiles[tx][ty] and ovw.house.tiles[tx][ty]:brightness() or 1
  love.graphics.setColor(255, 255, 255, v)
  self.shape:draw('line')
  love.graphics.print(self.direction, self.x + 5, self.y + 5)
end