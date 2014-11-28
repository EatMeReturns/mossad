require 'app/item'

Torch = extend(Item)
Torch.name = 'Torch'

function Torch:init()
  Item.init(self)

  self.type = 'Consumable'
  self.stacks = self.stacks or 1
end

function Torch:activate()
  ovw.spells:add(TorchSpell())
  ovw.player.hotbar:remove(self.index)
end

---

TorchSpell = class()

function TorchSpell:init()
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

function TorchSpell:destroy()
  ovw.view:unregister(self)
end

function TorchSpell:update()
  self.light.intensity = self.light.intensity - (.5 / self.maxHealth * tickRate)
  ovw.house:applyLight(self.light, 'ambient')
  self.health = timer.rot(self.health, function()
    ovw.spells:remove(self)
  end)
end

function TorchSpell:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle('line', self.x, self.y, 10)
end
