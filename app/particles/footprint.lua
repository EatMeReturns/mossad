Footprint = class()

Footprint.images = {
		player = love.graphics.newImage('media/graphics/particles/footprint.png'),
		playerRoll = love.graphics.newImage('media/graphics/particles/roll_print.png'),
		inkraven = love.graphics.newImage('media/graphics/particles/raven_print.png'),
		gloomrat = love.graphics.newImage('media/graphics/particles/rat_print.png')
					}

function Footprint:init(pos, angle, reverse, color, room, footprint)
	self.x, self.y = pos.x, pos.y
	self.tx, self.ty = ovw.house:cell(self.x, self.y)
	self.image = table.copy(Footprint.images[footprint])

	self.angle = angle + math.pi / 2
	self.reverse = reverse --alternates left and right foot

	self.color = table.copy(color)

	self.health = 2
	self.depth = DrawDepths.ground
	ovw.view:register(self)
	room:addObject(self)
end

function Footprint:destroy()
	ovw.view:unregister(self)
end

function Footprint:update()
	self.health = timer.rot(self.health, function()
		ovw.particles:remove(self)
	end)
end

function Footprint:draw()
 	local v = ovw.house.tiles[self.tx] and ovw.house.tiles[self.tx][self.ty] and ovw.house.tiles[self.tx][self.ty]:brightness() or 1
 	love.graphics.setColor(self.color[1], self.color[2], self.color[3], v * (.5 + self.health / 4))
 	love.graphics.draw(self.image, self.x, self.y, self.angle, 1 * self.reverse, 1, self.image:getWidth() / 2, self.image:getHeight() / 2)
end