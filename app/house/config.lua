----------------
-- Layout
----------------
House.cellSize = 32
House.roomCount = 5
House.roomSpacing = 2
House.carveSize = 2
House.hallwayCount = 5
House.hallwayLength = 30
House.enemyCount = 2

House.increaseDifficulty = function()
  if House.roomCount < 100 then
    House.roomCount = House.roomCount + 5
  end

  if House.hallwayCount < 60 then
    House.hallWayCount = House.hallwayCount + 2
  end

  if House.roomSpacing == 2 then
    House.roomSpacing = 1
  end

  House.enemyCount = House.enemyCount + 3
end
