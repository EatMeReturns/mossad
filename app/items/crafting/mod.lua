Mod = extend(Item)

function Mod:init(amount)
	Item.init(self)
	self.type = 'Mod'
	self.stacks = amount or 1
end