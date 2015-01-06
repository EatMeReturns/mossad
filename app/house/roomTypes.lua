require 'app/house/room'
require 'app/house/event'
require 'app/house/eventTypes'

load 'app/npcs'
load 'app/enemies'
load 'app/bosses'


enemyTables = {} --all enemies excludes biome-specific enemies.
enemyTables.allEnemies = {Spiderling, Shade, InkRaven, RubyMoth, Gloomrat}
enemyTables.easy = {Spiderling, Spiderling, Shade, Shade, Shade, InkRaven, InkRaven, RubyMoth, RubyMoth, Gloomrat}
enemyTables.medium = {Spiderling, Spiderling, Shade, Shade, InkRaven, RubyMoth, Gloomrat}
enemyTables.hard = {Spiderling, Shade, InkRaven, InkRaven, RubyMoth, Gloomrat, Gloomrat}
enemyTables.extraBirds = {Spiderling, Spiderling, Shade, InkRaven, InkRaven, InkRaven, InkRaven, RubyMoth, Gloomrat}
enemyTables.onlyMoths = {RubyMoth}
enemyTables.onlyWorms = {Worm}
enemyTables.miniBosses = {Worm}
enemyTables.cafe = {Zombie}

eventTables = {}
eventTables.noEvent = WeightedRandom({{{Event, nil}, 1}}, 1)

pickupTables = {}
pickupTables.trash = {}
pickupTables.common = {}
pickupTables.uncommon = {}
pickupTables.rare = {}
pickupTables.epic = {}
pickupTables.legendary = {}
pickupTables.experience = {}

npcTables = {}
npcTables.chest = WeightedRandom({{StorageChest, 0.05}, {nil, 0.95}}, 1)

--------------------------------------------------------------------------------------
---MAIN-------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

MainRectangle = extend(Room)
MainRectangle.doorsToSpawn = 3
MainRectangle.enemyTypes = enemyTables.allEnemies
MainRectangle.npcSpawnTable = npcTables.chest
MainRectangle.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainRectangle.dropChance = .3--pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
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

MainDiamond = extend(Room)
MainDiamond.doorsToSpawn = 6
MainDiamond.enemyTypes = enemyTables.medium
MainDiamond.npcSpawnTable = npcTables.chest
MainDiamond.enemySpawnTable = WeightedRandom({{5, 0.5}, {6, 0.25}, {7, 0.25}, {8, 0.1}, {9, 0.01}}, 1.11)
MainDiamond.dropChance = .75--pickupSpawnTable = WeightedRandom({{3, 0.5}, {4, 0.5}}, 1)
MainDiamond.eventSpawnTable = eventTables.noEvent
MainDiamond.floorType = 'Main'
MainDiamond.biome = 'Main'

MainDiamond.buildShape = 'diamond'

function MainDiamond:init(dir, w, h)
  Room.init(self)

  self.width = w or love.math.randomNormal(2, 20)
  self.width = w or math.round(math.clamp(self.width, 16, 24))
  if self.width % 2 == 0 then self.width = w or self.width + 1 end
  self.height = h or self.width

  --mid point minus 2, mid point plus 1
  local range = {math.floor(self.width / 2) - 2, math.floor(self.width / 2) + 2}
  for i = range[1], range[2] do
    self.walls.north[#self.walls.north + 1] = {x = i, y = -1, direction = 'north'}
    self.walls.south[#self.walls.south + 1] = {x = i, y = self.height, direction = 'south'}
  end

  range = {math.floor(self.height / 2) - 2, math.floor(self.height / 2) + 2}
  for i = range[1], range[2] do
    self.walls.west[#self.walls.west + 1] = {x = -1, y = i, direction = 'west'}
    self.walls.east[#self.walls.east + 1] = {x = self.width, y = i, direction = 'east'}
  end
end

function MainDiamond:spawnDoors(dir)
  for i = 1, self.doorsToSpawn do
    local spawnDir = table.random(directions)
    local spawnDoorMap = {}
    spawnDoorMap[spawnDir] = self
    local spawnDoor = Door(spawnDoorMap)
    self:addDoor(spawnDoor, spawnDir)
  end
end

function MainDiamond:carveRoom(tileMap)
  House.carveDiamond(self.x, self.y, self.width, self.height, self, tileMap)

  --spawn walls
  --for _, dir in pairs({'north', 'south', 'east', 'west'}) do
  --  for _, wall in pairs(self.walls[dir]) do
  --    local x, y = self.x + wall.x, self.y + wall.y
  --    tileMap[x] = tileMap[x] or {}
  --    tileMap[x][y] = Tile(self.floorType, x, y, self)
  --  end
  --end
end

--------------------------------------------------------------------------------------

MainStairwell = extend(Room)
MainStairwell.doorsToSpawn = 0
MainStairwell.enemyTypes = enemyTables.onlyMoths
MainStairwell.npcSpawnTable = nil
MainStairwell.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainStairwell.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
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
MainCircle.npcSpawnTable = npcTables.chest
MainCircle.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainCircle.dropChance = .3--pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
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
MainCorridor.npcSpawnTable = npcTables.chest
MainCorridor.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
MainCorridor.dropChance = .5--pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
MainCorridor.eventSpawnTable = WeightedRandom({{{RejectEvent, 'horizontal'}, 0.03}, {{Event, nil}, 0.97}}, 1)
MainCorridor.floorType = 'Main'
MainCorridor.biome = 'Main'

MainCorridor.buildShape = 'rectangle'

function MainCorridor:init(dir, length)
  Room.init(self)

  if dir == 'east' or dir == 'west' then
    if length then
      self.width = length
    else
      self.width = love.math.randomNormal(3, 14)
      self.width = math.round(math.clamp(self.width, 5, 50))
    end
    self.height = House.doorSize + 1
    self.event.direction = 'horizontal'
  elseif dir == 'north' or dir == 'south' then
    self.width = House.doorSize + 1
    if length then
      self.height = length
    else
      self.height = love.math.randomNormal(3, 14)
      self.height = math.round(math.clamp(self.height, 5, 50))
    end
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
MainBossRectangle.npcSpawnTable = nil
MainBossRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainBossRectangle.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
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
MainShopRectangle.doorsToSpawn = 2
MainShopRectangle.enemyTypes = enemyTables.onlyMoths
MainShopRectangle.npcSpawnTable = nil
MainShopRectangle.npcSpawnTable = WeightedRandom({{Shop, 1}}, 1)
MainShopRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainShopRectangle.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
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

MainCraftingStationRectangle = extend(Room)
MainCraftingStationRectangle.doorsToSpawn = 1
MainCraftingStationRectangle.enemyTypes = enemyTables.onlyMoths
MainCraftingStationRectangle.npcSpawnTable = npcTables.chest
MainCraftingStationRectangle.npcSpawnTable = WeightedRandom({{CraftingStation, 1}}, 1)
MainCraftingStationRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
MainCraftingStationRectangle.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
MainCraftingStationRectangle.eventSpawnTable = eventTables.noEvent
MainCraftingStationRectangle.floorType = 'Main'
MainCraftingStationRectangle.biome = 'Main'

MainCraftingStationRectangle.buildShape = 'rectangle'

function MainCraftingStationRectangle:init(dir, w, h)
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

function MainCraftingStationRectangle:spawnDoors(dir)
  MainRectangle.spawnDoors(self, dir)
end

function MainCraftingStationRectangle:carveRoom(tileMap)
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
---THE-TOWER--------------------------------------------------------------------------
--------------------------------------------------------------------------------------

TowerDiamond = extend(MainDiamond)
TowerDiamond.doorsToSpawn = 4
TowerDiamond.enemyTypes = enemyTables.extraBirds
TowerDiamond.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
TowerDiamond.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
TowerDiamond.eventSpawnTable = WeightedRandom({{{TrapEvent, InkRaven}, .03}, {{Event, nil}, .97}}, 1)
TowerDiamond.floorType = 'Tower'
TowerDiamond.biome = 'Tower'
TowerDiamond.hasFurniture = true

function TowerDiamond:init(dir)
  MainDiamond.init(self, dir, 21, 21)
end

function TowerDiamond:spawnDoors(dir)
  MainDiamond.spawnDoors(self, dir)
end

function TowerDiamond:carveRoom(tileMap)
  MainDiamond.carveRoom(self, tileMap)
end

function TowerDiamond:spawnFurniture()
  self:createStaircase(self.x + math.round(self.width / 2), self.y + math.round(self.height / 2), 'up')
end

--------------------------------------------------------------------------------------

TowerCorridor = extend(MainCorridor)
TowerCorridor.doorsToSpawn = 1
TowerCorridor.enemyTypes = enemyTables.medium
TowerCorridor.enemySpawnTable = WeightedRandom({{0, 0.5}, {1, 0.25}, {2, 0.25}, {3, 0.1}, {4, 0.01}}, 1.11)
TowerCorridor.dropChance = .5--pickupSpawnTable = WeightedRandom({{0, 0.625}, {1, 0.25}, {2, 0.125}}, 1)
TowerCorridor.eventSpawnTable = WeightedRandom({{{RejectEvent, 'horizontal'}, 0.03}, {{Event, nil}, 0.97}}, 1)
TowerCorridor.floorType = 'Tower'
TowerCorridor.biome = 'Tower'

function TowerCorridor:init(dir)
  MainCorridor.init(self, dir)
end

function TowerCorridor:spawnDoors(dir)
  MainCorridor.spawnDoors(self, dir)
end

function TowerCorridor:carveRoom(tileMap)
  MainCorridor.carveRoom(self, tileMap)
end

--------------------------------------------------------------------------------------

TowerTreasureCircle = extend(MainCircle)
TowerTreasureCircle.doorsToSpawn = 0
TowerTreasureCircle.enemyTypes = enemyTables.onlyMoths
TowerTreasureCircle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
TowerTreasureCircle.dropChance = 1--pickupSpawnTable = WeightedRandom({{4, 0.5}, {5, 0.5}}, 1)
TowerTreasureCircle.eventSpawnTable = eventTables.noEvent
TowerTreasureCircle.floorType = 'Tower'
TowerTreasureCircle.biome = 'Tower'

function TowerTreasureCircle:init(dir)
  MainCircle.init(self, dir, 3)
end

function TowerTreasureCircle:spawnDoors(dir)
  MainCircle.spawnDoors(self, dir)
end

function TowerTreasureCircle:carveRoom(tileMap)
  MainCircle.carveRoom(self, tileMap)
end

--------------------------------------------------------------------------------------

TowerExitRectangle = extend(MainBossRectangle)
TowerExitRectangle.doorsToSpawn = 6
TowerExitRectangle.enemyTypes = enemyTables.onlyMoths
TowerExitRectangle.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
TowerExitRectangle.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
TowerExitRectangle.floorType = 'Tower'
TowerExitRectangle.biome = 'Tower'

function TowerExitRectangle:init(dir)
  MainBossRectangle.init(self, dir, 15, 15, Avian)
end

function TowerExitRectangle:spawnDoors(dir)
  MainBossRectangle.spawnDoors(self, dir)
end

function TowerExitRectangle:carveRoom(tileMap)
  MainBossRectangle.carveRoom(self, tileMap)
end

--------------------------------------------------------------------------------------

TowerIvoryCircle = extend(MainCircle)
TowerIvoryCircle.doorsToSpawn = 0
TowerIvoryCircle.enemyTypes = enemyTables.onlyMoths
TowerIvoryCircle.enemySpawnTable = WeightedRandom({{3, 1}}, 1)
TowerIvoryCircle.dropChance = 1--pickupSpawnTable = WeightedRandom({{5, 0.25}, {7, 0.5}, {9, 0.25}}, 1)
TowerIvoryCircle.floorType = 'Tower'
TowerIvoryCircle.biome = 'Tower'


--------------------------------------------------------------------------------------
---GRAY-DUNGEON-----------------------------------------------------------------------
--------------------------------------------------------------------------------------

GrayChallengeRectangle = extend(MainRectangle)
GrayChallengeRectangle.doorsToSpawn = 6
GrayChallengeRectangle.enemyTypes = enemyTables.hard
GrayChallengeRectangle.enemySpawnTable = WeightedRandom({{5, 0.5}, {6, 0.25}, {7, 0.25}, {8, 0.1}, {9, 0.01}}, 1.11)
GrayChallengeRectangle.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
GrayChallengeRectangle.eventSpawnTable = eventTables.noEvent
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
GrayCorridor.enemyTypes = enemyTables.hard
GrayCorridor.enemySpawnTable = WeightedRandom({{2, 0.5}, {3, 0.25}, {4, 0.25}, {5, 0.1}, {6, 0.01}}, 1.11)
GrayCorridor.dropChance = .5--pickupSpawnTable = WeightedRandom({{0, 0.25}, {1, 0.625}, {2, 0.125}}, 1)
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
GrayTreasureRectangle.dropChance = 1--pickupSpawnTable = WeightedRandom({{3, 0.5}, {4, 0.5}}, 1)
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
GrayExitRectangle.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
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
GreatHallCircle.enemyTypes = enemyTables.onlyWorms
GreatHallCircle.enemySpawnTable = WeightedRandom({{0, .8}, {2, .2}}, 1)
GreatHallCircle.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
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
---CONCOURSE-------------------------------------------------------------------------
--------------------------------------------------------------------------------------

ConcourseCorridor = extend(MainCorridor)
ConcourseCorridor.doorsToSpawn = 12
ConcourseCorridor.enemyTypes = enemyTables.onlyMoths
ConcourseCorridor.enemySpawnTable = WeightedRandom({{0, 1}}, 1)
ConcourseCorridor.dropChance = 0--pickupSpawnTable = WeightedRandom({{0, 1}}, 1)
ConcourseCorridor.eventSpawnTable = eventTables.noEvent
ConcourseCorridor.floorType = 'Main'
ConcourseCorridor.biome = 'Concourse'

function ConcourseCorridor:init(dir)
  MainCorridor.init(self, dir, 120)
end

function ConcourseCorridor:spawnDoors(dir)
  MainCorridor.spawnDoors(self, dir)
end

function ConcourseCorridor:carveRoom(tileMap)
  MainCorridor.carveRoom(self, tileMap)
end

--------------------------------------------------------------------------------------

roomSpawnTables =
{
  Main = WeightedRandom(
    {
      {MainDiamond, 0.2},
      {MainCircle, 0.4},
      {MainStairwell, 0.2},
      {MainRectangle, 0.6},
      {MainShopRectangle, 0.1},
      {MainCraftingStationRectangle, 0.1},
      {MainCorridor, 0.3},
      {TowerCorridor, 0.03},
      {GrayCorridor, 0.03},
      {GreatHallCircle, 0.02},
      {ConcourseCorridor, 0.02}
    }, 2),
  Gray = WeightedRandom(
    {
      {GrayCorridor, 0.2},
      {GrayChallengeRectangle, 0.5},
      {GrayTreasureRectangle, 0.3}
    }, 1),
  GrayBoss = WeightedRandom(
    {
      {GrayCorridor, 0.2},
      {GrayChallengeRectangle, 0.5},
      {GrayTreasureRectangle, 0.2},
      {GrayExitRectangle, 0.1}
    }, 1),
  GrayBossOnly = WeightedRandom(
    {
      {GrayExitRectangle, 1}
    }, 1),
  Great_Hall = WeightedRandom(
    {
      {MainRectangle, 1}
    }, 1),
  Concourse = WeightedRandom(
    {
      {MainRectangle, 1}
    }, 1),
  Tower = WeightedRandom(
    {
      {TowerDiamond, 0.4},
      {TowerCorridor, 0.3},
      {TowerTreasureCircle, 0.3}
    }, 1),
  TowerBoss = WeightedRandom(
    {
      {TowerDiamond, 0.4},
      {TowerCorridor, 0.3},
      {TowerTreasureCircle, 0.2},
      {TowerExitRectangle, 0.1}
    }, 1),
  TowerBossOnly = WeightedRandom(
    {
      {TowerExitRectangle, 1}
    }, 1)
}

biomeBossTriggerCounts = --nil if not triggered from room counter, {min, max} otherwise
{
  Main = nil,
  Gray = {10, 20},
  Great_Hall = nil,
  Tower = {15, 30},
  Concourse = nil
}

biomeFaderMessages = 
{
  Main = {},
  Gray = {enter = 'Fear is the mind killer...'},
  Great_Hall = {enter = 'In this room, I am trivial.'},
  Tower = {enter = '\"You plan a tower that will pierce the clouds? Lay first the foundation of humility.\"\n\nSaint Augustine'},
  Concourse = {enter = 'Five and a half minutes of gloom.'}
}

biomeStaircaseExitRooms = 
{
  Gray = GrayTreasureRectangle,
  Great_Hall = MainRectangle,
  Tower = TowerDiamond,
  Main = MainRectangle,
  Concourse = MainRectangle
}