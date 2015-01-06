MeleeFlash = class()

function MeleeFlash:init(dis, dir, pos, theta)
	self.x, self.y = pos.x, pos.y
	self.dis = dis
	self.angles = {dir - theta / 2, dir + theta / 2}

	self.health = .2
	self.depth = DrawDepths.air
	ovw.view:register(self)
end

function MeleeFlash:destroy()
	ovw.view:unregister(self)
end

function MeleeFlash:update()
	self.health = timer.rot(self.health, function()
		ovw.particles:remove(self)
	end)
end

function MeleeFlash:draw()
	local v = self.health * 255
	love.graphics.setColor(255, 255, 255, v)
	love.graphics.setLineWidth(2)
	love.graphics.arc('fill', self.x, self.y, self.dis, self.angles[1], self.angles[2], 10)
	love.graphics.setLineWidth(1)
end