View = class()

function View:init()
  self.x = 0
  self.y = 0
  self.w = 600
  self.h = 450
  self.toDraw = {}
  self.target = nil

  self:resize()
  self.prevx = 0
  self.prevy = 0
  self.prevscale = self.scale
end

function View:update()
  self.prevx = self.x
  self.prevy = self.y
  self.prevscale = self.scale
  
  self:follow()
end

function View:draw()
  love.graphics.push()
  love.graphics.translate(0, self.margin)

  love.graphics.push()
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  love.graphics.scale(math.lerp(self.prevscale, self.scale, tickDelta / tickRate))
  love.graphics.translate(-x, -y)
  
  table.sort(self.toDraw, function(a, b)
    return a.depth > b.depth
  end)

  for _, v in ipairs(self.toDraw) do f.exe(v.draw, v) end

  love.graphics.pop()

  for _, v in ipairs(self.toDraw) do f.exe(v.gui, v) end
  
  local w, h = love.graphics.getDimensions()
  love.graphics.pop()
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle('fill', 0, 0, w, self.margin)
  love.graphics.rectangle('fill', 0, h - self.margin, w, self.margin)
end

function View:resize()
  self.scale = love.graphics.getWidth() / self.w
  self.margin = math.max(math.round(((love.graphics.getHeight() - love.graphics.getWidth() * (self.h / self.w)) / 2)), 0)
end

function View:register(x)
  table.insert(self.toDraw, x)
  x.depth = x.depth or 0
end

function View:unregister(x)
  for i = 1, #self.toDraw do
    if self.toDraw[i] == x then table.remove(self.toDraw, i) return end
  end
end

function View:setTarget(obj)
  self.target = obj
end

function View:convertZ(z)
  return (.8 * z) ^ (1 + (.0008 * z))  
end

function View:three(x, y, z)
  z = self:convertZ(z)
  return x - (z * ((self.x + self.w / 2 - x) / 500)), y - (z * ((self.y + self.h / 2 - y) / 500))
end

function View:follow()
  if not self.target then return end

  local dis, dir = math.vector(self.target.x, self.target.y, self:mouseX(), self:mouseY())
  local margin = 0.8

  dis = dis / 5
 
  self.x = self.target.x + math.dx(dis, dir) - (self.w / 2)
  self.y = self.target.y + math.dy(dis, dir) - (self.h / 2)

  self.x = math.clamp(self.x, self.target.x - (self.w * margin), self.target.x + (self.w * margin) - self.w)
  self.y = math.clamp(self.y, self.target.y - (self.h * margin), self.target.y + (self.h * margin) - self.h)
end

function View:mouseX()
  return math.round((love.mouse.getX() / self.scale) + self.x)
end

function View:mouseY()
  return math.round(((love.mouse.getY() - self.margin) / self.scale) + self.y)
end
