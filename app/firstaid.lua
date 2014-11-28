FirstAid = class()

FirstAid.cantUse = 0

function FirstAid:init()
  self.bodyParts = {}

  self.timers = {}
  self.timers.fadeIn = 1
  self.timers.fadeOut = 0
end

function FirstAid:update()
  self.cantUse = timer.rot(self.cantUse)

  table.with(self.bodyParts, 'update')
  if love.keyboard.isDown('tab') then
    self.timers.fadeIn = timer.rot(self.timers.fadeIn)
    self.timers.fadeOut = 1 - self.timers.fadeIn
  else
    self.timers.fadeOut = timer.rot(self.timers.fadeOut)
    self.timers.fadeIn = 1 - self.timers.fadeOut
  end
end

function FirstAid:activate(index)
  if ovw.player.kits > 0 and ovw.player.crippled then
    ovw.player.kits = ovw.player.kits - 1
    ovw.player:uncripple()
    ovw.restartTimer = 0
    ovw.hud.fader:add('ty raka')
  elseif self.cantUse == 0 then
    ovw.hud.fader:add('dat aint me')
    self.cantUse = 6
  end
end