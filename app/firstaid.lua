require 'app/item'

FirstAid = extend(Item)

FirstAid.name = 'First Aid'
FirstAid.cantUse = 0

function FirstAid:init()
  Item.init(self)
  self.stacks = self.stacks or 1
end

function FirstAid:update()
  self.cantUse = timer.rot(self.cantUse)
end

function FirstAid:mousepressed()
  if self.selected then
    if ovw.player.crippled then
      ovw.player:uncripple()
      ovw.restartTimer = 0
      ovw.player.inventory:remove(self.index)
      ovw.hud.fader:add('ty raka')
    elseif self.cantUse == 0 then
      ovw.hud.fader:add('dat aint me')
      self.cantUse = 6
    end
  end
end

