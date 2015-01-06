Worm = extend(Enemy) --A miniboss. consider Miniboss class?

Worm.collision = setmetatable({}, {__index = Enemy.collision})
Worm.collision.shape = 'circle'
Worm.collision.with = {
  room = Enemy.collision.with.room,
  enemy = Enemy.collision.with.enemy
}
Worm.radius = 32

Worm.tag = 'invincible'

Worm.deathMessage = 'Not your typical earthworm.'

Worm.name = {}
Worm.name.singular = 'Worm'
Worm.name.pluralized = 'Worms'

Worm.tunnel = 'plywood_worm_tunnel_modified.wav'

Worm.makeFootprints = false

function Worm:init(...)
	Enemy.init(self, ...)

	self.state = 'lurk'

	self.sight = 400

	self.chaseSpeed = 75

	self.target = nil
	self.targetAngle = 0

	self.damage = 20
	self.burstDamage = 20
	self.exp = 40
	self.dropChance = 1

	self.windupRange = 50
	self.burstRange = 80
	self.meleeRange = 0

	self.scanTimer = 1
	self.scanTime = 1
	self.windupTimer = 0
	self.windupTime = .25
	self.burstTimer = 0
	self.burstTime = .2
	self.meleeTimer = 0
	self.meleeTime = 1
	self.attackTimer = 0
	self.attackTime = .3
	self.digTimer = 0
	self.digTime = .5

	self.splinterTimer = 0
	self.splinterTime = .4
	self.dirtTimer = 0
	self.dirtTime = .1

	self.health = 100 * House.getDifficulty(true)
	self.maxHealth = self.health

	self.tunnelSound = ovw.sound:play(Worm.tunnel)
	self.tunnelSound:setLooping(true)
end

function Worm:destroy()
	if self.alerted then ovw.sound.miniBossCount = ovw.sound.miniBossCount - 1 end
	Enemy.destroy(self)
end

function Worm:update()
	Enemy.update(self)
	self.prevX, self.prevY = self.x, self.y

	self[self.state](self)

	self:setPosition(self.x, self.y)
	self.angle = math.anglerp(self.angle, self.targetAngle, math.clamp(1 * tickRate, 0, 1))

	if self.state == 'chase' then
		ovw.view.shake = ovw.view.shake + tickRate * 4 + tickRate * love.math.random() * 4
		self.tunnelSound:resume()
		self.dirtTimer = self.dirtTimer - tickRate
		if self.dirtTimer <= 0 then
			ovw.particles:add(DirtExplosion({x = self.x - math.cos(self.angle) * 100, y = self.y - math.sin(self.angle) * 100}, self.angle))
			self.dirtTimer = self.dirtTime
		end
		self.splinterTimer = self.splinterTimer - tickRate
		if self.splinterTimer <= 0 then
			ovw.particles:add(SplinteredWood({x = self.x - math.cos(self.angle) * 75, y = self.y - math.sin(self.angle) * 75}, self.angle, self.room))
			self.splinterTimer = self.splinterTime
		end
	else
		self.tunnelSound:pause()
	end
end

function Worm:draw() --draw the splintered wood image permanently if standing still
	local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
	local tx, ty = ovw.house:cell(self.x, self.y)
	local v = ovw.house.tiles[tx] and ovw.house.tiles[tx][ty] and ovw.house.tiles[tx][ty]:brightness() or 0
	if self.state == 'windup' then
		love.graphics.setColor(255, 255, 0, 0)
	elseif self.state ~= 'chase' and self.state ~= 'lurk' then
		love.graphics.setColor(255, 0, 0, v)
	else
		love.graphics.setColor(255, 255, 255, 0)
	end
	love.graphics.circle('fill', x, y, self.radius)

	if v > 25.5 then
		Enemy.drawHealth(self)
	end
end

function Worm:scan()
	self.target = nil
	local dis, dir = math.vector(self.x, self.y, ovw.player.x, ovw.player.y)

	self.scanTimer = self.scanTime

	if dis < self.sight then
		self.target = ovw.player
		self.targetAngle = dir
		self.state = 'chase'

		if not self.alerted then
			ovw.sound.miniBossCount = ovw.sound.miniBossCount + 1
			self.alerted = true
		end
	end

	if not self.target then
		self.state = 'lurk'
	end
end

function Worm:alert()
	if self.state == 'lurk' then
		self.target = ovw.player
		self.targetAngle = math.direction(self.x, self.y, ovw.player.x, ovw.player.y)
		self.state = 'chase'

		if not self.alerted then
			ovw.sound.miniBossCount = ovw.sound.miniBossCount + 1
			self.alerted = true
		end
	end
end

----------------
-- States
----------------

function Worm:lurk()
	self.scanTimer = self.scanTimer - tickRate

	if self.scanTimer <= 0 then
		self:scan()
	end
end

function Worm:chase()
	if self.target ~= nil then
		local dis, dir = math.vector(self.x, self.y, self.target.x, self.target.y)
		local minDis = math.max(dis - (self.radius + self.target.radius), 0)
		self.targetAngle = dir
		self.x = self.x + math.dx(math.min(self.chaseSpeed * tickRate, minDis), self.angle)
		self.y = self.y + math.dy(math.min(self.chaseSpeed * tickRate, minDis), self.angle)
		self.chaseSpeed = self.chaseSpeed + tickRate * 20
		if self.chaseSpeed > 200 then self.angle = self.targetAngle end

		if dis < self.windupRange then
			self.chaseSpeed = 75
			self.state = 'windup'
			self.windupTimer = self.windupTime
		end
	else
		self.state = 'lurk'
	end
end

function Worm:windup()
	self.windupTimer = self.windupTimer - tickRate
	if self.windupTimer <= 0 then
		self.state = 'burst'
		self.burstTimer = self.burstTime
		self.tag = 'enemy'
		--play a sound! GRAWRRRRR *WOOD EXPLODES*
		ovw.sound:play('plywood_worm_burst.wav')
		ovw.sound:play('worm_roar.wav')
		ovw.view.shake = ovw.view.shake + 20
	end
end

function Worm:burst()
	local dis, dir = math.vector(self.x, self.y, self.target.x, self.target.y)
	local maxDis = self.burstRange * 3

	if dis < self.burstRange then
		ovw.player:hurt(self.burstDamage)
		self.burstDamage = 0 --only hit 'em once; the pushing occurs over time
	end

	if dis < maxDis then
		dis = math.max(maxDis - dis, 0) / maxDis --150 is strength of push?
		local px = self.target.x + math.dx(600 * dis * tickRate, dir)
		local py = self.target.y + math.dy(600 * dis * tickRate, dir)

		local wall, d = ovw.collision:lineTest(self.target.x, self.target.y, px, py, 'wall', false, true)
		if wall then
			px = self.target.x + math.dx(d * tickRate, dir)
			py = self.target.y + math.dy(d * tickRate, dir)
		end

		self.target:setPosition(px, py)
	end

	self.burstTimer = self.burstTimer - tickRate
	if self.burstTimer <= 0 then
		self.burstDamage = 20
		self.state = 'melee'
		self.meleeTimer = self.meleeTime
	end
end

function Worm:melee()
	--rotate to face the player... occurs naturally during update()
	self.meleeTimer = self.meleeTimer - tickRate
	if self.meleeTimer <= 0 then
		--HIT 'EM
		self.state = table.random({'grab', 'reach', 'bite'})
		self.attackTimer = self.attackTime
	end
end

function Worm:bite()
	--dunno
	print('worm bite! ^vv^')
	self.attackTimer = self.attackTimer - tickRate
	if self.attackTimer <= 0 then
		self.state = 'dig'
		self.digTimer = self.digTime
	end
end

function Worm:reach()
	--dunno
	print('grabby worm :o')
	self.attackTimer = self.attackTimer - tickRate
	if self.attackTimer <= 0 then
		self.state = 'dig'
		self.digTimer = self.digTime
	end
end

function Worm:grab()
	--dunno
	print('hitty worm o:')
	self.attackTimer = self.attackTimer - tickRate
	if self.attackTimer <= 0 then
		self.state = 'dig'
		self.digTimer = self.digTime
	end
end

function Worm:dig()
	--just an animation here.
	self.digTimer = self.digTimer - tickRate
	if self.digTimer <= 0 then
		self.state = 'chase'
		self.tag = 'invincible'
	end
end

--lurk (basically waiting for the player to come in range. chases indefinitely.)
--chase (can go through walls holy flitsnap)
--windup
--burst
--melee (grab, reach, bite?)
--diglett used Dig!
--and back to chase.