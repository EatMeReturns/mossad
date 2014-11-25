Hud = class()

local g = love.graphics
local w, h = g.width, g.height

function Hud:init()
  self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
  self.fader = Fader()
  ovw.view:register(self)
end

function Hud:gui()
  g.setFont(self.font)
  self:blood()
  self:hotbar() 
  self:arsenal()
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

function Hud:hotbar()
  local size = 40
  for i = 1, 5 do
    local item = ovw.player.hotbar.items[i]
    local alpha = not item and 20 or (ovw.player.hotbar.items[i].active and 255 or 100)
    g.setColor(255, 255, 255, alpha)
    g.rectangle('line', 2 + (size + 2) * (i - 1) + .5, 2 + .5, size, size)
    if item then
      local str = item.name
      if item.stacks then str = item.stacks .. ' ' .. str end
      g.print(str, 2 + (size + 2) * (i - 1) + .5 + 4, 2 + .5 + 1)
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
    g.rectangle('line', 2 + .5, 2 + (size + 2) * (i + 1) + .5, size, size)
    if weapon then
      local str = weapon.name
      if weapon.stacks then str = weapon.stacks .. ' ' .. str end
      g.print(str, 2 + .5 + 1, 2 + (size + 2) * (i + 1) + .5 + 4)
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

function Hud:debug()
  if not debug then return end
  g.setColor(255, 255, 255)
  g.print(love.timer.getFPS() .. 'fps ' .. (ovw.view.scale * 100) .. '%', 1, h() - g.getFont():getHeight())
end

