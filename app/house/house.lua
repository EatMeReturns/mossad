House = class()
House.tag = 'wall'
House.collision = {with = {}}

require 'app/house/config'
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

  --local furthestRoom = room
  --local furthestDis = 0

  for i = 1, self.roomCount do
    -- Pick a source room
    local oldRoom = randomFrom(self.rooms)
    self:createRoom(oldRoom)
  end
end

function House:regenerate(pRoom)
  table.each(self.rooms, function(room, index)
    if math.distance(self:pos(pRoom.x + pRoom.width / 2, pRoom.y + pRoom.height / 2, room.x + room.width / 2, room.y + room.height / 2)) <= self.spawnRange / 2 then
      table.each(room.doors, function(door, index)
        if not door.connected then door:connect() end
      end)
    end
  end)

  table.each(self.rooms, function(room, index)
    if math.distance(self:pos(pRoom.x + pRoom.width / 2, pRoom.y + pRoom.height / 2, room.x + room.width / 2, room.y + room.height / 2)) > self.spawnRange then
      --if self.biome == 'Main' or room.biome ~= self.biome then room:destroy() end
      room:destroy()
    end
  end)

  self:computeTiles()
  self:computeShapes()
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
    self:carveDoor(oldRoom.x + oldWall.x, oldRoom.y + oldWall.y, newRoom.x + newWall.x, newRoom.y + newWall.y, newRoom)

    return true
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

  --map tiles and collision pieces
  self:computeTiles()
  self:computeShapes()
  room:computeCollision(self:pos(room.x, room.y, room.width, room.height))
end

function House:carveDoor(x1, y1, x2, y2, room)
  local dx = math.sign(x2 - x1)
  local dy = math.sign(y2 - y1)

  if dx == 0 then
    self:carve(x1 - self.doorSize, y1, x1 + self.doorSize, y2, room)
  end

  if dy == 0 then
    self:carve(x1, y1 - self.doorSize, x2, y1 + self.doorSize, room)
  end
end

function House:carve(x1, y1, x2, y2, room)
  local dx = math.sign(x2 - x1)
  local dy = math.sign(y2 - y1)

  for y = y1, y2, dy do
    for x = x1, x2, dx do
      self.tiles[x] = self.tiles[x] or {}
      self.tiles[x][y] = self.tiles[x][y] or Tile(room.floorType, x, y, room)
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
          end
        else
          self.tiles[x][y] = nil
        end
      end
    end
  end
end

function House:computeTilesInRoom(room)
  local function get(x, y)
    return self.tiles[x] and self.tiles[x][y]
  end

  for x = room.x, room.x + room.width do
    for y = room.y, room.y + room.height do
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
  x = x + self.cellSize / 2 + (room.width / 2 * self.cellSize)
  y = y + self.cellSize / 2 + (room.height / 2 * self.cellSize)
  ovw.npcs:add((npc)({x = x, y = y, room = room}))
end

function House:spawnEnemiesInRoom(amt, room)
  --local types = {Spiderling, Shade, InkRaven}
  for i = 1, amt do
    local x, y = self:pos(room.x, room.y)
    x = x + self.cellSize / 2 + love.math.random() * ((room.width - 2) * self.cellSize)
    y = y + self.cellSize / 2 + love.math.random() * ((room.height - 2) * self.cellSize)
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
    x = x + self.cellSize / 2 + love.math.random() * ((room.width - 2) * self.cellSize)
    y = y + self.cellSize / 2 + love.math.random() * ((room.height - 2) * self.cellSize)
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