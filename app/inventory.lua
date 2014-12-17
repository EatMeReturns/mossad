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
	if love.keyboard.isDown('e') then
		self.timers.fadeIn = timer.rot(self.timers.fadeIn)
		self.timers.fadeOut = 1 - self.timers.fadeIn
	else
		self.timers.fadeOut = timer.rot(self.timers.fadeOut)
		self.timers.fadeIn = 1 - self.timers.fadeOut
	end
end

function Inventory:add(item)
  local stacks = item.stacks
  if stacks then
    for i = 1, #self.items do
      for j = 1, #self.items[i] do
	    if self.items[i][j].name == item.name then
	      self.items[i][j].stacks = self.items[i][j].stacks + stacks
	      return true
	    end
	  end
    end
  end
  local inventoryCount = #self.items[1] + #self.items[2] + #self.items[3]
  if inventoryCount < 24 then
    table.insert(self.items[math.max(1, math.ceil(inventoryCount / 8))], item)
    item.index = inventoryCount + 1
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
