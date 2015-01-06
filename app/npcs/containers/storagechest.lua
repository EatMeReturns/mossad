StorageChest = extend(Container)

StorageChest.npcType = 'Chest'

function StorageChest:init(data)
	Container.init(self, data)
	self.name = 'Storage Chest'
	self.items = {{}, {}, {}} --3x3 grid
	self.dropChance = .35
	table.each(self.items, function(column, index) self.items[index] = pickupTables.drop(self) end)
end

function StorageChest:activate(x, y)
	local item = new(self.items[x][y])

	if ovw.player:loot(item) then
		self.items[x][y] = nil
	end
end