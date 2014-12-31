Orb = extend(Pickup)

Orb.tag = 'pickup'
Orb.collision = {
	shape = 'circle',
	with = {player = function(self, player, dx, dy) self:activate() end}
}

Orb.images = {
	health = love.graphics.newImage('media/graphics/icons/healthOrb.png'),
	stamina = love.graphics.newImage('media/graphics/icons/staminaOrb.png'),
	experience = love.graphics.newImage('media/graphics/icons/experienceOrb.png')
}

Orb.pickupRange = 150

function Orb:init(data)
	self.x, self.y = 0, 0
	self.prevX, self.prevY = 0, 0
	self.orbType = nil
	self.followSpeed = 0
	self.amount = 0
	for k, v in pairs(data) do self[k] = v end
	assert(self.orbType)
	assert(self.room)
	self.image = Orb.images[self.orbType]
	self.room:addObject(self)
	self.radius = 4
	ovw.collision:register(self)
	ovw.view:register(self)
	self.depth = -5 - self.amount / 50
end

function Orb:destroy()
	self.room:removeObject(self)
	ovw.collision:unregister(self)
	ovw.view:unregister(self)
end

function Orb:remove()
 	ovw.pickups:remove(self)
end

function Orb:update()
	if self.amount < 1 then self:remove() end

	self.prevX, self.prevY = self.x, self.y
    local dis, dir = math.vector(self.x, self.y, ovw.player.x, ovw.player.y)
	if math.distance(self.x, self.y, ovw.player.x, ovw.player.y) < self.pickupRange then
		self.followSpeed = math.lerp(self.followSpeed, math.max(20, dis * 4 * tickRate), tickRate)
		self:setPosition(self.x + math.dx(1, dir) * self.followSpeed, self.y + math.dy(1, dir) * self.followSpeed)
	end
end

function Orb:draw()
	local tx, ty = ovw.house:cell(self.x, self.y)
	local v = ovw.house.tiles[tx] and ovw.house.tiles[tx][ty] and ovw.house.tiles[tx][ty]:brightness() or 1
	love.graphics.setColor(255, 255, 255, v)
	local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
	local scale = math.max(.5, self.amount / 20)
	love.graphics.draw(self.image, self.x - 10 * scale, self.y - 10 * scale, 0, scale, scale)
end

function Orb:setPosition(x, y)
	self.x, self.y = x, y
	self.shape:moveTo(x, y)
end

function Orb:activate()
	if self.orbType == 'health' then
		ovw.player.orbs.health = ovw.player.orbs.health + self.amount
	elseif self.orbType == 'stamina' then
		ovw.player.orbs.stamina = ovw.player.orbs.stamina + self.amount / 10
	elseif self.orbType == 'experience' then
    	ovw.player:learn(self.amount)
	else
		--this orb type is a FALSEHOOD
	end
	return self:remove()
end