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

	self.amount = .25 * (level and (level > 1 and (level ^ (1 + level / 10)) or 1) or 1)
end

function OnyxAgate:update()
	ovw.player.ammoMultiplier = ovw.player.ammoMultiplier + self.amount
	_G[self.style].update(self)
end