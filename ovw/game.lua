Game = class()

function Game:load()
  devMode = false
  paused = true
  started = false
  useShader = true

  ----------------------------------------------------------------------------------

  DrawDepths = {}
  DrawDepths.debug = -100 --shapes
  DrawDepths.air = -5 --muzzleflash, meleeflash, blood
  DrawDepths.player = -3 --the player
  DrawDepths.movers = -2 --enemies, npcs
  DrawDepths.walls = -1 --room walls, unpassable terrain
  DrawDepths.sitters = 0 --pickups, flares, default spell
  DrawDepths.furniture = 1 --staircases, chests
  DrawDepths.ground = 2 --blood splats
  DrawDepths.doodads = 4 --floor sprites
  DrawDepths.house = 5 --tiles


  ----------------------------------------------------------------------------------

  WeightedLoot = {}

  WeightedLoot.rarities = {
                          {'trash', 1},      -- + .000 / 20 * House.getDifficulty(true)
                          {'common', .1},    -- + .900 / 20 * House.getDifficulty(true)
                          {'uncommon', .01}, -- + .990 / 20 * House.getDifficulty(true)
                          {'rare', .001}     -- + .999 / 20 * House.getDifficulty(true)
                          }
  WeightedLoot.totalRarityWeight = 1.1110

  WeightedLoot.trash = {
                        items = {
                                {Glowstick, 0.1},
                                {Battery, 0.05},
                                {FirstAidKit, 0.1},
                                {Ammo, 0.75}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {1, .5},
                                {2, .3},
                                {3, .2}
                                },
                        totalSizeWeight = 1
                        }

  WeightedLoot.common = {
                        items = {
                                {Battery, .17},
                                {Glowstick, .1},
                                {FirstAidKit, .05},
                                {Ammo, .6},
                                {Agate, .05},
                                {BloodElement, .01},
                                {ElectricElement, .01},
                                {OceanElement, .01}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {1, .6},
                                {2, .25},
                                {3, .12},
                                {4, .03}
                                },
                        totalSizeWeight = 1
                        }

  WeightedLoot.uncommon = {
                        items = {
                                {FirstAidKit, .44},
                                {Agate, .2},
                                {BloodElement, .11},
                                {ElectricElement, .11},
                                {OceanElement, .11},
                                {EarthElement, .01},
                                {RoyalElement, .01},
                                {FlameElement, .01}
                                },
                        totalItemWeight = 1,
                        sizes = {
                                {1, .5},
                                {2, .4},
                                {3, .1}
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
                                {1, .75},
                                {2, .25}
                                },
                        totalSizeWeight = 1
                        }

  ----------------------------------------------------------------------------------
  WeightedShop = {}

  WeightedShop.trash = {
                        items = { --{{Item, Cost}, Weight}
                                {{Glowstick, 1}, 0.4},
                                {{Battery, 2}, 0.2},
                                {{FirstAidKit, 3}, 0.4}
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
                                {{Glowstick, 1}, 0.23},
                                {{Battery, 2}, 0.2},
                                {{FirstAidKit, 3}, 0.27},
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

  function duplicateTable(t) return table.duplicate(t) end--local duplicate = {} table.each(t, function(v, k) duplicate[k] = v end) return duplicate end

  pickupTables = {}

  pickupTables.trash = {
                        items = WeightedRandom(duplicateTable(WeightedLoot.trash.items), WeightedLoot.trash.totalItemWeight),
                        sizes = WeightedRandom(duplicateTable(WeightedLoot.trash.sizes), WeightedLoot.trash.totalSizeWeight),
                        shop = {
                                items = WeightedRandom(duplicateTable(WeightedShop.trash.items), WeightedShop.trash.totalItemWeight),
                                sizes = WeightedRandom(duplicateTable(WeightedShop.trash.sizes), WeightedShop.trash.totalSizeWeight)
                               }
                        }

  pickupTables.common = {
                        items = WeightedRandom(duplicateTable(WeightedLoot.common.items), WeightedLoot.common.totalItemWeight),
                        sizes = WeightedRandom(duplicateTable(WeightedLoot.common.sizes), WeightedLoot.common.totalSizeWeight),
                        shop = {
                                items = WeightedRandom(duplicateTable(WeightedShop.common.items), WeightedShop.common.totalItemWeight),
                                sizes = WeightedRandom(duplicateTable(WeightedShop.common.sizes), WeightedShop.common.totalSizeWeight)
                               }
                        }

  pickupTables.uncommon = {
                        items = WeightedRandom(duplicateTable(WeightedLoot.uncommon.items), WeightedLoot.uncommon.totalItemWeight),
                        sizes = WeightedRandom(duplicateTable(WeightedLoot.uncommon.sizes), WeightedLoot.uncommon.totalSizeWeight),
                        shop = {
                                items = WeightedRandom(duplicateTable(WeightedShop.uncommon.items), WeightedShop.uncommon.totalItemWeight),
                                sizes = WeightedRandom(duplicateTable(WeightedShop.uncommon.sizes), WeightedShop.uncommon.totalSizeWeight)
                               }
                        }

  pickupTables.rare = {
                        items = WeightedRandom(duplicateTable(WeightedLoot.rare.items), WeightedLoot.rare.totalItemWeight),
                        sizes = WeightedRandom(duplicateTable(WeightedLoot.rare.sizes), WeightedLoot.rare.totalSizeWeight),
                        shop = {
                                items = WeightedRandom(duplicateTable(WeightedShop.rare.items), WeightedShop.rare.totalItemWeight),
                                sizes = WeightedRandom(duplicateTable(WeightedShop.rare.sizes), WeightedShop.rare.totalSizeWeight)
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
  --        if mode is chest, then number of stacks.
  --        if mode is orb, then amount for orb to pass in through data table.
  --        if mode is item, then number of stacks.
  --        if amount is nil, then passes in nil for shop and item or 0 for orb.

    if mode == 'orb' then --item is 'experience' or 'health' or 'stamina'
      return ovw.pickups:add(Orb({x = position.x, y = position.y, orbType = item, room = room, amount = amount or 0}))
    elseif mode == 'shop' then --item is {class that extends Item, ammo cost}
      return item
    elseif mode == 'chest' then --item is class that extends Item
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
    local chest = source.npcType and source.npcType == 'Chest'
    local orb = rarity == 'experience' or rarity == 'stamina' or rarity == 'health'
    local mode = shop and 'shop' or (chest and 'chest' or (orb and 'orb' or 'item'))

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
          x = x + House.halfCell + love.math.random() * ((source.width - 2) * House.cellSize)
          local tx = math.round(source.width / 2 + .5) * House.cellSize - math.abs(x - source.x * House.cellSize - math.round(source.width / 2 + .5) * House.cellSize)
          tx = tx * .6
          y = y + House.halfCell + House.pos(nil, source.height / 2) - dimensionsRatio * tx + love.math.random() * tx * dimensionsRatio * 2
        else --rectangle
          x = x + House.halfCell + love.math.random() * ((source.width - 2) * House.cellSize)
          y = y + House.halfCell + love.math.random() * ((source.height - 2) * House.cellSize)
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

  pickupTables.drop = function(source, overrideDropChance)
    --calculate chance to drop any loot at all
    local chance = overrideDropChance and overrideDropChance or (source.dropChance and source.dropChance or 1)
    if love.math.random() <= chance then
      --we drop something! setup the tables.
      local rarities = {}
      local pickups = {}

      --calculate the rarity table
      --table.insert(rarities, House.getRarity())
      local difficultyModifier = House.getDifficulty(true) / 20
      local rarityTable = {
                          {'trash', 1 + 0},
                          {'common', .1 + (.1 * difficultyModifier)},
                          {'uncommon', .01 + (.11 * difficultyModifier)},
                          {'rare', .001 + (.111 * difficultyModifier)}
                          }
      local rarityTableTotalWeight = 1 + .1 + .01 + .001 + ((.1 + .11 + .111) * difficultyModifier)
      local weightedRarities = WeightedRandom(rarityTable, rarityTableTotalWeight)

      --select the rarities to spawn from
      local pickedRarity = weightedRarities:pick()[1]
      table.insert(rarities, pickedRarity)
      local diff = (House.getDifficulty(true) - 1) / 20 --if you're level 20, you'll always get essentials
      if love.math.random() < diff then table.insert(rarities, 'trash') end

      --spawn dat loot!
      table.each(rarities, function(rarity, index) table.each(pickupTables.spawnPickups(rarity, source), function(pickup, index) table.insert(pickups, pickup) end) end)
      return pickups
    end
    return {}
  end

  ----------------------------------------------------------------------------------

  self.view = View()
  self.collision = Collision()
  self.sound = Sound()
  self.menu = Menu()
  self.tutorial = Tutorial()
  self.fileManager = FileManager()

  self.toUpdate = {}

  --load the cursors
  cursors = {}
  cursors.pointer = love.mouse.newCursor('media/graphics/cursors/pointer.png', 0, 0)
  cursors.target = love.mouse.newCursor('media/graphics/cursors/target.png', 16, 16)
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
    love.audio.setVolume(self.sound.volumes.master)
    self.sound.music:setVolume(self.sound.volumes.music)
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
      table.insert(self.toUpdate, self.sound)
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

  self.sound:reset()

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
  --TODO: sound options
  if key == 'm' then self.sound:mute(self.sound.music) end

  if started then
    if key == 'n' then self.hud.notebook:toggle() end
    if key == 'escape' then self:pause() end
    if self.tutorial.state ~= 'Done' then
      --TODO: check tutorial navigation input
      if key == 'return' then self.tutorial:next() end
      if key == 'backspace' then self.tutorial:back() end
    elseif self.hud.notebook.open then
      --TODO: check notebook navigation input
      if key == 'return' then self.hud.notebook:next() end
      if key == 'backspace' then self.hud.notebook:back() end
    end
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