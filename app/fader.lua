Fader = class()

function Fader:init()
	self.currentText = 1
	self.textCount = 1
	self.texts = {}
	self.texts[1] = 'mossad is coming'
	self.opacity = -255
	ovw.view:register(self)
end

function Fader:add(text) --USE ME TO ADD A NEW MESSAGE TO THE FADER
	self.textCount = self.textCount + 1
	self.texts[self.textCount] = text
end

function Fader:fade()
	self.opacity = self.opacity + tickRate * 100
end

function Fader:update()
	if self.texts[self.currentText] then
		if self.opacity < 255 then
			self:fade()
		else
			self.texts[self.currentText] = nil
			self.currentText = self.currentText + 1
			self.opacity = -255
		end
	end
end

function Fader:gui()
	if self.texts[self.currentText] then
		love.graphics.setColor(255, 255, 255, 255 - math.abs(self.opacity))
		love.graphics.printf(self.texts[self.currentText], W(0.5) - 150, H(0.5), 300, "center")
	end
end