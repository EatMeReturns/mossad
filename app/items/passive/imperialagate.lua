ImperialAgate = extend(Item)

ImperialAgate.name = 'Imperial Agate'
ImperialAgate.pickupMessage = 'All your life are belong to me'

function ImperialAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = .025 * (level and (level > 1 and (level ^ (1 + level / 10)) or 1) or 1)
end

function ImperialAgate:update()
	ovw.player.lifeStealMultiplier = ovw.player.lifeStealMultiplier + self.amount
end