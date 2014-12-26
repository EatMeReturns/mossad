Event = class()

Event.showTimer = false -- flag requires self.timer, adds timer to hud subtext
Event.repeatable = false -- will only repeat if triggered again

function Event:init(room)
	self.triggered = false
	self.room = room
end

function Event:triggerEvent()
	if not self.triggered then ovw.player.events[self] = self end
	self.triggered = true
end

function Event:endEvent()
	ovw.player.events[self] = nil
	if self.repeatable then self:resetEvent() end
end

function Event:updateEvent()
	if self.timer then
		self.timer = self.timer - tickRate
		if self.timer <= 0 then
			return true
		end
	end

	return false
end

function Event:resetEvent()
	self.triggered = false
end