local function load(dir)
  for _, file in pairs(love.filesystem.getDirectoryItems(dir)) do
    local path = dir .. '/' .. file
    if string.find(path, '%.lua') and not string.find(path, '%..+%.lua') then
      require(path:gsub('%.lua', ''))
    end
  end
  
  if love.filesystem.exists(dir .. '.lua') then require(dir) end
end

--Load Libraries and Utilities
load 'lib/lutil'
load 'lib'

--Load the Game
load 'ovw'

--Load Content
load 'app'
load 'app/bosses'
load 'app/buffs'
load 'app/enemies'
load 'app/hud'
load 'app/items'
load 'app/items/active'
load 'app/items/core'
load 'app/items/passive'
load 'app/items/weapons'
load 'app/items/crafting'
load 'app/items/crafting/modifiers'
load 'app/items/crafting/bases'
load 'app/npcs'
load 'app/pickups'
load 'app/player/firstaid'
load 'app/player'
load 'app/spells'

--Load the House
load 'app/house/house'
load 'app/house'