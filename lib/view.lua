View = class()

function View:init()
  self.x = 0
  self.y = 0
  self.w = 800 / 1.3
  self.h = 600 / 1.3
  self.toDraw = {}
  self.drawStream = {}
  self.target = nil

  self:resize()
  self.prevx = 0
  self.prevy = 0
  self.prevscale = self.scale
  self.followMargin = .8

  self.shake = 0

  self.targetScale = self.scale
  self.targetFollowMargin = self.followMargin

  self.scaleModifier = 0
end

function View:update()
  self.prevx = self.x
  self.prevy = self.y
  self.prevscale = self.scale

  if not devMode then
    self.targetScale = (love.keyboard.isDown('tab') and 3.25 or 1.3) + self.scaleModifier
  end
  
  local prevw, prevh = self.w, self.h
  local xf, yf = love.mouse.scaleX() / love.graphics.getWidth(), love.mouse.scaleY() / love.graphics.getHeight()
  self.scale = math.max(.6, math.lerp(self.scale, self.targetScale, 5 * tickRate))
  self.w = 800 / self.scale
  self.h = 600 / self.scale
  self.x = self.x + (prevw - self.w) * xf
  self.y = self.y + (prevh - self.h) * yf

  self:follow()

  self.x = self.x - self.shake + love.math.random() * 2 * self.shake
  self.y = self.y - self.shake + love.math.random() * 2 * self.shake
  self.shake = math.lerp(self.shake, 0, 5 * tickRate)
end

function View:draw()
  love.graphics.push()
  love.graphics.scale(love.graphics.getWidth() / 800, love.graphics.getHeight() / 600)
  love.graphics.push()
  love.graphics.translate(0, self.margin)

  if started and not paused then
    love.graphics.push()
    local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
    love.graphics.scale(math.lerp(self.prevscale, self.scale, tickDelta / tickRate))
    love.graphics.translate(-x, -y)

    table.sort(self.toDraw, function(a, b)
      return a.depth > b.depth
    end)

    for _, v in ipairs(self.toDraw) do table.insert(self.drawStream, v) end

    for i = 1, #self.drawStream do
      if self.drawStream[i] then f.exe(self.drawStream[i].draw, self.drawStream[i]) end
      self.drawStream[i] = nil
    end
    
    if devMode then
      local xx, yy = ovw.house:snap(x, y)
      love.graphics.setColor(255, 255, 255, 20)
      for i = xx - ovw.house.cellSize, xx + self.w + ovw.house.cellSize, ovw.house.cellSize do
        love.graphics.line(i, y, i, y + self.h)
      end
      for i = yy - ovw.house.cellSize, yy + self.h + ovw.house.cellSize, ovw.house.cellSize do
        love.graphics.line(x, i, x + self.w, i)
      end
    end

    love.graphics.pop()
  end

  for _, v in ipairs(self.toDraw) do f.exe(v.gui, v) end
  
  local w, h = love.graphics.getDimensions()
  love.graphics.pop()
  love.graphics.pop()
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle('fill', 0, 0, w, self.margin)
  love.graphics.rectangle('fill', 0, h - self.margin, w, self.margin)
end

function View:resize()
  self.scale = 0--love.graphics.getWidth() / 800 + 1.3
  self.margin = 0--math.max(math.round(((love.graphics.getHeight() - love.graphics.getWidth() * (self.h / self.w)) / 2)), 0)
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
  self.x = obj.x
  self.y = obj.y
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
  self.targetFollowMargin = love.keyboard.isDown('tab') and 0.5 or 0.8
  self.followMargin = math.lerp(self.followMargin, self.targetFollowMargin, 8 * tickRate)

  dis = dis / 5
 
  self.x = self.target.x + math.dx(dis, dir) - (self.w / 2)
  self.y = self.target.y + math.dy(dis, dir) - (self.h / 2)

  self.x = math.clamp(self.x, self.target.x - (self.w * self.followMargin), self.target.x + (self.w * self.followMargin) - self.w)
  self.y = math.clamp(self.y, self.target.y - (self.h * self.followMargin), self.target.y + (self.h * self.followMargin) - self.h)
end

function View:mousepressed(x, y, button)
  if button == 'wu' then
    self.targetScale = math.min(self.targetScale + .1, 2)
  elseif button == 'wd' then
    self.targetScale = math.max(self.targetScale - .1, .1)
  end
end

function View:mouseX()
  return math.round((love.mouse.scaleX() / self.scale) + self.x)
end

function View:mouseY()
  return math.round(((love.mouse.scaleY() - self.margin) / self.scale) + self.y)
end

function View:playerPosOnScreen()
  local x, y = ovw.player.x - self.x + 85, 600 - (ovw.player.y - self.y) - 60
  local weapon = ovw.player.arsenal.weapons[ovw.player.arsenal.selected]
  if weapon then
    x = x + weapon.tipOffset:getX()
    y = y - weapon.tipOffset:getY()
  end
  return {x, y}
end