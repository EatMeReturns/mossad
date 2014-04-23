Hud = class()

local g = love.graphics

function Hud:init()
  self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
  ovw.view:register(self)
end

function Hud:gui()
  g.setFont(self.font)
  g.setColor(255, 255, 255)
  g.print(love.timer.getFPS() .. 'fps', 0, 0)
end
