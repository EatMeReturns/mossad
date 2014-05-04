local hardon = require 'lib/hardon'

require 'app/house/room'
require 'app/house/roomRectangle'

local function randomFrom(t)
  if #t == 0 then return end
  return t[love.math.random(1, #t)]
end

House = class()
House.cellSize = 32

function House:init()
  self.roomTypes = {RoomRectangle}
  self.rooms = {}

  self.grid = {}

  self:generate()

  self.depth = 5
  ovw.view:register(self)
end

function House:destroy()
  ovw.view:unregister(self)
end

function House:draw()
  love.graphics.setColor(50, 0, 0)
  local x1, x2 = self:snap(ovw.view.x, ovw.view.x + ovw.view.w)
  x1, x2 = x1 / self.cellSize - 1, x2 / self.cellSize + 1
  local y1, y2 = self:snap(ovw.view.y, ovw.view.y + ovw.view.h)
  y1, y2 = y1 / self.cellSize - 1, y2 / self.cellSize + 1
  for x = x1, x2 do
    for y = y1, y2 do
      if self.grid[x] and self.grid[x][y] == 1 then
        love.graphics.rectangle('fill', self:cell(x, y, 1, 1))
      end
    end
  end
end

function House:snap(x, ...)
  if not x then return end
  return math.floor(x / self.cellSize) * self.cellSize, self:snap(...)
end

function House:cell(x, ...)
  if not x then return end
  return x * self.cellSize, self:cell(...)
end

function House:generate()
  local opposite = {
    north = 'south',
    south = 'north',
    east = 'west',
    west = 'east'
  }

  local offset = {
    north = {0, -1},
    south = {0, 1},
    east = {1, 0},
    west = {-1, 0}
  }
  
  -- Create initial room
  self:addRoom(RoomRectangle())

  -- Loop until 100 rooms are created
  repeat

    -- Pick a source room, create a destination room
    local oldRoom = randomFrom(self.rooms)
    local newRoom = randomFrom(self.roomTypes)()

    -- Pick a wall from the old room to add the newRoom to
    local oldWall = oldRoom:randomWall()
    local newWall = newRoom:randomWall(opposite[oldWall.direction])

    -- Position the new room
    newRoom:move(oldRoom.x + oldWall.x - newWall.x, oldRoom.y + oldWall.y - newWall.y)
    newRoom:move(unpack(offset[oldWall.direction]))

    -- If it doesn't overlap with another room, add it.
    if self:collisionTest(newRoom) then
      self:addRoom(newRoom)
      self:addDoor(oldRoom.x + oldWall.x, oldRoom.y + oldWall.y, newRoom.x + newWall.x, newRoom.y + newWall.y)
    end

  until #self.rooms > 100
end

function House:addRoom(room)
  for x = room.x, room.x + room.width do
    for y = room.y, room.y + room.height do
      self.grid[x] = self.grid[x] or {}
      self.grid[x][y] = 1
    end
  end

  table.insert(self.rooms, room)
end

function House:addDoor(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1

  if dx == 0 then
    for y = y1, y2, dy do
      for x = x1 - 1, x1 + 1 do
        self.grid[x] = self.grid[x] or {}
        self.grid[x][y] = 1
      end
    end
  end

  if dy == 0 then
    for x = x1, x2, dx do
      for y = y1 - 1, y1 + 1 do
        self.grid[x] = self.grid[x] or {}
        self.grid[x][y] = 1
      end
    end
  end
end

function House:collisionTest(room)
  local padding = 1
  for x = room.x - padding, room.x + room.width + padding do
    for y = room.y - padding, room.y + room.height + padding do
      if self.grid[x] and self.grid[x][y] == 1 then return false end
    end
  end

  return true
end
