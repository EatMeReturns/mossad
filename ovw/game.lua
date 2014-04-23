Game = class()

function Game:load()
  self:loadColors()
  
  self.collision = Collision()
  self.level = Level()
  self.player = Player()
  
  self.canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
  self.canvas:renderTo(function()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, 800, 600)
    love.graphics.setBlendMode('subtractive')
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle('fill', 400, 300, 200)
    love.graphics.setBlendMode('alpha')
  end)
end

function Game:loadColors()
  white = {255, 255, 255, 255}
  gray = {155, 155, 155, 255}
  black = {0, 0, 0, 255}
  red = {255, 0, 0, 255}
  green = {0, 255, 0, 255}
  blue = {0, 0, 255, 255}
  purple = {255, 0, 255, 255}
  pink = {255, 105, 155, 255}
  yellow = {255, 255, 0, 255}
  orange = {255, 105, 0, 255}
end

function Game:update()
  self.player:update()
  self.level:update()
  self.collision:resolve()
end

function Game:draw()
  love.graphics.push()
  --love.graphics.scale(0.5)
  local x, y = math.lerp(self.player.prevX, self.player.x, delta / tickRate), math.lerp(self.player.prevY, self.player.y, delta / tickRate)
  love.graphics.translate(400 - x, 300 - y)
  self.level:draw()
  self.player:draw()
  love.graphics.pop()
  love.graphics.setColor(255, 255, 255)
  --love.graphics.draw(self.canvas, 0, 0)
end

function Game:keyreleased(key)
  if key == 'escape' then love.event.quit() end
end
