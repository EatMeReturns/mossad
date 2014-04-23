Door = class()
Door.tag = 'door' --for collision

Door.collision = {
  shape = 'rectangle',
  static = true
}

function Door:init(x, y, direction)
	level.doorCount = level.doorCount + 1
	self.width = 10
	self.height = 10
	self.x = x - self.width / 2
	self.y = y - self.height / 2
	self.direction = direction
	self.room = nil

	ovw.collision:register(self)
	self.shape:moveTo(self.x + self.width / 2, self.y + self.height / 2)
end

function Door:setRoom(room)
	self.room = room
end

function Door:destroy()
	self.room = nil
	level.doorCount = level.doorCount - 1
	ovw.collision.hc:remove(self.shape)
end

function Door:cut()
	local collideWalls = ovw.collision:pointTest2(self.x, self.y, 'wall')
	table.each(collideWalls, function(wall) wall:destroy()--[[self:separateWall(wall)]] end)
	collideWalls = ovw.collision:pointTest2(self.x + self.width, self.y + self.height, 'wall')
	table.each(collideWalls, function(wall) wall:destroy()--[[self:separateWall(wall)]] end)
end

function Door:separateWall(wall)
	if wall.width == 10 then
		--wall is vertical
		local topWall = Wall(wall.x, wall.y, wall.width, wall.height / 2 - self.height * 2)
		local bottomWall = Wall(wall.x, wall.y + wall.height / 2 + self.height * 2, wall.width, wall.height / 2 - self.height * 2)
		topWall:setRoom(wall.room)
		bottomWall:setRoom(wall.room)
		table.insert(wall.room.walls, topWall)
		table.insert(wall.room.walls, bottomWall)
	else
		--wall is horizontal
		local leftWall = Wall(wall.x, wall.y, wall.width / 2 - self.width * 2, wall.height)
		local rightWall = Wall(wall.x + wall.width / 2 + self.width * 2, wall.y, wall.width / 2 - self.width * 2, wall.height)
		leftWall:setRoom(wall.room)
		rightWall:setRoom(wall.room)
		table.insert(wall.room.walls, leftWall)
		table.insert(wall.room.walls, rightWall)
	end
	wall:destroy()
end

function Door:update()
	local collideWalls = ovw.collision:pointTest2(self.x, self.y, 'wall')
	table.each(collideWalls, function(wall) wall:destroy(self) end)
	collideWalls = ovw.collision:pointTest2(self.x + self.width, self.y + self.height, 'wall')
	table.each(collideWalls, function(wall) wall:destroy(self) end)
end

function Door:draw()
	love.graphics.setColor(255, 0, 0, 55)
	--self.shape:draw('fill')
	love.graphics.setColor(0, 0, 255, 255)
	--love.graphics.line(self.x, self.y, self.x + self.width, self.y + self.height)
end