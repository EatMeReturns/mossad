Room = class()

local function randomFrom(t)
  if #t == 0 then return end
  return t[love.math.random(1, #t)]
end

local dirs = {'north', 'south', 'east', 'west'}

function Room:init()
  self.walls = {
    north = {},
    south = {},
    east = {},
    west = {}
  }

  self.x, self.y = 0, 0
  self.width, self.height = 0, 0
end

function Room:randomWall(dir)
  dir = dir or randomFrom(dirs)
  return self.walls[dir][love.math.random(2, #self.walls[dir] - 1)]
end

function Room:move(dx, dy)
  self.x, self.y = self.x + dx, self.y + dy
end

function Room:moveTo(x, y)
  self.x, self.y = x, y
end

-- Compile all individual wall tiles into maximal-sized rectangles
function Room:compile()
  local startx, starty, prev
  startx, starty, prev = 0, 0
  local n, s, e, w = {}, {}, {}, {}
  for i = 1, #self.walls.north do
    local wall = self.walls.north[i]
    if math.abs(wall.x - prev) > 1 or wall.y ~= starty then
      n[#n + 1] = {x = startx, y = starty, width = prev - startx, height = 1}
      startx = wall.x
    end
    prev = wall.x
  end
  self.walls.north = n
end
