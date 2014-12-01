House = class()
House.tag = 'wall'
House.collision = {with = {}}

require 'app/house/config'
require 'app/house/tiles'
require 'app/house/room'
require 'app/house/roomRectangle'

local function randomFrom(t)
  if #t == 0 then return end
  return t[love.math.random(1, #t)]
end

function House:init()
  self.roomTypes = {RoomRectangle}
  self.rooms = {}

  self.tiles = {}

  self.lightMap = {}
  
  self:generate()

  self.depth = 5
  ovw.view:register(self)
end

function House:destroy()
  ovw.collision.hc:remove(unpack(self.shapes))
  ovw.view:unregister(self)
end

function House:update()
  local x1, x2, y1, y2 = self:cell(ovw.view.x, ovw.view.x + ovw.view.w, ovw.view.y, ovw.view.y + ovw.view.h)
  
  for x = x1, x2 do
    for y = y1, y2 do
      if self.tiles[x] and self.tiles[x][y] then
        self.tiles[x][y]:updateLight(x, y)
      end
    end
  end

  self.ambientColor[1] = math.lerp(self.ambientColor[1], self.targetAmbient[1], .2 * tickRate)
  self.ambientColor[2] = math.lerp(self.ambientColor[2], self.targetAmbient[2], .2 * tickRate)
  self.ambientColor[3] = math.lerp(self.ambientColor[3], self.targetAmbient[3], .2 * tickRate)
end

function House:draw()
  local x1, x2, y1, y2 = self:cell(ovw.view.x, ovw.view.x + ovw.view.w, ovw.view.y, ovw.view.y + ovw.view.h)
  
  for x = x1, x2 do
    for y = y1, y2 do
      if self.tiles[x] and self.tiles[x][y] then
        self.tiles[x][y]:draw()
      end
    end
  end
end

function House:snap(x, ...)
  if not x then return end
  return math.round(x / self.cellSize) * self.cellSize, self:snap(...)
end

function House:cell(x, ...)
  if not x then return end
  return math.round((x - self.cellSize / 2) / self.cellSize), self:cell(...)
end

function House:pos(x, ...)
  if not x then return end
  return x * self.cellSize, self:pos(...)
end

function House:applyLight(light, type)
  local x1, x2 = self:cell(light.x - light.maxDis, light.x + light.maxDis)
  local y1, y2 = self:cell(light.y - light.maxDis, light.y + light.maxDis)
  
  for x = x1, x2 do
    for y = y1, y2 do
      if self.tiles[x] and self.tiles[x][y] then
        self.tiles[x][y]:applyLight(light, type)
      end
    end
  end
end

function House:sealBossRoom()
  local x, y, w, h, shape
  local border = .5 * self.cellSize

  x, y, w, h = self:pos(self.bossRoom.x - 1, self.bossRoom.y - 1, self.bossRoom.width + 1, self.bossRoom.height + 1)

  shape = ovw.collision.hc:addRectangle(x, y, w, border)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(self.shapes, shape)
  
  shape = ovw.collision.hc:addRectangle(x, y, border, h)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(self.shapes, shape)

  shape = ovw.collision.hc:addRectangle(x + w + border, y, border, h)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(self.shapes, shape)

  shape = ovw.collision.hc:addRectangle(x, y + h + border, w, border)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(self.shapes, shape)
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
    return self.tiles[x] and self.tiles[x][y]
  end

  local room = RoomRectangle()
  room.x, room.y = 100, 100
  self:addRoom(room)

  local furthestRoom = room
  local furthestDis = 0

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
      
      local dis = math.distance(100, 100, newRoom.x, newRoom.y)
      if dis > furthestDis then
        furthestDis = dis
        furthestRoom = newRoom
      end
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
    for i = 1, length do
      x, y = x + dx, y + dy
      if get(x, y) then
        hallways = hallways + 1
        self:carve(x1, y1, x, y)
        break
      end
    end
  until hallways > self.hallwayCount
  
  -- Place boss room
  local newRoom = BossRoom()
  local oldRoom = furthestRoom
  self.bossRoom = newRoom
  while true do
    local oldWall = oldRoom:randomWall()
    local newWall = newRoom:randomWall(opposite[oldWall.direction])

    newRoom:moveTo(0, 0)
    newRoom:move(oldRoom.x + oldWall.x - newWall.x, oldRoom.y + oldWall.y - newWall.y)
    local dx, dy = unpack(offset[oldWall.direction])
    newRoom:move(dx * 1, dy * 1)

    -- If it doesn't overlap with another room, add it.
    if self:collisionTest(newRoom) then
      self:addRoom(newRoom)
      self:carve(oldRoom.x + oldWall.x, oldRoom.y + oldWall.y, newRoom.x + newWall.x, newRoom.y + newWall.y)
      break
    end
  end

  self:computeTiles()
  self:computeShapes()
end

function House:addRoom(room)
  local val = getmetatable(room).__index == BossRoom and 'boss' or 'main'
  for x = room.x, room.x + room.width do
    for y = room.y, room.y + room.height do
      self.tiles[x] = self.tiles[x] or {}
      self.tiles[x][y] = Tile(val, x, y)
    end
  end

  for _, dir in pairs({'north', 'south', 'east', 'west'}) do
    for _, wall in pairs(room.walls[dir]) do
      local x, y = room.x + wall.x, room.y + wall.y
      self.tiles[x] = self.tiles[x] or {}
      self.tiles[x][y] = Tile(val, x, y)
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
        self.tiles[x] = self.tiles[x] or {}
        self.tiles[x][y] = self.tiles[x][y] or Tile('main', x, y)
      end
    end
  end

  if dy == 0 then
    for x = x1, x2, dx do
      for y = y1 - self.carveSize, y1 + self.carveSize do
        self.tiles[x] = self.tiles[x] or {}
        self.tiles[x][y] = self.tiles[x][y] or Tile('main', x, y)
      end
    end
  end
end

function House:collisionTest(room)
  local padding = self.roomSpacing - 1
  --if getmetatable(room).__index == BossRoom then padding = padding + 3 end
  for x = room.x - padding, room.x + room.width + padding do
    for y = room.y - padding, room.y + room.height + padding do
      if self.tiles[x] and self.tiles[x][y] then return false end
    end
  end

  return true
end

function House:computeTiles()
  local function get(x, y)
    return self.tiles[x] and self.tiles[x][y]
  end

  for x in pairs(self.tiles) do
    for y in pairs(self.tiles[x]) do
      if get(x, y) then
        local n, s, e, w = get(x, y - 1), get(x, y + 1), get(x + 1, y), get(x - 1, y)
        local nw, ne = get(x - 1, y - 1), get(x + 1, y - 1)
        local sw, se = get(x - 1, y + 1), get(x + 1, y + 1)
        if w and e and not n then
          self.tiles[x][y].tile = 'n'
        elseif w and e and not s then
          self.tiles[x][y].tile = 's'
        elseif n and s and not e then
          self.tiles[x][y].tile = 'e'
        elseif n and s and not w then
          self.tiles[x][y].tile = 'w'
        elseif e and s and not w and not n then
          self.tiles[x][y].tile = 'nw'
        elseif w and s and not e and not n then
          self.tiles[x][y].tile = 'ne'
        elseif e and n and not w and not s then
          self.tiles[x][y].tile = 'sw'
        elseif w and n and not e and not s then
          self.tiles[x][y].tile = 'se'
        elseif w and n and not nw then
          self.tiles[x][y].tile = 'inw'
        elseif n and e and not ne then
          self.tiles[x][y].tile = 'ine'
        elseif s and w and not sw then
          self.tiles[x][y].tile = 'isw'
        elseif s and e and not se then
          self.tiles[x][y].tile = 'ise'
        elseif get(x, y) then
          self.tiles[x][y].tile = 'c'
        end
      end
    end
  end
end

function House:computeShapes()
  self.shapes = {}

  local function coords(x, y, w, d)
    if d == 'n' then
      return ovw.collision.hc:addRectangle(self:pos(x, y, w, .5))
    elseif d == 's' then
      return ovw.collision.hc:addRectangle(self:pos(x, y + .5, w, .5))
    elseif d == 'w' then
      return ovw.collision.hc:addRectangle(self:pos(x, y, .5, w))
    elseif d == 'e' then
      return ovw.collision.hc:addRectangle(self:pos(x + .5, y, .5, w))
    elseif d == 'inw' then
      return ovw.collision.hc:addRectangle(self:pos(x, y, .5, .5))
    elseif d == 'ine' then
      return ovw.collision.hc:addRectangle(self:pos(x + .5, y, .5, .5))
    elseif d == 'isw' then
      return ovw.collision.hc:addRectangle(self:pos(x, y + .5, .5, .5))
    elseif d == 'ise' then
      return ovw.collision.hc:addRectangle(self:pos(x + .5, y + .5, .5, .5))
    elseif d == 'nw' then
      local pts = {
        x, y,
        x + 1, y,
        x + 1, y + .5,
        x + .5, y + .5,
        x + .5, y + 1,
        x, y + 1
      }
      return ovw.collision.hc:addPolygon(self:pos(unpack(pts)))
    elseif d == 'ne' then
      local pts = {
        x, y,
        x + 1, y,
        x + 1, y + 1,
        x + .5, y + 1,
        x + .5, y + .5,
        x, y + .5
      }
      return ovw.collision.hc:addPolygon(self:pos(unpack(pts)))
    elseif d == 'sw' then
      local pts = {
        x, y,
        x + .5, y,
        x + .5, y + .5,
        x + 1, y + .5,
        x + 1, y + 1,
        x, y + 1
      }
      return ovw.collision.hc:addPolygon(self:pos(unpack(pts)))
    elseif d == 'se' then
      local pts = {
        x + .5, y,
        x + 1, y,
        x + 1, y + 1,
        x, y + 1,
        x, y + .5,
        x + .5, y + .5
      }
      return ovw.collision.hc:addPolygon(self:pos(unpack(pts)))
    else
      return ovw.collision.hc:addRectangle(self:pos(x, y, 1, 1))
    end
  end

  local tiles = table.copy(self.tiles)

  for x in pairs(tiles) do
    for y in pairs(tiles[x]) do
      if tiles[x][y] and tiles[x][y].tile ~= 'c' then
        local z = 1
        local d = tiles[x][y].tile
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

function House:spawnEnemies()
  local types = {Shade, InkRaven}
  while table.count(ovw.enemies.objects) < self.enemyCount do
    local room = randomFrom(self.rooms)
    local x, y = self:pos(room.x, room.y)
    x = x + self.cellSize / 2 + love.math.random() * ((room.width - 2) * self.cellSize)
    y = y + self.cellSize / 2 + love.math.random() * ((room.height - 2) * self.cellSize)
    if room ~= self.rooms[1] and room ~= self.bossRoom then
      ovw.enemies:add(randomFrom(types)(x, y))
    end
  end
end

function House:spawnItems()
  local function make(i)
    local room = randomFrom(self.rooms)
    local x, y = self:pos(room.x, room.y)
    x = x + self.cellSize / 2 + love.math.random() * ((room.width - 2) * self.cellSize)
    y = y + self.cellSize / 2 + love.math.random() * ((room.height - 2) * self.cellSize)
    if room ~= self.bossRoom then
      ovw.pickups:add(Pickup({x = x, y = y, itemType = i}))
      return true
    end
  end

  local probs = {
    {Glowstick, .2},
    {FirstAidKit, .15},
    {Ammo, .5},
    {Torch, .15}
  }

  for i = 1, self.itemCount do
    local x = love.math.random()
    for j = 1, #probs do
      local item, chance = unpack(probs[j])
      if x < chance then
        if make(item) then
          break
        else
          i = i - 1
          break
        end
      end
      x = x - chance
    end
  end
end
