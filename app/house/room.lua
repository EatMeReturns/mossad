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
  return self.walls[dir][love.math.random(3, #self.walls[dir] - 2)]
end

function Room:move(dx, dy)
  self.x, self.y = self.x + dx, self.y + dy
end

function Room:moveTo(x, y)
  self.x, self.y = x, y
end
