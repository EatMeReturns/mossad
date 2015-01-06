Zombie = extend(Enemy)

Zombie.collision = setmetatable({}, {__index = Enemy.collision})

Zombie.collision.shape = 'circle'
Zombie.radius = 20

Zombie.images = {
				crawl = love.graphics.newImage('media/graphics/enemies/zombie_crawl.png'),
				bite = love.graphics.newImage('media/graphics/enemies/zombie_bite.png')
				}

Zombie.anims = {
				crawl = newAnimation(Zombie.images.crawl, 120, 120, 1/10),
				bite = newAnimation(Zombie.images.bite, 120, 120, 1/16)
				}

Zombie.name = {}
Zombie.name.singular = 'Zombie'
Zombie.name.pluralized = 'Zombies'

Zombie.footprint = 'playerRoll'
Zombie.lastFootprintTime = .001

function Zombie:init(...)
	Enemy.init(self, ...)

	self.anims = {chase = table.copy(Zombie.anims.crawl), bite = table.copy(Zombie.anims.bite)}
	self.anim = self.anims.chase

	self.state = 'lurk'

	self.sight = 500
	self.target = nil

	self.chaseSpeed = 190

	self.damage = 3 --hits often. CHOMP CHOMP CHOMP CHOMP
	self.exp = 10
	self.dropChance = .75

	self.scanTimer = .3
	self.scanTime = .3
	self.biteTimer = 0
	self.biteTime = .5
	self.groanTimer = 3 + love.math.random() * 2
	self.groanTime = 3

	self.bloodTimer = 0
	self.bloodTime = .15

	self.biteRange = 50

	self.health = 40 * House.getDifficulty(true)
	self.maxHealth = self.health
	self.targetAngle = love.math.random() * 2 * math.pi
	self.followTarget = nil
end

function Zombie:destroy()
	Enemy.destroy(self)
end

function Zombie:update()
	Enemy.update(self)
	self.prevX, self.prevY = self.x, self.y

	self[self.state](self)

	self.bloodTimer = self.bloodTimer - tickRate
	if self.bloodTimer <= 0 then
		self.bloodTimer = self.bloodTime
		ovw.particles:add(BloodSplat({x = self.x, y = self.y}, {50, 0, 0}, self.room))
		ovw.particles:add(BloodSplat({x = self.x, y = self.y}, {50, 0, 0}, self.room))
		ovw.particles:add(BloodSplat({x = self.x, y = self.y}, {50, 0, 0}, self.room))
	end

	self:setPosition(self.x, self.y)
	self.angle = math.anglerp(self.angle, self.targetAngle, math.clamp(6 * tickRate, 0, 1))

	self.anim:update(tickRate)
end

function Zombie:draw()
	local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
	local tx, ty = ovw.house:cell(self.x, self.y)
	local v = ovw.house.tiles[tx] and ovw.house.tiles[tx][ty] and ovw.house.tiles[tx][ty]:brightness() or 1
	love.graphics.setColor(150, 150, 150, v)
	self.anim:draw(x, y, self.angle - math.pi / 2, 1, 1, self.anim:getWidth() / 2, self.anim:getHeight() / 2)
end

function Zombie:scan()
	local dis, dir = math.vector(self.x, self.y, ovw.player.x, ovw.player.y)

	if dis < self.sight then
		local blocked = ovw.collision:lineTest(self.x, self.y, ovw.player.x, ovw.player.y, 'wall')
    	if not blocked then
			self.target = ovw.player
			if self.state ~= 'chase' then
				self.state = 'chase'
				local roar = ovw.sound:play('zombie_roar_modified.wav')
				roar:setVolume(ovw.sound.volumes.fx)
			end
		end
	end

	if not self.target then
    	self.targetAngle = self.targetAngle + (love.math.random() * 360 - 180)
		self.state = 'lurk'
	end

	self.scanTimer = self.scanTime
end

function Zombie:alert()
	if self.state == 'lurk' then
		self.target = ovw.player
		self.state = 'chase'
		self.scanTimer = self.scanTime
		local roar = ovw.sound:play('zombie_roar_modified.wav')
		roar:setVolume(ovw.sound.volumes.fx)
	end
end

----------------
-- States
----------------
--chase, bite, lurk
function Zombie:lurk()
	self.scanTimer = self.scanTimer - tickRate

	if self.scanTimer <= 0 then
		self:scan()
	end
end

function Zombie:chase()
	self.scanTimer = self.scanTimer - tickRate

	if self.scanTimer <= 0 then
		self:scan()
	end

	self.groanTimer = self.groanTimer - tickRate

	if self.groanTimer <= 0 then
		local groanInt = math.clamp(math.ceil(love.math.random() * 3), 1, 3)
		local groan = ovw.sound:play('zombie_groan_' .. groanInt .. '.wav')
		groan:setVolume(ovw.sound.volumes.fx)
		self.groanTimer = self.groanTime + love.math.random() * 2
	end

	if self.target ~= nil then
		local dis, dir = math.vector(self.x, self.y, self.target.x, self.target.y)
		local minDis = math.max(dis - (self.radius + self.target.radius), 0)
		self.targetAngle = dir
		self.x = self.x + math.dx(math.min(self.chaseSpeed * tickRate, minDis), self.angle)
		self.y = self.y + math.dy(math.min(self.chaseSpeed * tickRate, minDis), self.angle)

		if dis < self.biteRange then
		  self.state = 'bite'
		  self.biteTimer = self.biteTime
		  self.anim = self.anims.bite
		end
	else
		self.state = 'lurk'
	end
end

function Zombie:bite()
	local dis, dir = math.vector(self.x, self.y, self.target.x, self.target.y)

	self.targetAngle = dir

	self.biteTimer = self.biteTimer - tickRate

	if self.biteTimer <= 0 then
		if dis <= self.biteRange then
			ovw.player:hurt(self.damage)
			local bite = ovw.sound:play('zombie_bite.wav')
			bite:setVolume(ovw.sound.volumes.fx)
		else
			local clack = ovw.sound:play('zombie_clack_modified.wav')
			clack:setVolume(ovw.sound.volumes.fx)
		end
		self.state = 'chase'
		self.anim = self.anims.chase
	end
end