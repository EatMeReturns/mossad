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
Room.floorType = 'main'

local function randomFrom(t)
  if #t == 0 then return end
  return t[love.math.random(1, #t)]
end

local dirs = {'north', 'south', 'east', 'west'}

function Room:init()
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
end

function Room:destroy()
  ovw.house:removeRoom(self)
  if self.sealShapes then table.each(self.sealShapes, function(shape, key) ovw.collision.hc:remove(shape) end) self.sealShapes = nil end
  ovw.collision.hc:remove(self.shape)
  table.with(self.objects, 'remove')
  table.with(self.tiles, 'destroy')
  table.each(self.doors, function(door, side)
    door.rooms[side] = nil
    door.connected = false
  end)
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

function Room:addObject(obj)
  table.insert(self.objects, self.idCounter, obj)
  obj.id = self.idCounter
  self.idCounter = self.idCounter + 1
  obj.room = self
end

function Room:removeObject(obj)
  self.objects[obj.id] = nil
end

function Room:computeCollision(x, y, w, h)
  self.shape = ovw.collision.hc:addRectangle(x, y, w, h)
  ovw.collision.hc:setPassive(self.shape)
  self.shape.owner = self
end

function Room:addDoor(door, side)
  self.doors[side] = door
end

Door = class()

function Door:init(rooms)
  self.connected = #rooms > 1
  self.rooms = rooms
end

function Door:connect()
  assert(not self.connected)
  if self.rooms.west and not self.rooms.east then
    self.connected = ovw.house:createRoom(self.rooms.west, 'west')
  elseif self.rooms.east and not self.rooms.west then
    self.connected = ovw.house:createRoom(self.rooms.east, 'east')
  elseif self.rooms.north and not self.rooms.south then
    self.connected = ovw.house:createRoom(self.rooms.north, 'north')
  elseif self.rooms.south and not self.rooms.north then
    self.connected = ovw.house:createRoom(self.rooms.south, 'south')
  else
    self.connected = false
  end
end