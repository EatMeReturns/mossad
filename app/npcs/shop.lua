Shop = extend(NPC)

Shop.collision = setmetatable({}, {__index = NPC.collision})
Shop.collision.shape = 'circle'
Shop.radius = 20

Shop.npcType = 'Shop'

function Shop:init(data)
	NPC.init(self, data)

	self.dropChance = 1
	self.name = love.math.random() < .5 and 'Battle-Scarred Trader' or 'Orphaned Peddler'
	self.noteTag = ' ammo'
	self.items = {}
	--self.items = table.duplicate(pickupTables.drop(self))
	table.shuffle(self.items)
	table.each(pickupTables.drop(self), function(v, k)
		local item = v[1]()
		local cost = v[2]
		if item.stacks then cost = cost * item.stacks end
		table.insert(self.items, {item, cost})
	end)
end

function Shop:activate(index)
	local item = self.items[index][1]
	local cost = self.items[index][2]

	if ovw.player.ammo >= cost then
		if ovw.player:loot(item) then
			ovw.player.ammo = ovw.player.ammo - cost
			table.remove(self.items, index)
		end
	else
		ovw.hud.fader:add('I require more minerals')
	end
end