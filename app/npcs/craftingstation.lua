CraftingStation = extend(NPC)

CraftingStation.collision = setmetatable({}, {__index = NPC.collision})
CraftingStation.collision.shape = 'circle'
CraftingStation.radius = 20

CraftingStation.npcType = 'CraftingStation'

CraftingStation.craftButton = {x = 490 + .5, y = 200 + .5, width = 100, height = 30}

function CraftingStation:init(data)
	NPC.init(self, data)

	self.name = 'Transmuter'
	self.noteTag = 'Level '
	self.items = {} --no higher than 2
	self.depth = DrawDepths.furniture
end

function CraftingStation:update()
	NPC.update(self)
	table.with(self.items, 'update')
end

function CraftingStation:mousepressed(...)
	table.with(self.items, 'mousepressed', ...)
end

function CraftingStation:activate()
	if self.items[1] and self.items[2] then
		if self.items[1].type == 'Base' then
			if self.items[2].type == 'Base' then

				--two bases, combine if the same level
				if self.items[1].level == self.items[2].level then
					self.items[1].level = self.items[1].level + 1
					self.items[2]:destroy()
					self.items[2] = nil
				else
					ovw.hud.fader:add('Nothing happened. One of these is heavier...')
				end
			else

				--1 base, 2 mods
				local output = nil
				local level = self.items[1].level
				table.each(self.items[1].mods, function(mod, index)
					if self.items[2].name == mod[1].name then output = mod[2] end
				end)
				if output then
					if self.items[2].stacks >= level then
						--remove the items and grant the output
						local matNames = {self.items[1].name, self.items[2].name}
						self:remove(2, level)
						self:remove(1)
						self.items[1] = new(output, level, matNames)
						ovw.hud.fader:add(self.items[1].pickupMessage)
					else
						--not enough mods for the level of the base
						ovw.hud.fader:add('Nothing happened. One of these is heavier...')
					end
				else
					ovw.hud.fader:add('These seem incompatible.')
				end
			end
		else
			if self.items[2].type == 'Base' then

				--1 mods, 2 base
				local output = nil
				local level = self.items[2].level
				table.each(self.items[2].mods, function(mod, index)
					if self.items[1].name == mod[1].name then output = mod[2] end
				end)
				if output then
					if self.items[1].stacks >= level then
						--remove the items and grant the output
						local matNames = {self.items[1].name, self.items[2].name}
						self:remove(1, level)
						self:remove(2)
						self.items[2] = new(output, level, matNames)
						ovw.hud.fader:add(self.items[2].pickupMessage)
					else
						--not enough mods for the level of the base
						ovw.hud.fader:add('Nothing happened. One of these is heavier...')
					end
				else
					ovw.hud.fader:add('These seem incompatible.')
				end
			else

				--two mods
				local output = nil
				table.each(self.items[1].mods, function(mod, index)
					if self.items[2].name == mod[1].name then output = mod[2] end
				end)
				if output then
					if ovw.player.inventory:add(new(output, 1)) then
						--remove one from each stack and grant the output
						self:remove(1, 1)
						self:remove(2, 1)
					else
						ovw.hud.fader:print('My bags are too full!')
					end
				else
					ovw.hud.fader:add('These seem incompatible.')
				end
			end
		end
	else
		ovw.hud.fader:add('There\'s an empty slot in the device.')
	end
end

function CraftingStation:add(item)
	if item.type == 'Base' or item.type == 'Mod' then
		local stacks = item.stacks
		if stacks then
			for i = 1, 2 do
				if self.items[i] and self.items[i].name == item.name then
					self.items[i].stacks = self.items[i].stacks + stacks
					return true
				end
			end
		end
		for i = 1, 2 do
			if not self.items[i] then
				self.items[i] = item
				item.index = i
				return true
			end
		end
	end

	return false
end

function CraftingStation:remove(index, amount)
	if not index then NPC.remove(self) end

	local item = self.items[index]
	if item then
		if item.stacks then
			item.stacks = item.stacks - amount
			if item.stacks > 0 then
				--f.exe(item.init, item)
				return
			end
		end
		item:destroy()
		self.items[index] = nil
	end
end