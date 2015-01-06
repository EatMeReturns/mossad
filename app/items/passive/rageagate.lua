RageAgate = extend(Item)

RageAgate.name = 'Rage Agate'
RageAgate.pickupMessage = 'My weapons smolder with entrenched anger.' --Rage Agate the Machine

function RageAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = calculateAgateAmount(level)
end

function RageAgate:update()
	ovw.player.damageMultiplier = ovw.player.damageMultiplier + (.4 * self.amount - .2)
end