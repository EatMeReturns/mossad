Game = class()

function Game:load()
  self.view = View()
  self.hud = Hud()
  self.collision = Collision()
  self.house = House()
  self.player = Player()
  self.spells = Manager()
  self.enemies = Manager()
  self.boss = nil

  Pickup({
    x = self.player.x,
    y = self.player.y + 80,
    itemType = Glowstick
  })

  self.house:spawnEnemies()
end

function Game:update()
  self.house:update()
  self.player:update()
  self.spells:update()
  self.enemies:update()
  if self.boss then self.boss:update() end
  self.collision:resolve()
  self.view:update()
  self.hud.fader:update()
end

function Game:draw()
  self.view:draw()
end

function Game:keypressed(key)
  if key == 'escape' then love.event.quit()
  elseif key == 'r' then
    self.house:destroy()
    self.house = new(House)
  end
  self.player:keypressed(key)
end

function Game:mousepressed(...)
  self.view:mousepressed(...)
  self.player:mousepressed(...)
end
