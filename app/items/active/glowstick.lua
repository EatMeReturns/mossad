Glowstick = extend(Item)

Glowstick.name = 'Glowstick'

function Glowstick:init(amt)
  Item.init(self)

  self.type = 'Consumable'
  if amt then self.stacks = amt end
  self.stacks = self.stacks or math.round(math.clamp(love.math.randomNormal(1, .75), 1, 2))
end

function Glowstick:activate(alt)
  if alt then
    --ovw.spells:add(TorchSpell())
  else
    ovw.buffs:add(GlowstickBuff())
  end
  ovw.player.hotbar:remove(self.index)
end

---

GlowstickBuff = extend(Buff)

function GlowstickBuff:init()
  Buff.init(self)

  self.name = 'Glowstick'

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
end

function GlowstickBuff:update()
  Buff.update(self)

  self.light.x, self.light.y = ovw.player.x, ovw.player.y
  ovw.house:applyLight(self.light, 'ambient')
end