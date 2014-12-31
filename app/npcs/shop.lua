Shop = extend(NPC)

Shop.itemTables = {}

Shop.collision = setmetatable({}, {__index = NPC.collision})
Shop.collision.shape = 'circle'
Shop.radius = 20

Shop.npcType = 'Shop'

function Shop:init(data)
	NPC.init(self, data)

	self.name = love.math.random() < .5 and 'Battle-Scarred Trader' or 'Orphaned Peddler'
	self.noteTag = ' ammo'
	self.items = {}
	--local rareItem = self.itemTables.Rare:pick()[1]
	--table.insert(self.items, {rareItem[1], rareItem[2]}) --shop always has 1 rare item. consider revising?
	table.each(pickupTables.spawnPickups('trash', self), function(item, i) table.insert(self.items, {item[1], item[2]}) end)
	table.shuffle(self.items)
	table.each(self.items, function(v, k) v[1] = new(v[1]) if v[1].stacks then v[2] = v[2] * v[1].stacks end end)
end

function Shop:activate(index)
	local item = self.items[index][1]
	local cost = self.items[index][2]

	if ovw.player.ammo >= cost then
		if item.name == 'First Aid Kit' then
				ovw.player.kits = ovw.player.kits + 1
				ovw.player.ammo = ovw.player.ammo - cost
				table.remove(self.items, index)
		elseif item.name == 'Battery' then
				ovw.player.batteries = ovw.player.batteries + 1
				ovw.player.ammo = ovw.player.ammo - cost
				table.remove(self.items, index)
		else
			if ovw.player.hotbar:add(item) then
				ovw.player.ammo = ovw.player.ammo - cost
				table.remove(self.items, index)
				ovw.hud.fader:add(item.pickupMessage)
			elseif ovw.player.arsenal:add(item) then
				ovw.player.ammo = ovw.player.ammo - cost
				table.remove(self.items, index)
				ovw.hud.fader:add(item.pickupMessage)
			elseif ovw.player.inventory:add(item) then
				ovw.player.ammo = ovw.player.ammo - cost
				table.remove(self.items, index)
				ovw.hud.fader:add(item.pickupMessage)
			else
				ovw.hud.fader:add('I am carrying too much...')
			end
		end
	else
		ovw.hud.fader:add('I require more minerals')
	end
end