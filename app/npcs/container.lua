Container = extend(NPC)

Container.collision = setmetatable({}, {__index = NPC.collision})
Container.collision.shape = 'rectangle'
Container.width = 30
Container.height = 30

Container.npcType = 'Container'

function Container:init(data)
	NPC.init(self, data)

	self.name = 'Container' --Ammo Box, Corpse, Storage Chest, ???
	self.items = {}
	self.dropChance = 1
	self.depth = DrawDepths.furniture
end

Container.activate = f.empty