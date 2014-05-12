require 'app/item'

Weapon = extend(Item)

function Weapon:init()
  self.timers = {}
  self.timers.shoot = 0
  self.timers.reload = 0

  self.currentAmmo = self.ammo
  self.currentClip = self.clip
end

function Weapon:destroy()
  --
end

function Weapon:update()
  self.timers.shoot = timer.rot(self.timers.shoot)
  self.timers.reload = timer.rot(self.timers.reload, function()
    local amt = math.min(self.clip - self.currentClip, self.currentAmmo)
    self.currentClip = self.currentClip + amt
    self.currentAmmo = self.currentAmmo - amt
  end)
 
  if self.selected and love.mouse.isDown('l') then
    if self.timers.shoot == 0 and self.timers.reload == 0 and self.currentClip > 0 then
      local projectile = Projectile(self.damage, ovw.player.x, ovw.player.y, ovw.player.angle, 15)
      ovw.spells:add(projectile)

      self.timers.shoot = self.fireSpeed
      self.currentClip = self.currentClip - 1
      if self.currentClip == 0 then self.timers.reload = self.reloadSpeed end
    end
  end
end

function Weapon:reload()
  if self.currentClip < self.clip and self.timers.reload == 0 then
    selef.timers.reload = self.reloadSpeed
  end
end
