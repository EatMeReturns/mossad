Pickup = class()

Pickup.tag = 'pickup'
Pickup.collision = {
  shape = 'circle',
  with = {
  wall = function(self, other, dx, dy)
    self:setPosition(self.x + dx, self.y + dy)
  end
  }
}

function Pickup:init(data)
  self.x, self.y = 0, 0
  self.angle = love.math.random() * math.pi * 2
  self.timers = {}
  self.timers.pickup = 1.25 * (10 / (10 + (ovw.player and ovw.player:getStat('agility', true) or 0)))
  self.pickupSpeed = 1.25
  self.state = 'Not'
  self.item = nil
  self.itemType = nil
  for k, v in pairs(data) do self[k] = v end
  assert(self.item or self.itemType)
  assert(self.room)
  self.room:addObject(self)
  self.radius = 8
  self.depth = DrawDepths.sitters
  ovw.collision:register(self)
  ovw.view:register(self)
end

function Pickup:destroy()
  self.room:removeObject(self)
  ovw.collision:unregister(self)
  ovw.view:unregister(self)
end

function Pickup:remove()
  ovw.pickups:remove(self)
end

function Pickup:draw()
  local tx, ty = ovw.house:cell(self.x, self.y)
  local v = ovw.house.tiles[tx] and ovw.house.tiles[tx][ty] and ovw.house.tiles[tx][ty]:brightness() or 1
  if self.state == 'Hot' then
    local val = self.timers.pickup / (self.pickupSpeed * (10 / (10 + ovw.player:getStat('agility', true))))
    love.graphics.setColor(255, 255, 0, 255)
    love.graphics.rectangle('fill', self.x - self.radius, self.y + self.radius + 2, self.radius * 2 * val, 3)
  else
    love.graphics.setColor(255, 255, 255, v)
  end

  local image = self.item and self.item.image or self.itemType.image
  local scaling = self.item and self.item.scaling or self.itemType.scaling
  if image then
    --draw the image
    love.graphics.setColor(255, 255, 255, v)
    love.graphics.draw(image, self.x, self.y, self.angle, scaling.x, scaling.y, image:getWidth() / 2, image:getHeight() / 2)
  else
    self.shape:draw('line')
  end
end

function Pickup:update()
  if math.distance(self.x, self.y, ovw.player.x, ovw.player.y) < 40 then
    self.state = 'Hot'
    if love.keyboard.isDown('e') then
      self.timers.pickup = timer.rot(self.timers.pickup, function() self:activate() end)
    else
      self.timers.pickup = self.pickupSpeed * (10 / (10 + ovw.player:getStat('agility', true)))
    end
  else
    self.state = 'Not'
  end
end

function Pickup:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end

function Pickup:activate()
  self.item = self.item or new(self.itemType)

  if ovw.player:loot(self.item) then
    return self:remove()
  end
end

function Pickup.collision.with.player(self, player, dx, dy)
  if self.dirty then
    self:setPosition(self.x + dx * 1.3, self.y + dy * 1.3)
    self.dirty = false
    return
  end
end

function Pickup.collision.with.pickup(self, other, dx, dy)
  self:setPosition(self.x + dx / 2, self.y + dy / 2)
  other:setPosition(other.x - dx / 2, other.y - dy / 2)
end
