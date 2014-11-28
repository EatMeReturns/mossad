require 'app/item'

Glowstick = extend(Item)

Glowstick.name = 'Glowstick'

function Glowstick:init()
  Item.init(self)

  self.light = {
    minDis = 50,
    maxDis = 400,
    intensity = .75,
    falloff = 1,
    posterization = 1
  }

  self.type = 'Consumable'
  self.health = 120
  self.maxHealth = self.health
  self.stacks = self.stacks or math.round(math.clamp(love.math.randomNormal(2, 1.25), 1, 5))
end

function Glowstick:update()
  if self.active then
    self.light.x, self.light.y = ovw.player.x, ovw.player.y
    ovw.house:applyLight(self.light, 'ambient')
    self.health = self.health - tickRate
    if self.health <= 0 then
      ovw.player.hotbar:remove(self.index)
    end
  end
end

function Glowstick:activate()
  self.active = not self.active
end

function Glowstick:val()
  return self.health / self.maxHealth
end
