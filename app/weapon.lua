require 'app/item'

Weapon = extend(Item)

function Weapon:init()
  self.timers = {}
  self.timers.shoot = 0
  self.timers.reload = 0

  self.state = 'Idle'
  self.selected = false
  
  self.image = itemImage
  self.type = 'Weapon'

  self.tipOffset = {getX = function() return math.sin(ovw.player.angle + math.pi * 37 / 72) * 40 end, getY = function() return 10 - math.cos(ovw.player.angle + math.pi * 37 / 72) * 40 end}

  self.currentClip = self.clip
end

function Weapon:destroy()
  --
end

function Weapon:update()
  self.timers.shoot = timer.rot(self.timers.shoot)
  if self.selected then
    if self.timers.reload > 0 then 
      self.state = 'Reloading'
    end
    self.timers.reload = timer.rot(self.timers.reload, function()
      local amt = math.min(self.clip - self.currentClip, ovw.player.ammo)
      if self.fireMode == 'Single' then amt = math.min(amt, 1) end
      self.currentClip = self.currentClip + amt
      ovw.player.ammo = ovw.player.ammo - amt
    end)
  else
    self.timers.reload = 0
    self.state = 'Idle'
  end

  if self.state == 'Reloading' and self.timers.reload == 0 then
    if self.fireMode == 'Single' and self.currentClip < self.clip then
      self.timers.reload = self.reloadSpeed
    else
      self.state = 'Firing'
    end
  end

  if self.state == 'Firing' and not love.mouse.isDown('l') then
    self.state = 'Idle'
  end
 
  if self.selected and love.mouse.isDown('l') then
    if not (self.fireMode ~= 'Automatic' and self.state == 'Firing') then
      if self.timers.shoot == 0 and (self.timers.reload == 0 or self.fireMode == 'Single') and self.currentClip > 0 then
        self.state = 'Firing'

        for i = 0, self.spread - 1 do 
          local dAngle = i * (love.math.random() * 0.05 - 0.025)
          local x, y = ovw.player.x + self.tipOffset.getX(), ovw.player.y + self.tipOffset.getY()
          local x2, y2 = x + math.dx(1200, ovw.player.angle + dAngle), y + math.dy(1200, ovw.player.angle + dAngle)
          local wall, d = ovw.collision:lineTest(x, y, x2, y2, 'wall', false, true)
          d = d == math.huge and 1200 or d

          x2, y2 = x + math.dx(d, ovw.player.angle + dAngle), y + math.dy(d, ovw.player.angle + dAngle)
          local enemy, d2 = ovw.collision:lineTest(x, y, x2, y2, 'enemy', false, true)
          d = d2 == math.huge and d or d2
          
          if enemy then enemy:hurt(self.damage) end
          ovw.particles:add(MuzzleFlash(d, ovw.player.angle + i * love.math.random() * 0.075 - 0.0375, {x = x, y = y}))
        end

        self.timers.shoot = self.fireSpeed
        self.currentClip = self.currentClip - 1
        if self.fireMode == 'Single' then self.timers.reload = 0 end
        if self.currentClip == 0 then self.timers.reload = self.reloadSpeed end
      end
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
