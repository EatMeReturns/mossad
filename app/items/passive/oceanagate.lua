OceanAgate = extend(Item)

OceanAgate.name = 'Ocean Agate'
OceanAgate.pickupMessage = 'The waters within are calm, healing the soul.'

function OceanAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = calculateAgateAmount(level)
end

function OceanAgate:update()
	ovw.player.healthRegen = ovw.player.healthRegen + (.4 * self.amount - .2)
end