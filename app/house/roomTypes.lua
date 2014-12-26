require 'app/house/room'

require 'app/npc'
require 'app/shop'

require 'app/enemy'
require 'app/spiderling'
require 'app/shade'
require 'app/inkraven'
require 'app/rubymoth'

require 'app/boss'
require 'app/avian'

require 'app/house/event'
require 'app/house/eventTypes'

enemyTables = {}
enemyTables.allEnemies = {Spiderling, Shade, InkRaven, RubyMoth}
enemyTables.extraBirds = {Spiderling, Shade, InkRaven, InkRaven, InkRaven, RubyMoth}
enemyTables.onlyMoths = {RubyMoth}

eventTables = {}
eventTables.noEvent = WeightedRandom({{{Event, nil}, 1}}, 1)

--------------------------------------------------------------------------------------
---MAIN-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

MainRectangle = extend(Room)
MainRectangle.doorsToSpawn = 3
MainRectangle.enemyTypes = enemyTables.allEnemies
MainRectangle.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainRectangle.pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
MainRectangle.eventSpawnTable = WeightedRandom({{{TrapEvent, Spiderling}, .03}, {{Event, nil}, .97}}, 1)
MainRectangle.floorType = 'Main'
MainRectangle.biome = 'Main'

MainRectangle.buildShape = 'rectangle'

function MainRectangle:init(dir, w, h)
  Room.init(self)

  self.width = w or love.math.randomNormal(2, 12)
  self.height = h or love.math.randomNormal(2, 12)
  self.width = math.round(math.clamp(self.width, 5, 50))
  self.height = math.round(math.clamp(self.height, 5, 50))

  for i = -1, self.width do
    self.walls.north[#self.walls.north + 1] = {x = i, y = -1, direction = 'north'}
    self.walls.south[#self.walls.south + 1] = {x = i, y = self.height, direction = 'south'}
  end

  for i = -1, self.height do
    self.walls.west[#self.walls.west + 1] = {x = -1, y = i, direction = 'west'}
    self.walls.east[#self.walls.east + 1] = {x = self.width, y = i, direction = 'east'}
  end
end

function MainRectangle:spawnDoors(dir)
  for i = 1, self.doorsToSpawn do
    local spawnDir = table.random(directions)
    local spawnDoorMap = {}
    spawnDoorMap[spawnDir] = self
    local spawnDoor = Door(spawnDoorMap)
    self:addDoor(spawnDoor, spawnDir)
  end
end

function MainRectangle:carveRoom(tileMap)
  House.carveRect(self.x, self.y, self.x + self.width, self.y + self.height, self, tileMap)

  --spawn walls
  for _, dir in pairs({'north', 'south', 'east', 'west'}) do
    for _, wall in pairs(self.walls[dir]) do
      local x, y = self.x + wall.x, self.y + wall.y
      tileMap[x] = tileMap[x] or {}
      tileMap[x][y] = Tile(self.floorType, x, y, self)
    end
  end
end

--------------------------------------------------------------------------------------

MainStairwell = extend(Room)
MainStairwell.doorsToSpawn = 0
MainStairwell.enemyTypes = enemyTables.onlyMoths
MainStairwell.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainStairwell.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
MainStairwell.eventSpawnTable = eventTables.noEvent
MainStairwell.hasFurniture = true
MainStairwell.floorType = 'Main'
MainStairwell.biome = 'Main'

MainStairwell.buildShape = 'rectangle'

function MainStairwell:init(dir)
  Room.init(self)

  self.width = 3
  self.height = 3

  for i = -1, self.width do
    self.walls.north[#self.walls.north + 1] = {x = i, y = -1, direction = 'north'}
    self.walls.south[#self.walls.south + 1] = {x = i, y = self.height, direction = 'south'}
  end

  for i = -1, self.height do
    self.walls.west[#self.walls.west + 1] = {x = -1, y = i, direction = 'west'}
    self.walls.east[#self.walls.east + 1] = {x = self.width, y = i, direction = 'east'}
  end
end

function MainStairwell:spawnDoors(dir)
  for i = 1, self.doorsToSpawn do
    local spawnDir = table.random(directions)
    local spawnDoorMap = {}
    spawnDoorMap[spawnDir] = self
    local spawnDoor = Door(spawnDoorMap)
    self:addDoor(spawnDoor, spawnDir)
  end
end

function MainStairwell:carveRoom(tileMap)
  House.carveRect(self.x, self.y, self.x + self.width, self.y + self.height, self, tileMap)

  --spawn walls
  for _, dir in pairs({'north', 'south', 'east', 'west'}) do
    for _, wall in pairs(self.walls[dir]) do
      local x, y = self.x + wall.x, self.y + wall.y
      tileMap[x] = tileMap[x] or {}
      tileMap[x][y] = Tile(self.floorType, x, y, self)
    end
  end
end

function MainStairwell:spawnFurniture()
  local direction = love.math.random() < .5 and 'up' or 'down'
  self:createStaircase(self.x + 1, self.y + 1, direction)
end

--------------------------------------------------------------------------------------

MainCircle = extend(Room)
MainCircle.doorsToSpawn = 3
MainCircle.enemyTypes = enemyTables.allEnemies
MainCircle.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainCircle.pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
MainCircle.eventSpawnTable = WeightedRandom({{{TrapEvent, Spiderling}, .03}, {{Event, nil}, .97}}, 1)
MainCircle.floorType = 'Main'
MainCircle.biome = 'Main'

MainCircle.buildShape = 'circle'

function MainCircle:init(dir, r)
  Room.init(self)
  
  self.radius = r or love.math.randomNormal(1, 6)
  self.radius = not r and math.round(math.clamp(self.radius, 4, 8)) or self.radius
  self.angle = 0
  self.width = self.radius * 2
  self.height = self.radius * 2

  for i = -1, self.width do
    self.walls.north[#self.walls.north + 1] = {x = i, y = -1, direction = 'north'}
    self.walls.south[#self.walls.south + 1] = {x = i, y = self.height, direction = 'south'}
  end

  for i = -1, self.height do
    self.walls.west[#self.walls.west + 1] = {x = -1, y = i, direction = 'west'}
    self.walls.east[#self.walls.east + 1] = {x = self.width, y = i, direction = 'east'}
  end
end

function MainCircle:spawnDoors(dir)
  for i = 1, self.doorsToSpawn do
    local spawnDir = table.random(directions)
    local spawnDoorMap = {}
    spawnDoorMap[spawnDir] = self
    local spawnDoor = Door(spawnDoorMap)
    self:addDoor(spawnDoor, spawnDir)
  end
end

function MainCircle:carveRoom(tileMap)
  --spawn tiles
  --for x = self.x, self.x + self.width do
  --  for y = self.y, self.y + self.height do
  --    tileMap[x] = tileMap[x] or {}
  --    tileMap[x][y] = Tile(self.floorType, x, y, self)
  --  end
  --end
  House.carveRound(self.x + self.width / 2, self.y + self.height / 2, self.width / 2, self.height / 2, self, tileMap)
end

--------------------------------------------------------------------------------------

MainCorridor = extend(Room)
MainCorridor.doorsToSpawn = 1
MainCorridor.enemyTypes = enemyTables.allEnemies
MainCorridor.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainCorridor.pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
MainCorridor.eventSpawnTable = WeightedRandom({{{RejectEvent, 'horizontal'}, 0.03}, {{Event, nil}, 0.97}}, 1)
MainCorridor.floorType = 'Main'
MainCorridor.biome = 'Main'

MainCorridor.buildShape = 'rectangle'

function MainCorridor:init(dir)
  Room.init(self)

  if dir == 'east' or dir == 'west' then
    self.width = love.math.randomNormal(3, 14)
    self.width = math.round(math.clamp(self.width, 5, 50))
    self.height = House.doorSize + 1
    self.event.direction = 'horizontal'
  elseif dir == 'north' or dir == 'south' then
    self.width = House.doorSize + 1
    self.height = love.math.randomNormal(3, 14)
    self.height = math.round(math.clamp(self.height, 5, 50))
    self.event.direction = 'vertical'
  end

  for i = -1, self.width do
    self.walls.north[#self.walls.north + 1] = {x = i, y = -1, direction = 'north'}
    self.walls.south[#self.walls.south + 1] = {x = i, y = self.height, direction = 'south'}
  end

  for i = -1, self.height do
    self.walls.west[#self.walls.west + 1] = {x = -1, y = i, direction = 'west'}
    self.walls.east[#self.walls.east + 1] = {x = self.width, y = i, direction = 'east'}
  end
end

function MainCorridor:spawnDoors(dir)
  for i = 1, self.doorsToSpawn do
    local spawnDir = dir
    local spawnDoorMap = {}
    spawnDoorMap[spawnDir] = self
    local spawnDoor = Door(spawnDoorMap)
    self:addDoor(spawnDoor, spawnDir)
  end
end

function MainCorridor:carveRoom(tileMap)
  --spawn tiles
  for x = self.x, self.x + self.width do
    for y = self.y, self.y + self.height do
      tileMap[x] = tileMap[x] or {}
      tileMap[x][y] = Tile(self.floorType, x, y, self)
    end
  end

  --spawn walls
  for _, dir in pairs({'north', 'south', 'east', 'west'}) do
    for _, wall in pairs(self.walls[dir]) do
      local x, y = self.x + wall.x, self.y + wall.y
      tileMap[x] = tileMap[x] or {}
      tileMap[x][y] = Tile(self.floorType, x, y, self)
    end
  end
end

--------------------------------------------------------------------------------------

MainBossRectangle = extend(Room)
MainBossRectangle.doorsToSpawn = 6
MainBossRectangle.enemyTypes = enemyTables.onlyMoths
MainBossRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainBossRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
MainBossRectangle.eventSpawnTable = eventTables.noEvent
MainBossRectangle.floorType = 'Main'
MainBossRectangle.biome = 'Main'

MainBossRectangle.buildShape = 'rectangle'

function MainBossRectangle:init(dir, w, h, boss)
  Room.init(self)

  self.event = BossEvent(self, boss)

  self.width = w
  self.height = h

  for i = -1, self.width do
    self.walls.north[#self.walls.north + 1] = {x = i, y = -1, direction = 'north'}
    self.walls.south[#self.walls.south + 1] = {x = i, y = self.height, direction = 'south'}
  end

  for i = -1, self.height do
    self.walls.west[#self.walls.west + 1] = {x = -1, y = i, direction = 'west'}
    self.walls.east[#self.walls.east + 1] = {x = self.width, y = i, direction = 'east'}
  end
end

function MainBossRectangle:spawnDoors(dir)
  for i = 1, self.doorsToSpawn do
    local spawnDir = table.random(directions)
    local spawnDoorMap = {}
    spawnDoorMap[spawnDir] = self
    local spawnDoor = Door(spawnDoorMap)
    self:addDoor(spawnDoor, spawnDir)
  end
end

function MainBossRectangle:carveRoom(tileMap)
  --spawn tiles
  for x = self.x, self.x + self.width do
    for y = self.y, self.y + self.height do
      tileMap[x] = tileMap[x] or {}
      tileMap[x][y] = Tile(self.floorType, x, y, self)
    end
  end

  --spawn walls
  for _, dir in pairs({'north', 'south', 'east', 'west'}) do
    for _, wall in pairs(self.walls[dir]) do
      local x, y = self.x + wall.x, self.y + wall.y
      tileMap[x] = tileMap[x] or {}
      tileMap[x][y] = Tile(self.floorType, x, y, self)
    end
  end
end

--------------------------------------------------------------------------------------

MainShopRectangle = extend(Room)
MainShopRectangle.doorsToSpawn = 0
MainCorridor.enemyTypes = enemyTables.onlyMoths
MainShopRectangle.npcSpawnTable = WeightedRandom({{Shop, 1}}, 1)
MainShopRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainShopRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
MainShopRectangle.eventSpawnTable = eventTables.noEvent
MainShopRectangle.floorType = 'Main'
MainShopRectangle.biome = 'Main'

MainShopRectangle.buildShape = 'rectangle'

function MainShopRectangle:init(dir, w, h)
  Room.init(self)

  self.width = 7
  self.height = 7

  for i = -1, self.width do
    self.walls.north[#self.walls.north + 1] = {x = i, y = -1, direction = 'north'}
    self.walls.south[#self.walls.south + 1] = {x = i, y = self.height, direction = 'south'}
  end

  for i = -1, self.height do
    self.walls.west[#self.walls.west + 1] = {x = -1, y = i, direction = 'west'}
    self.walls.east[#self.walls.east + 1] = {x = self.width, y = i, direction = 'east'}
  end
end

function MainShopRectangle:spawnDoors(dir)
  MainRectangle.spawnDoors(self, dir)
end

function MainShopRectangle:carveRoom(tileMap)
  --spawn tiles
  for x = self.x, self.x + self.width do
    for y = self.y, self.y + self.height do
      tileMap[x] = tileMap[x] or {}
      tileMap[x][y] = Tile(self.floorType, x, y, self)
    end
  end

  --spawn walls
  for _, dir in pairs({'north', 'south', 'east', 'west'}) do
    for _, wall in pairs(self.walls[dir]) do
      local x, y = self.x + wall.x, self.y + wall.y
      tileMap[x] = tileMap[x] or {}
      tileMap[x][y] = Tile(self.floorType, x, y, self)
    end
  end
end


--------------------------------------------------------------------------------------
---GRAY-DUNGEON-----------------------------------------------------------------------
--------------------------------------------------------------------------------------

GrayChallengeRectangle = extend(MainRectangle)
GrayChallengeRectangle.doorsToSpawn = 6
GrayChallengeRectangle.enemyTypes = enemyTables.extraBirds
GrayChallengeRectangle.enemySpawnTable = WeightedRandom({{5, 0.5}, {6, 0.25}, {7, 0.25}, {8, 0.1}, {9, 0.01}}, 1.11)
GrayChallengeRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
GrayChallengeRectangle.eventSpawnTable = WeightedRandom({{{TrapEvent, InkRaven}, .03}, {{Event, nil}, .97}}, 1)
GrayChallengeRectangle.floorType = 'Gray'
GrayChallengeRectangle.biome = 'Gray'

function GrayChallengeRectangle:init(dir)
  MainRectangle.init(self, dir, love.math.randomNormal(2, 18), love.math.randomNormal(2, 18))
end

function GrayChallengeRectangle:spawnDoors(dir)
  MainRectangle.spawnDoors(self, dir)
end

function GrayChallengeRectangle:carveRoom(tileMap)
  MainRectangle.carveRoom(self, tileMap)
end

--------------------------------------------------------------------------------------

GrayCorridor = extend(MainCorridor)
GrayCorridor.doorsToSpawn = 1
GrayCorridor.enemyTypes = enemyTables.extraBirds
GrayCorridor.enemySpawnTable = WeightedRandom({{2, 0.5}, {3, 0.25}, {4, 0.25}, {5, 0.1}, {6, 0.01}}, 1.11)
GrayCorridor.pickupSpawnTable = WeightedRandom({{0, 0.25}, {1, 0.625}, {2, 0.125}}, 1)
GrayCorridor.eventSpawnTable = eventTables.noEvent
GrayCorridor.floorType = 'Gray'
GrayCorridor.biome = 'Gray'

function GrayCorridor:init(dir)
  MainCorridor.init(self, dir)
end

function GrayCorridor:spawnDoors(dir)
  MainCorridor.spawnDoors(self, dir)
end

function GrayCorridor:carveRoom(tileMap)
  MainCorridor.carveRoom(self, tileMap)
end

--------------------------------------------------------------------------------------

GrayTreasureRectangle = extend(MainRectangle)
GrayTreasureRectangle.doorsToSpawn = 0
GrayTreasureRectangle.enemyTypes = enemyTables.onlyMoths
GrayTreasureRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
GrayTreasureRectangle.pickupSpawnTable = WeightedRandom({{3, 0.5}, {4, 0.5}}, 1)
GrayTreasureRectangle.eventSpawnTable = eventTables.noEvent
GrayTreasureRectangle.floorType = 'Gray'
GrayTreasureRectangle.biome = 'Gray'

function GrayTreasureRectangle:init(dir)
  MainRectangle.init(self, dir, love.math.randomNormal(1, 5), love.math.randomNormal(1, 5))
end

function GrayTreasureRectangle:spawnDoors(dir)
  MainRectangle.spawnDoors(self, dir)
end

function GrayTreasureRectangle:carveRoom(tileMap)
  MainRectangle.carveRoom(self, tileMap)
end

--------------------------------------------------------------------------------------

GrayExitRectangle = extend(MainBossRectangle)
GrayExitRectangle.doorsToSpawn = 6
GrayExitRectangle.enemyTypes = enemyTables.onlyMoths
GrayExitRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
GrayExitRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
GrayExitRectangle.floorType = 'Gray'
GrayExitRectangle.biome = 'Gray'

function GrayExitRectangle:init(dir)
  MainBossRectangle.init(self, dir, 15, 15, Avian)
end

function GrayExitRectangle:spawnDoors(dir)
  MainBossRectangle.spawnDoors(self, dir)
end

function GrayExitRectangle:carveRoom(tileMap)
  MainBossRectangle.carveRoom(self, tileMap)
end

--------------------------------------------------------------------------------------
---GREAT-HALL-------------------------------------------------------------------------
--------------------------------------------------------------------------------------

GreatHallCircle = extend(MainCircle)
GreatHallCircle.doorsToSpawn = 12
GreatHallCircle.enemyTypes = enemyTables.onlyMoths
GreatHallCircle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
GreatHallCircle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
GreatHallCircle.eventSpawnTable = eventTables.noEvent
GreatHallCircle.floorType = 'Main'
GreatHallCircle.biome = 'Great_Hall'

function GreatHallCircle:init(dir)
  MainCircle.init(self, dir, 30)
end

function GreatHallCircle:spawnDoors(dir)
  for i = 1, self.doorsToSpawn do
    local spawnDir = table.random(directions)
    local spawnDoorMap = {}
    spawnDoorMap[spawnDir] = self
    local spawnDoor = Door(spawnDoorMap)
    self:addDoor(spawnDoor, spawnDir)
  end
end

function GreatHallCircle:carveRoom(tileMap)
  MainCircle.carveRoom(self, tileMap)
end

function GreatHallCircle:spawnFurniture()
  local direction = (ovw.house and ovw.house.floor or 0) - (math.ceil(love.math.random() * 10) + 3)
  self:createStaircase(self.x + self.radius, self.y + self.radius, direction)
end

--------------------------------------------------------------------------------------

roomSpawnTables =
{
  Main = WeightedRandom(
    {
      {MainCircle, 0.5},
      {MainStairwell, 0.02},
      {MainRectangle, 0.75},
      {MainShopRectangle, 0.1},
      {MainCorridor, 0.1},
      {GrayCorridor, 0.02},
      {GreatHallCircle, 0.01}
    }, 1.50),
  Gray = WeightedRandom(
    {
      {GrayCorridor, 0.2},
      {GrayChallengeRectangle, 0.5},
      {GrayTreasureRectangle, 0.2},
      {GrayExitRectangle, 0.1}
    }, 1),
  Great_Hall = WeightedRandom(
    {
      {MainRectangle, 1}
    }, 1)
}