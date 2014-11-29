Hud = class()

local g = love.graphics
local w, h = g.width, g.height

function Hud:init()
  self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
  self.fader = Fader()
  self.mouseText = 'Test!'
  self.grabbed = {}
  self.grabbed.item = nil
  self.grabbed.slotType = nil --arsenal, hotbar, or inventory?
  self.grabbed.index = 0
  ovw.view:register(self)
end

function Hud:gui()
  g.setFont(self.font)
  self:blood()
  self:stamina()
  self:inventory()
  self:hotbar() 
  self:arsenal()
  self:firstaid()
  self:mouse()
  self.fader:gui()
  self:debug()
end

function Hud:drawBar(x, y, w, h, v, d)
  local segmentW = w / d
  local segmentI = 0
  while v >= 1 / d do
    g.rectangle('fill', x + segmentI * segmentW, y, segmentW - 1, h)
    v = v - 1 / d
    segmentI = segmentI + 1
  end
  if v > 0 then g.rectangle('fill', x + segmentI * segmentW, y, w * v, h) end
end

function Hud:blood() -- Yo sach a hudblood, haarry
  local p = ovw.player
  local alpha = math.max(1 - (tick - p.lastHit) * tickRate, 0) / 6
  alpha = math.min(alpha * 100, 100)
  g.setColor(80, 0, 0, alpha)
  g.rectangle('fill', 0, 0, w(), h())
end

function Hud:stamina()
  local p = ovw.player
  local x = 400 - 50
  local y = 600 - 30
  local ww = 100
  local hh = 7
  local val = p.energy / p.stamina
  local maxVal = p.stamina
  local alpha = val > .9 and 60 + (1 - val) * 1950 or 255
  g.setColor(255, math.min(255, 255 * val * 2), math.max(0, 510 * (val - 0.5)), alpha)
  self:drawBar(x, y, ww, hh, val, maxVal)
end

function Hud:inventory()
  local size = 40
  for i = 1, 3 do
    for j = 1, 8 do
      local item = ovw.player.inventory.items[i][j]
      local alpha = ovw.player.inventory.timers.fadeOut * (not item and 20 or (ovw.player.inventory.items[i][j].focus and 255 or 100))
      g.setColor(255, 255, 255, alpha)
      if item then g.draw(item.image, 650 + (size + 2) * (i - 1) + .5, 100 + (size + 2) * (j - 1) + .5) end
      g.rectangle('line', 650 + (size + 2) * (i - 1) + .5, 100 + (size + 2) * (j - 1) + .5, size, size)
      if item then
        if item.stacks then
          g.print(item.stacks, 650 + (size + 2) * (i - 1) + .5 + 4, 100 + (size + 2) * (j - 1) + .5 + 1)
        end
        local val = item.val and item:val() or 0
        g.rectangle('fill', 650 + (size + 2) * (i - 1) + .5, 100 + (size + 2) * (j - 1) + .5 + size - 3, size * val, 3)
      end
    end
  end
end

function Hud:hotbar()
  local size = 40
  for i = 1, 5 do
    local item = ovw.player.hotbar.items[i]
    local alpha = not item and 20 or (ovw.player.hotbar.items[i].active and 255 or 100)
    g.setColor(255, 255, 255, alpha)
    if item then g.draw(item.image, 2 + (size + 2) * (i - 1) + .5, 2 + .5) end
    g.rectangle('line', 2 + (size + 2) * (i - 1) + .5, 2 + .5, size, size)
    if item then
      if item.stacks then
        g.print(item.stacks, 2 + (size + 2) * (i - 1) + .5 + 4, 2 + .5 + 1)
      end
      local val = item.val and item:val() or 0
      local maxVal = item.maxVal and math.min(20, item:maxVal()) or 1
      self:drawBar(2 + (size + 2) * (i - 1) + .5, 2 + .5 + size - 3, size, 3, val, maxVal)
      --g.rectangle('fill', 2 + (size + 2) * (i - 1) + .5, 2 + .5 + size - 3, size * val, 3)
    end
  end
end

function Hud:arsenal()
  local size = 40
  for i = 1, 2 do
    local weapon = ovw.player.arsenal.weapons[i]
    local alpha = not weapon and 10 or (ovw.player.arsenal.selected == i and 255 or 100)
    g.setColor(255, 255, 255, alpha)
    if weapon then g.draw(weapon.image, 2 + .5, 2 + (size + 2) * (i + 1) + .5) end
    g.rectangle('line', 2 + .5, 2 + (size + 2) * (i + 1) + .5, size, size)
    if weapon then
      if weapon.stacks then
        g.print(weapon.stacks, 2 + .5 + 1, 2 + (size + 2) * (i + 1) + .5 + 4)
      end
      local val = weapon.val and weapon:val() or 0
      local maxVal = weapon.maxVal and weapon:maxVal() or 1
      if weapon.state == 'Reloading' then 
        g.setColor(255, 255, 0, alpha)
      elseif weapon.state == 'Firing' then
        g.setColor(255, 0, 0, alpha)
      end
      self:drawBar(2 + .5, 2 + (size + 2) * (i + 1) + .5, size, 3, val, maxVal)
      --g.rectangle('fill', 2 + .5, 2 + (size + 2) * (i + 1) + .5, size * val, 3)
    end
  end

  if ovw.player.ammo == 0 then g.setColor(255, 0, 0)
  else g.setColor(255, 255, 255) end
  g.print('ammo: ' .. ovw.player.ammo, 2, size * 2 - 8)
end

function Hud:firstaid()
  local size = 40
  for i = 1, 4 do
    local bodyPart = ovw.player.firstAid.bodyParts[i]
    local green, blue = 255, 255
    local alpha = ovw.player.firstAid.timers.fadeOut * (bodyPart.wounded and 255 or (bodyPart.crippled and 255 or 100))
    if bodyPart.crippled then blue = 0 end
    if bodyPart.wounded then green = 0 end
    g.setColor(255, green, blue, alpha)
    g.draw(bodyPart.image, 300 + .5, 220 + (size + 2) * (i - 1) + .5)
    g.rectangle('line', 300 + .5, 220 + (size + 2) * (i - 1) + .5, size, size)
    local val = bodyPart.val and bodyPart:val() or 0
    g.rectangle('fill', 300 + .5, 220 + (size + 2) * (i - 1) + size - 3 + .5, size * val, 3)
  end

  if ovw.player.kits == 0 then g.setColor(255, 0, 0)
  else g.setColor(255, 255, 255) end
  g.print('kits: ' .. ovw.player.kits, 2, size * 2 - 20)
end

function Hud:mouse()
  local size = 40

  self.mouseText = ''

  if love.keyboard.isDown('e') then

    --highlight inventory slots
    for i = 1, 3 do
      for j = 1, 8 do
        local item = ovw.player.inventory.items[i][j]
        if self:mouseOverSlot(650 + (size + 2) * (i - 1) + .5, 100 + (size + 2) * (j - 1) + .5, size) and item then
          --draw a yellow box
          g.setColor(255, 255, 0)
          g.rectangle('line', 650 + (size + 2) * (i - 1) + .5, 100 + (size + 2) * (j - 1) + .5, size, size)
          --set the mouseText
          self.mouseText = item.name
        end
      end
    end

    --highlight hotbar slots
    for i = 1, 5 do
      local item = ovw.player.hotbar.items[i]
      if self:mouseOverSlot(2 + (size + 2) * (i - 1) + .5, 2 + .5, size) and item then
        --draw a yellow box
        g.setColor(255, 255, 0)
        g.rectangle('line', 2 + (size + 2) * (i - 1) + .5, 2 + .5, size, size)
        --set the mouseText
        self.mouseText = item.name
      end
    end

    --highlight arsenal slots
    for i = 1, 2 do
      local weapon = ovw.player.arsenal.weapons[i]
      if self:mouseOverSlot(2 + .5, 2 + (size + 2) * (i + 1) + .5, size) and weapon then
        --draw a yellow box
        g.setColor(255, 255, 0)
        g.rectangle('line', 2 + .5, 2 + (size + 2) * (i + 1) + .5, size, size)
        --set the mouseText
        self.mouseText = weapon.name
      end
    end

    --draw the grabbed item
    g.setColor(255, 255, 255, 255)
    local item = self.grabbed.item
    if item then
      g.draw(item.image, love.mouse.getX() + 15 + .5, love.mouse.getY() + 15 + .5)
      g.rectangle('line', love.mouse.getX() + 15 + .5, love.mouse.getY() + 15 + .5, size, size)
      if item.stacks then
        g.print(item.stacks, love.mouse.getX() + 15 + .5 + 4, love.mouse.getY() + 15 + .5 + 1)
      end
      local val = item.val and item:val() or 0
      g.rectangle('fill', love.mouse.getX() + 15 + .5, love.mouse.getY() + 15 + .5 + size - 3, size * val, 3)
    end
  else
    if self.grabbed.item then self:returnGrabbedItem() end

    if love.keyboard.isDown('tab') then
      --highlight firstaid slots
      for i = 1, 4 do
        local bodyPart = ovw.player.firstAid.bodyParts[i]
        if self:mouseOverSlot(300 + .5, 220 + (size + 2) * (i - 1) + .5, size) then
          --draw a highlight box
          if bodyPart.wounded or bodyPart.crippled then g.setColor(0, 255, 0) else g.setColor(255, 255, 255) end
          g.rectangle('line', 300 + .5, 220 + (size + 2) * (i - 1) + .5, size, size)
          --set the mouseText
          self.mouseText = bodyPart.name .. ((bodyPart.wounded and ' wounded!') or ((bodyPart.crippled and ' crippled!') or ''))
        end
      end
    end
  end

  --print the mouse text
  g.setColor(255, 255, 255, 255)
  g.print(self.mouseText or '', love.mouse.getX() + 15, love.mouse.getY())
end

function Hud:mousepressed(x, y, button)
  local size = 40

  if love.keyboard.isDown('e') then

    --grab inventory slots
    for i = 1, 3 do
      for j = 1, 8 do
        local item = ovw.player.inventory.items[i][j]
        if self:mouseOverSlot(650 + (size + 2) * (i - 1) + .5, 100 + (size + 2) * (j - 1) + .5, size, x, y) then
          if item then
            if self.grabbed.item then
              if self.grabbed.slotType == 'arsenal' and item.type ~= 'Weapon' then
                --can't put not-a-weapon in arsenal!
              elseif self.grabbed.slotType == 'hotbar' and (item.type ~= 'Consumable' and item.type ~= 'Active') then
                --can't put not-a-usable in hotbar!
              elseif button == 'l' then
                if self.grabbed.item.name == item.name and item.stacks then
                  --add stack
                  item.stacks = item.stacks + self.grabbed.item.stacks
                  self.grabbed.item = nil
                else
                  --swap
                  self.grabbed.item, ovw.player.inventory.items[i][j] = ovw.player.inventory.items[i][j], self.grabbed.item
                  ovw.player.inventory.items[i][j].index, self.grabbed.item.index = self.grabbed.item.index, ovw.player.inventory.items[i][j].index
                  self:returnGrabbedItem()
                end
              elseif button == 'r' and self.grabbed.item.name == item.name and item.stacks then
                --pull one from stack
                item.stacks, self.grabbed.item.stacks = item.stacks - 1, self.grabbed.item.stacks + 1
                if item.stacks == 0 then ovw.player.inventory.items[i][j] = nil end
              end
            else
              if button == 'l' then
                --grab stack
                self.grabbed.item, ovw.player.inventory.items[i][j] = ovw.player.inventory.items[i][j], nil
                self.grabbed.index = self.grabbed.item.index
                self.grabbed.slotType = 'inventory'
              elseif button == 'r' and item.stacks then
                --grab one
                self.grabbed.item = _G[item.name]()
                self.grabbed.item.stacks = 1
                self.grabbed.item.index = item.index
                item.stacks = item.stacks - 1
                if item.stacks == 0 then ovw.player.inventory.items[i][j] = nil end
                self.grabbed.index = self.grabbed.item.index
                self.grabbed.slotType = 'inventory'
              end
            end
          else
            if self.grabbed.item then
              --place
              ovw.player.inventory.items[i][j], self.grabbed.item = self.grabbed.item, nil
              ovw.player.inventory.items[i][j].index = (i - 1) * 8 + j
            else
              --you just clicked nothing on an empty slot
            end
          end
          return
        end
      end
    end

    --grab hotbar slots
    for i = 1, 5 do
      local item = ovw.player.hotbar.items[i]
      if self:mouseOverSlot(2 + (size + 2) * (i - 1) + .5, 2 + .5, size, x, y) then
        if item then
          if self.grabbed.item then
            if self.grabbed.item.type ~= 'Consumable' and self.grabbed.item.type ~= 'Active' then
              --can't put not-a-usable in hotbar!
            elseif button == 'l' then
              if self.grabbed.item.name == item.name and item.stacks then
                --add stack
                item.stacks = item.stacks + self.grabbed.item.stacks
                self.grabbed.item = nil
              else
                --swap
                self.grabbed.item, ovw.player.hotbar.items[i] = ovw.player.hotbar.items[i], self.grabbed.item
                ovw.player.hotbar.items[i].index, self.grabbed.item.index = self.grabbed.item.index, ovw.player.hotbar.items[i].index
                self:returnGrabbedItem()
              end
            elseif button == 'r' and self.grabbed.item.name == item.name and item.stacks then
              --pull one from stack
              item.stacks, self.grabbed.item.stacks = item.stacks - 1, self.grabbed.item.stacks + 1
              if item.stacks == 0 then ovw.player.hotbar.items[i] = nil end
            end
          else
            if button == 'l' then
              --grab stack
              self.grabbed.item, ovw.player.hotbar.items[i] = ovw.player.hotbar.items[i], nil
              self.grabbed.index = self.grabbed.item.index
              self.grabbed.slotType = 'hotbar'
            elseif button == 'r' and item.stacks then
              --grab one
              self.grabbed.item = _G[item.name]()
              self.grabbed.item.stacks = 1
              self.grabbed.item.index = item.index
              item.stacks = item.stacks - 1
              if item.stacks == 0 then ovw.player.hotbar.items[i] = nil end
              self.grabbed.index = self.grabbed.item.index
              self.grabbed.slotType = 'hotbar'
            end
          end
        else
          if self.grabbed.item then
            if self.grabbed.item.type ~= 'Consumable' and self.grabbed.item.type ~= 'Active' then
              --can't put not-a-usable in hotbar!
            else
              --place
              ovw.player.hotbar.items[i], self.grabbed.item = self.grabbed.item, nil
              ovw.player.hotbar.items[i].index = i
            end
          else
            --you just clicked nothing on an empty slot
          end
        end
        return
      end
    end

    --grab arsenal slots
    if button == 'l' then
      for i = 1, 2 do
        local weapon = ovw.player.arsenal.weapons[i]
        if self:mouseOverSlot(2 + .5, 2 + (size + 2) * (i + 1) + .5, size, x, y) then
          if weapon then
            if self.grabbed.item then
              if self.grabbed.item.type ~= 'Weapon' then
                --can't put not-a-weapon in arsenal!
              else
                --swap
                self.grabbed.item, ovw.player.arsenal.weapons[i] = ovw.player.arsenal.weapons[i], self.grabbed.item
                ovw.player.arsenal.weapons[i].index, self.grabbed.item.index = self.grabbed.item.index, ovw.player.arsenal.weapons[i].index
                self:returnGrabbedItem()
              end
            else
              --grab
              self.grabbed.item, ovw.player.arsenal.weapons[i] = ovw.player.arsenal.weapons[i], nil
              self.grabbed.index = self.grabbed.item.index
              self.grabbed.slotType = 'arsenal'
            end
          else
            if self.grabbed.item then
              if self.grabbed.item.type ~= 'Weapon' then
                --can't put not-a-weapon in arsenal!
              else
                --place
                ovw.player.arsenal.weapons[i], self.grabbed.item = self.grabbed.item, nil
                ovw.player.arsenal.weapons[i].index = i
              end
            else
              --you just clicked nothing on an empty slot
            end
          end
          return
        end
      end
    end

    if self.grabbed.item then
      --drop dat bass
      if button == 'l' then
      --drop the stack
      elseif button == 'r' then
        --drop one from stack
      end
    end
  elseif love.keyboard.isDown('tab') then
    if button == 'l' or button == 'r' then
      for i = 1, 4 do
        local bodyPart = ovw.player.firstAid.bodyParts[i]
        if self:mouseOverSlot(300 + .5, 220 + (size + 2) * (i - 1) + .5, size) then
          ovw.player.firstAid:setHeal(i)
        end
      end
    end
  end
end

function Hud:returnGrabbedItem()
  local index = self.grabbed.index
  local item = self.grabbed.item
  if self.grabbed.slotType == 'inventory' then
    local i = math.max(1, math.ceil(index / 8))
    local j = (index % 8 == 0 and 8) or (index % 8)
    if ovw.player.inventory.items[i][j] then
      if ovw.player.inventory.items[i][j].name == item.name then
        --add stacks
        ovw.player.inventory.items[i][j].stacks = ovw.player.inventory.items[i][j].stacks + item.stacks
        self.grabbed.item = nil
        return true
      else
        --you broke it.
        return false
      end
    else
      ovw.player.inventory.items[i][j] = item
      self.grabbed.item = nil
      return true
    end
  elseif self.grabbed.slotType == 'hotbar' then
    if ovw.player.hotbar.items[index] then
      if ovw.player.hotbar.items[index].name == item.name then
        --add stacks
        ovw.player.hotbar.items[index].stacks = ovw.player.hotbar.items[index].stacks + item.stacks
        self.grabbed.item = nil
        return true
      else
        --you broke it.
        return false
      end
    else
      ovw.player.hotbar.items[index] = item
      self.grabbed.item = nil
      return true
    end
  elseif self.grabbed.slotType == 'arsenal' then
    if ovw.player.arsenal.weapons[index] then
      --you broke it.
      return false
    else
      ovw.player.arsenal.weapons[index] = item
      self.grabbed.item = nil
      return true
    end
  else
    return false
  end
end

function Hud:debug()
  if not debug then return end
  g.setColor(255, 255, 255)
  g.print(love.timer.getFPS() .. 'fps ' .. (ovw.view.scale * 100) .. '%', 1, h() - g.getFont():getHeight())
end

function Hud:mouseOverSlot(x, y, size, mx, my)
  return (mx or love.mouse.getX()) >= x and (mx or love.mouse.getX()) <= x + size and (my or love.mouse.getY()) >= y and (my or love.mouse.getY()) <= y + size
end