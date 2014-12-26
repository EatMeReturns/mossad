Buff = class()

Buff.name = 'Buff'
Buff.health = 60
Buff.maxHealth = 60

Buff.init = f.empty


function Buff:update()
	self.health = timer.rot(self.health, function()
		ovw.buffs:remove(self)
	end)
end

function Buff:val()
	return self.health / self.maxHealth
end

function Buff:maxVal()
	return self.maxHealth
end