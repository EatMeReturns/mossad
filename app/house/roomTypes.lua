require 'app/house/room'
require 'app/house/bossroom'
require 'app/shop'

--------------------------------------------------------------------------------------
---MAIN-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

MainRectangle = extend(Room)
MainRectangle.doorsToSpawn = 3
MainRectangle.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainRectangle.pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
MainRectangle.floorType = 'main'
MainRectangle.biome = 'main'

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

--------------------------------------------------------------------------------------

MainCorridor = extend(Room)
MainCorridor.doorsToSpawn = 1
MainCorridor.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainCorridor.pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
MainCorridor.floorType = 'main'
MainCorridor.biome = 'main'

function MainCorridor:init(dir)
  Room.init(self)

  if dir == 'east' or dir == 'west' then
    self.width = love.math.randomNormal(3, 14)
    self.height = 5
  elseif dir == 'north' or dir == 'south' then
    self.width = 5
    self.height = love.math.randomNormal(3, 14)
  end
  self.width = math.round(self.width)
  self.height = math.round(self.height)

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

--------------------------------------------------------------------------------------

MainBossRectangle = extend(BossRoom)
MainBossRectangle.doorsToSpawn = 6
MainBossRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainBossRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
MainBossRectangle.floorType = 'main'
MainBossRectangle.biome = 'main'

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

--------------------------------------------------------------------------------------

MainShopRectangle = extend(Room)
MainShopRectangle.doorsToSpawn = 0
MainShopRectangle.npcSpawnTable = WeightedRandom({{Shop, 1}}, 1)
MainShopRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainShopRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
MainShopRectangle.floorType = 'main'
MainShopRectangle.biome = 'main'

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


--------------------------------------------------------------------------------------
---GRAY-DUNGEON-----------------------------------------------------------------------
--------------------------------------------------------------------------------------

GrayChallengeRectangle = extend(MainRectangle)
GrayChallengeRectangle.doorsToSpawn = 6
GrayChallengeRectangle.enemySpawnTable = WeightedRandom({{5, 0.5}, {6, 0.25}, {7, 0.25}, {8, 0.1}, {9, 0.01}}, 1.11)
GrayChallengeRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
GrayChallengeRectangle.floorType = 'gray'
GrayChallengeRectangle.biome = 'gray'

function GrayChallengeRectangle:init(dir)
  MainRectangle.init(self, dir, love.math.randomNormal(2, 18), love.math.randomNormal(2, 18))
end

function GrayChallengeRectangle:spawnDoors(dir)
  MainRectangle.spawnDoors(self, dir)
end

--------------------------------------------------------------------------------------

GrayCorridor = extend(MainCorridor)
GrayCorridor.doorsToSpawn = 1
GrayCorridor.enemySpawnTable = WeightedRandom({{2, 0.5}, {3, 0.25}, {4, 0.25}, {5, 0.1}, {6, 0.01}}, 1.11)
GrayCorridor.pickupSpawnTable = WeightedRandom({{0, 0.25}, {1, 0.625}, {2, 0.125}}, 1)
GrayCorridor.floorType = 'gray'
GrayCorridor.biome = 'gray'

function GrayCorridor:init(dir)
  MainCorridor.init(self, dir)
end

function GrayCorridor:spawnDoors(dir)
  MainCorridor.spawnDoors(self, dir)
end

--------------------------------------------------------------------------------------

GrayTreasureRectangle = extend(MainRectangle)
GrayTreasureRectangle.doorsToSpawn = 0
GrayTreasureRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
GrayTreasureRectangle.pickupSpawnTable = WeightedRandom({{3, 0.5}, {4, 0.5}}, 1)
GrayTreasureRectangle.floorType = 'gray'
GrayTreasureRectangle.biome = 'gray'

function GrayTreasureRectangle:init(dir)
  MainRectangle.init(self, dir, love.math.randomNormal(1, 5), love.math.randomNormal(1, 5))
end

function GrayTreasureRectangle:spawnDoors(dir)
  MainRectangle.spawnDoors(self, dir)
end

--------------------------------------------------------------------------------------

GrayExitRectangle = extend(MainBossRectangle)
GrayExitRectangle.doorsToSpawn = 6
GrayExitRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
GrayExitRectangle.pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
GrayExitRectangle.floorType = 'gray'
GrayExitRectangle.biome = 'gray'

function GrayExitRectangle:init(dir)
  MainBossRectangle.init(self, dir, 20, 20, Avian)
end

function GrayExitRectangle:spawnDoors(dir)
  MainBossRectangle.spawnDoors(self, dir)
end

--------------------------------------------------------------------------------------

roomSpawnTables =
{
  main = WeightedRandom(
    {
      {MainRectangle, 0.75},
      {MainShopRectangle, 0.1},
      {MainCorridor, 0.1},
      {GrayCorridor, 0.05}
    }, 1),
  gray = WeightedRandom(
    {
      {GrayCorridor, 0.2},
      {GrayChallengeRectangle, 0.6},
      {GrayTreasureRectangle, 0.15},
      {GrayExitRectangle, 0.05}
    }, 1)
}