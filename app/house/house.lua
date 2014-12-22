House = class()
House.tag = 'wall'
House.collision = {with = {}}

require 'app/house/houseConfig'
require 'app/house/tiles'
require 'app/house/room'
require 'app/house/roomTypes'

local function randomFrom(t)
  if #t == 0 then return end
  return table.random(t) --t[love.math.random(1, #t)]
end

function House:init()
  --self.roomTypes = {RoomRectangle}
  self.rooms = {}
  self.idCounter = 1

  self.tiles = {}

  self.lightMap = {}

  self.biome = 'Main'

  self.algorithmTimer = .06
  self.doorsToConnect = {}
  self.roomsToDestroy = {}
  self.roomsToCompute = {}
  self.roomsToShape = {}
  self.needShaping = false

  self.shapes = {}
  self.newShapes = {}
  
  self:generate()

  self.depth = 5
  ovw.view:register(self)
end

function House:destroy()
  table.with(self.rooms, 'destroy')
  ovw.collision.hc:remove(unpack(self.shapes))
  ovw.view:unregister(self)
end

function House:update()
  local x1, x2, y1, y2 = self:cell(ovw.view.x, ovw.view.x + ovw.view.w, ovw.view.y, ovw.view.y + ovw.view.h)
  
  for x = x1, x2 do
    for y = y1, y2 do
      if self.tiles[x] and self.tiles[x][y] then
        self.tiles[x][y]:update()
        self.tiles[x][y]:updateLight(x, y)
      end
    end
  end

  self.algorithmTimer = self.algorithmTimer - tickRate
  if self.algorithmTimer <= 0 then
    if #self.doorsToConnect > 0 then
      local room = self.doorsToConnect[1]:connect()
      table.remove(self.doorsToConnect, 1)
      if room then
        table.insert(self.roomsToCompute, room)
        --self:computeTilesInRoom(room)
        --self:computeShapesInRoom(room)
      end
      self.needShaping = true
    elseif #self.roomsToDestroy > 0 then
      self.roomsToDestroy[1]:destroy()
      table.remove(self.roomsToDestroy, 1)
      self.needShaping = true
    elseif #self.roomsToCompute > 0 then
      local room = self.roomsToCompute[1]
      if self.roomsToCompute[1] then
        self:computeTilesInRoom(room)
        --self:computeShapesInRoom(room)
      end
      table.remove(self.roomsToCompute, 1)
      self.needShaping = true
    elseif self.needShaping then
      --self:computeTiles()
      self.roomsToShape = {}
      table.each(self.rooms, function(room, key) table.insert(self.roomsToShape, room) end)
      self.needShaping = false
    elseif #self.roomsToShape > 0 then
      self:computeShapesInRoom(self.roomsToShape[1])
      table.remove(self.roomsToShape, 1)
      if #self.roomsToShape == 0 then
        self:computeShapes()
      end
    end
    self.algorithmTimer = .06
  end

  local crippled = false
  local wounded = false
  table.each(ovw.player.firstAid.bodyParts, function(bodyPart, key) if bodyPart.wounded then wounded = true elseif bodyPart.crippled then crippled = true end end)
  if wounded then self.targetAmbient = {100, 0, 0} elseif crippled then self.targetAmbient = {255, 100, 100} else self.targetAmbient = {255, 255, 255} end

  self.ambientColor[1] = math.lerp(self.ambientColor[1], self.targetAmbient[1], .5 * tickRate)
  self.ambientColor[2] = math.lerp(self.ambientColor[2], self.targetAmbient[2], .5 * tickRate)
  self.ambientColor[3] = math.lerp(self.ambientColor[3], self.targetAmbient[3], .5 * tickRate)
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

function House.pos(self, x, ...)
  if not x then return end
  return x * House.cellSize, House.pos(self, ...)
end

function House:applyLight(light, type)
  if love.math.random() < (light.flicker or 1) then
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
end

function House:sealRoom(room)
  local x, y, w, h, shape
  local border = .5 * self.cellSize

  x, y, w, h = self:pos(room.x - 1, room.y - 1, room.width + 1, room.height + 1)

  if not room.sealShapes then room.sealShapes = {} end

  shape = ovw.collision.hc:addRectangle(x, y, w, border)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(room.sealShapes, shape)
  --table.insert(self.shapes, shape)
  
  shape = ovw.collision.hc:addRectangle(x, y, border, h)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(room.sealShapes, shape)
  --table.insert(self.shapes, shape)

  shape = ovw.collision.hc:addRectangle(x + w + border, y, border, h)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(room.sealShapes, shape)
  --table.insert(self.shapes, shape)

  shape = ovw.collision.hc:addRectangle(x, y + h + border, w, border)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(room.sealShapes, shape)
  --table.insert(self.shapes, shape)
end

function House:openRoom(room)
  if room.sealShapes then table.each(room.sealShapes, function(shape, key) ovw.collision.hc:remove(shape) end) room.sealShapes = nil end
end

function House:generate()
  
  local function get(x, y)
    return self.tiles[x] and self.tiles[x][y]
  end

  local room = MainRectangle()
  room.x, room.y = 100, 100
  self:addRoom(room, 0, 0)
  ovw.pickups:add(Pickup({x = (room.x + room.width / 2) * self.cellSize + love.math.random() * 300 - 150, y = (room.y + room.height / 2) * self.cellSize + love.math.random() * 300 - 150, itemType = Pistol, room = room}))

  for i = 1, self.roomCount do
    -- Pick a source room
    local oldRoom = randomFrom(self.rooms)
    self:createRoom(oldRoom)
  end

  self:computeTiles()
  self:computeShapes()
end

function House:regenerate(pRoom)
  local pRoomX = self:pos(pRoom.x + pRoom.width / 2)
  local pRoomY = self:pos(pRoom.y + pRoom.height / 2)

  table.each(self.rooms, function(room, index)
    local dis = math.distance(pRoomX, pRoomY, self:pos(room.x + room.width / 2, room.y + room.height / 2))
    if dis <= self.spawnRange / 2 then
      table.each(room.doors, function(door, index)
        if not door.connected then table.insert(self.doorsToConnect, door) end--door:connect() end
      end)
    elseif dis > self.spawnRange then
      --if self.biome == 'Main' or room.biome ~= self.biome then room:destroy() end
      table.insert(self.roomsToDestroy, room)--room:destroy()
    end
  end)

  --self:computeTiles()
  --self:computeShapes()
end

function House:createRoom(oldRoom, oldDirection)
  -- Pick a wall from the old room to add the newRoom to
  local oldWall = oldDirection and oldRoom:randomWall(oldDirection) or oldRoom:randomWall()
  oldDirection = oldDirection or oldWall.direction

  -- Create the door between the rooms
  local doorMap = {}
  doorMap[oldDirection] = oldRoom

  -- Create a destination room
  local newRoom = (roomSpawnTables[self.biome]:pick()[1])(oldDirection) --randomFrom(self.roomTypes)()

  -- Generate unconnected doors on spawn
  newRoom:spawnDoors(oldDirection)

  -- Select the associated wall from the new room
  local newWall = newRoom:randomWall(oppositeDirections[oldWall.direction])

  -- Position the new room
  newRoom:move(oldRoom.x + oldWall.x - newWall.x, oldRoom.y + oldWall.y - newWall.y)
  newRoom:move(unpack(directionOffsets[oldWall.direction]))

  -- Add the door to the associated wall.
  doorMap[newWall.direction] = newRoom
  local door = Door(doorMap)

  -- If it doesn't overlap with another room, add it.
  if self:collisionTest(newRoom) then
    oldRoom:addDoor(door, oldWall.direction)
    newRoom:addDoor(door, newWall.direction)

    self:addRoom(newRoom, newRoom.enemySpawnTable:pick()[1], newRoom.pickupSpawnTable:pick()[1])
    local dx, dy = math.sign(oldRoom.x - newRoom.x), math.sign(oldRoom.y - newRoom.y)
    if oldWall.direction == 'north' or oldWall.direction == 'south' then
      dx = 0
    else
      dy = 0
    end
    self:carveDoor(
      oldRoom.x + math.round(oldRoom.width / 2) * dx + oldWall.x,
      oldRoom.y + math.round(oldRoom.height / 2) * dy + oldWall.y,
      newRoom.x - math.round(newRoom.width / 2) * dx + newWall.x,
      newRoom.y - math.round(newRoom.height / 2) * dy + newWall.y,
      newRoom, door
    )

    return true, newRoom
  else
    return false
  end
end

function House:removeRoom(room)
  self.rooms[room.id] = nil
end

function House:addRoom(room, enemyCount, pickupCount)
  --init room id
  table.insert(self.rooms, self.idCounter, room)
  room.id = self.idCounter
  self.idCounter = self.idCounter + 1

  --the room needs tiles
  room:carveRoom(self.tiles)

  --spawn room contents
  if room.npcSpawnTable then self:spawnNPCsInRoom(room.npcSpawnTable:pick()[1], room) end
  self:spawnEnemiesInRoom(enemyCount, room)
  self:spawnPickupsInRoom(pickupCount, room)

  --map collision pieces
  room:computeCollision()
end

function House:carveDoor(x1, y1, x2, y2, room, door)
  local dx = math.sign(x2 - x1)
  local dy = math.sign(y2 - y1)

  if dx == 0 then
    table.each(House.carveRect(x1 - self.doorSize, y1, x1 + self.doorSize, y2, room, self.tiles), function(tile, key) table.insert(door.tiles, tile) end)
  end

  if dy == 0 then
    table.each(House.carveRect(x1, y1 - self.doorSize, x2, y1 + self.doorSize, room, self.tiles), function(tile, key) table.insert(door.tiles, tile) end)
  end

  if x2 < x1 then x1, x2 = x2, x1 end
  if y2 < y1 then y1, y2 = y2, y1 end
  self:computeTilesInDoor(x1 - self.doorSize, y1 - self.doorSize, x2 + self.doorSize, y2 + self.doorSize)
end

function House.carveRect(x1, y1, x2, y2, room, tileMap)
  local dx = math.sign(x2 - x1)
  local dy = math.sign(y2 - y1)
  local carvedTiles = {}

  for y = y1, y2, dy do
    for x = x1, x2, dx do
      tileMap[x] = tileMap[x] or {}
      if not tileMap[x][y] then
       tileMap[x][y] = Tile(room.floorType, x, y, room)
        table.insert(carvedTiles, tileMap[x][y])
      end
    end
  end

  return carvedTiles
end

function House.carveRound(cx, cy, xradius, yradius, room, tileMap)
  for y = cy - yradius - 1, cy + yradius + 1 do
    for x = cx - xradius - 1, cx + xradius + 1 do
      local dis, dir = math.vector(cx - .5, cy - .5, x, y)
      local radAtAngle = math.abs(xradius * yradius / math.sqrt(xradius ^ 2 * math.sin(dir) ^ 2 + yradius ^ 2 * math.cos(dir) ^ 2))
      if dis <= radAtAngle + 1 then
        tileMap[x] = tileMap[x] or {}
        tileMap[x][y] = tileMap[x][y] or Tile(room.floorType, x, y, room)
      end
    end
  end
end

function House:collisionTest(room)
  local padding = 0 --self.roomSpacing - 1
  --if getmetatable(room).__index == BossRoom then padding = padding + 3 end
  for x = room.x - padding, room.x + room.width + padding do
    for y = room.y - padding, room.y + room.height + padding do
      if self.tiles[x] and self.tiles[x][y] then return false end
    end
  end

  return true --no other room colliding with room!
end

function House:computeTiles()
  local function get(x, y)
    return self.tiles[x] and self.tiles[x][y]
  end

  for x in pairs(self.tiles) do
    if table.count(self.tiles[x]) == 0 then 
      self.tiles[x] = nil
    else
      for y in pairs(self.tiles[x]) do
        if get(x, y) then
          if self.rooms[self.tiles[x][y].roomID] then
            local n, s, e, w = get(x, y - 1), get(x, y + 1), get(x + 1, y), get(x - 1, y)
            local nw, ne = get(x - 1, y - 1), get(x + 1, y - 1)
            local sw, se = get(x - 1, y + 1), get(x + 1, y + 1)
            if w and e and not n and sw and se then
              self.tiles[x][y].tile = 'n'
            elseif w and e and not s and nw and ne then
              self.tiles[x][y].tile = 's'
            elseif n and s and not e and nw and sw then
              self.tiles[x][y].tile = 'e'
            elseif n and s and not w and ne and se then
              self.tiles[x][y].tile = 'w'
            elseif e and s and se and ((not w and not n) or (w and nw and not sw and not n) or (n and nw and not ne and not w)) then--e and s and not w and not n then
              self.tiles[x][y].tile = 'nw'
            elseif w and s and sw and ((not e and not n) or (e and ne and not se and not n) or (n and ne and not nw and not e)) then--w and s and not e and not n then
              self.tiles[x][y].tile = 'ne'
            elseif e and n and ne and ((not w and not s) or (w and sw and not nw and not s) or (s and sw and not se and not w)) then--e and n and not w and not s then
              self.tiles[x][y].tile = 'sw'
            elseif w and n and nw and ((not e and not s) or (e and se and not ne and not s) or (s and se and not sw and not e)) then--w and n and not e and not s then
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
            else
              self.tiles[x][y].tile = 'none'
              self.tiles[x][y] = nil
            end
          else
            self.tiles[x][y] = nil
          end
        end
      end
    end
  end
end

function House:computeTilesInRoom(room)
  local function get(x, y)
    return self.tiles[x] and self.tiles[x][y]
  end

  for x = room.x - 5, room.x + room.width + 5 do
    if table.count(self.tiles[x]) == 0 then 
      self.tiles[x] = nil
    else
      for y = room.y - 5, room.y + room.height + 5 do
        if get(x, y) then
          if self.rooms[self.tiles[x][y].roomID] then
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
            elseif e and s and se and ((not w and not n) or (w and nw and not sw and not n) or (n and nw and not ne and not w)) then
              self.tiles[x][y].tile = 'nw'
            elseif w and s and sw and ((not e and not n) or (e and ne and not se and not n) or (n and ne and not nw and not e)) then
              self.tiles[x][y].tile = 'ne'
            elseif e and n and ne and ((not w and not s) or (w and sw and not nw and not s) or (s and sw and not se and not w)) then
              self.tiles[x][y].tile = 'sw'
            elseif w and n and nw and ((not e and not s) or (e and se and not ne and not s) or (s and se and not sw and not e)) then
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
            else
              self.tiles[x][y].tile = 'none'
              self.tiles[x][y] = nil
            end
          else
            self.tiles[x][y] = nil
          end
        end
      end
    end
  end
end

function House:computeTilesInDoor(x1, y1, x2, y2)
  local function get(x, y)
    return self.tiles[x] and self.tiles[x][y]
  end

  for x = x1 - 3, x2 + 3 do
    if table.count(self.tiles[x]) == 0 then 
      self.tiles[x] = nil
    else
      for y = y1 - 3, y2 + 3 do
        if get(x, y) then
          if self.rooms[self.tiles[x][y].roomID] then
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
            elseif e and s and se and ((not w and not n) or (w and nw and not sw and not n) or (n and nw and not ne and not w)) then
              self.tiles[x][y].tile = 'nw'
            elseif w and s and sw and ((not e and not n) or (e and ne and not se and not n) or (n and ne and not nw and not e)) then
              self.tiles[x][y].tile = 'ne'
            elseif e and n and ne and ((not w and not s) or (w and sw and not nw and not s) or (s and sw and not se and not w)) then
              self.tiles[x][y].tile = 'sw'
            elseif w and n and nw and ((not e and not s) or (e and se and not ne and not s) or (s and se and not sw and not e)) then
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
            else
              self.tiles[x][y].tile = 'none'
              self.tiles[x][y] = nil
            end
          else
            self.tiles[x][y] = nil
          end
        end
      end
    end
  end
end

function House:computeShapesInRoom(room)
  --table.each(self.shapes, function(shape, key) ovw.collision.hc:remove(shape) end)
  --self.shapes = {}

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

  for x = room.x - 5, room.x + room.width + 5 do
    for y = room.y - 5, room.y + room.height + 5 do
      if tiles[x] and tiles[x][y] and tiles[x][y].tile ~= 'c' then
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
        table.insert(self.newShapes, shape)
      end
    end
  end
end

function House:computeShapes()
  table.each(self.shapes, function(shape, key) ovw.collision.hc:remove(shape) end)
  self.shapes = {}
  table.each(self.newShapes, function(shape, key) table.insert(self.shapes, shape) end)
  self.newShapes = {}
end

function House:forceComputeShapes()
  table.each(self.shapes, function(shape, key) ovw.collision.hc:remove(shape) end)
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

function House:spawnNPCsInRoom(npc, room)
  local x, y = self:pos(room.x, room.y)
  if room.buildShape == 'circle' then
    local dir = love.math.random() * math.pi * 2 - math.pi
    local dis = love.math.random() * (room.radius - 2)
    x = self:pos(room.x + room.width / 2) + self:pos(math.cos(dir) * dis)
    y = self:pos(room.y + room.height / 2) + self:pos(math.sin(dir) * dis)
  else
    x = x + self.cellSize / 2 + love.math.random() * ((room.width - 2) * self.cellSize)
    y = y + self.cellSize / 2 + love.math.random() * ((room.height - 2) * self.cellSize)
  end
  ovw.npcs:add((npc)({x = x, y = y, room = room}))
end

function House:spawnEnemiesInRoom(amt, room)
  --local types = {Spiderling, Shade, InkRaven}
  for i = 1, amt do
    local x, y = self:pos(room.x, room.y)
    if room.buildShape == 'circle' then
      local dir = love.math.random() * math.pi * 2 - math.pi
      local dis = love.math.random() * (room.radius - 2)
      x = self:pos(room.x + room.width / 2) + self:pos(math.cos(dir) * dis)
      y = self:pos(room.y + room.height / 2) + self:pos(math.sin(dir) * dis)
    else
      x = x + self.cellSize / 2 + love.math.random() * ((room.width - 2) * self.cellSize)
      y = y + self.cellSize / 2 + love.math.random() * ((room.height - 2) * self.cellSize)
    end
    local enemyType = randomFrom(room.enemyTypes)
    if enemyType == Spiderling then
      for i = 1, 2 + math.ceil(love.math.random() * 2) do
        ovw.enemies:add(Spiderling(x, y, room))
        x = x + love.math.random() * self.cellSize - self.cellSize / 2
        y = y + love.math.random() * self.cellSize - self.cellSize / 2
      end
    else
      ovw.enemies:add(enemyType(x, y, room))
    end
  end
end

function House:spawnPickupsInRoom(amt, room)
  local function make(i)
    local x, y = self:pos(room.x, room.y)
    if room.buildShape == 'circle' then
      local dir = love.math.random() * math.pi * 2 - math.pi
      local dis = love.math.random() * (room.radius - 2)
      x = self:pos(room.x + room.width / 2) + self:pos(math.cos(dir) * dis)
      y = self:pos(room.y + room.height / 2) + self:pos(math.sin(dir) * dis)
    else
      x = x + self.cellSize / 2 + love.math.random() * ((room.width - 2) * self.cellSize)
      y = y + self.cellSize / 2 + love.math.random() * ((room.height - 2) * self.cellSize)
    end
    ovw.pickups:add(Pickup({x = x, y = y, itemType = i, room = room}))
    return true
  end

  if amt > 2 then
    amt = amt - 2
    make((makeLootTable('Rare'))[1])
  end

  for i = 1, amt do
    table.each(makeLootTable('Common'), function(v, k) make(v) end)
  end
end