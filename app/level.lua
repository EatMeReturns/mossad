local hardon = require 'lib/hardon'

Level = class()
Level.gridSize = 32

function Level:init()
  self.rooms = Manager()
  
  self.depth = 5
  ovw.view:register(self)
end

function Level:update()
  self.rooms:update()
end

function Level:draw()
  self.rooms:draw()
end

function Level:load()
  self.rooms:add(Room({
    x = -8,
    y = -4,
    w = 16,
    h = 8
  }))
end

function Level:snap(x, ...)
  if not x then return end
  return math.round(x / self.gridSize) * self.gridSize, self:snap(...)
end

function Level:grid(x, ...)
  if not x then return end
  return x * self.gridSize, self:grid(...)
end
