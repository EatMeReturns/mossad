Hud = class()

local g = love.graphics
local w, h = g.width, g.height

function Hud:init()
  self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
  ovw.view:register(self)
  self.fader = Fader()
end

function Hud:gui()
  self:blood()
  self:items()
  self.fader:gui()
  self:debug()
end

function Hud:blood() -- Yo sach a hudblood, haarry
  local p = ovw.player
  local amt = 1 - (p.iNeedHealing / p.iNeedTooMuchHealing)
  local alpha = math.min(((1 - (math.min(amt, .5) / .5)) + math.max(1 - (tick - p.lastHit) * tickRate, 0) / 6) * 200, 200)
  g.setColor(160, 0, 0, alpha)
  g.rectangle('fill', 0, 0, w(), h())
end

function Hud:items()
  local size = 40
  for i = 1, 4 do
    local item = ovw.player.items[i]
    local alpha = not item and 80 or (ovw.player.itemSelect == i and 255 or 160)
    g.setColor(255, 255, 255, alpha)
    g.rectangle('line', 2 + (size + 2) * (i - 1) + .5, 2 + .5, size, size)
    if item then
      g.print(item.name, 2 + (size + 2) * (i - 1) + .5 + 4, 2 + .5 + 1)
    end
  end
end

function Hud:debug()
  g.setFont(self.font)
  g.setColor(255, 255, 255)
  g.print(love.timer.getFPS() .. 'fps ' .. (ovw.view.scale * 100) .. '%', 1, h() - g.getFont():getHeight())
end

