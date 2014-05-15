Inventory = class()

function Inventory:init()
  self.items = {}
  self.selected = nil
end

function Inventory:update()
  table.with(self.items, 'update')
end

function Inventory:keypressed(...)
  table.with(self.items, 'keypressed', ...)
end

function Inventory:mousepressed(...)
  table.with(self.items, 'mousepressed', ...)
end

function Inventory:add(item)
  local stacks = item.stacks
  if stacks then
    for i = 1, #self.items do
      if self.items[i].name == item.name then
        self.items[i].stacks = self.items[i].stacks + stacks
        return true
      end
    end
  end
  if #self.items < 5 then
    table.insert(self.items, item)
    item.index = #self.items
    if not self.selected then self:select(#self.items) end
    return true
  end
  return false
end

function Inventory:remove(index)
  local item = self.items[index]
  if item then
    if item.stacks then
      item.stacks = item.stacks - 1
      if item.stacks > 0 then
        local sel = item.selected
        f.exe(item.init, item)
        item.selected = sel
        return
      end
    end
    item:destroy()
    table.remove(self.items, index)
    while not self.items[self.selected] do
      self.selected = self.selected - 1
    end
    self:select(self.selected)
  end
end

function Inventory:drop(index)
  index = index or self.selected
  local item = self.items[index]
  if item then
    item.selected = false
    f.exe(item.drop, item)
    Pickup({
      x = ovw.player.x,
      y = ovw.player.y,
      dirty = true,
      item = item
    })
    table.remove(self.items, index)
    while not self.items[self.selected] do
      self.selected = self.selected - 1
    end
    self:select(self.selected)
  end
end

function Inventory:select(index)
  local old, new = self.items[self.selected], self.items[index]
  self.selected = index
  if old then
    old.selected = false
    f.exe(old.deselect, old)
  end

  if new then
    new.selected = true
    f.exe(new.select, new)
  end
end
