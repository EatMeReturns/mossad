IrisAgate = extend(Item)

IrisAgate.name = 'Iris Agate'
IrisAgate.pickupMessage = 'The Iris leaves no experience unexamined... and also more?'

function IrisAgate:init(level, materials)
	Item.init(self)

	self.type = 'Passive'
	self.style = ''

	if materials[1] == 'Iridescent Element [Green]' or materials[2] == 'Iridescent Element [Green]' then self.style = 'MossAgate'
	elseif materials[1] == 'Iridescent Element [Purple]' or materials[2] == 'Iridescent Element [Purple]' then self.style = 'ImperialAgate'
	else self.style = 'TigerAgate' end

	self.amount = .25 * (level and (level > 1 and (level ^ (1 + level / 10)) or 1) or 1)
end

function IrisAgate:update()
	ovw.player.experienceMultiplier = ovw.player.experienceMultiplier + self.amount
	_G[self.style].update(self)
end