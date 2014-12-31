----------------
-- Layout
----------------
House.cellSize = 32
House.halfCell = House.cellSize / 2
House.roomCount = 10
House.roomSpacing = 2
House.doorSize = 2
House.enemyCount = 10
House.itemCount = 5
House.spawnRange = 350
House.difficulty = 1
House.difficultyMult = 1

oppositeDirections = {
  north = 'south',
  south = 'north',
  east = 'west',
  west = 'east'
}

directionOffsets = {
  north = {0, -House.roomSpacing},
  south = {0, House.roomSpacing},
  east = {House.roomSpacing, 0},
  west = {-House.roomSpacing, 0}
}

directions = {
  north = 'north',
  south = 'south',
  east = 'east',
  west = 'west'
}

House.increaseDifficulty = function()
  House.difficulty = House.difficulty + 1
  House.difficultyMult = House.difficultyMult + 0.1
  print(House.difficulty, House.difficultyMult, House.getRarity())
end

House.getDifficulty = function(multiplier) --if multiplier is true, ~basically~ returns 1 + difficulty / 10.
  return multiplier and House.difficultyMult * (math.abs(ovw.house.currentFloor) + 1) or House.difficulty * (math.abs(ovw.house.currentFloor) + 1)
end

House.getRarity = function(floor) --if floor is true, will scale based on current floor
  local diff = House.difficulty * (floor and (math.abs(ovw.house.currentFloor) + 1) or 1)
  if diff <= 5 then return 'trash'
  elseif diff <= 10 then return 'common'
  elseif diff <= 15 then return 'uncommon'
  elseif diff <= 20 then return 'rare'
  elseif diff <= 25 then return 'epic'
  else return 'legendary' end
end