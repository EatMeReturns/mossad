Weapon = class()

function Weapon:init(owner)
	self.owner = owner
	self.x = self.owner.x
	self.y = self.owner.y
	self.damage = 10
	self.projectile = 'Bullet'
	self.speed = 5 --projectile per second
	self.clip = 8
	self.clipSize = 8
	self.ammo = 4 --max clips
	self.reloadTime = 2
	self.timer = 0
end

function Weapon:fire()
	if self.timer <= 0 then
		if self.clip > 0 then
			table.insert(level.projectiles, Projectile(self.damage, self.x, self.y, math.direction(400, 300, love.mouse.getX(), love.mouse.getY()), 15))
			self.clip = self.clip - 1
			self.timer = 1 / self.speed
		else
			if self.ammo > 0 then
				self.ammo = self.ammo - 1
				self.clip = self.clipSize
				self.timer = self.reloadTime
			end
		end
	end
end

function Weapon:update()
	self.x = self.owner.x
	self.y = self.owner.y
	if self.timer > tickRate then
		self.timer = self.timer - tickRate
	else
		self.timer = 0
	end
end

function Weapon:draw()
	--
end