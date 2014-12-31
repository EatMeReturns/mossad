LightningAgate = extend(Item)

LightningAgate.name = 'Lightning Agate'
LightningAgate.pickupMessage = 'I feel tingly...'

function LightningAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = 30 * (level and (level > 1 and (level ^ (1 + level / 10)) or 1) or 1)
end

function LightningAgate:update()
	ovw.player.speedModifier = ovw.player.speedModifier + self.amount
end