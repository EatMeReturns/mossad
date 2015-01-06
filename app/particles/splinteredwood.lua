SplinteredWood = class()

SplinteredWood.image = love.graphics.newImage('media/graphics/particles/splintered_wood_modified.png')

function SplinteredWood:init(pos, angle, room)
	self.x, self.y = pos.x, pos.y
	self.angle = angle - math.pi / 2
	self.tx, self.ty = ovw.house:cell(self.x + math.cos(self.angle) * self.image:getWidth() / 2, self.y + math.sin(self.angle) * self.image:getHeight() / 2)
	self.image = table.copy(SplinteredWood.image)

	self.health = 8
	self.depth = DrawDepths.ground
	ovw.view:register(self)
	room:addObject(self)
end

function SplinteredWood:destroy()
	ovw.view:unregister(self)
end

function SplinteredWood:update()
	self.health = timer.rot(self.health, function()
		ovw.particles:remove(self)
	end)
end

function SplinteredWood:draw()
 	local v = ovw.house.tiles[self.tx] and ovw.house.tiles[self.tx][self.ty] and ovw.house.tiles[self.tx][self.ty]:brightness() or 1
 	love.graphics.setColor(255, 255, 255, v * (.5 + self.health / 16))
 	love.graphics.draw(self.image, self.x - math.cos(self.angle) * self.image:getWidth() / 2, self.y - math.sin(self.angle) * self.image:getHeight() / 2, self.angle)
end