require 'app/item'

Glowstick = extend(Item)

Glowstick.name = 'Glowstick'

function Glowstick:init()
  Item.init(self)

  self.light = {
    minDis = 35,
    maxDis = 400,
    intensity = 1,
    falloff = 1,
    posterization = 1
  }

  self.health = 10
  self.on = false
end

function Glowstick:select()

end

function Glowstick:deselect()

end

function Glowstick:update()
  if self.on then
    ovw.house:applyLight(self.light)
    self.health = timer.rot(self.health, function()
      ovw.player:removeItem(self.index)
    end)
  end
end

function Glowstick:mousepressed()
  if self.selected then
    self.on = not self.on
  end
end
