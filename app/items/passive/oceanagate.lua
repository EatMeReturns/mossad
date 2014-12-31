OceanAgate = extend(Item)

OceanAgate.name = 'Ocean Agate'
OceanAgate.pickupMessage = 'The waters within are calm, healing the soul.'

function OceanAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = .2 * (level and (level > 1 and (level ^ (1 + level / 10)) or 1) or 1)
end

function OceanAgate:update()
	ovw.player.healthRegen = ovw.player.healthRegen + self.amount
end