----------------
-- Layout
----------------
House.cellSize = 32
House.roomCount = 10
House.roomSpacing = 2
House.carveSize = 2
House.hallwayCount = 5
House.hallwayLength = 30
House.enemyCount = 10
House.itemCount = 5

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

  House.enemyCount = House.enemyCount + 6
  House.itemCount = House.itemCount + 2
end
