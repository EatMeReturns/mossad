Fader = class()

local g = love.graphics
local w, h = 800, 600

function Fader:init()
  self.font = g.newFont('media/fonts/pixel.ttf', 10)
  self.texts = {}
  self.opacity = -255
  self.fadeTimer = 0
end

function Fader:add(text) --USE ME TO ADD A NEW MESSAGE TO THE FADER
  if text then table.insert(self.texts, text) end
end

function Fader:fade()
  self.opacity = math.min(self.opacity + tickRate * 255 / self.fadeTimer, 255)
end

function Fader:update()
  if self.texts[1] then
    self.fadeTimer = math.max(string.len(self.texts[1]) / 15, .8)
    if self.opacity < 255 then
      self:fade()
    else
      table.remove(self.texts, 1)
      self.opacity = -255
    end
  end
end

function Fader:gui()
  if self.texts[1] then
    g.setColor(255, 255, 255, 255 - math.abs(self.opacity))
    g.setFont(self.font)
    g.printf(self.texts[1], w / 2 - 150, h / 2 - 150, 300, 'center')
    g.setFont(ovw.hud.font)
  end
end
