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
  self.drawTiles = true
  ovw.view:register(self)

  self.tileImage = love.graphics.newImage('media/graphics/newTiles.png')
  local w, h = self.tileImage:getDimensions()
  self.tilemap = {}
  self.tilemap.main = love.graphics.newQuad(36, 36, 32, 32, w, h)
  self.tilemap.n = love.graphics.newQuad(36, 1, 32, 32, w, h)
  self.tilemap.s = love.graphics.newQuad(36, 71, 32, 32, w, h)
  self.tilemap.e = love.graphics.newQuad(71, 36, 32, 32, w, h)
  self.tilemap.w = love.graphics.newQuad(1, 36, 32, 32, w, h)
  self.tilemap.nw = love.graphics.newQuad(1, 1, 32, 32, w, h)
  self.tilemap.ne = love.graphics.newQuad(71, 1, 32, 32, w, h)
  self.tilemap.sw = love.graphics.newQuad(1, 71, 32, 32, w, h)
  self.tilemap.se = love.graphics.newQuad(71, 71, 32, 32, w, h)
end

function House:destroy()
  ovw.view:unregister(self)
end

function House:draw()
  local x1, x2 = self:snap(ovw.view.x, ovw.view.x + ovw.view.w)
  x1, x2 = x1 / self.cellSize - 1, x2 / self.cellSize + 1
  local y1, y2 = self:snap(ovw.view.y, ovw.view.y + ovw.view.h)
  y1, y2 = y1 / self.cellSize - 1, y2 / self.cellSize + 1
  for x = x1, x2 do
    for y = y1, y2 do
      if self.grid[x] and self.grid[x][y] == 1 then
        love.graphics.setColor(50, 0, 0)
        love.graphics.rectangle('fill', self:cell(x, y, 1, 1))
      end

      if self.drawTiles and self.tiles[x] and self.tiles[x][y] then
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(self.tileImage, self.tilemap[self.tiles[x][y]], x * self.cellSize, y * self.cellSize)
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
    north = {0, -3},
    south = {0, 3},
    east = {3, 0},
    west = {-3, 0}
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

  self:computeTiles()
end

function House:addRoom(room)
  for x = room.x, room.x + room.width do
    for y = room.y, room.y + room.height do
      self.grid[x] = self.grid[x] or {}
      self.grid[x][y] = 1
    end
  end

  for _, dir in pairs({'north', 'south', 'east', 'west'}) do
    for _, wall in pairs(room.walls[dir]) do
      local x, y = room.x + wall.x, room.y + wall.y
      self.grid[x] = self.grid[x] or {}
      self.grid[x][y] = 1
    end
  end

  table.insert(self.rooms, room)
end

function House:addDoor(x1, y1, x2, y2)
  local dx = math.sign(x2 - x1)
  local dy = math.sign(y2 - y1)

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
  local padding = 2
  for x = room.x - padding, room.x + room.width + padding do
    for y = room.y - padding, room.y + room.height + padding do
      if self.grid[x] and self.grid[x][y] == 1 then return false end
    end
  end

  return true
end

function House:computeTiles()
  local function get(x, y)
    return self.grid[x] and self.grid[x][y] == 1
  end

  self.tiles = {}
  for x in pairs(self.grid) do
    for y in pairs(self.grid[x]) do
      if self.grid[x][y] and self.grid[x][y] == 1 then
        self.tiles[x] = self.tiles[x] or {}
        if get(x, y) and get(x - 1, y) and get(x + 1, y) and not get(x, y - 1) then
          self.tiles[x][y] = 'n'
        elseif get(x, y) and get(x - 1, y) and get(x + 1, y) and not get(x, y + 1) then
          self.tiles[x][y] = 's'
        elseif get(x, y) and get(x, y - 1) and get(x, y + 1) and not get(x + 1, y) then
          self.tiles[x][y] = 'e'
        elseif get(x, y) and get(x, y - 1) and get(x, y + 1) and not get(x - 1, y) then
          self.tiles[x][y] = 'w'
        elseif get(x, y) then
          self.tiles[x][y] = 'main'
        end
      end
    end
  end
end
