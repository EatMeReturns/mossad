Fader = class()

local g = love.graphics
local w, h = g.width, g.height

function Fader:init()
  self.texts = {}
  self.texts[1] = 'mossad is coming'
  self.texts[2] = 'no really...he is'
  self.opacity = -255
end

function Fader:add(text) --USE ME TO ADD A NEW MESSAGE TO THE FADER
  table.insert(self.texts, text)
end

function Fader:fade()
  self.opacity = math.min(self.opacity + tickRate * 255, 255)
end

function Fader:update()
  if self.texts[1] then
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
    g.printf(self.texts[1], w(0.5) - 150, h(0.5), 300, 'center')
  end
end
