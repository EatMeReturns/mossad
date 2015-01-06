Note = extend(Pickup)

Note.tag = 'pickup'
Note.collision = {
	shape = 'rectangle',
	with = {player = function(self, player, dx, dy) self:activate() end,
			wall = Pickup.collision.with.wall
			}
}

function Note:init(data)
	self.x, self.y = 0, 0
	for k, v in pairs(data) do self[k] = v end
	assert(self.noteText)
	assert(self.room)
	self.room:addObject(self)
	self.width, self.height = 16
	ovw.collision:register(self)
	ovw.view:register(self)
end

function Note:destroy()
	self.room:removeObject(self)
	ovw.collision:unregister(self)
	ovw.view:unregister(self)
end

function Note:remove()
	ovw.pickups:remove(self)
end

function Note:update()
	--I don't think notes actually have to update...
end

function Note:draw()
	local tx, ty = ovw.house:cell(self.x, self.y)
	local v = ovw.house.tiles[tx] and ovw.house.tiles[tx][ty] and ovw.house.tiles[tx][ty]:brightness() or 1
	love.graphics.setColor(255, 255, 255, v)
	local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
	local scale = math.max(.5, self.amount / 20)
	self.shape:draw('line')
end

function Note:setPosition(x, y)
	self.x, self.y = x, y
	self.shape:moveTo(x, y)
end

function Note:activate()
	ovw.hud.notebook:add(self.noteText)
	self:remove()
end