Hotbar = class()

function Hotbar:init()
  self.items = {}
end

function Hotbar:update()
  table.with(self.items, 'update')
end

function Hotbar:mousepressed(...)
  table.with(self.items, 'mousepressed', ...)
end

function Hotbar:add(item)
  if item.type == 'Consumable' or item.type == 'Active' then
    local stacks = item.stacks
    if stacks then
      for i = 1, 5 do
        if self.items[i] and self.items[i].name == item.name then
          self.items[i].stacks = self.items[i].stacks + stacks
          return true
        end
      end
    end
    for i = 1, 5 do
      if not self.items[i] then
        self.items[i] = item
        item.index = i
        return true
      end
    end
  end
  
  return false
end

function Hotbar:remove(index)
  local item = self.items[index]
  if item then
    if item.stacks then
      item.stacks = item.stacks - 1
      if item.stacks > 0 then
        f.exe(item.init, item)
        return
      end
    end
    item:destroy()
    self.items[index] = nil
  end
end

function Hotbar:drop(index)
  local item = self.items[index]
  if item then
    f.exe(item.drop, item)
    Pickup({
      x = ovw.player.x,
      y = ovw.player.y,
      dirty = true,
      item = item
    })
    self.items[index] = nil
  end
end

function Hotbar:activate(index, shift)
  if self.items[index] then self.items[index]:activate(shift) end
end
