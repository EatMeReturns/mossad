BloodSplat = class()

BloodSplat.images = {
	{love.graphics.newImage('media/graphics/particles/blood_splat_1.png'), .1, .1},
	{love.graphics.newImage('media/graphics/particles/blood_splat_2.png'), .1, .1},
	{love.graphics.newImage('media/graphics/particles/blood_splat_3.png'), .1, .1},
	{love.graphics.newImage('media/graphics/particles/blood_splat_4.png'), .1, .1}
}

BloodSplat.collision = {
	shape = 'circle',
	static = true,
	with = {
			player = function(self, player)
				player.footprintTimer = player.footprintTime
				player.footprintColor = self.color
			end,

			enemy = function(self, enemy)
				enemy.footprintTimer = enemy.footprintTime
				enemy.footprintColor = self.color
			end
		}
}

BloodSplat.tag = 'bloodsplat'

function BloodSplat:init(pos, color, room)
	self.x, self.y = pos.x, pos.y
	self.tx, self.ty = ovw.house:cell(self.x, self.y)
	self.image = table.copy(table.random(BloodSplat.images))
	self.sx, self.sy, self.image = self.image[2], self.image[3], self.image[1]

	self.color = table.copy(color)

	self.health = 5 + love.math.random() * 10
	self.depth = DrawDepths.ground
	self.radius = 15
	ovw.collision:register(self)
	ovw.view:register(self)
	room:addObject(self)
end

function BloodSplat:destroy()
	ovw.view:unregister(self)
	ovw.collision:unregister(self)
end

function BloodSplat:update()
	self.health = timer.rot(self.health, function()
		ovw.particles:remove(self)
	end)
end

function BloodSplat:draw()
 	local v = ovw.house.tiles[self.tx] and ovw.house.tiles[self.tx][self.ty] and ovw.house.tiles[self.tx][self.ty]:brightness() or 1
 	love.graphics.setColor(self.color[1], self.color[2], self.color[3], v)
 	love.graphics.draw(self.image, self.x, self.y, 0, self.sx, self.sy, self.image:getWidth() / 2, self.image:getHeight() / 2)
end