Spell = class()
Spell.type = 'Placed' --Placed, Projectile, Active
Spell.health = 60
Spell.maxHealth = Spell.health
Spell.x, Spell.y = 0, 0

function Spell:init()
	self.x, self.y = ovw.player.x, ovw.player.y
	ovw.view:register(self)
end

function Spell:destroy()
	ovw.view:unregister(self)
end

function Spell:update()
	self.health = timer.rot(self.health, function()
		ovw.spells:remove(self)
	end)
end

Spell.draw = f.empty