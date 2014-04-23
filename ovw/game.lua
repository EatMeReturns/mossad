Game = class()

function Game:load()
  self:loadColors()
  
  self.view = View()
  self.collision = Collision()
  self.level = Level()
  self.player = Player()
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
  self.view:update()
end

function Game:draw()
  self.view:draw()

  --[[
  love.graphics.push()
  local x, y = math.lerp(self.player.prevX, self.player.x, delta / tickRate), math.lerp(self.player.prevY, self.player.y, delta / tickRate)
  love.graphics.translate(400 - x, 300 - y)
  self.level:draw()
  self.player:draw()
  love.graphics.pop()
  love.graphics.setColor(255, 255, 255)
  ]]
end

function Game:keyreleased(key)
  if key == 'escape' then love.event.quit() end
end
