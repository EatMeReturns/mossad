Game = class()

function Game:load()
  self.view = View()
  self.hud = Hud()
  self.collision = Collision()
  self.level = Level()
  self.player = Player()

  self.level:load()
end

function Game:update()
  self.player:update()
  self.level:update()
  self.collision:resolve()
  self.view:update()
end

function Game:draw()
  self.view:draw()
end

function Game:keypressed(key)
  if key == 'escape' then love.event.quit() end
  self.player:keypressed(key)
end
