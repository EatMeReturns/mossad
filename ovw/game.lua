Game = class()

function Game:load()
  self.view = View()
  self.hud = Hud()
  self.collision = Collision()
  self.house = House()
  self.player = Player()
  self.spells = Manager()
  self.enemies = Manager()

  for i = 1, 60 do
    local room = self.house.rooms[love.math.random(1, #self.house.rooms)]
    local x, y = self.house:cell(room.x + room.width / 2, room.y + room.height / 2)
    self.enemies:add(Shade(x, y))
  end
end

function Game:update()
  self.house:update()
  self.player:update()
  self.spells:update()
  self.enemies:update()
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
end
