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
end

House.getDifficulty = function(multiplier, round) --if multiplier is true, ~basically~ returns 1 + difficulty / 10. if round is true, rounds to nearest integer when multiplier is false.
  local currentFloor = ovw.house and ovw.house.currentFloor or 1
  local diff = multiplier and (House.difficultyMult * (1 + math.abs(currentFloor / 10))) or (House.difficulty * (1 + math.abs(currentFloor / 10)))
  if not multiplier and round then diff = math.round(diff) end
  return diff
end

House.getRarity = function(floor) --if floor is true, will scale based on current floor
  local currentFloor = ovw.house and ovw.house.currentFloor or 1
  local diff = House.difficulty * (floor and (math.abs(currentFloor) + 1) or 1)
  if diff <= 5 then return 'trash'
  elseif diff <= 10 then return 'common'
  elseif diff <= 15 then return 'uncommon'
  elseif diff <= 20 then return 'rare'
  elseif diff <= 25 then return 'epic'
  else return 'legendary' end
end