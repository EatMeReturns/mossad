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

	self.amount = calculateAgateAmount(level)
end

function IrisAgate:update()
	ovw.player.experienceMultiplier = ovw.player.experienceMultiplier + (.4 * self.amount - .2)
	_G[self.style].update(self)
end