Game = class()

function Game:load()
  self.view = View()
  self.hud = Hud()
  self.collision = Collision()
  self.house = House()
  self.player = Player()
  self.spells = Manager()
end

function Game:update()
  self.player:update()
  self.spells:update()
  self.collision:resolve()
  self.view:update()
  self.hud.fader:update()
end

function Game:draw()
  self.view:draw()
end

function Game:keypressed(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'g' then self.view.drawGrid = not self.view.drawGrid
  elseif key == 'r' then
    self.house:destroy()
    self.house = new(House)
  elseif key == 't' then self.house.drawTiles = not self.house.drawTiles end
  self.player:keypressed(key)
end

function Game:mousepressed(...)
  self.view:mousepressed(...)
end
