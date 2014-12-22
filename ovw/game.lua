Game = class()

function Game:load()
  devMode = false
  paused = true
  started = false

  ----------------------------------------------------------------------------------

  WeightedLoot = {}

  WeightedLoot.Common = WeightedRandom(
    {
      {Battery, .1},
      {Glowstick, .05},
      {FirstAidKit, .05},
      {Ammo, .8}}, 1)

  WeightedLoot.Rare = WeightedRandom(
    {
      {Pistol, .2},
      {Shotgun, .2},
      {Crossbow, .2},
      {Flaregun, .2},
      {Rifle, .2},
      {BeholdEye, .2}}, 1.2)

  ----------------------------------------------------------------------------------

  WeightedLootSizes = {}

  WeightedLootSizes.Common = WeightedRandom(
  {{0, 1}, {1, .6}, {2, .25}, {3, .12}, {4, .03}}, 2)

  WeightedLootSizes.Rare = WeightedRandom(
  {{1, 1}}, 1)

  ----------------------------------------------------------------------------------

  Shop.itemTables.Common = WeightedRandom(
  {
    {{Glowstick, 1}, 0.5},
    {{Battery, 2}, 0.25},
    {{FirstAidKit, 3}, 0.25}}, 1)

  Shop.itemTables.Rare = WeightedRandom(
  {
    {{Glowstick, 1}, 0.5},
    {{Battery, 2}, 0.25},
    {{FirstAidKit, 3}, 0.25}}, 1)
  
  Shop.itemTableSizes = WeightedRandom(
  {
    {2, .25},
    {3, .25},
    {4, .5}}, 1)

  ----------------------------------------------------------------------------------

  function makeLootTable(rarity) return (WeightedLoot[rarity]):pick((WeightedLootSizes[rarity]):pick()[1]) end

  self.view = View()
  self.collision = Collision()
  self.menu = Menu()
  self.tutorial = Tutorial()
  self.fileManager = FileManager()

  self.toUpdate = {}
end

function Game:start(agility, armor, stamina)
  self.hud = Hud()
  self.spells = Manager()
  self.particles = Manager()
  self.enemies = Manager()
  self.npcs = Manager()
  self.pickups = Manager()
  self.house = House()
  self.player = Player(agility, armor, stamina)
  self.boss = nil

  started = true
  paused = false
  self.menu.state = 'Paused'
end

function Game:quit()
  self.fileManager:saveOptions()
  love.event.quit()
end

function Game:update()
  if started then
    if not paused then
      table.insert(self.toUpdate, self.house)
      table.insert(self.toUpdate, self.player)
      table.insert(self.toUpdate, self.spells)
      table.insert(self.toUpdate, self.particles)
      table.insert(self.toUpdate, self.enemies)
      table.insert(self.toUpdate, self.npcs)
      table.insert(self.toUpdate, self.pickups)
      table.insert(self.toUpdate, self.boss)
      table.insert(self.toUpdate, self.collision)
      table.insert(self.toUpdate, self.view)
      table.insert(self.toUpdate, self.hud.fader)
    end
  end

  for i = 1, #self.toUpdate do
    if self.toUpdate[i] then self.toUpdate[i]:update() end
    self.toUpdate[i] = nil
  end
end

function Game:draw()
  self.view:draw()
end

function Game:restart()
  love.event.clear()
  self.toUpdate = {}
  self.view = View()
  self.collision = Collision()
  self.menu = Menu()
  self.hud = nil
  self.spells = nil
  self.particles = nil
  self.enemies = nil
  self.npcs = nil
  self.pickups = nil
  self.house = nil
  self.player = nil
  self.boss = nil

  started = false
  paused = true

  self.fileManager:loadOptions()
  --Overwatch:remove(ovw)
  --Overwatch:add(Game)
end

function Game:focus(focus)
  if started and not focus then self:pause(true) end
end

function Game:pause(v)
  paused = v and v or not paused
  if not paused then graphicsPaused = false end
end

function Game:fullscreen()
  local x, y = love.mouse.scaleX(), love.mouse.scaleY()
  love.window.setFullscreen(not love.window.getFullscreen())
  love.mouse.setPosition(x * (love.graphics.getWidth() / 800), y * (love.graphics.getHeight() / 600))

  ovw.fileManager.optionsData.fullscreen = love.window.getFullscreen()
end

function Game:keypressed(key)
  if key == 'f11' then self:fullscreen() end

  if started then
    if key == 'return' then self.tutorial:next() end
    if key == 'backspace' then self.tutorial:back() end
    if key == 'escape' then self:pause() end
    if paused then
      self.menu:keypressed(key)
    else
      if key == '`' then devMode = not devMode end
      self.player:keypressed(key)
    end
  else
    self.menu:keypressed(key)
  end
end

function Game:mousepressed(...)
  if started and not paused then
    self.view:mousepressed(...)
    self.player:mousepressed(...)
    self.hud:mousepressed(...)
  end
end

function Game:mousereleased(...)
  if not started or paused then
    self.menu:mousereleased(...)
  end
end