Inventory = class()

function Inventory:init()
  self.items = {}
  self.selected = nil
end

function Inventory:update()
  table.with(self.items, 'update')
end

function Inventory:mousepressed(...)
  table.with(self.items, 'mousepressed', ...)
end

function Inventory:add(item)
  table.insert(self.items, item)
  item.index = #self.items
  if not self.selected then self:select(#self.items) end
end

function Inventory:remove(index)
  local item = self.items[index]
  if item then
    item:destroy()
    table.remove(self.items, index)
    while not self.items[self.selected] do
      self.selected = self.selected - 1
    end
    self:select(self.itemSelect)
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
