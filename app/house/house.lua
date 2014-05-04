House = class()

----------------
-- Parameters
----------------
House.cellSize = 32
House.roomCount = 100
House.roomSpacing = 1
House.carveSize = 2
House.hallwayCount = 35
House.hallwayLength = 20

House.tag = 'wall'
House.collision = {with = {}}

require 'app/house/room'
require 'app/house/roomRectangle'

local function randomFrom(t)
  if #t == 0 then return end
  return t[love.math.random(1, #t)]
end

function House:init()
  self.roomTypes = {RoomRectangle}
  self.rooms = {}

  self.grid = {}
  
  self.tileImage = love.graphics.newImage('media/graphics/newTiles.png')
  local w, h = self.tileImage:getDimensions()
  local function t(x, y) return love.graphics.newQuad(1 + (x * 35), 1 + (y * 35), 32, 32, w, h) end
  self.tilemap = {}
  self.tilemap.main = t(1, 4)
  self.tilemap.n = t(1, 3)
  self.tilemap.s = t(1, 5)
  self.tilemap.e = t(2, 4)
  self.tilemap.w = t(0, 4)
  self.tilemap.nw = t(0, 3)
  self.tilemap.ne = t(2, 3)
  self.tilemap.sw = t(0, 5)
  self.tilemap.se = t(2, 5)
  self.tilemap.inw = t(3, 3)
  self.tilemap.ine = t(4, 3)
  self.tilemap.isw = t(3, 4)
  self.tilemap.ise = t(4, 4)

  self:generate()

  self.depth = 5
  ovw.view:register(self)
end

function House:destroy()
  ovw.view:unregister(self)
end

function House:draw()
  local x1, x2 = self:snap(ovw.view.x, ovw.view.x + ovw.view.w)
  x1, x2 = x1 / self.cellSize - 1, x2 / self.cellSize + 1
  local y1, y2 = self:snap(ovw.view.y, ovw.view.y + ovw.view.h)
  y1, y2 = y1 / self.cellSize - 1, y2 / self.cellSize + 1
  
  love.graphics.setColor(255, 255, 255)
  for x = x1, x2 do
    for y = y1, y2 do
      if self.tiles[x] and self.tiles[x][y] then
        love.graphics.draw(self.tileImage, self.tilemap[self.tiles[x][y]], x * self.cellSize, y * self.cellSize)
      end
    end
  end

  for i = 1, #self.shapes do
    self.shapes[i]:draw('line')
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
    north = {0, -self.roomSpacing},
    south = {0, self.roomSpacing},
    east = {self.roomSpacing, 0},
    west = {-self.roomSpacing, 0}
  }
  
  local function get(x, y)
    return self.grid[x] and self.grid[x][y] == 1
  end

  local room = RoomRectangle()
  room.x, room.y = 100, 100
  self:addRoom(room)

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
      self:carve(oldRoom.x + oldWall.x, oldRoom.y + oldWall.y, newRoom.x + newWall.x, newRoom.y + newWall.y)
    end

  until #self.rooms > self.roomCount

  local hallways = 0
  repeat
    local room = randomFrom(self.rooms)
    local wall = room:randomWall()
    local length = love.math.randomNormal(self.hallwayLength / 4, self.hallwayLength)
    local x, y = room.x + wall.x, room.y + wall.y
    local x1, y1 = x, y
    local dx, dy = math.sign(offset[wall.direction][1]), math.sign(offset[wall.direction][2])
    local tmp = {}
    local turn = love.math.random() > .5
    for i = 1, length do
      x, y = x + dx, y + dy
      if get(x, y) then
        hallways = hallways + 1
        self:carve(x1, y1, x, y)
        break
      end
    end
  until hallways > self.hallwayCount

  self:computeTiles()
  self:computeShapes()
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

function House:carve(x1, y1, x2, y2)
  local dx = math.sign(x2 - x1)
  local dy = math.sign(y2 - y1)

  if dx == 0 then
    for y = y1, y2, dy do
      for x = x1 - self.carveSize, x1 + self.carveSize do
        self.grid[x] = self.grid[x] or {}
        self.grid[x][y] = 1
      end
    end
  end

  if dy == 0 then
    for x = x1, x2, dx do
      for y = y1 - self.carveSize, y1 + self.carveSize do
        self.grid[x] = self.grid[x] or {}
        self.grid[x][y] = 1
      end
    end
  end
end

function House:collisionTest(room)
  local padding = self.roomSpacing - 1
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
        local n, s, e, w = get(x, y - 1), get(x, y + 1), get(x + 1, y), get(x - 1, y)
        local nw, ne = get(x - 1, y - 1), get(x + 1, y - 1)
        local sw, se = get(x - 1, y + 1), get(x + 1, y + 1)
        if w and e and not n then
          self.tiles[x][y] = 'n'
        elseif w and e and not s then
          self.tiles[x][y] = 's'
        elseif n and s and not e then
          self.tiles[x][y] = 'e'
        elseif n and s and not w then
          self.tiles[x][y] = 'w'
        elseif e and s and not w and not n then
          self.tiles[x][y] = 'nw'
        elseif w and s and not e and not n then
          self.tiles[x][y] = 'ne'
        elseif e and n and not w and not s then
          self.tiles[x][y] = 'sw'
        elseif w and n and not e and not s then
          self.tiles[x][y] = 'se'
        elseif w and n and not nw then
          self.tiles[x][y] = 'inw'
        elseif n and e and not ne then
          self.tiles[x][y] = 'ine'
        elseif s and w and not sw then
          self.tiles[x][y] = 'isw'
        elseif s and e and not se then
          self.tiles[x][y] = 'ise'
        elseif get(x, y) then
          self.tiles[x][y] = 'main'
        end
      end
    end
  end
end

function House:computeShapes()
  self.shapes = {}

  function coords(x, y, w, d)
    if d == 'n' then
      return ovw.collision.hc:addRectangle(self:cell(x, y, w, .5))
    elseif d == 's' then
      return ovw.collision.hc:addRectangle(self:cell(x, y + .5, w, .5))
    elseif d == 'w' then
      return ovw.collision.hc:addRectangle(self:cell(x, y, .5, w))
    elseif d == 'e' then
      return ovw.collision.hc:addRectangle(self:cell(x + .5, y, .5, w))
    elseif d == 'inw' then
      return ovw.collision.hc:addRectangle(self:cell(x, y, .5, .5))
    elseif d == 'ine' then
      return ovw.collision.hc:addRectangle(self:cell(x + .5, y, .5, .5))
    elseif d == 'isw' then
      return ovw.collision.hc:addRectangle(self:cell(x, y + .5, .5, .5))
    elseif d == 'ise' then
      return ovw.collision.hc:addRectangle(self:cell(x + .5, y + .5, .5, .5))
    elseif d == 'nw' then
      local pts = {
        x, y,
        x + 1, y,
        x + 1, y + .5,
        x + .5, y + .5,
        x + .5, y + 1,
        x, y + 1
      }
      return ovw.collision.hc:addPolygon(self:cell(unpack(pts)))
    elseif d == 'ne' then
      local pts = {
        x, y,
        x + 1, y,
        x + 1, y + 1,
        x + .5, y + 1,
        x + .5, y + .5,
        x, y + .5
      }
      return ovw.collision.hc:addPolygon(self:cell(unpack(pts)))
    elseif d == 'sw' then
      local pts = {
        x, y,
        x + .5, y,
        x + .5, y + .5,
        x + 1, y + .5,
        x + 1, y + 1,
        x, y + 1
      }
      return ovw.collision.hc:addPolygon(self:cell(unpack(pts)))
    elseif d == 'se' then
      local pts = {
        x + .5, y,
        x + 1, y,
        x + 1, y + 1,
        x, y + 1,
        x, y + .5,
        x + .5, y + .5
      }
      return ovw.collision.hc:addPolygon(self:cell(unpack(pts)))
    else
      return ovw.collision.hc:addRectangle(self:cell(x, y, 1, 1))
    end
  end

  local tiles = table.copy(self.tiles)

  for x in pairs(tiles) do
    for y in pairs(tiles[x]) do
      if tiles[x][y] and tiles[x][y] ~= 'main' then
        local z = 1
        local d = tiles[x][y]
        local xx, yy = x, y
        
        if d == 'n' or d == 's' then
          tiles[xx][yy] = nil
          while true do
            if tiles[xx - 1][yy] == 'n' or tiles[xx - 1][yy] == 's' then
              tiles[xx - 1][yy] = nil
              xx = xx - 1
              z = z + 1
            else
              break
            end
          end

          while true do
            if tiles[xx + z][yy] == 'n' or tiles[xx + z][yy] == 's' then
              tiles[xx + z][yy] = nil
              z = z + 1
            else
              break
            end
          end
        elseif d == 'w' or d == 'e' then
          tiles[xx][yy] = nil
          while true do
            if tiles[xx][yy - 1] == 'w' or tiles[xx][yy - 1] == 'e' then
              tiles[xx][yy - 1] = nil
              yy = yy - 1
              z = z + 1
            else
              break
            end
          end

          while true do
            if tiles[xx][yy + z] == 'w' or tiles[xx][yy + z] == 'e' then
              tiles[xx][yy + z] = nil
              z = z + 1
            else
              break
            end
          end
        end
        
        local shape = coords(xx, yy, z, d)
        
        ovw.collision.hc:setPassive(shape)
        shape.owner = self
        table.insert(self.shapes, shape)
      end
    end
  end
end
