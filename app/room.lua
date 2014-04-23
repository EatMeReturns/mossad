Room = class()
Room.tag = 'room' --for collision

Room.collision = {
  shape = 'rectangle',
  static = true
}

function Room:init(type, age, x, y, w, h, walls, doors, contents)
	self.type = type
	self.age = age
	self.x = x
	self.y = y
	self.width = w
	self.height = h
	self.wallThickness = 10
	self.walls = walls
	self.doors = doors
	self.contents = contents

	ovw.collision:register(self)
	self.shape:moveTo(self.x, self.y)

	table.with(self.walls, 'setRoom', self)
	table.with(self.doors, 'setRoom', self)
	table.with(self.contents, 'setRoom', self)

	self.color = table.copy(level.roomColors[self.type])
  self.alpha = 0
end

function Room:destroy()
	ovw.collision.hc:remove(self.shape)
	table.with(self.walls, 'destroy')
	table.with(self.doors, 'destroy')
	self.walls = {}
	self.doors = {}
end

function Room:spawnRooms()
	table.each(self.doors, function(door)
		local roomW = 100
		local roomH = 100
		local roomX = self.x + math.cos(math.rad(door.direction)) * roomW
		local roomY = self.y + math.sin(math.rad(door.direction)) * roomH
		if not ovw.collision:pointTest(roomX, roomY, 'room') then
			local roomType = 'Room'
			if love.math.random() < .001 then roomType = 'Base'
			elseif love.math.random() < .0015 then roomType = 'Shop'
			elseif love.math.random() < .002 then roomType = 'Boss'
			elseif love.math.random() < .0025 then roomType = 'Event'
			end

			local wallW = 10
			local doorCount = math.ceil(love.math.random() * 2 - (0.5 * (#level.rooms / 120)))
			local contents = {}
			if roomType ~= 'Boss' then
				--if doorCount == 0 and love.math.random() > 0.95 then table.insert(contents, Stalker(roomX, roomY, 10)) end
			else
				--table.insert(contents, Enemy(roomX, roomY, 50))
			end
			local oppositeDirection = door.direction + 180
			if oppositeDirection >= 360 then oppositeDirection = oppositeDirection - 360 end
			local doors = {Door(door.x + 5, door.y + 5, oppositeDirection)}
			local doorSides = {oppositeDirection}
			while doorCount > 0 do
				local side = math.floor(love.math.random() * 4) * 90
				if not table.has(doorSides, side) then
					local newDoor = Door(roomX + math.cos(math.rad(side)) * roomW / 2, roomY + math.sin(math.rad(side)) * roomH / 2, side)
          
					table.insert(doors, newDoor)
					table.insert(doorSides, side)
					doorCount = doorCount - 1
				end
			end

			local walls = {}
			if love.math.random() < 1 then table.insert(walls, Wall(roomX - roomW / 2, roomY - roomH / 2, roomW, wallW)) end
			if love.math.random() < 1 then table.insert(walls, Wall(roomX + roomW / 2 - wallW, roomY - roomH / 2, wallW, roomH)) end
			if love.math.random() < 1 then table.insert(walls, Wall(roomX - roomW / 2, roomY + roomH / 2 - wallW, roomW, wallW)) end
			if love.math.random() < 1 then table.insert(walls, Wall(roomX - roomW / 2, roomY - roomH / 2, wallW, roomH)) end

			local room = Room(roomType, self.age, roomX, roomY, roomW, roomH, walls, doors, contents)
			table.with(walls, 'setRoom', room)
			table.with(doors, 'setRoom', room)
			table.with(contents, 'setRoom', room)
			table.with(doors, 'cut')
			table.insert(level.newRooms, room)
		end
	end)
end

function Room:update()
	table.with(self.doors, 'update')

  -- Fade rooms in/out based on player LOS
  if ovw.collision:lineTest(self.x, self.y, ovw.player.x, ovw.player.y, 'wall') then
    self.alpha = math.lerp(self.alpha, 0, math.min(1 * tickRate, 1))
  else
    self.alpha = math.lerp(self.alpha, .2, math.min(3 * tickRate, 1))
  end

  table.each(self.walls, function(w) w.alpha = self.alpha end)
end

function Room:draw()
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4] * self.alpha)
	self.shape:draw('fill')
	table.with(self.walls, 'draw', self.color)
	table.with(self.doors, 'draw')
end
