Shade = extend(Enemy)

function Shade:scan()
	local targetX = self.x + math.cos(self.direction) * self.sight
	local targetY = self.y + math.sin(self.direction) * self.sight
	self.target = nil
	local rooms = ovw.collision:lineTest(self.x, self.y, targetX, targetY, 'room', true)
	table.each(rooms, function(room) if table.has(room.contents, ovw.player) then self.target = ovw.player end end)
	if target ~= nil then
		--player found! self.state = chase?
	else
		--nothing there. self.state = wander?
		self.direction = self.direction + (love.math.random() * 60 - 30)
	end
	self.scanTimer = 1
end

function Shade:update()
	self.scanTimer = self.scanTimer - tickRate
	if self.scanTimer <= 0 then self:scan() end
	self.prevX = self.x
	self.prevY = self.y
	if self.target ~= nil then
		self.direction = math.direction(self.x, self.y, self.target.x, self.target.y)
		self.x = self.x + math.cos(self.direction) * (self.runSpeed * tickRate)
		self.y = self.y + math.sin(self.direction) * (self.runSpeed * tickRate)
	else
		self.x = self.x + math.cos(self.direction) * (self.walkSpeed * tickRate)
		self.y = self.y + math.sin(self.direction) * (self.walkSpeed * tickRate)
	end

	self:setPosition(self.x, self.y)
	self.angle = self.direction
end

function Shade:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  love.graphics.setColor(255, 255, 255, 255)
  if self.target ~= nil then love.graphics.setColor(255, 0, 0, 255) end
  self.shape:draw()
  love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * self.radius, self.y + math.sin(self.angle) * self.radius)
end
