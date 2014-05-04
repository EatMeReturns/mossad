Fader = class()

function Fader:init()
	self.text = 'mossad is coming'
	self.opacity = -255
	ovw.view:register(self)
end

function Fader:set(text)
	self.text = text
	self.opacity = -255
end

function Fader:fade()
	self.opacity = self.opacity + tickRate * 100
end

function Fader:update()
	if self.opacity < 255 then
		self:fade()
	else
		self.opacity = 255
	end
end

function Fader:gui()
	love.graphics.setColor(255, 255, 255, 255 - math.abs(self.opacity))
	love.graphics.printf(self.text, W(0.5) - 150, H(0.5), 300, "center")
end