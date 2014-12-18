MeleeFlash = class()

function MeleeFlash:init(dis, dir, pos, theta)
	self.x, self.y = pos.x, pos.y
	self.vertices = {
		self.x + math.cos(dir - theta / 2) * dis, self.y + math.sin(dir - theta / 2) * dis,
		self.x, self.y,
		self.x + math.cos(dir + theta / 2) * dis, self.y + math.sin(dir + theta / 2) * dis
	}

	self.health = .2
	self.depth = -5
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
	love.graphics.polygon('fill', self.vertices[1], self.vertices[2], self.vertices[3], self.vertices[4], self.vertices[5], self.vertices[6])
	love.graphics.setLineWidth(1)
end