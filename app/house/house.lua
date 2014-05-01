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

  self.scratch = hardon(self.cellSize)

  self:generate()

  self.depth = 5
  ovw.view:register(self)
end

function House:update()
  --
end

function House:destroy()
  ovw.view:unregister(self)
end

function House:draw()
  for shape in pairs(self.scratch:shapesInRange(ovw.view.x / self.cellSize, ovw.view.y / self.cellSize, (ovw.view.x + ovw.view.w) / self.cellSize, (ovw.view.y + ovw.view.h) / self.cellSize)) do
    shape.room:draw()
  end
end

function House:load()
  --
end

function House:snap(x, ...)
  if not x then return end
  return math.round(x / self.cellSize) * self.cellSize, self:snap(...)
end

function House:grid(x, ...)
  if not x then return end
  return x * self.cellSize, self:grid(...)
end

function House:generate()
  local opposite = {
    north = 'south',
    south = 'north',
    east = 'west',
    west = 'east'
  }

  -- Create initial room
  self.rooms[#self.rooms + 1] = RoomRectangle()
  local shape = self.scratch:addRectangle(self.rooms[1].x, self.rooms[1].y, self.rooms[1].width, self.rooms[1].height)
  shape.room = self.rooms[1]

  -- Loop until 100 rooms are created
  repeat

    -- Pick a source room, create a destination room
    local oldRoom = randomFrom(self.rooms)
    local newRoom = randomFrom(self.roomTypes)()

    -- Pick a wall from each
    local oldWall = oldRoom:randomWall()
    local newWall = newRoom:randomWall(opposite[oldWall.direction])

    -- Position the new room
    newRoom:move(oldRoom.x + oldWall.x - newWall.x, oldRoom.y + oldWall.y - newWall.y)

    local shape = self.scratch:addRectangle(newRoom.x, newRoom.y, newRoom.width, newRoom.height)
    shape.room = newRoom
    
    -- If it doesn't overlap with another room, add it.
    if table.count(table.filter(shape:neighbors(), f.cur(shape.collidesWith, shape))) == 0 then
      self.rooms[#self.rooms + 1] = newRoom
    else
      self.scratch:remove(shape)
    end

  until #self.rooms > 100
end
