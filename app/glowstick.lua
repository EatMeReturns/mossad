require 'app/item'

Glowstick = extend(Item)

Glowstick.name = 'Glowstick'

function Glowstick:init()
  self.light = {
    minDis = 35,
    maxDis = 400,
    intensity = 0,
    falloff = 1,
    posterization = 1
  }
end

function Glowstick:select()
  self.light.intensity = 1
end

function Glowstick:deselect()
  self.light.intensity = 0
end

function Glowstick:update()
  ovw.house:applyLight(self.light)
end
