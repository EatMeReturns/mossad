FirstAid = class()

function FirstAid:init()
  self.bodyParts = {BodyPart('Head', 1), BodyPart('Arms', 2), BodyPart('Torso', 3), BodyPart('Legs', 4)}
  self.debuffs = nil

  self.healPart = 0

  self.timers = {}
  self.timers.healing = 0
  self.timers.fadeIn = 1
  self.timers.fadeOut = 0
end

function FirstAid:update()
  self.timers.healing = timer.rot(self.timers.healing)

  if love.keyboard.isDown('tab') then
    self.timers.fadeIn = timer.rot(self.timers.fadeIn)
    self.timers.fadeOut = 1 - self.timers.fadeIn
  else
    if self.healPart ~= 0 then
      local healBodyPart = self.bodyParts[self.healPart]
      if healBodyPart.hasKit then healBodyPart:cancelHeal() end
    end

    self.timers.fadeOut = timer.rot(self.timers.fadeOut)
    self.timers.fadeIn = 1 - self.timers.fadeOut
  end

  for i = 1, 4 do 
    if started then self.bodyParts[i]:update() else break end
  end
end

function FirstAid:setHeal(index)
  if self.healPart ~= 0 then
    self.bodyParts[self.healPart]:cancelHeal()
    self.healPart = 0
  end

  local healBodyPart = self.bodyParts[index]
  if healBodyPart.currentHealth == healBodyPart.maxHealth and not healBodyPart.crippled then
    ovw.hud.fader:add('dat aint me')
  elseif ovw.player.kits <= 0 then
    ovw.hud.fader:add('find a kit nerd')
  else
    self.healPart = index
    healBodyPart:startHeal()
  end
end