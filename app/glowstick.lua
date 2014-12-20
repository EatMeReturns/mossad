require 'app/item'

Glowstick = extend(Item)

Glowstick.name = 'Glowstick'

function Glowstick:init()
  Item.init(self)

  self.type = 'Consumable'
  self.stacks = self.stacks or math.round(math.clamp(love.math.randomNormal(1, .75), 1, 2))
end

function Glowstick:activate(alt)
  if alt then
    ovw.spells:add(TorchSpell())
  else
    ovw.spells:add(GlowstickSpell())
  end
  ovw.player.hotbar:remove(self.index)
end

---

GlowstickSpell = class()

function GlowstickSpell:init()
  self.type = 'Buff'
  self.buffName = 'Glowstick'

  self.light = {
    minDis = 50,
    maxDis = 400,
    shape = 'circle',
    intensity = .75,
    falloff = 1,
    posterization = 1,
    flicker = 0.5,
    color = {100, 255, 100, 5} --the fourth value is color intensity, not alpha
  }

  self.health = 60
  self.maxHealth = self.health
end

function GlowstickSpell:update()
  self.light.x, self.light.y = ovw.player.x, ovw.player.y
  ovw.house:applyLight(self.light, 'ambient')
  self.health = timer.rot(self.health, function()
    ovw.spells:remove(self)
  end)
end

function GlowstickSpell:val()
  return self.health / self.maxHealth
end

function GlowstickSpell:maxVal()
  return self.maxHealth
end