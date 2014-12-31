Inventory = class()

function Inventory:init()
	self.items = {{}, {}, {}}

	self.timers = {}
	self.timers.fadeIn = 1
	self.timers.fadeOut = 0
end

function Inventory:update()
  table.each(self.items, function(row, key)
    table.each(row, function(item, key)
      if item.type == 'Passive' then item:update() end
    end)
  end)
  if love.keyboard.isDown('tab') or ovw.player.npc and love.keyboard.isDown('e') then
    self.timers.fadeIn = timer.rot(self.timers.fadeIn)
    self.timers.fadeOut = 1 - self.timers.fadeIn
  else
    self.timers.fadeOut = timer.rot(self.timers.fadeOut)
    self.timers.fadeIn = 1 - self.timers.fadeOut
  end
end

function Inventory:draw()
  table.each(self.items, function(row, key)
    table.each(row, function(item, key)
      if item.type == 'Passive' then item:draw() end
    end)
  end)
end

function Inventory:add(item)
  local stacks = item.stacks
  local lowestEmpty = {i = 4, j = 9}
  for i = 1, 3 do
    for j = 1, 8 do
      if self.items[i][j] then
  	    if stacks and self.items[i][j].name == item.name then
  	      self.items[i][j].stacks = self.items[i][j].stacks + stacks
	      return true
       end
      elseif lowestEmpty.i == 4 then
        lowestEmpty = {i = i, j = j}
      end
    end
  end

  if lowestEmpty.i ~= 4 then
    self.items[lowestEmpty.i][lowestEmpty.j] = item
    item.index = (lowestEmpty.i - 1) * 8 + lowestEmpty.j
    return true
  end
  return false
end

function Inventory:remove(index)
  local item = self.items[math.max(1, math.ceil(index / 8))][(index % 8 == 0 and 8) or (index % 8)]
  if item then
    if item.stacks then
      item.stacks = item.stacks - 1
      if item.stacks > 0 then
        f.exe(item.init, item)
        return
      end
    end
    item:destroy()
    table.remove(self.items[math.max(1, math.ceil(index / 8))], (index % 8) + 1)
  end
end

function Inventory:drop(index)
  local item = self.items[index]
  if item then
    f.exe(item.drop, item)
    Pickup({
      x = ovw.player.x,
      y = ovw.player.y,
      dirty = true,
      item = item
    })
    table.remove(self.items, index)
  end
end

function Inventory:activate(index)
  if self.items[index] then self.items[index]:activate() end
end
