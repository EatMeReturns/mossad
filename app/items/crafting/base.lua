Base = extend(Item)

Base.mods = {} --list of items to craft with it, and what it creates

function Base:init(level)
	Item.init(self)
	self.type = 'Base'
	self.level = level or 1
end