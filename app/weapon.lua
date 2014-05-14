require 'app/item'

Weapon = extend(Item)

function Weapon:init()
  self.timers = {}
  self.timers.shoot = 0
  self.timers.reload = 0

  self.currentClip = self.clip
end

function Weapon:destroy()
  --
end

function Weapon:update()
  self.timers.shoot = timer.rot(self.timers.shoot)
  self.timers.reload = timer.rot(self.timers.reload, function()
    local amt = math.min(self.clip - self.currentClip, ovw.player.ammo)
    self.currentClip = self.currentClip + amt
    ovw.player.ammo = ovw.player.ammo - amt
  end)
 
  if self.selected and love.mouse.isDown('l') then
    if self.timers.shoot == 0 and self.timers.reload == 0 and self.currentClip > 0 then
      local x, y = ovw.player.x, ovw.player.y - 15
      local x2, y2 = x + math.dx(1200, ovw.player.angle), y + math.dy(1200, ovw.player.angle)
      local wall, d = ovw.collision:lineTest(x, y, x2, y2, 'wall', false, true)
      d = d == math.huge and 1200 or d

      x2, y2 = x + math.dx(d, ovw.player.angle), y + math.dy(d, ovw.player.angle)
      local enemy, d2 = ovw.collision:lineTest(x, y, x2, y2, 'enemy', false, true)
      d = d2 == math.huge and d or d2
      
      if enemy then enemy:hurt(self.damage) end

      ovw.particles:add(MuzzleFlash(d, ovw.player.angle))

      self.timers.shoot = self.fireSpeed
      self.currentClip = self.currentClip - 1
      if self.currentClip == 0 then self.timers.reload = self.reloadSpeed end
    end
  end
end

function Weapon:keypressed(key)
  if key == 'r' then
    if self.currentClip < self.clip and self.timers.reload == 0 then
      self.timers.reload = self.reloadSpeed
    end
  end
end

function Weapon:val()
  if self.timers.reload > 0 then return self.timers.reload / self.reloadSpeed end
  return self.currentClip / self.clip
end
