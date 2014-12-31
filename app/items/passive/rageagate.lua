RageAgate = extend(Item)

RageAgate.name = 'Rage Agate'
RageAgate.pickupMessage = 'My weapons smolder with entrenched anger.' --Rage Agate the Machine

function RageAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = .2 * (level and (level > 1 and (level ^ (1 + level / 10)) or 1) or 1)
end

function RageAgate:update()
	ovw.player.damageMultiplier = ovw.player.damageMultiplier + self.amount
end