require 'app/house/room'
require 'app/house/event'

load 'app/npcs'
load 'app/enemies'
load 'app/bosses'

---------------------------------------------------------------------------------------
---BOSS--------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

BossEvent = extend(Event)
BossEvent.boss = Boss

function BossEvent:init(room, boss)
	Event.init(self, room)
	self.boss = boss
end

function BossEvent:triggerEvent()
	if not self.triggered then
		Event.triggerEvent(self)
		ovw.house.biome = 'Main'
		self.room.biome = 'Main'
		ovw.enemies:add((self.boss)())
	    ovw.house:sealRoom(self.room)
	end
end

function BossEvent:endEvent()
	if self.triggered then
		Event.endEvent(self)
		ovw.house:openRoom(self.room)
  		ovw.house:increaseDifficulty()
	end
end

---------------------------------------------------------------------------------------
---TRAP--------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

TrapEvent = extend(Event)
TrapEvent.enemies = {}
TrapEvent.enemyType = Enemy
TrapEvent.showTimer = true

function TrapEvent:init(room, enemyType)
	Event.init(self, room)
	self.enemyType = enemyType
	self.enemies = {}
end

function TrapEvent:triggerEvent()
	if not self.triggered then
		Event.triggerEvent(self)
		local amt = House.getDifficulty(true) * 3
		self.enemies = ovw.house:spawnEnemiesInRoom(amt, self.room, self.enemyType)
		self.timer = 10 + House.getDifficulty() * 2
		ovw.house:sealRoom(self.room)
		ovw.hud.fader:add('\"It\'s a trap!\"\n\nAdmiral Ackbar')
	end
end

function TrapEvent:updateEvent()
	if self.triggered and self.timer > 0 then
		local outOfTime = Event.updateEvent(self)
		table.each(self.enemies, function(enemy, index) if enemy.health <= 0 then table.remove(self.enemies, index) end end)
		if #self.enemies == 0 then
			--success!
			self:endEvent(true)
			ovw.hud.fader:add('Calculated.')
		elseif outOfTime then
			--failure...
			self:endEvent(false)
			ovw.hud.fader:add('Sometimes, survival is reward enough. This is not one of those times.')
		end
	end
end

function TrapEvent:endEvent(success)
	if self.triggered then
		Event.endEvent(self)
		if success then
			self.timer = 0
			ovw.house:spawnPickupsInRoom(5, self.room)
		end
		ovw.house:openRoom(self.room)
	end
end

---------------------------------------------------------------------------------------
---REJECT------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

RejectEvent = extend(Event)
RejectEvent.direction = 'horizontal' --horizontal, vertical; up, down, left, right
RejectEvent.dis, RejectEvent.dir, RejectEvent.maxDis, RejectEvent.source = 0, 0, 50, {x = 0, y = 0}

function RejectEvent:init(room, direction)
	Event.init(self, room)
	self.direction = direction
	self.timer = 1
	self.time = 1
end

function RejectEvent:triggerEvent()
	if not self.triggered then
		Event.triggerEvent(self)
		if self.direction == 'horizontal' then
			if ovw.player.x < House.cellSize * (self.room.x + self.room.width / 2) then self.direction = 'left'
			else self.direction = 'right' end
		else
			if ovw.player.y < House.cellSize * (self.room.y + self.room.height / 2) then self.direction = 'up'
			else self.direction = 'down' end
		end
		ovw.hud.fader:add('What is this wind...?')
	end
end

function RejectEvent:updateEvent()
	local function get(x, y) return ovw.house.tiles[x] and ovw.house.tiles[x][y] end

	if self.triggered and self.room.width > 0 and self.room.height > 0 then

		if self.triggered then
			local outOfTime = Event.updateEvent(self)
			if outOfTime then

				if self.direction == 'right' then
					self.source = {x = self.room.x * House.cellSize, y = (self.room.y + self.room.height / 2) * House.cellSize}
					for y = self.room.y - 1, self.room.y + self.room.height + 1 do
						if get(self.room.x, y) then ovw.house.tiles[self.room.x][y] = nil end
					end
					self.room.width = self.room.width - 1
					self.room.x = self.room.x + 1
				elseif self.direction == 'left' then
					self.source = {x = (self.room.x + self.room.width) * House.cellSize, y = (self.room.y + self.room.height / 2) * House.cellSize}
					for y = self.room.y - 1, self.room.y + self.room.height + 1 do
						if get(self.room.x + self.room.width, y) then ovw.house.tiles[self.room.x + self.room.width][y] = nil end
					end
					self.room.width = self.room.width - 1
				elseif self.direction == 'up' then
					self.source = {x = (self.room.x + self.room.width / 2) * House.cellSize, y = (self.room.y + self.room.height) * House.cellSize}
					for x = self.room.x - 1, self.room.x + self.room.width + 1 do
						if get(x, self.room.y + self.room.height) then ovw.house.tiles[x][self.room.y + self.room.height] = nil end
					end
					self.room.height = self.room.height - 1
				else --down
					self.source = {x = (self.room.x + self.room.width / 2) * House.cellSize, y = self.room.y * House.cellSize}
					for x = self.room.x - 1, self.room.x + self.room.width + 1 do
						if get(x, self.room.y) then ovw.house.tiles[x][self.room.y] = nil end
					end
					self.room.height = self.room.height - 1
					self.room.y = self.room.y + 1
				end

				if self.room.width <= 0 or self.room.height <= 0 then
					self:endEvent()
				end

				self.maxDis = math.min(self.maxDis * 2, 500)
				self.time = self.time ^ 2 * .8
				self.timer = self.time
				ovw.house:computeTilesInRoom(self.room)
			end

			local newMax = self.maxDis * (1 + ovw.player.speed / ovw.player.maxSpeed)
			self.dis = math.distance(self.source.x, self.source.y, ovw.player.x, ovw.player.y)
			self.dis = math.max(newMax - self.dis, 0) / newMax
			self.dir = math.direction(self.source.x, self.source.y, ovw.player.x, ovw.player.y)

			local px, py = ovw.player.x, ovw.player.y
			if self.direction == 'left' or self.direction == 'right' then
				px = ovw.player.x + math.dx(newMax * self.dis * tickRate, self.dir)
				local wall, d = ovw.collision:lineTest(ovw.player.x, ovw.player.y, px, py, 'wall', false, true)
				if wall then px = ovw.player.x + math.dx(d * tickRate, self.dir) end
			else
				py = ovw.player.y + math.dy(newMax * self.dis * tickRate, self.dir)
				local wall, d = ovw.collision:lineTest(ovw.player.x, ovw.player.y, px, py, 'wall', false, true)
				if wall then py = ovw.player.y + math.dy(d * tickRate, self.dir) end
			end
			ovw.player:setPosition(px, py)
		end
	end
end

function RejectEvent:endEvent()
	if self.triggered then
		Event.endEvent(self)
		self.room:destroy()
	end
end

---------------------------------------------------------------------------------------
---ASSIST------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

--A crippled person approaches the player and begs for a first aid kit.
--You can:
--A) give him a kit, at which point he either thanks you, follows you, or gives you a
--reward.
--B) kill him, at which point he either drops great loot, becomes a miniboss, or nada
--C) ignore him, at which point he either turns in to a miniboss or upon leaving the
--room you hear him die.

---------------------------------------------------------------------------------------
---GLORY-------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

--A person is fighting a very large number of enemies. One of the following happens:
--A) the enemies kill him and then you
--B) you manage to fend off the swarm, and the person has died and dropped good loot
--C) the person dies andbecomes a miniboss, and the room becomes incredibly challenging
--D) the person runs through to another room, with the swarm following him

---------------------------------------------------------------------------------------
---STAIRS------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

--A hidden area opens up, revealing a staircase from which comes:
--A) nothing.
--B) a horde of enemies/a miniboss
--C) an npc

---------------------------------------------------------------------------------------
---COLLAPSE----------------------------------------------------------------------------
---------------------------------------------------------------------------------------

--The floor collapses beneath you. you either:
--A) fall down a floor and take damage.
--B) use skills/speed/items to go back out the way you came in time