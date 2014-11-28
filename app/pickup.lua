Pickup = class()

Pickup.tag = 'pickup'
Pickup.collision = {
  shape = 'circle',
  with = {}
}

function Pickup:init(data)
  self.x, self.y = 0, 0
  self.timers = {}
  self.timers.pickup = 1.25
  self.state = 'Not'
  self.item = nil
  self.itemType = nil
  for k, v in pairs(data) do self[k] = v end
  assert(self.item or self.itemType)
  self.radius = 8
  ovw.collision:register(self)
  ovw.view:register(self)
end

function Pickup:destroy()
  ovw.collision:unregister(self)
  ovw.view:unregister(self)
end

function Pickup:draw()
  if self.state == 'Hot' then
    local val = self.timers.pickup / 1.25
    love.graphics.setColor(255, 255, 0, 255)
    love.graphics.rectangle('fill', self.x - self.radius, self.y + self.radius + 2, self.radius * 2 * val, 3)
  else
    love.graphics.setColor(255, 255, 255, 80)
  end
  self.shape:draw('line')
end

function Pickup:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end

function Pickup:activate()
  if self.itemType == Ammo then
    ovw.player.ammo = ovw.player.ammo + math.round(math.clamp(love.math.randomNormal(4, 5), 1, 12))
    return self:destroy()
  end

  if self.itemType == FirstAidKit then
    ovw.player.kits = ovw.player.kits + 1
    return self:destroy()
  end

  self.item = self.item or new(self.itemType)
  if ovw.player.hotbar:add(self.item) then
    self:destroy()
  elseif ovw.player.inventory:add(self.item) then
    self:destroy()
  end
end

function Pickup:update()
  if math.distance(self.x, self.y, ovw.player.x, ovw.player.y + 12) < 40 then
    self.state = 'Hot'
    if love.keyboard.isDown('f') then
      self.timers.pickup = timer.rot(self.timers.pickup, function() self:activate() end)
    else
      self.timers.pickup = 1.25
    end
  else
    self.state = 'Not'
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
