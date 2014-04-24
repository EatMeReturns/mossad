Pickup = class()

Pickup.tag = 'pickup'
Pickup.collision = {
  shape = 'circle',
  with = {
    player = Pickup.pickup
  }
}

function Pickup:init(data)
  self.x, self.y = 0, 0
  self.item = nil
  self.itemType = nil
  table.merge(data, self)
  self.radius = 4
  ovw.collision:register(self)
end

function Pickup:draw()
  love.graphics.setColor(255, 255, 255, 80)
  self.shape:draw('line')
end

function Pickup:pickup(player, dx, dy)
  if #player.items < 4 then
    local item = self.item or new(self.itemType)
    table.insert(player.items, item)
  end
end
