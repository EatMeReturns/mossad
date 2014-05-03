Hud = class()

local g = love.graphics

function Hud:init()
  self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
  ovw.view:register(self)
  self.fader = Fader()
end

function Hud:gui()
  self:debug()
  self:items()
  self.fader:gui()
end

function Hud:debug()
  g.setFont(self.font)
  g.setColor(255, 255, 255)
  g.print(love.timer.getFPS() .. 'fps', 1, g.height() - g.getFont():getHeight())
end

function Hud:items()
  for i = 1, 4 do
    local item = ovw.player.items[i]
    local alpha = not item and 80 or (ovw.player.itemSelect == i and 255 or 160)
    g.setColor(255, 255, 255, alpha)
    g.rectangle('line', 2 + 66 * (i - 1) + .5, 2 + .5, 64, 64)
    if item then
      g.print(item.name, 2 + 66 * (i - 1) + .5 + 4, 2 + .5 + 1)
    end
  end
end
