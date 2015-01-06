TigerAgate = extend(Item)

TigerAgate.name = 'Tiger Agate'
TigerAgate.pickupMessage = '\"When a man wants to murder a tiger he calls it sport; when a tiger wants to murder him he calls it ferocity.\"\n\nGeorge Bernard Shaw'

function TigerAgate:init(level)
	Item.init(self)

	self.type = 'Passive'

	self.amount = calculateAgateAmount(level)
	--self.amount = 1 * (level and (level > 1 and (level ^ (1 + level / 10)) ^ (1/3) or 1) or 1)
end

function TigerAgate:update()
	ovw.player.agilityModifier = ovw.player.agilityModifier + self.amount
end