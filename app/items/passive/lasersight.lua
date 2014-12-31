LaserSight = extend(Item)

LaserSight.name = 'Laser Sight'
LaserSight.pickupMessage = 'Don\'t aim at any aircraft.'

function LaserSight:init()
	Item.init(self)

	self.type = 'Passive'

	local colorNames = {' [Red]', ' [Green]', ' [Blue]'}
	self.color = {}
	local rgb = {0, 0, 0}
	if love.math.random() < .33 then rgb = {1, 0, 0}
	elseif love.math.random() < .5 then rgb = {0, 1, 0}
	else rgb = {0, 0, 1} end
	for i = 1, 3 do
		self.color[i] = rgb[i] * 200 + love.math.random() * 55
		self.name = self.name .. (rgb[i] > 0 and colorNames[i] or '')
	end
end

function LaserSight:update()
	ovw.player.hasLaserSight = true
end

function LaserSight:draw()
	local p = ovw.player
	local weapon = p.arsenal.weapons[p.arsenal.selected]
	if weapon then
		local x, y = p.x + weapon.tipOffset.getX(), p.y + weapon.tipOffset.getY()
		local dis = weapon.MAX_RANGE
		local x2, y2 = x + math.dx(dis, p.angle), y + math.dy(dis, p.angle)
		love.graphics.setColor(self.color[1], self.color[2], self.color[3], 50)
		love.graphics.line(x, y, x2, y2)
	end
end