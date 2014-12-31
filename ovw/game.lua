Game = class()

function Game:load()
  devMode = false
  paused = true
  started = false
  useShader = true

  ----------------------------------------------------------------------------------

  WeightedLoot = {}

  WeightedLoot.trash = {
                        items = {
                                {Glowstick, 0.25},
                                {Battery, 0.25},
                                {FirstAidKit, 0.1},
                                {Ammo, 0.4}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {0, .7},
                                {1, .15},
                                {2, .1},
                                {3, .05}
                                },
                        totalSizeWeight = 1
                        }

  WeightedLoot.common = {
                        items = {
                                {Battery, .1},
                                {Glowstick, .05},
                                {FirstAidKit, .05},
                                {Ammo, .72},
                                {Agate, .05},
                                {BloodElement, .01},
                                {ElectricElement, .01},
                                {OceanElement, .01}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {0, 1},
                                {1, .6},
                                {2, .25},
                                {3, .12},
                                {4, .03}
                                },
                        totalSizeWeight = 2
                        }

  WeightedLoot.uncommon = {
                        items = {
                                {FirstAidKit, .45},
                                {Agate, .22},
                                {BloodElement, .1},
                                {ElectricElement, .1},
                                {OceanElement, .1},
                                {EarthElement, .01},
                                {RoyalElement, .01},
                                {FlameElement, .01}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {0, .25},
                                {1, .4},
                                {2, .3},
                                {3, .05}
                                },
                        totalSizeWeight = 1
                        }

  WeightedLoot.rare = {
                        items = {
                                {Pistol, .2},
                                {Shotgun, .2},
                                {Crossbow, .2},
                                {Flaregun, .2},
                                {Rifle, .2},
                                {BeholdEye, .2},
                                {LaserSight, .2},
                                {Camera, .2},
                                {SolarFlare, .2},
                                {Blinkstone, .2}
                                },
                        totalItemWeight = 2,
                        sizes = {
                                {0, .1},
                                {1, .7},
                                {2, .2}
                                },
                        totalSizeWeight = 1
                        }

  ----------------------------------------------------------------------------------
  WeightedShop = {}

  WeightedShop.trash = {
                        items = { --{{Item, Cost}, Weight}
                                {{Glowstick, 1}, 0.5},
                                {{Battery, 2}, 0.3},
                                {{FirstAidKit, 3}, 0.2}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {1, .25},
                                {2, .5},
                                {3, .25}
                                },
                        totalSizeWeight = 1
                        }

  WeightedShop.common = {
                        items = { --{{Item, Cost}, Weight}
                                {{Glowstick, 1}, 0.3},
                                {{Battery, 2}, 0.25},
                                {{FirstAidKit, 3}, 0.27},
                                {{BloodElement, 4}, .06},
                                {{ElectricElement, 4}, .06},
                                {{WaterElement, 4}, .06}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {2, .25},
                                {3, .25},
                                {4, .5}
                                },
                        totalSizeWeight = 1
                        }

  WeightedShop.uncommon = {
                        items = { --{{Item, Cost}, Weight}
                                {{FirstAidKit, 3}, 0.5},
                                {{Agate, 15}, 0.2},
                                {{BloodElement, 4}, .1},
                                {{ElectricElement, 4}, .1},
                                {{WaterElement, 4}, .1}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {2, .25},
                                {3, .25},
                                {4, .5}
                                },
                        totalSizeWeight = 1
                        }

  WeightedShop.rare = {
                        items = { --{{Item, Cost}, Weight}
                                {{Agate, 15}, 0.7},
                                {{RageAgate, 25}, 0.1},
                                {{OceanAgate, 25}, 0.1},
                                {{LightningAgate, 25}, 0.1}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {1, .9},
                                {2, .1}
                                },
                        totalSizeWeight = 1
                        }

  ----------------------------------------------------------------------------------

  function duplicateTable(t) local duplicate = {} table.each(t, function(v, k) duplicate[k] = v end) return duplicate end

  pickupTables = {}

  pickupTables.trash = {
                        items = WeightedRandom(duplicateTable(WeightedLoot.trash.items), WeightedLoot.trash.totalItemWeight),
                        sizes = WeightedRandom(duplicateTable(WeightedLoot.trash.sizes), WeightedLoot.trash.totalSizeWeight),
                        shop = {
                                items = WeightedRandom(duplicateTable(WeightedShop.trash.items), WeightedShop.trash.totalItemWeight),
                                sizes = WeightedRandom(duplicateTable(WeightedShop.trash.sizes), WeightedShop.trash.totalSizeWeight)
                               }
                        }

  pickupTables.getItems = function(rarity, shop, amount)
  --rarity: trash, common, uncommon, rare, epic, legendary, or experience.
  --shop: optional. if true, will return shop items and sizes with attached prices.
  --amount: optional. if nil, will pick randomly from rarity's sizes.

    --either the shop for 'rarity' or 'rarity' itself
    local source = shop and pickupTables[rarity].shop or pickupTables[rarity]

    --either 'amount' or a size value from 'source'
    local size = amount or source.sizes:pick()[1]

    --a table of randomly selected items from 'source' of length 'size'
    local items = source.items:pick(size)

    return items
  end

  pickupTables.makeItem = function(room, position, item, mode, amount) --mode is 'item', 'orb', or 'shop'
  --room: the room to spawn the pickup in.
  --position: the x and y locations of the pickup.
  --item: the itemType of the pickup. if mode is orb, then orbType.
  --mode: item, orb, shop.
  --amount: if mode is shop, then number of stacks.
  --        if mode is orb, then amount for orb to pass in through data table.
  --        if mode is item, then number of stacks.
  --        if amount is nil, then passes in nil for shop and item or 0 for orb.

    if mode == 'orb' then --item is 'experience' or 'health' or 'stamina'
      return ovw.pickups:add(Orb({x = position.x, y = position.y, orbType = item, room = room, amount = amount or 0}))
    elseif mode == 'shop' then --item is {class that extends Item, ammo cost}
      return item
    else --mode == 'item', item is class that extends Item
      return ovw.pickups:add(Pickup({x = position.x, y = position.y, itemType = item, room = room, amount = amount}))
    end
  end

  pickupTables.makeOrb = function(room, position, orbType, amount)
    return ovw.pickups:add(Orb({x = position.x, y = position.y, orbType = orbType, room = room, amount = amount}))
  end

  pickupTables.spawnPickups = function(rarity, source) --source is any table with x, y, and room values
  --rarity: trash, common, uncommon, rare, epic, legendary, or experience.
  --source: the table containing an x and y position to spawn at.
  --        if table has a buildType, then random within that room.
  --        if table has a radius, then random within that circle.
  --        if table has a width and height, then random within that rectangle.
  --        if table has an npcType, then formatted for that npc.
    local room = source.buildShape
    local shop = source.npcType and source.npcType == 'Shop'
    local orb = rarity == 'experience' or rarity == 'stamina' or rarity == 'health'
    local mode = shop and 'shop' or (orb and 'orb' or 'item')

    local getPickupPosition = function()
      local position = {x = source.x, y = source.y}
      if room then
        local x, y = House.pos(nil, source.x, source.y)
        if room == 'circle' then
          local dir = love.math.random() * math.pi * 2 - math.pi
          local dis = love.math.random() * (source.radius - 2)
          x = House.pos(nil, source.x + source.width / 2) + House.pos(nil, math.cos(dir) * dis)
          y = House.pos(nil, source.y + source.height / 2) + House.pos(nil, math.sin(dir) * dis)
        elseif room == 'diamond' then
          local dimensionsRatio = (source.height / source.width)
          x = source.x + House.halfCell + love.math.random() * ((source.width - 2) * House.cellSize)
          local tx = math.round(source.width / 2 + .5) * House.cellSize - math.abs(x - source.x * House.cellSize - math.round(source.width / 2 + .5) * House.cellSize)
          tx = tx * .6
          y = source.y + House.halfCell + House.pos(nil, source.height / 2) - dimensionsRatio * tx + love.math.random() * tx * dimensionsRatio * 2
        else --rectangle
          x = source.x + House.halfCell + love.math.random() * ((source.width - 2) * House.cellSize)
          y = source.y + House.halfCell + love.math.random() * ((source.height - 2) * House.cellSize)
        end
        position.x, position.y = x, y
      elseif source.radius then
        local dir = love.math.random() * math.pi * 2 - math.pi
        local dis = love.math.random() * (source.radius - 2)
        position.x = source.x + math.cos(dir) * dis
        position.y = source.y + math.sin(dir) * dis
      elseif source.width and source.height then
        position.x = source.x + love.math.random() * source.width
        position.y = source.y + love.math.random() * source.height
      end
      return position
    end

    local pickups = {}
    table.each(pickupTables.getItems(rarity, shop), function(item, index)
      local position = getPickupPosition()
      table.insert(pickups, pickupTables.makeItem(room and source or source.room, {x = position.x, y = position.y}, item, mode))
    end)
    return pickups
  end

  pickupTables.drop = function(source)
    if source.dropChance and love.math.random() < source.dropChance then
      local rarities = {}
      table.insert(rarities, House.getRarity())
      local diff = (House.getDifficulty(true) - 1) / 20 --if you're level 20, you'll always get essentials
      if love.math.random() < diff then table.insert(rarities, 'trash') end

      table.each(rarities, function(rarity) pickupTables.spawnPickups(rarity, source) end)
    end
  end

  ----------------------------------------------------------------------------------

  self.view = View()
  self.collision = Collision()
  self.menu = Menu()
  self.tutorial = Tutorial()
  self.fileManager = FileManager()

  self.toUpdate = {}

  --load the cursors
  cursors = {}
  cursors.pointer = love.mouse.newCursor('media/graphics/cursors/pointer.png', 0, 0)
  cursors.target =  love.mouse.newCursor('media/graphics/cursors/target.png', 16, 16)
  love.mouse.setCursor(cursors.pointer)
end

function Game:start(agility, armor, stamina)
  self.hud = Hud()
  self.buffs = Manager()
  self.spells = Manager()
  self.particles = Manager()
  self.enemies = Manager()
  self.npcs = Manager()
  self.pickups = Manager()
  self.furniture = Manager()
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
      table.insert(self.toUpdate, self.house) --level generation first, gotta have rooms
      table.insert(self.toUpdate, self.player) --player stats modify pretty much everything else
      table.insert(self.toUpdate, self.buffs) --may affect future calculations/modifiers
      table.insert(self.toUpdate, self.spells)
      table.insert(self.toUpdate, self.particles)
      table.insert(self.toUpdate, self.enemies)
      table.insert(self.toUpdate, self.npcs)
      table.insert(self.toUpdate, self.pickups)
      table.insert(self.toUpdate, self.furniture)
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
  self:clearStreams()
  self.view = View()
  self.collision = Collision()
  self.menu = Menu()
  self.hud = nil
  self.buffs = nil
  self.spells = nil
  self.particles = nil
  self.enemies = nil
  self.npcs = nil
  self.pickups = nil
  self.furniture = nil
  self.house = nil
  self.player = nil
  self.boss = nil

  started = false
  paused = true

  self.fileManager:loadOptions()
  love.mouse.setCursor(cursors.pointer)
  --Overwatch:remove(ovw)
  --Overwatch:add(Game)
end

function Game:clearStreams()
  self.toUpdate = {}
  self.view.drawStream = {}
end

function Game:focus(focus)
  if started and not focus then self:pause(true) end
end

function Game:pause(v)
  paused = v and v or not paused
  if not paused then graphicsPaused = false else love.mouse.setCursor(cursors.pointer) end
end

function Game:fullscreen()
  local x, y = love.mouse.scaleX(), love.mouse.scaleY()
  love.window.setFullscreen(not love.window.getFullscreen(), 'desktop')
  Tile.lightingShader:send('windowScale', {love.window.getWidth() / 800, love.window.getHeight() / 600})
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