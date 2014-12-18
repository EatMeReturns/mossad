Game = class()

function Game:load()
  devMode = false

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
  {{1, .6}, {2, .25}, {3, .12}, {4, .03}}, 1)

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
  self.hud = Hud()
  self.spells = Manager()
  self.particles = Manager()
  self.enemies = Manager()
  self.npcs = Manager()
  self.pickups = Manager()
  self.house = House()
  self.player = Player()
  self.boss = nil

  --self.house:spawnEnemies()
  --self.house:spawnPickups()
end

function Game:update()
  self.house:update()
  self.player:update()
  self.spells:update()
  self.particles:update()
  self.enemies:update()
  self.npcs:update()
  self.pickups:update()
  if self.boss then self.boss:update() end
  self.collision:resolve()
  self.view:update()
  self.hud.fader:update()
end

function Game:draw()
  self.view:draw()
end

function Game:restart()
  print('restarted.')
  ovw.house:destroy()
  Overwatch:remove(ovw)
  Overwatch:add(Game)
end

function Game:keypressed(key)
  if key == 'escape' then love.event.quit()
  elseif key == '`' then devMode = not devMode end
  self.player:keypressed(key)
end

function Game:mousepressed(...)
  self.view:mousepressed(...)
  self.player:mousepressed(...)
  self.hud:mousepressed(...)
end
