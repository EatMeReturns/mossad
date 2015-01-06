DirtExplosion = class()

DirtExplosion.anim = newAnimation(love.graphics.newImage('media/graphics/particles/dirt_explosion.png'), 128, 128, 1/32, 16, 1)

function DirtExplosion:init(pos, angle)
	self.x, self.y = pos.x, pos.y
	self.angle = angle - math.pi / 2
	self.anim = table.copy(DirtExplosion.anim)
	self.tx, self.ty = ovw.house:cell(self.x, self.y)


	self.health = .5
	self.depth = DrawDepths.air
	ovw.view:register(self)
end

function DirtExplosion:destroy()
	ovw.view:unregister(self)
end

function DirtExplosion:update()
	self.health = timer.rot(self.health, function()
		ovw.particles:remove(self)
	end)

	self.anim:update(tickRate)
end

function DirtExplosion:draw()
 	local v = ovw.house.tiles[self.tx] and ovw.house.tiles[self.tx][self.ty] and ovw.house.tiles[self.tx][self.ty]:brightness() or 1
 	love.graphics.setColor(255, 255, 255, math.sqrt(v / 255) * 255)
 	self.anim:draw(self.x - math.cos(self.angle) * self.anim:getWidth() / 2, self.y - math.sin(self.angle) * self.anim:getHeight() / 2, self.angle)
end