require 'app/item'

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
  
  self.image = Item.image
  self.type = 'Weapon'

  self.tipOffset = {getX = function() return math.sin(ovw.player.angle + math.pi * 37 / 72) * 40 end, getY = function() return 10 - math.cos(ovw.player.angle + math.pi * 37 / 72) * 40 end}

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
      self.timers.reload = self.reloadSpeed * (10 / (10 + ovw.player.agility))
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
          local x, y = ovw.player.x + self.tipOffset.getX(), ovw.player.y + self.tipOffset.getY()
          local dAngle = math.direction(x, y, ovw.view:mouseX(), ovw.view:mouseY()) + i * (love.math.random() * 0.075 - 0.0375)

          if self.name == 'Flaregun' then
            ovw.spells:add(FlareSpell(dAngle, x, y, self.damage))
          else
            local x2, y2 = x + math.dx(Weapon.MAX_RANGE, dAngle), y + math.dy(Weapon.MAX_RANGE, dAngle)
            local wall, d = ovw.collision:lineTest(x, y, x2, y2, 'wall', false, true)
            d = d == math.huge and Weapon.MAX_RANGE or d

            x2, y2 = x + math.dx(d, dAngle), y + math.dy(d, dAngle)
            local enemy, d2 = ovw.collision:lineTest(x, y, x2, y2, 'enemy', false, true)
            d = d2 == math.huge and d or d2
            
            if enemy then enemy:hurt(self.damage) end
            ovw.particles:add(MuzzleFlash(d, dAngle, {x = x, y = y}, self.damage))
          end
        end

        self.timers.shoot = self.fireSpeed
        self.currentClip = self.currentClip - 1
        if self.fireMode == 'Single' then self.timers.reload = 0 end
        if self.currentClip == 0 then self.timers.reload = self.reloadSpeed * (10 / (10 + ovw.player.agility)) end
      end
    end
  end
end

function Weapon:melee()
  local meleeRange = 54
  local meleeArcW = math.pi / 2
  --check reqs
  if self.timers.melee == 0 then
    if self.state ~= 'Firing' then
      local p = ovw.player
      local energyCost = self.weight * 2 / 10
      if p.energy >= energyCost then
        --we have the strength!
        p.energy = p.energy - energyCost

        --calculate info
        local meleeDamage = math.ceil(math.sqrt(self.weight) * 15)
        self.timers.melee = self.weight * 2 / 10

        --find area and check for enemies
        table.each(ovw.collision:arcTest(p.x, p.y, meleeRange, p.angle, meleeArcW, 'enemy', true, false), function(enemy, key)
          --hit enemies in area
          enemy:hurt(meleeDamage)
        end)

        --add a particle
        ovw.particles:add(MeleeFlash(meleeRange, p.angle, {x = p.x, y = p.y}, meleeArcW))
      else
        --not enough energy
      end
    end
  end
end

function Weapon:keypressed(key)
  if key == 'r' then
    if self.currentClip < self.clip and self.timers.reload == 0 and ovw.player.ammo > 0 then
      self.timers.reload = self.reloadSpeed * (10 / (10 + ovw.player.agility))
    end
  end
end

function Weapon:val()
  if self.timers.reload > 0 then return self.timers.reload / (self.reloadSpeed * (10 / (10 + ovw.player.agility))) end
  return self.currentClip / self.clip
end

function Weapon:maxVal()
  if self.timers.reload > 0 then return (self.reloadSpeed * (10 / (10 + ovw.player.agility))) end
  return self.clip
end