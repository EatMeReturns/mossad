Room = class()

function Room:init(data)
  table.merge(data, self)
  self:addWalls()

  self:addDoor(self.x + 8, self.y - 1)
end

function Room:draw()
  local g = love.graphics
  g.setColor(50, 50, 50, 100)
  
  g.rectangle('fill', ovw.level:grid(self.x, self.y, self.w, self.h))

  g.setColor(150, 150, 150, 100)
  table.each(self.walls, function(wall)
    g.rectangle('fill', ovw.level:grid(unpack(wall)))
  end)
end

function Room:addWalls()
  self.walls = {}

  -- Ew
  table.insert(self.walls, {self.x - 1, self.y - 1, self.w + 2, 1})
  table.insert(self.walls, {self.x - 1, self.y, 1, self.h})
  table.insert(self.walls, {self.x + self.w, self.y, 1, self.h})
  table.insert(self.walls, {self.x - 1, self.y + self.h, self.w + 2, 1})
end

function Room:addDoor(x, y)
  assert((x >= self.x and x <= self.x + self.w) or (y >= self.y and y <= self.y + self.h))

  table.each(self.walls, function(wall)
    if math.inside(x, y, unpack(wall)) then
      local copy = table.copy(wall)
      wall[3] = x - self.x
      copy[1] = x
      copy[3] = self.w - wall[3] + 1
      table.insert(self.walls, copy)
      return true
    end
  end)
end
