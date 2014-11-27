Hud = class()

local g = love.graphics
local w, h = g.width, g.height

function Hud:init()
  self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
  self.fader = Fader()
  self.mouseText = 'Test!'
  ovw.view:register(self)
end

function Hud:gui()
  g.setFont(self.font)
  self:blood()
  self:inventory()
  self:hotbar() 
  self:arsenal()
  self:mouse()
  self.fader:gui()
  self:debug()
end

function Hud:blood() -- Yo sach a hudblood, haarry
  local p = ovw.player
  local amt = 1 - (p.iNeedHealing / p.iNeedTooMuchHealing)
  local alpha = math.max(1 - (tick - p.lastHit) * tickRate, 0) / 6
  alpha = math.min(alpha * 100, 100)
  g.setColor(80, 0, 0, alpha)
  g.rectangle('fill', 0, 0, w(), h())
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
      g.rectangle('fill', 2 + (size + 2) * (i - 1) + .5, 2 + .5 + size - 3, size * val, 3)
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
      if weapon.state == 'Reloading' then 
        g.setColor(255, 255, 0, alpha)
      elseif weapon.state == 'Firing' then
        g.setColor(255, 0, 0, alpha)
      end
      g.rectangle('fill', 2 + .5, 2 + (size + 2) * (i + 1) + .5, size * val, 3)
    end
  end
  if ovw.player.ammo == 0 then g.setColor(255, 0, 0)
  else g.setColor(255, 255, 255) end
  g.print('ammo: ' .. ovw.player.ammo, 2, size * 2 - 8)
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
        g.setColor(255, 255, 0)
        g.rectangle('line', 2 + .5, 2 + (size + 2) * (i + 1) + .5, size, size)
        self.mouseText = weapon.name
      end
    end
  end

  g.setColor(255, 255, 255)
  g.print(self.mouseText or '', love.mouse.getX() + 15, love.mouse.getY())
end

function Hud:debug()
  if not debug then return end
  g.setColor(255, 255, 255)
  g.print(love.timer.getFPS() .. 'fps ' .. (ovw.view.scale * 100) .. '%', 1, h() - g.getFont():getHeight())
end

function Hud:mouseOverSlot(x, y, size)
  return love.mouse.getX() >= x and love.mouse.getX() <= x + size and love.mouse.getY() >= y and love.mouse.getY() <= y + size
end