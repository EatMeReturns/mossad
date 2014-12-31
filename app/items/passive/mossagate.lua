MossAgate = extend(Item)

MossAgate.name = 'Moss Agate'
MossAgate.pickupMessage = 'As the moss grows with each passing moment, so do my energies return.'

function MossAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = .025 * (level and (level > 1 and (level ^ (1 + level / 10)) or 1) or 1)
end

function MossAgate:update()
	ovw.player.staminaRegen = ovw.player.staminaRegen + self.amount
end