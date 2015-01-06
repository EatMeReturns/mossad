ImperialAgate = extend(Item)

ImperialAgate.name = 'Imperial Agate'
ImperialAgate.pickupMessage = 'All your life are belong to me'

function ImperialAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = calculateAgateAmount(level)
end

function ImperialAgate:update()
	ovw.player.lifeStealMultiplier = ovw.player.lifeStealMultiplier + (.1 * self.amount)
end