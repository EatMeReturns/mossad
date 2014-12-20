require 'app/house/room'
require 'app/house/bossroom'
require 'app/shop'

require 'app/enemy'
require 'app/spiderling'
require 'app/shade'
require 'app/inkraven'
require 'app/rubymoth'

require 'app/boss'
require 'app/avian'

local allEnemies = {Spiderling, Shade, InkRaven, RubyMoth}
local extraBirds = {Spiderling, Shade, InkRaven, InkRaven}
onlyMoths = {RubyMoth}

--------------------------------------------------------------------------------------
---MAIN-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

MainRectangle = extend(Room)
MainRectangle.doorsToSpawn = 3
MainRectangle.enemyTypes = allEnemies
MainRectangle.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainRectangle.pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
MainRectangle.floorType = 'Main'
MainRectangle.biome = 'Main'

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

MainCorridor = extend(Room)
MainCorridor.doorsToSpawn = 1
MainCorridor.enemyTypes = allEnemies
MainCorridor.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainCorridor.pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
MainCorridor.floorType = 'Main'
MainCorridor.biome = 'Main'

function MainCorridor:init(dir)
  Room.init(self)

  if dir == 'east' or dir == 'west' then
    self.width = love.math.randomNormal(3, 14)
    self.height = 5
  elseif dir == 'north' or dir == 'south' then
    self.width = 5
    self.height = love.math.randomNormal(3, 14)
  end
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

MainBossRectangle = extend(BossRoom)
MainBossRectangle.doorsToSpawn = 6
MainBossRectangle.enemyTypes = onlyMoths
MainBossRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainBossRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
MainBossRectangle.floorType = 'Main'
MainBossRectangle.biome = 'Main'

function MainBossRectangle:init(dir, w, h, boss)
  BossRoom.init(self, boss)

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
MainCorridor.enemyTypes = onlyMoths
MainShopRectangle.npcSpawnTable = WeightedRandom({{Shop, 1}}, 1)
MainShopRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainShopRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
MainShopRectangle.floorType = 'Main'
MainShopRectangle.biome = 'Main'

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
GrayChallengeRectangle.enemyTypes = extraBirds
GrayChallengeRectangle.enemySpawnTable = WeightedRandom({{5, 0.5}, {6, 0.25}, {7, 0.25}, {8, 0.1}, {9, 0.01}}, 1.11)
GrayChallengeRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
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
GrayCorridor.enemyTypes = extraBirds
GrayCorridor.enemySpawnTable = WeightedRandom({{2, 0.5}, {3, 0.25}, {4, 0.25}, {5, 0.1}, {6, 0.01}}, 1.11)
GrayCorridor.pickupSpawnTable = WeightedRandom({{0, 0.25}, {1, 0.625}, {2, 0.125}}, 1)
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
GrayTreasureRectangle.enemyTypes = onlyMoths
GrayTreasureRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
GrayTreasureRectangle.pickupSpawnTable = WeightedRandom({{3, 0.5}, {4, 0.5}}, 1)
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
GrayExitRectangle.enemyTypes = onlyMoths
GrayExitRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
GrayExitRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
GrayExitRectangle.floorType = 'Gray'
GrayExitRectangle.biome = 'Gray'

function GrayExitRectangle:init(dir)
  MainBossRectangle.init(self, dir, 20, 20, Avian)
end

function GrayExitRectangle:spawnDoors(dir)
  MainBossRectangle.spawnDoors(self, dir)
end

function GrayExitRectangle:carveRoom(tileMap)
  MainBossRectangle.carveRoom(self, tileMap)
end

--------------------------------------------------------------------------------------

roomSpawnTables =
{
  Main = WeightedRandom(
    {
      {MainRectangle, 0.75},
      {MainShopRectangle, 0.1},
      {MainCorridor, 0.1},
      {GrayCorridor, 0.05}
    }, 1),
  Gray = WeightedRandom(
    {
      {GrayCorridor, 0.2},
      {GrayChallengeRectangle, 0.6},
      {GrayTreasureRectangle, 0.15},
      {GrayExitRectangle, 0.05}
    }, 1)
}