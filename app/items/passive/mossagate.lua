MossAgate = extend(Item)

MossAgate.name = 'Moss Agate'
MossAgate.pickupMessage = 'As the moss grows with each passing moment, so do my energies return.'

function MossAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = calculateAgateAmount(level)
end

function MossAgate:update()
	ovw.player.staminaRegen = ovw.player.staminaRegen + (.04 * self.amount - .02)
end