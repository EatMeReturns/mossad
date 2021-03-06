Weapon = extend(Item)
Weapon.pickupMessage = 'You\'ve found a bug! Congratulations! This weapon has no pickup message.'

Weapon.MAX_RANGE = 550

function Weapon:init()
  self.timers = {}
  self.timers.shoot = 0
  self.timers.reload = 0
  self.timers.melee = 0

  self.state = 'Idle'
  self.selected = false
  self.reloadSoundState = 0
  
  self.type = 'Weapon'

  self.tipOffset = {
    getX = function() return math.sin(love.mouse.scaleDirection() + math.pi * .54) * 43 end,
    getY = function() return -math.cos(love.mouse.scaleDirection() + math.pi * .54) * 43 end
  }

  self.currentClip = self.clip
end

function Weapon:destroy()
  --
end

function Weapon:update()
  self.timers.shoot = timer.rot(self.timers.shoot)
  self.timers.melee = timer.rot(self.timers.melee)
  if self.selected then
    if self.timers.reload > 0 then 
      self.state = 'Reloading'
      local currentReloadSound = math.ceil(5 * self.timers.reload / (self.reloadSpeed * ((10 / (10 + ovw.player:getStat('agility', true))))))
      if currentReloadSound ~= self.reloadSoundState then
        self.reloadSoundState = currentReloadSound
        local reloadSound = ovw.sound:play('pistol_reload_' .. currentReloadSound..'.wav')
        reloadSound:setVolume(ovw.sound.volumes.fx)
      end
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
      self.timers.reload = self.reloadSpeed * (10 / (10 + ovw.player:getStat('agility', true)))
    else
      self.state = 'Firing'
    end
  end

  if self.state == 'Firing' and not love.mouse.isDown('l') then
    self.state = 'Idle'
  end
 
  if self.selected and love.mouse.isDown('l') and not ovw.player.mouseOverUI then
    if not (self.fireMode ~= 'Automatic' and self.state == 'Firing') then
      if self.timers.shoot == 0 and (self.timers.reload == 0 or self.fireMode == 'Single') and self.currentClip > 0 then
        self.state = 'Firing'

        self:fire()

        self.timers.shoot = self.fireSpeed
        self.currentClip = self.currentClip - 1
        if self.fireMode == 'Single' then self.timers.reload = 0 end
        if self.currentClip == 0 then self.timers.reload = self.reloadSpeed * (10 / (10 + ovw.player:getStat('agility', true))) end
      end
    end
  end
end

function Weapon:fire()
  local x, y = ovw.player.x + self.tipOffset.getX(), ovw.player.y + self.tipOffset.getY()
  for i = 0, self.spread - 1 do 
    local dAngle = ovw.player.angle + i * (love.math.random() * 0.075 - 0.0375)

    local x2, y2 = x + math.dx(Weapon.MAX_RANGE, dAngle), y + math.dy(Weapon.MAX_RANGE, dAngle)
    local wall, d = ovw.collision:lineTest(x, y, x2, y2, 'wall', false, true)
    d = d == math.huge and Weapon.MAX_RANGE or d

    x2, y2 = x + math.dx(d, dAngle), y + math.dy(d, dAngle)
    local enemy, d2 = ovw.collision:lineTest(x, y, x2, y2, 'enemy', false, true)
    d = d2 == math.huge and d or d2
    
    if enemy then
      enemy:hurt(self.damage)
      local splat = ovw.sound:play('shot_splat.wav')
      splat:setVolume(ovw.sound.volumes.fx)
    end
    ovw.particles:add(MuzzleFlash(d, dAngle, {x = x, y = y}, self.damage))
  end
  local shotSound = ovw.sound:play('pistol_gunshot_modified.wav')
  shotSound:setVolume(ovw.sound.volumes.fx)
  local bullet = ovw.sound:play('bullet_drop_modified.wav')
  bullet:setVolume(ovw.sound.volumes.ambience)
end

function Weapon:melee()
  --check reqs
  if self.timers.melee == 0 then
    if self.state ~= 'Firing' then
      local p = ovw.player
      local energyCost = math.sqrt(self.weight) * 2 / 10
      if p.energy >= energyCost then
        --we have the strength!
        p.energy = p.energy - energyCost

        --calculate info
        local meleeRange = 54
        local meleeArcW = math.pi / 2
        local meleeDamage = math.ceil(math.sqrt(self.weight) * 15)
        self.timers.melee = self.weight * 2 / 10

        --find area and check for enemies
        local landed = false
        table.each(ovw.collision:arcTest(p.x, p.y, meleeRange, p.angle, meleeArcW, 'enemy', true, false), function(enemy, key)
          --hit enemies in area
          enemy:hurt(meleeDamage)
          landed = true
        end)

        --add a particle
        ovw.particles:add(MeleeFlash(meleeRange, p.angle, {x = p.x, y = p.y}, meleeArcW))

        if not landed then
          local swing = ovw.sound:play('swing_modified.wav')
          swing:setVolume(ovw.sound.volumes.fx)
        else
          local thud = ovw.sound:play('thud_modified.wav')
          thud:setVolume(math.min(1, ovw.sound.volumes.fx * 2))
        end
      else
        --not enough energy
      end
    end
  end
end

function Weapon:keypressed(key)
  if key == 'r' then
    if self.currentClip < self.clip and self.timers.reload == 0 and ovw.player.ammo > 0 then
      self.timers.reload = self.reloadSpeed * (10 / (10 + ovw.player:getStat('agility', true)))
      self.reloadSoundState = 0
    end
  end
end

function Weapon:val()
  if self.timers.reload > 0 then return self.timers.reload / (self.reloadSpeed * (10 / (10 + ovw.player:getStat('agility', true)))) end
  return self.currentClip / self.clip
end

function Weapon:maxVal()
  if self.timers.reload > 0 then return (self.reloadSpeed * (10 / (10 + ovw.player:getStat('agility', true)))) end
  return self.clip
end