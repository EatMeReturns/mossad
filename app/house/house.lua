House = class()
House.tag = 'wall'
House.collision = {with = {}}

require 'app/house/houseConfig'
require 'app/house/tiles'
require 'app/house/room'
require 'app/house/roomTypes'

local function randomFrom(t)
  if #t == 0 then return end
  return table.random(t)
end

function House:init()
  self.rooms = {}
  self.idCounter = 1

  self.floors = {}
  self.currentFloor = 0 --0 is ground, negatives for underground
  self:createFloor(self.currentFloor, true)
  self.tiles = {}
  self.drawRanges = {xMin = 0, xMax = 0, yMin = 0, yMin = 0}

  self.biome = 'Main'
  self.biomeCounter = 0

  self.algorithmTimer = .001
  self.algorithmTimerMax = .001 --option to change this to reduce algorithm lag
  self.doorsToConnect = {}
  self.roomsToFill = {}
  self.roomsToDestroy = {}
  self.doorsToDisconnect = {}
  self.doorsToCarve = {}
  self.doorsToCompute = {}
  self.roomsToCompute = {}
  self.roomsToShape = {}
  self.needShaping = false
  self.floorReady = false
  self.miniBossCounter = 0
  self.miniBossTrigger = 40

  self.staircaseTimer = 3
  self.staircaseReady = false

  self.shapes = {}
  self.newShapes = {}
  
  self:generate()

  self.depth = DrawDepths.house
  ovw.view:register(self)
end

function House:destroy()
  table.with(self.rooms, 'destroy')
  ovw.collision.hc:remove(unpack(self.shapes))
  ovw.view:unregister(self)
end

function House:removeRoom(room)
  self.rooms[room.id] = nil
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

--================================================================================--
--UTILITIES ------------------------------------------------------------------------
--================================================================================--

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

function House.cell(self, x, ...)
  if not x then return end
  return math.round((x - House.halfCell) / House.cellSize), House.cell(self, ...)
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
  
  shape = ovw.collision.hc:addRectangle(x, y, border, h)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(room.sealShapes, shape)

  shape = ovw.collision.hc:addRectangle(x + w + border, y, border, h)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(room.sealShapes, shape)

  shape = ovw.collision.hc:addRectangle(x, y + h + border, w, border)
  ovw.collision.hc:setPassive(shape)
  shape.owner = self
  table.insert(room.sealShapes, shape)
end

function House:openRoom(room)
  if room.sealShapes then table.each(room.sealShapes, function(shape, key) ovw.collision.hc:remove(shape) end) room.sealShapes = nil end
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

--================================================================================--
--ALGORITHM ------------------------------------------------------------------------
--================================================================================--

function House:update()

  --Lighting

  local x1, x2, y1, y2 = self:cell(ovw.view.x, ovw.view.x + ovw.view.w, ovw.view.y, ovw.view.y + ovw.view.h)
  self.drawRanges = {xMin = x1, xMax = x2, yMin = y1, yMax = y2}

  for x = x1, x2 do
    for y = y1, y2 do
      if self.tiles[x] and self.tiles[x][y] then
        self.tiles[x][y]:update()
        self.tiles[x][y]:updateLight()
      end
    end
  end

  --Staircase Timer

  if not self.staircaseReady then
    self.staircaseTimer = self.staircaseTimer - tickRate
    if self.staircaseTimer <= 0 then
      self.staircaseReady = true
      self.staircaseTimer = 3
    end
  end

  --Ambience

  local crippled = false
  local wounded = false
  local bodyPart = ovw.player.firstAid.bodyParts[1]
  if bodyPart.wounded then wounded = true
  elseif bodyPart.crippled then crippled = true end
  if wounded then self.targetAmbient = {100, 0, 0} elseif crippled then self.targetAmbient = {255, 100, 100} else self.targetAmbient = {255, 255, 255} end

  self.ambientColor[1] = math.lerp(self.ambientColor[1], self.targetAmbient[1], .5 * tickRate)
  self.ambientColor[2] = math.lerp(self.ambientColor[2], self.targetAmbient[2], .5 * tickRate)
  self.ambientColor[3] = math.lerp(self.ambientColor[3], self.targetAmbient[3], .5 * tickRate)

  --Algorithm

  self.algorithmTimer = self.algorithmTimer - tickRate
  if self.algorithmTimer <= 0 then
    self.floorReady = false
    if #self.doorsToConnect > 0 then --print('connecting')
      local room = self.doorsToConnect[1]:connect()
      table.remove(self.doorsToConnect, 1)
      if room then
        table.insert(self.roomsToCompute, room)
      end
      self.needShaping = true

    elseif #self.roomsToFill > 0 then --print('filling')
      local room = self.roomsToFill[1]
      self:fillRoom(room, room.enemySpawnTable:pick()[1], room.pickupSpawnTable:pick()[1])
      table.remove(self.roomsToFill, 1)
      self.needShaping = true

    elseif #self.roomsToDestroy > 0 then --print('destroying')
      self.roomsToDestroy[1]:destroy()
      table.remove(self.roomsToDestroy, 1)
      self.needShaping = true

    elseif #self.doorsToDisconnect > 0 then --print('disconnecting')
      self.doorsToDisconnect[1]:disconnect()
      table.remove(self.doorsToDisconnect, 1)
      self.needShaping = true

    elseif #self.doorsToCarve > 0 then --print('carving doors')
      self:carveDoor(self.doorsToCarve[1])
      table.remove(self.doorsToCarve, 1)
      self.needShaping = true

    elseif #self.doorsToCompute > 0 then --print('computing doors')
      self:computeTilesInDoor(self.doorsToCompute[1])
      table.remove(self.doorsToCompute, 1)
      self.needShaping = true

    elseif #self.roomsToCompute > 0 then --print('computing rooms')
      local room = self.roomsToCompute[1]
      if self.roomsToCompute[1] then
        self:computeTilesInRoom(room)
      end
      table.remove(self.roomsToCompute, 1)
      self.needShaping = true

    elseif self.needShaping then --print('start shaping') --This is somehow missing out on a recently-traversed room. Maybe the room isn't added to self.rooms yet?
      self.roomsToShape = {}
      table.each(self.rooms, function(room, key) table.insert(self.roomsToShape, room) end)
      self.needShaping = false

    elseif #self.roomsToShape > 0 then --print('shaping')
      self:computeShapesInRoom(self.roomsToShape[1])
      table.remove(self.roomsToShape, 1)
      if #self.roomsToShape == 0 then --print('done')
        self:computeShapes()
      end

    else
      self.floorReady = true

    end
    self.algorithmTimer = self.algorithmTimerMax
  end
end

function House:generate()
  local room = MainRectangle()
  room.event = Event()
  room.npcSpawnTable = nil
  room.x, room.y = 100, 100
  self:addRoom(room, 0, 0)
  ovw.pickups:add(Pickup({x = (room.x + room.width / 2) * self.cellSize + love.math.random() * 300 - 150, y = (room.y + room.height / 2) * self.cellSize + love.math.random() * 300 - 150, itemType = Pistol, room = room}))
  self:sealRoom(room)

  room:spawnDoors(room:randomWall())
  self:computeTilesInRoom(room)
  self:regenerate(room)
end

function House:regenerate(pRoom)
  --calculate player room's center
  local pRoomX = self:pos(pRoom.x + pRoom.width / 2)
  local pRoomY = self:pos(pRoom.y + pRoom.height / 2)

  --calculate player room's pseudo-radius
  local pRoomRadius = 0
  if pRoom.buildShape == 'circle' then pRoomRadius = self:pos(pRoom.radius)
  elseif pRoom.buildShape == 'diamond' then pRoomRadius = self:pos((pRoom.width + pRoom.height) / 4)
  else pRoomRadius = self:pos((pRoom.width > pRoom.height and pRoom.width or pRoom.height) / 2) end

  table.each(self.rooms, function(room, index)
    --always compute doors for the current room
    local dis, dir = 0, 0

    if room ~= pRoom then
      --calculate distance
      dis, dir = math.vector(pRoomX, pRoomY, self:pos(room.x + room.width / 2, room.y + room.height / 2))

      --calculate other room's pseudo-radius
      local roomRadius = 0
      if room.buildShape == 'circle' then
        roomRadius = self:pos(room.radius)
      elseif room.buildShape == 'diamond' then
        dir = math.abs(dir)
        if dir < math.pi / 4 or dir > math.pi * 3 / 4 then dir = room.width / 2 else dir = room.height / 2 end
        roomRadius = self:pos(dir / 2)
      else --rectangle
        dir = math.abs(dir)
        if dir < math.pi / 4 or dir > math.pi * 3 / 4 then dir = room.width / 2 else dir = room.height / 2 end
        roomRadius = self:pos(dir / 2)
      end

      --reduce distance by pseudo-radii
      dis = dis - pRoomRadius
      dis = dis - roomRadius
    end

    --compare distance to spawn/destroy ranges
    if dis <= self.spawnRange / 2 then
      table.each(room.doors, function(door, index)
        if not door.connected then table.insert(self.doorsToConnect, door) end
      end)
    elseif dis > self.spawnRange then
      table.insert(self.roomsToDestroy, room)
    end
  end)
end

function House:createRoom(oldRoom, oldDirection)
  -- Pick a wall from the old room to add the newRoom to
  local oldWall = oldDirection and oldRoom:randomWall(oldDirection) or oldRoom:randomWall()
  oldDirection = oldDirection or oldWall.direction

  -- Create the door between the rooms
  --local doorMap = {}
  --doorMap[oldDirection] = oldRoom
  local oldDoor = oldRoom.doors[oldDirection]

  -- Create a destination room
  local newRoom = nil
  if biomeBossTriggerCounts[self.biome] then
    if self.biomeCounter >= biomeBossTriggerCounts[self.biome][2] then
      --max
      newRoom = (roomSpawnTables[self.biome .. 'BossOnly']:pick()[1])(oldDirection)
    elseif self.biomeCounter >= biomeBossTriggerCounts[self.biome][1] then
      --min
      newRoom = (roomSpawnTables[self.biome .. 'Boss']:pick()[1])(oldDirection)
    else
      --not ready for boss yet
      newRoom = (roomSpawnTables[self.biome]:pick()[1])(oldDirection)
    end
  else
    --no boss
    newRoom = (roomSpawnTables[self.biome]:pick()[1])(oldDirection)
  end

  -- Generate unconnected doors on spawn
  newRoom:spawnDoors(oldDirection)

  -- Select the associated wall from the new room
  local newWall = newRoom:randomWall(oppositeDirections[oldWall.direction])

  -- Position the new room
  newRoom:move(oldRoom.x + oldWall.x - newWall.x, oldRoom.y + oldWall.y - newWall.y)
  newRoom:move(unpack(directionOffsets[oldWall.direction]))

  -- Add the door to the associated wall.
  --doorMap[newWall.direction] = newRoom
  --local door = Door(doorMap)
  oldDoor.rooms[newWall.direction] = newRoom

  -- If it doesn't overlap with another room, add it.
  if self:collisionTest(newRoom) then
    --oldRoom:addDoor(door, oldWall.direction)
    newRoom:addDoor(oldDoor, newWall.direction)

    self:addRoom(newRoom)
    local dx, dy = math.sign(oldRoom.x - newRoom.x), math.sign(oldRoom.y - newRoom.y)
    if oldWall.direction == 'north' or oldWall.direction == 'south' then
      dx = 0
    else
      dy = 0
    end

    oldDoor.cx1 = oldRoom.x + math.round(oldRoom.width / 2) * dx + oldWall.x
    oldDoor.cy1 = oldRoom.y + math.round(oldRoom.height / 2) * dy + oldWall.y
    oldDoor.cx2 = newRoom.x - math.round(newRoom.width / 2) * dx + newWall.x
    oldDoor.cy2 = newRoom.y - math.round(newRoom.height / 2) * dy + newWall.y
    table.insert(self.doorsToCarve, oldDoor)

    --self:carveDoor(
    --  oldRoom.x + math.round(oldRoom.width / 2) * dx + oldWall.x,
    --  oldRoom.y + math.round(oldRoom.height / 2) * dy + oldWall.y,
    --  newRoom.x - math.round(newRoom.width / 2) * dx + newWall.x,
    --  newRoom.y - math.round(newRoom.height / 2) * dy + newWall.y,
    --  newRoom, door
    --)

    return true, newRoom
  else
    return false
  end
end

function House:addRoom(room)
  --init room id
  table.insert(self.rooms, self.idCounter, room)
  room.id = self.idCounter
  self.idCounter = self.idCounter + 1
  self.miniBossCounter = self.miniBossCounter + 1

  --the room needs tiles
  room:carveRoom(self.tiles)

  --map collision pieces
  room:computeCollision()

  table.insert(self.roomsToFill, room)
end

function House:fillRoom(room, enemyCount, pickupCount)
  --spawn room contents
  if room.npcSpawnTable then self:spawnNPCsInRoom(room.npcSpawnTable:pick()[1], room) end
  self:spawnEnemiesInRoom(enemyCount, room)
  if self.miniBossCounter >= self.miniBossTrigger then
    self.miniBossCounter = 0
    self:spawnEnemiesInRoom(1, room, randomFrom(enemyTables.miniBosses))
  end
  self:spawnPickupsInRoom(pickupCount, room)
  room:spawnFurniture()
end

function House:carveDoor(door)
  local room = door.rooms[door.newestDirection]
  local x1, y1, x2, y2 = door.cx1, door.cy1, door.cx2, door.cy2
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
      if dx == 0 then break end
    end
    if dy == 0 then break end
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

function House.carveDiamond(rx, ry, rw, rh, room, tileMap)
  local dimensionsRatio = (rh / rw)
  for x = rx, rx + rw do
    local tx = math.round(rw / 2 + .5) - math.abs(x - rx - math.round(rw / 2 - .5))
    for y = ry + math.round(rh / 2 - .5) - tx * dimensionsRatio, ry + math.round(rh / 2 - .5) + tx * dimensionsRatio do
      tileMap[x] = tileMap[x] or {}
      tileMap[x][y] = tileMap[x][y] or Tile(room.floorType, x, y, room)
    end
  end
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
  local function get(x, y) if self.tiles[x] and self.tiles[x][y] then return true else return false end end

  for x = room.x - 5, room.x + room.width + 5 do
    if table.count(self.tiles[x]) == 0 then self.tiles[x] = nil else
      for y = room.y - 5, room.y + room.height + 5 do
        local tile = self.tiles[x][y]
        if tile then
          if self.rooms[tile.roomID] then
            local n, s, e, w = get(x, y - 1), get(x, y + 1), get(x + 1, y), get(x - 1, y)
            local nw, ne = get(x - 1, y - 1), get(x + 1, y - 1)
            local sw, se = get(x - 1, y + 1), get(x + 1, y + 1)
            local left = w and nw and sw
            local right = e and ne and se
            local top = n and nw and ne
            local bottom = s and sw and se
            local horizontal = w and e
            local vertical = n and s
            local slash = sw and ne
            local notslash = not (sw or ne)
            local backslash = nw and se
            local notbackslash = not (nw or se)
            local sides = horizontal and vertical
            local corners = slash and backslash
            local box = sides and corners
            local topleft = n and w and nw
            local nottopleft = not (n or w or nw)
            local topright = n and e and ne
            local nottopright = not (n or e or ne)
            local bottomleft = s and w and sw
            local notbottomleft = not (s or w or sw)
            local bottomright = s and e and se
            local notbottomright = not (s or e or se)

            if box then --center
              tile.tile = 'c'
            elseif sides and ne and nw and se then --i southwest
              tile.tile = 'isw'
            elseif sides and ne and nw and sw then --i southeast
              tile.tile = 'ise'
            elseif sides and se and nw and sw then --i northeast
              tile.tile = 'ine'
            elseif sides and ne and sw and se then --i northwest
              tile.tile = 'inw'
            elseif topleft and not bottomright and not (sw and s) and not (ne and e) then --southeast
              tile.tile = 'se'
            elseif topright and not bottomleft and not (se and s) and not (nw and w) then --southwest
              tile.tile = 'sw'
            elseif bottomleft and not topright and not (nw and n) and not (se and e) then --northeast
              tile.tile = 'ne'
            elseif bottomright and not topleft and not (ne and n) and not (sw and w) then --northwest
              tile.tile = 'nw'
            elseif topleft and bottomright and notslash then --double i /
              tile.tile = 'c' --TILE DNE
            elseif topright and bottomleft and notbackslash then --double i \
              tile.tile = 'c' --TILE DNE
            elseif left and vertical then --east
              tile.tile = 'e'
            elseif right and vertical then --west
              tile.tile = 'w'
            elseif top and horizontal then --south
              tile.tile = 's'
            elseif bottom and horizontal then --north
              tile.tile = 'n'
            else --none
              tile.tile = 'none'
              tile:destroy()
            end
          else
            --tile's room doesn't exist.
            tile:destroy()
          end
        else
          --no tile at this position.
        end
      end
    end
  end
end

function House:computeTilesInRoom2(room)
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
  local tiles = {}
  for x in pairs(self.tiles) do
    tiles[x] = tiles[x] or {}
    for y in pairs(self.tiles[x]) do
      local tile = self.tiles[x][y]
      tiles[x][y] = {tile = tile.tile, traverseTable = {}}
    end
  end
  local function get(x, y) return tiles[x] and tiles[x][y] end --does the tile exist?

  local opposites = {
          north_left = 'south_left',
          north_right = 'south_right',
          south_left = 'north_left',
          south_right = 'north_right',
          west_bottom = 'east_bottom',
          west_top = 'east_top',
          east_bottom = 'west_bottom',
          east_top = 'west_top'
        }

  local algorithmBlocks = { --direction is direction to traverse in

      c = {traverseMax = 0, pos = {},
            direction = {}, size = 0},

      none = {traverseMax = 0, pos = {},
            direction = {}, size = 0},

      ---

      w = {traverseMax = 1, pos = {},
            direction = {'north_left', 'south_left'}, size = 1},

      e = {traverseMax = 1, pos = {},
            direction = {'north_right', 'south_right'}, size = 1},

      n = {traverseMax = 1, pos = {},
            direction = {'west_top', 'east_top'}, size = 1},

      s = {traverseMax = 1, pos = {},
            direction = {'west_bottom', 'east_bottom'}, size = 1},

      ---                                pos should be the far corner and the lesser corner
      
      nw = {traverseMax = 2, pos = {south_left = {x = 0, y = 0}, east_top = {x = 0, y = 0}},
            direction = {'south_left', 'east_top'}, size = 1},

      ne = {traverseMax = 2, pos = {south_right = {x = .5, y = 0}, west_top = {x = 1, y = 0}},
            direction = {'south_right', 'west_top'}, size = 1},

      se = {traverseMax = 2, pos = {north_right = {x = .5, y = 1}, west_bottom = {x = 1, y = .5}},
            direction = {'north_right', 'west_bottom'}, size = 1},

      sw = {traverseMax = 2, pos = {north_left = {x = 0, y = 1}, east_bottom = {x = 0, y = .5}},
            direction = {'north_left', 'east_bottom'}, size = 1},

      ---

      inw = {traverseMax = 2, pos = {north_left = {x = 0, y = .5}, west_top = {x = .5, y = 0}},
            direction = {'north_left', 'west_top'}, size = .5},

      ine = {traverseMax = 2, pos = {north_right = {x = .5, y = .5}, east_top = {x = .5, y = 0}},
            direction = {'north_right', 'east_top'}, size = .5},

      ise = {traverseMax = 2, pos = {south_right = {x = .5, y = .5}, east_bottom = {x = .5, y = .5}},
            direction = {'south_right', 'east_bottom'}, size = .5},

      isw = {traverseMax = 2, pos = {south_left = {x = 0, y = .5}, west_bottom = {x = .5, y = .5}},
            direction = {'south_left', 'west_bottom'}, size = .5}

    }

  for x = room.x - 5, room.x + room.width + 5 do --for tiles in and around room, do
    for y = room.y - 5, room.y + room.height + 5 do
      local tile = get(x, y)
      if tile then --if tile exists, then
        local block = algorithmBlocks[tile.tile]
        if block.traverseMax > 1 then --if corner piece, then
          while table.count(tile.traverseTable) < block.traverseMax do --while not done crafting, do
            local direction = 1
            while true do --get direction
              if not table.has(tile.traverseTable, block.direction[direction]) then
                direction = block.direction[direction]
                table.insert(tile.traverseTable, direction)
                break
              else
                direction = direction + 1
              end
            end

            local length = block.size
            local currentX, currentY = x, y
            local shapeCoords = {x1 = 0, y1 = 0, x2 = 0, y2 = 0}

            if direction == 'west_top' or direction == 'west_bottom' then --shoot west

              while true do
                local nextTile = get(currentX - 1, currentY)
                if not nextTile then
                  --no tile, we're done here. also, an error has occurred.
                  break
                else
                  local nextBlock = algorithmBlocks[nextTile.tile]
                  local sourceDirection = opposites[direction]
                  if table.has(nextBlock.direction, sourceDirection) then
                    --the tiles synchronize!
                    if not table.has(nextTile.traverseTable, sourceDirection) then
                      --the next tile hasn't already been traversed in this direction!
                      table.insert(nextTile.traverseTable, sourceDirection)
                      length = length + nextBlock.size
                      if table.has(nextBlock.direction, direction) then
                        --keep traveling in this direction!
                        currentX = currentX - 1
                      else
                        --we've hit the end.
                        break
                      end
                    else
                      --the tile we're shooting from should already have been traversed
                      --in this direction. an error has occurred. (how'd you do that?)
                      break
                    end
                  else
                    --we've run in to a non-syncing tile. an error has occurred.
                    break
                  end
                end
              end --get the shape's vertices
              shapeCoords = {x1 = x + block.pos[direction].x, y1 = y + block.pos[direction].y,
                             x2 = -length, y2 = .5}

            elseif direction == 'east_top' or direction == 'east_bottom' then --shoot east

              while true do
                local nextTile = get(currentX + 1, currentY)
                if not nextTile then
                  --no tile, we're done here. also, an error has occurred.
                  break
                else
                  local nextBlock = algorithmBlocks[nextTile.tile]
                  local sourceDirection = opposites[direction]
                  if table.has(nextBlock.direction, sourceDirection) then
                    --the tiles synchronize!
                    if not table.has(nextTile.traverseTable, sourceDirection) then
                      --the next tile hasn't already been traversed in this direction!
                      table.insert(nextTile.traverseTable, sourceDirection)
                      length = length + nextBlock.size
                      if table.has(nextBlock.direction, direction) then
                        --keep traveling in this direction!
                        currentX = currentX + 1
                      else
                        --we've hit the end.
                        break
                      end
                    else
                      --the tile we're shooting from should already have been traversed
                      --in this direction. an error has occurred. (how'd you do that?)
                      break
                    end
                  else
                    --we've run in to a non-syncing tile. an error has occurred.
                    break
                  end
                end
              end --get the shape's vertices
              shapeCoords = {x1 = x + block.pos[direction].x, y1 = y + block.pos[direction].y,
                             x2 = length, y2 = .5}

            elseif direction == 'north_left' or direction == 'north_right' then --shoot north

              while true do
                local nextTile = get(currentX, currentY - 1)
                if not nextTile then
                  --no tile, we're done here. also, an error has occurred.
                  break
                else
                  local nextBlock = algorithmBlocks[nextTile.tile]
                  local sourceDirection = opposites[direction]
                  if table.has(nextBlock.direction, sourceDirection) then
                    --the tiles synchronize!
                    if not table.has(nextTile.traverseTable, sourceDirection) then
                      --the next tile hasn't already been traversed in this direction!
                      table.insert(nextTile.traverseTable, sourceDirection)
                      length = length + nextBlock.size
                      if table.has(nextBlock.direction, direction) then
                        --keep traveling in this direction!
                        currentY = currentY - 1
                      else
                        --we've hit the end.
                        break
                      end
                    else
                      --the tile we're shooting from should already have been traversed
                      --in this direction. an error has occurred. (how'd you do that?)
                      break
                    end
                  else
                    --we've run in to a non-syncing tile. an error has occurred.
                    break
                  end
                end
              end --get the shape's vertices
              shapeCoords = {x1 = x + block.pos[direction].x, y1 = y + block.pos[direction].y,
                             x2 = .5, y2 = -length}

            elseif direction == 'south_left' or direction == 'south_right' then --shoot south

              while true do
                local nextTile = get(currentX, currentY + 1)
                if not nextTile then
                  --no tile, we're done here. also, an error has occurred.
                  break
                else
                  local nextBlock = algorithmBlocks[nextTile.tile]
                  local sourceDirection = opposites[direction]
                  if table.has(nextBlock.direction, sourceDirection) then
                    --the tiles synchronize!
                    if not table.has(nextTile.traverseTable, sourceDirection) then
                      --the next tile hasn't already been traversed in this direction!
                      table.insert(nextTile.traverseTable, sourceDirection)
                      length = length + nextBlock.size
                      if table.has(nextBlock.direction, direction) then
                        --keep traveling in this direction!
                        currentY = currentY + 1
                      else
                        --we've hit the end.
                        break
                      end
                    else
                      --the tile we're shooting from should already have been traversed
                      --in this direction. an error has occurred. (how'd you do that?)
                      break
                    end
                  else
                    --we've run in to a non-syncing tile. an error has occurred.
                    break
                  end
                end
              end --get the shape's vertices
              shapeCoords = {x1 = x + block.pos[direction].x, y1 = y + block.pos[direction].y,
                             x2 = .5, y2 = length}

            else
              --how'd you do that?
            end

            --build the shape
            if shapeCoords.x1 ~= shapeCoords.x2 and shapeCoords.y1 ~= shapeCoords.y2 then
              local shape = ovw.collision.hc:addRectangle(self:pos(shapeCoords.x1, shapeCoords.y1, shapeCoords.x2, shapeCoords.y2))
              ovw.collision.hc:setPassive(shape)
              shape.owner = self
              table.insert(self.newShapes, shape)
            else
              --there isn't a shape.
            end
          end
        end
      end
    end
  end
end

function House:computeShapesInRoom2(room)
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

--================================================================================--
--ROOM CONTENTS --------------------------------------------------------------------
--================================================================================--

function House:spawnNPCsInRoom(npc, room)
  if npc then
    local x, y = self:pos(room.x, room.y)
    if room.buildShape == 'circle' then
      local dir = love.math.random() * math.pi * 2 - math.pi
      local dis = love.math.random() * (room.radius - 2)
      x = self:pos(room.x + room.width / 2) + self:pos(math.cos(dir) * dis)
      y = self:pos(room.y + room.height / 2) + self:pos(math.sin(dir) * dis)
    elseif room.buildShape == 'diamond' then
      local dimensionsRatio = (room.height / room.width)
      x = x + self.halfCell + love.math.random() * ((room.width - 2) * self.cellSize)
      local tx = math.round(room.width / 2 + .5) * self.cellSize - math.abs(x - room.x * self.cellSize - math.round(room.width / 2 + .5) * self.cellSize)
      tx = tx * .6
      y = y + self.halfCell + self:pos(room.height / 2) - dimensionsRatio * tx + love.math.random() * tx * dimensionsRatio * 2
    else --rectangle
      x = x + self.halfCell + love.math.random() * ((room.width - 2) * self.cellSize)
      y = y + self.halfCell + love.math.random() * ((room.height - 2) * self.cellSize)
    end
    ovw.npcs:add(npc({x = x, y = y, room = room}))
  end
end

function House:spawnEnemiesInRoom(amt, room, enemyType)
  local enemies = {}
  for i = 1, amt do
    local x, y = self:pos(room.x, room.y)
    if room.buildShape == 'circle' then
      local dir = love.math.random() * math.pi * 2 - math.pi
      local dis = love.math.random() * (room.radius - 2)
      x = self:pos(room.x + room.width / 2) + self:pos(math.cos(dir) * dis)
      y = self:pos(room.y + room.height / 2) + self:pos(math.sin(dir) * dis)
    elseif room.buildShape == 'diamond' then
      local dimensionsRatio = (room.height / room.width)
      x = x + self.halfCell + love.math.random() * ((room.width - 2) * self.cellSize)
      local tx = math.round(room.width / 2 + .5) * self.cellSize - math.abs(x - room.x * self.cellSize - math.round(room.width / 2 + .5) * self.cellSize)
      tx = tx * .6
      y = y + self.halfCell + self:pos(room.height / 2) - dimensionsRatio * tx + love.math.random() * tx * dimensionsRatio * 2
    else
      x = x + self.halfCell + love.math.random() * ((room.width - 2) * self.cellSize)
      y = y + self.halfCell + love.math.random() * ((room.height - 2) * self.cellSize)
    end
    local spawnEnemyType = enemyType and enemyType or randomFrom(room.enemyTypes)
    if spawnEnemyType == Spiderling then
      for i = 1, 2 + math.ceil(love.math.random() * 2) do
        table.insert(enemies, ovw.enemies:add(Spiderling(x, y, room)))
        x = x + love.math.random() * self.cellSize - self.halfCell
        y = y + love.math.random() * self.cellSize - self.halfCell
      end
    else
      table.insert(enemies, ovw.enemies:add(spawnEnemyType(x, y, room)))
    end
  end
  return enemies
end

function House:spawnPickupsInRoom(amount, room)--amt, room, pickupType, orbType) --orbType optional
  return pickupTables.drop(room)--pickupTables.spawnPickups('trash', room)
end

--================================================================================--
--STAIRCASES -----------------------------------------------------------------------
--================================================================================--

function House:refreshRoom(room, id)
  self.rooms[id] = room
  room:carveRoom(self.tiles)
  room:computeCollision()

  table.each(room.doors, function(door, side) self:refreshDoor(room, door) end)
end

function House:refreshDoor(room, door)
  if #door.tiles > 0 then
    local x, y = door.tiles[1].x, door.tiles[1].y
    local x1, y1, x2, y2 = x, y, x, y
    for i = 2, #door.tiles do
      x, y = door.tiles[i].x, door.tiles[i].y
      x1 = math.min(x1, x)
      y1 = math.min(y1, y)
      x2 = math.max(x2, x)
      y2 = math.max(y2, y)
    end
    House.carveRect(x1, y1, x2, y2, room, self.tiles)
    self:computeTilesInDoor(x1, y1, x2, y2)
    self:computeTilesInRoom(room)
  end
end

function House:createFloor(i, override)
  if not override and i == self.currentFloor then
    --you're already on this floor?
  else
    self.floors[i] = {rooms = {}, spells = {}, particles = {}, enemies = {}, npcs = {}, pickups = {}, furniture = {}}
  end
end

function House:setFloor(i)
  if i == self.currentFloor then
    --you're already on this floor?
    print('already on this floor, how did you do that?')
  else
    --does the new floor exist yet?
    if not self.floors[i] then
      self:createFloor(i)
    end

    --store the currentFloor rooms
    self:createFloor(self.currentFloor, true)
    local currentFloorData = self.floors[self.currentFloor]
    table.each(self.rooms, function(room, id) ovw.collision.hc:remove(room.shape) currentFloorData.rooms[id] = room end)
    self:saveFloorDataBlock(self.currentFloor, 'spells')
    self:saveFloorDataBlock(self.currentFloor, 'particles', true) --PARTICLES DON'T COLLIDE
    self:saveFloorDataBlock(self.currentFloor, 'enemies')
    self:saveFloorDataBlock(self.currentFloor, 'npcs')
    self:saveFloorDataBlock(self.currentFloor, 'pickups')
    self:saveFloorDataBlock(self.currentFloor, 'furniture')

    --clear the floor structure
    self.rooms = {}
    self.tiles = {}
    self:forceComputeShapes()
    self:computeTiles()

    --load the newFloor rooms
    self.currentFloor = i
    local newFloorData = self.floors[self.currentFloor]
    table.each(newFloorData.rooms, function(room, id) self:refreshRoom(room, id) end)
    self:loadFloorDataBlock(self.currentFloor, 'spells')
    self:loadFloorDataBlock(self.currentFloor, 'particles', true) --PARTICLES DON'T COLLIDE
    self:loadFloorDataBlock(self.currentFloor, 'enemies')
    self:loadFloorDataBlock(self.currentFloor, 'npcs')
    self:loadFloorDataBlock(self.currentFloor, 'pickups')
    self:loadFloorDataBlock(self.currentFloor, 'furniture')

    --build the floor, don't cross the streams!
    ovw:clearStreams()
    self:computeTiles()
    self:forceComputeShapes()
  end
end

function House:saveFloorDataBlock(floor, block, noCollision, noDrawing)
  table.each(ovw[block].objects, function(object, id)
    if not noCollision then ovw.collision:unregister(object) end
    if not noDrawing then ovw.view:unregister(object) end
    self.floors[floor][block][id] = object
    ovw[block].objects[id] = nil
  end)
end

function House:loadFloorDataBlock(floor, block, noCollision, noDrawing)
  table.each(self.floors[floor][block], function(object, id)
    if not noCollision then ovw.collision:register(object) end
    if not noDrawing then ovw.view:register(object) end
    ovw[block].objects[id] = object
    self.floors[floor][block][id] = nil
  end)
end

function House:changeFloor(staircase)
  if self.floorReady and self.staircaseReady then
    self.staircaseReady = false
    local targetFloor = 0
    local newDirection
    if staircase.direction == 'up' then
      targetFloor = self.currentFloor + 1
      newDirection = 'down'
    elseif staircase.direction == 'down' then
      targetFloor = self.currentFloor - 1
      newDirection = 'up'
    else
      --staircase.direction is the exact floor to change to, from like an elevator or something
      targetFloor = staircase.direction
      newDirection = self.currentFloor
    end

    staircase:remove()

    local spawnX, spawnY = self:cell(ovw.player.x, ovw.player.y)
    local needRoom = true
    self:setFloor(targetFloor)
    for id, room in pairs(self.rooms) do
      if room:hasTile(spawnX, spawnY) then
        needRoom = false
        room:createStaircase(spawnX, spawnY, newDirection)
      end

      --self:computeTilesInRoom(room)
      --self:computeShapesInRoom(room)
    end

    if needRoom then
      local newRoom = biomeStaircaseExitRooms[self.biome]()
      newRoom.event = Event()
      newRoom.x, newRoom.y = spawnX - math.round(newRoom.width / 2), spawnY - math.round(newRoom.height / 2)
      self:addRoom(newRoom, 0, 0)

      newRoom:createStaircase(spawnX, spawnY, newDirection)

      newRoom:spawnDoors(newRoom:randomWall())
      self:computeTilesInRoom(newRoom)
      self:regenerate(newRoom)
    end

    --place the followers
    table.each(ovw.player.followers, function(follower, key) follower.x, follower.y = ovw.player.x, ovw.player.y ovw.enemies:add(follower) ovw.view:register(follower) end)

    --build the floor
    self:computeTiles()
    self:forceComputeShapes()

    --reset the sounds
    ovw.sound:reset()
  end
end