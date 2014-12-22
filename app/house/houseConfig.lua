----------------
-- Layout
----------------
House.cellSize = 32
House.roomCount = 10
House.roomSpacing = 2
House.doorSize = 2
House.enemyCount = 10
House.itemCount = 5
House.spawnRange = 750
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
