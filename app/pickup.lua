Pickup = class()

Pickup.tag = 'pickup'
Pickup.collision = {
  shape = 'circle',
  with = {}
}

function Pickup:init(data)
  self.x, self.y = 0, 0
  self.item = nil
  self.itemType = nil
  table.merge(data, self)
  assert(self.item or self.itemType)
  self.radius = 8
  ovw.collision:register(self)
  ovw.view:register(self)
end

function Pickup:draw()
  love.graphics.setColor(255, 255, 255, 80)
  self.shape:draw('line')
end

function Pickup.collision.with.player(self, player, dx, dy)
  if #player.inventory.items < 4 then
    local item = self.item or new(self.itemType)
    ovw.player.inventory:add(item)
    ovw.collision:unregister(self)
    ovw.view:unregister(self)
  end
end
