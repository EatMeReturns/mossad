OnyxAgate = extend(Item)

OnyxAgate.name = 'Onyx Agate'
OnyxAgate.pickupMessage = 'My weapons hunger; the Onyx provides... and also more?'

function OnyxAgate:init(level, materials)
	Item.init(self)

	self.type = 'Passive'
	self.style = ''

	if materials[1] == 'Void Element [Green]' or materials[2] == 'Void Element [Green]' then self.style = 'MossAgate'
	elseif materials[1] == 'Void Element [Purple]' or materials[2] == 'Void Element [Purple]' then self.style = 'ImperialAgate'
	else self.style = 'TigerAgate' end

	self.amount = calculateAgateAmount(level)
end

function OnyxAgate:update()
	ovw.player.ammoMultiplier = ovw.player.ammoMultiplier + (.4 * self.amount - .2)
	_G[self.style].update(self)
end