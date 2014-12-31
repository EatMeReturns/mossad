require 'app/item'

Torch = extend(Item) --UNUSED.
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

TorchSpell = extend(Spell)

function TorchSpell:init()
  Spell.init(self)
  
  self.type = 'Placed'
  self.x, self.y = ovw.player.x, ovw.player.y
  self.light = {
    minDis = 30,
    maxDis = 250,
    shape = 'circle',
    intensity = 1,
    falloff = 1,
    posterization = 10,
    flicker = 0.5,
    color = {100, 255, 100, 5}, --the fourth value is color intensity, not alpha
    x = self.x,
    y = self.y
  }

  self.health = 60
  self.maxHealth = self.health
end

function TorchSpell:update()
  Spell.update(self)

  self.light.intensity = self.light.intensity - (.5 / self.maxHealth * tickRate)
  ovw.house:applyLight(self.light, 'ambient')
end

function TorchSpell:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle('line', self.x, self.y, 10)
end
