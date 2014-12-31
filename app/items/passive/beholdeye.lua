BeholdEye = extend(Item)

BeholdEye.image = love.graphics.newImage('media/graphics/icons/beholdeye.png')

BeholdEye.name = 'Behold of the Eye'
BeholdEye.pickupMessage = '\"The humans say that beauty is in the eye of the beholder, you know, but as usual they\'ve got it arse-about\"\n\nThe Behold of the Eye by Hal Duncan'

function BeholdEye:init()
	Item.init(self)

	self.type = 'Passive'

	self.light = {
		minDis = 50,
		maxDis = 100,
		shape = 'circle',
		intensity = 1,
		falloff = 1,
		posterization = 1,
		flicker = 1,
		color = {255, 255, 100, 5} --the fourth value is color intensity, not alpha
	}
end

function BeholdEye:update()
	table.each(ovw.pickups.objects, function(pickup, key)
		if math.distance(pickup.x, pickup.y, ovw.player.x, ovw.player.y) < 450 then
			self.light.x, self.light.y = pickup.x, pickup.y
 			ovw.house:applyLight(self.light, 'ambient')
 		end
	end)
end