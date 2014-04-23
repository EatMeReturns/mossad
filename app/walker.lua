Walker = class()

function Walker:init(level, x, y, direction, life, speed, 
						roomW, roomH, roomVariance, lastDoor)
	self.level = level
	self.x = x
	self.y = y
	self.direction = direction
	self.life = life
	self.speed = speed
	self.roomW = roomW
	self.roomH = roomH
	self.roomVariance = roomVariance

	self.lastDoor = lastDoor
end

function Walker:walk()
	local direction = self.direction
	--generate a room
	local roomW = 100 --love.math.random() * 50 + 75
	local roomH = 100 --love.math.random() * 50 + 75
	self.x = self.x + math.cos(math.rad(direction)) * roomW
	self.y = self.y + math.sin(math.rad(direction)) * roomH
	local roomX = self.x-- + math.cos(math.rad(direction)) * roomW-- / 2
	local roomY = self.y-- + math.sin(math.rad(direction)) * roomH-- / 2
	local wallWidth = 10
	local doorCount = 1
	local walls = {Wall(roomX - roomW / 2, roomY - roomH / 2, roomW, wallWidth, self.life),
				   Wall(roomX + roomW / 2 - wallWidth, roomY - roomH / 2, wallWidth, roomH, self.life),
				   Wall(roomX - roomW / 2, roomY + roomH / 2 - wallWidth, roomW, wallWidth, self.life),
				   Wall(roomX - roomW / 2, roomY - roomH / 2, wallWidth, roomH, self.life)
				}
	local doors = {}
	while doorCount > 0 do
		local side = math.floor(love.math.random() * 4) * 90
		local door = Door(roomX + math.cos(math.rad(side)) * roomW / 2, roomY + math.sin(math.rad(side)) * roomH / 2, side)
		table.insert(doors, door)
		table.insert(level.walkers, Walker(level, roomX, roomY, side, 1, 10, 10, 10, 0, door))
		doorCount = doorCount - 1
	end
	local contents = {}
	local room = Room('Room', self.life, roomX, roomY, roomW, roomH, walls, doors, contents, self.lastDoor)
	table.with(doors, 'cut', room)
	table.insert(self.level.rooms, room)

	self.life = self.life - 1
	if self.life <= 0 then self:destroy() end
end

function Walker:destroy()
	self.level.walkers = table.filter(self.level.walkers, function(walker) if walker == self then return false else return true end end)
end
--[[DEPRECATED
function Walker:walk(isTurn, turnVariance)
	if isTurn then 
		if love.math.random() <= 0.2 then walker = Walker(self.level, self.x, self.y, self.direction + self.turnDegree + turnVariance, self.life / 3, self.speed, self.roomW, self.roomH, self.roomVariance, self.turnChance, self.turnDegree, self.turnVariance) end
		self.direction = self.direction - self.turnDegree + turnVariance
	end
	local dx = math.dx(self.speed, math.rad(self.direction))
	local dy = math.dy(self.speed, math.rad(self.direction))
	self.x = self.x + dx
	self.y = self.y + dy
	table.insert(self.level.walls, Wall(self.x - dy * 3, self.y + dx * 3, self.roomW, self.roomH))
	table.insert(self.level.walls, Wall(self.x + dy * 3, self.y - dx * 3, self.roomW, self.roomH))
	table.insert(self.level.paths, Path(self.level, self.x, self.y, 25))
	if isTurn then
		--we would fill in the corner here
	end

	self.life = self.life - 1
end]]