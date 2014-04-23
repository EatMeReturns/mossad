Enemy = class()
Enemy.tag = 'enemy' --for collision

Enemy.collision = {
	shape = 'circle',
	static = false,
	with = {
		wall = function(self, other, dx, dy)
			self:setPosition(self.x + dx, self.y + dy)
		end,
		enemy = function(self, other, dx, dy)
			self:setPosition(self.x + dx / 2, self.y + dy / 2)
			other:setPosition(other.x - dx / 2, other.y - dy / 2)
		end
	}
}

function Enemy:init(x, y, health)
	table.insert(level.enemies, self)
	level.enemyCount = level.enemyCount + 1
	self.x = x
	self.y = y
	self.angle = 0
	self.radius = 9 + 3 * health / 10
	self.speed = 0
	self.maxSpeed = 300
	self.health = health

	self.weapon = Weapon(self)

	self.prevX = self.x
	self.prevY = self.y

	ovw.collision:register(self)
end

function Enemy:setRoom(room)
	self.room = room
end

function Enemy:destroy()
	self.room = nil
	level.enemyCount = level.enemyCount - 1
	ovw.collision.hc:remove(self.shape)
	ovw.player.weapon.ammo = ovw.player.weapon.ammo + 1
end

function Enemy:update()
	if self.health <= 0 then level.enemies = table.filter(level.enemies, function(enemy) if enemy == self then return false else return true end end) self:destroy() end
	self.prevX = self.x
	self.prevY = self.y
	self:move()
	self.angle = math.direction(self.x, self.y, ovw.player.x, ovw.player.y)
	self.weapon:update()
end

function Enemy:draw()
  local x, y = math.lerp(self.prevX, self.x, delta / tickRate), math.lerp(self.prevY, self.y, delta / tickRate)
  self.shape:moveTo(x, y)
  love.graphics.setColor(red[1], red[2], red[3], 128)
  self.shape:draw('fill')
  love.graphics.setColor(red[1], red[2], red[3], 255)
  self.shape:draw('line')
  love.graphics.line(x, y, x + math.dx(self.radius - .5, self.angle), y + math.dy(self.radius - .5, self.angle))
  self.shape:moveTo(self.x, self.y)
end

function Enemy:damage(amount)
	self.health = self.health - amount
end

function Enemy:move()
  local w, a, s, d = self.y > ovw.player.y, self.x > ovw.player.x, self.y < ovw.player.y, self.x < ovw.player.x
  local moving = w or a or s or d
  
  local up, down, left, right, dx, dy = 1.5 * math.pi, .5 * math.pi, math.pi, 2.0 * math.pi
    
  if moving then self.speed = self.maxSpeed
  else self.speed = 0 end
    
  if not moving then return end
  
  if a and not d then dx = left elseif d then dx = right end
  if w and not s then dy = up elseif s then dy = down end

  if dx or dy then
    if not dx then dx = dy end
    if not dy then dy = dx end
    if dx == right and dy == down then dx = 0 end
    
    local dir = (dx + dy) / 2
    self.x, self.y = self.x + math.cos(dir) * (self.speed * tickRate), self.y + math.sin(dir) * (self.speed * tickRate)
  end
  
  self:setPosition(self.x, self.y)
end

function Enemy:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end