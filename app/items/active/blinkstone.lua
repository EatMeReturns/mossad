Blinkstone = extend(Item)

Blinkstone.name = 'Blinkstone'

function Blinkstone:init()
	Item.init(self)

	self.type = 'Active'

	self.timer = 0
	self.time = .2

	self.blinkRange = 250
end

function Blinkstone:activate()
	if ovw.player.energy >= 1 and not self.active then
		ovw.player.energy = ovw.player.energy - 1
		self:blink()
		self.active = true
		self.timer = self.time
	end
end

function Blinkstone:blink()
	local dir = ovw.player.angle
	local length = math.min(self.blinkRange, love.mouse.distance())
	local ready = false
	local blinkTarget = {x = ovw.player.x, y = ovw.player.y}
	while length > 0 do
		local x, y = math.dx(length, dir), math.dy(length, dir)
		if not ready then
			local tx, ty = ovw.house:cell(ovw.player.x + x, ovw.player.y + y)
			if ovw.house.tiles[tx] and ovw.house.tiles[tx][ty] then
				local tile = ovw.house.tiles[tx][ty]
				if tile.Brightness > .3 then
					blinkTarget.x, blinkTarget.y = tile.posX + House.halfCell, tile.posY + House.halfCell
					ready = true
				end
			end
		else
			ovw.particles:add(BlinkstoneFlash{x = ovw.player.x + x, y = ovw.player.y + y})
		end
		length = length - 15
	end

	ovw.player:setPosition(blinkTarget.x, blinkTarget.y)
end

function Blinkstone:update()
	self.timer = self.timer - tickRate
	if self.timer <= 0 then self.active = false self.timer = 0 end
end

function Blinkstone:val()
	return self.active and self.timer / self.time or 1
end

---

BlinkstoneFlash = class()

BlinkstoneFlash.anim = newAnimation(love.graphics.newImage('media/graphics/blackSmoke.png'), 164, 164, .2 / 40, 40, 1)
BlinkstoneFlash.anim:setMode('once')

function BlinkstoneFlash:init(pos)
	self.anim = table.copy(BlinkstoneFlash.anim)

	self.x, self.y = pos.x, pos.y

	self.health = .2
	self.depth = -5
	ovw.view:register(self)
end

function BlinkstoneFlash:destroy()
	ovw.view:unregister(self)
end

function BlinkstoneFlash:update()
	self.health = timer.rot(self.health, function()
		ovw.particles:remove(self)
	end)

	self.anim:update(tickRate)
end

function BlinkstoneFlash:draw()
	local v = self.health / .2 * 255
	love.graphics.setColor(255, 255, 255, v)
	self.anim:draw(self.x - self.anim:getWidth() / 2, self.y - self.anim:getHeight() + 15, 0, 1, 1)
end