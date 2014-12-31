Gloomrat = extend(Enemy)

Gloomrat.collision = setmetatable({}, {__index = Enemy.collision})
Gloomrat.collision.shape = 'circle'
Gloomrat.radius = 16

Gloomrat.name = {}
Gloomrat.name.singular = 'Gloomrat'
Gloomrat.name.pluralized = 'Gloomrats'

function Gloomrat:init(...)
	Enemy.init(self, ...)

	self.state = 'roam' --roam, startled, aggressive, lunge, fatigue

	self.sight = 265
	self.target = nil
	self.scanTimer = 0

	self.runSpeed = 300
	self.walkSpeed = 100
	self.maxSpeed = 350

	self.damage = 6 --hits OFTEN when aggressive
	self.exp = 15 + math.ceil(love.math.random() * 15)
	self.dropChance = 1

	self.children = {} -- younglings need protectins!!!!!!1!!111!1

	self.roamTime = 1.2
	self.roamTimer = 0

	self.startledTime = .7 -- Time spent running away
	self.startledTimer = 0
	self.startledRange = 250

	self.aggressiveTime = .4 -- Time spent between attacks
	self.aggressiveTimer = 0
	self.aggressiveRange = 100

	self.lungeTime = .21 -- Time it takes to lunge
	self.lungeTimer = 0
	self.lungeRange = 45 -- damage is dealt if player is this close after lunging

	self.fatigueTime = .2 -- Time to stand still between roams/aggros
	self.fatigueTimer = 0

	self.health = love.math.random(37, 45) * House.getDifficulty(true)
	self.maxHealth = self.health
end

function Gloomrat:update()
  self.prevX = self.x
  self.prevY = self.y

  self[self.state](self)

  self:setPosition(self.x, self.y)
  self.angle = math.anglerp(self.angle, self.targetAngle, math.clamp(6 * tickRate, 0, 1))
end

function Gloomrat:draw()
	local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
 	local tx, ty = ovw.house:cell(self.x, self.y)
 	local v = ovw.house.tiles[tx] and ovw.house.tiles[tx][ty] and ovw.house.tiles[tx][ty]:brightness() or 1
	if self.state == 'aggressive' or self.state == 'lunge' then
		love.graphics.setColor(255, 0, 0, v)
	elseif self.state == 'startled' then
		love.graphics.setColor(255, 255, 0, v)
	else
		love.graphics.setColor(255, 255, 255, v)
	end
	local p25 = math.pi * 2 / 5
	local x1, y1 = self.x + math.dx(self.radius, self.angle), self.y + math.dy(self.radius, self.angle)
	local x2, y2 = self.x + math.dx(self.radius, self.angle - p25), self.y + math.dy(self.radius, self.angle - p25)
	local x3, y3 = self.x + math.dx(self.radius, self.angle - p25 * 2), self.y + math.dy(self.radius, self.angle - p25 * 2)
	local x4, y4 = self.x + math.dx(self.radius, self.angle + p25 * 2), self.y + math.dy(self.radius, self.angle + p25 * 2)
	local x5, y5 = self.x + math.dx(self.radius, self.angle + p25), self.y + math.dy(self.radius, self.angle + p25)
	love.graphics.polygon('fill', x1, y1, x2, y2, x3, y3, x4, y4, x5, y5)

	if v > 25.5 then
		Enemy.drawHealth(self)
	end
end

function Gloomrat:scan()
	self.target = nil
	local dis, dir = math.vector(self.x, self.y, ovw.player.x, ovw.player.y)
	if dis < self.sight then
	    local blocked = ovw.collision:lineTest(self.x, self.y, ovw.player.x, ovw.player.y, 'wall')
	    if not blocked then
	    	local angles = {}
	    	for i = -3, 3 do
	    		table.insert(angles, dir - math.pi + i * (math.pi * 2 / 3) / 7)
	    	end
	    	local angry = true
	    	local runAngle = 0
	    	for k, v in pairs(angles) do
	    		local testAngle = v
	    		local testPos = {x = self.x + math.dx(self.aggressiveRange, testAngle), y = self.y + math.dy(self.aggressiveRange, testAngle)}
	    		local wall = ovw.collision:lineTest(self.x, self.y, testPos.x, testPos.y, 'wall')
	    		if not wall then
	    			runAngle = testAngle
	    			angry = false
	    		end
	    	end
			--sweep a pi * 2 / 3 cone behind at range aggressiveRange
			--if no location to go to because of walls, become aggressive
			--otherwise, run back to the found location
			if angry then
				self.state = 'aggressive'
				self.aggressiveTimer = self.aggressiveTime
				self.targetAngle = dir
				self.target = ovw.player
			else
	    		self.state = 'startled'
	    		self.startledTimer = self.startledTime
	    		self.targetAngle = runAngle
	    		self.angle = runAngle
	    		self.target = ovw.player
	    	end
	    end
	end

	if not self.target then
	    --self.targetAngle = self.targetAngle + (love.math.random() * 60 - 30)
	    self.state = 'roam'
	    --self.roamTimer = self.roamTime
	end

	self.scanTimer = .2
end

----------------
-- States
----------------
function Gloomrat:roam()
	self.scanTimer = self.scanTimer - tickRate
	self.roamTimer = self.roamTimer - tickRate

	if self.roamTimer > .5 then
		self.x = self.x + math.dx(self.walkSpeed * tickRate, self.angle)
		self.y = self.y + math.dy(self.walkSpeed * tickRate, self.angle)
	elseif self.roamTimer <= 0 then
	    self.roamTimer = self.roamTime
	    self.targetAngle = self.targetAngle + (love.math.random() * 60 - 30)
	end


	if self.scanTimer <= 0 then
		self:scan()
	end
end

function Gloomrat:startled()
	self.startledTimer = self.startledTimer - tickRate

	if self.startledTimer <= 0 then
		self:scan()
	end

	self.x = self.x + math.dx(self.runSpeed * tickRate, self.angle)
	self.y = self.y + math.dy(self.runSpeed * tickRate, self.angle)
end

function Gloomrat:aggressive()
	self.targetAngle = math.direction(self.x, self.y, self.target.x, self.target.y)
	self.x = self.x + math.dx(self.runSpeed * tickRate, self.angle)
	self.y = self.y + math.dy(self.runSpeed * tickRate, self.angle)
	self.aggressiveTimer = self.aggressiveTimer - tickRate
	if self.aggressiveTimer <= 0 then
		self.state = 'lunge'
		self.lungeTimer = self.lungeTime
		self.angle = self.targetAngle
	end
end

function Gloomrat:lunge()
	local dis, dir = math.vector(self.x, self.y, self.target.x, self.target.y)
	local speed = self.startledRange / self.lungeTime * tickRate
	speed = math.min(self.maxSpeed, speed, math.max(dis - (self.radius + self.target.radius), 0))
	self.x = self.x + math.dx(speed, self.angle)
	self.y = self.y + math.dy(speed, self.angle)

	-- Let it change its direction slightly while lunging
	self.targetAngle = math.anglerp(self.targetAngle, dir, 4 * tickRate)

	if math.distance(self.x, self.y, ovw.player.x, ovw.player.y) < self.lungeRange then
		ovw.player:hurt(self.damage)
		self.lungeTimer = 0
		self.state = 'fatigue'
		self.fatigueTimer = self.fatigueTime
		return
	end

	self.lungeTimer = self.lungeTimer - tickRate
	if self.lungeTimer <= 0 then
		self.state = 'fatigue'
		self.fatigueTimer = self.fatigueTime
	end
end

function Gloomrat:fatigue()
	-- Turn slower
	local dir = math.direction(self.x, self.y, self.target.x, self.target.y)
	self.targetAngle = math.anglerp(self.targetAngle, dir, 2 * tickRate)
	self.x = self.x - math.dx(self.walkSpeed * tickRate, self.angle)
	self.y = self.y - math.dy(self.walkSpeed * tickRate, self.angle)

	self.fatigueTimer = self.fatigueTimer - tickRate
	if self.fatigueTimer <= 0 then
		self.state = 'roam'
		self.roamTimer = self.roamTime
		self:scan()
	end
end

function Gloomrat:alert()
	if self.state == 'roam' then
		self.target = ovw.player
		self.state = 'aggressive'
		self.aggressiveTimer = 0
		self.scanTimer = 1
	end
end
	--scurries, protects young, doesn't like to be cornered