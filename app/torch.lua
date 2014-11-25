require 'app/item'

TorchItem = extend(Item)
TorchItem.name = 'Torch'

function TorchItem:init()
  self.stacks = self.stacks or 1
end

function TorchItem:activate()
  ovw.spells:add(Torch())
  ovw.player.hotbar:remove(self.index)
end

---

Torch = class()

function Torch:init()
  self.x, self.y = ovw.player.x, ovw.player.y
  self.light = {
    minDis = 30,
    maxDis = 250,
    intensity = 1,
    falloff = 1,
    posterization = 10,
    x = self.x,
    y = self.y
  }

  self.health = 15
  self.maxHealth = self.health
  ovw.view:register(self)
end

function Torch:destroy()
  ovw.view:unregister(self)
end

function Torch:update()
  self.light.intensity = self.light.intensity - (.5 / self.maxHealth * tickRate)
  ovw.house:applyLight(self.light, 'ambient')
  self.health = timer.rot(self.health, function()
    ovw.spells:remove(self)
  end)
end

function Torch:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle('line', self.x, self.y, 10)
end
