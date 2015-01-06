BloodParticle = class()

BloodParticle.anims = {
	newAnimation(love.graphics.newImage('media/graphics/particles/blood_hit_05.png'), 128, 128, 1/32, 16, 1),
	newAnimation(love.graphics.newImage('media/graphics/particles/blood_hit_07.png'), 128, 128, 1/32, 16, 1)
						}

function BloodParticle:init(pos, color)
	self.x, self.y = pos.x, pos.y
	self.tx, self.ty = ovw.house:cell(self.x, self.y)
	self.anim = table.copy(table.random(BloodParticle.anims))

	self.color = table.copy(color)

	self.health = .5
	self.depth = DrawDepths.air
	ovw.view:register(self)
end

function BloodParticle:destroy()
	ovw.view:unregister(self)
end

function BloodParticle:update()
	self.health = timer.rot(self.health, function()
		ovw.particles:remove(self)
	end)

	self.anim:update(tickRate)
end

function BloodParticle:draw()
 	local v = ovw.house.tiles[self.tx] and ovw.house.tiles[self.tx][self.ty] and ovw.house.tiles[self.tx][self.ty]:brightness() or 1
	love.graphics.setColor(self.color[1], self.color[2], self.color[3], v)
	self.anim:draw(self.x - self.anim:getWidth() * 3 / 8, self.y - self.anim:getWidth() * 3 / 8, 0, .75, .75)
end