require 'app/npc'

Shop = extend(NPC)

Shop.itemTables = {}

Shop.collision = setmetatable({}, {__index = NPC.collision})
Shop.collision.shape = 'circle'
Shop.radius = 20

function Shop:init(data)
	NPC.init(self, data)

	self.name = 'Battle-Scarred Trader'
	self.noteTag = ' ammo'
	self.items = {}
	table.insert(self.items, table.copy(self.itemTables.Rare:pick()[1]))
	self.items = table.copy(self.itemTables.Common:pick(self.itemTableSizes:pick()[1]))
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
			elseif ovw.player.arsenal:add(item) then
				ovw.player.ammo = ovw.player.ammo - cost
				table.remove(self.items, index)
			elseif ovw.player.inventory:add(item) then
				ovw.player.ammo = ovw.player.ammo - cost
				table.remove(self.items, index)
			else
				ovw.hud.fader:add('I am carrying too much...')
			end
		end
	else
		ovw.hud.fader:add('I require more minerals')
	end
end