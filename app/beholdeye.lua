require 'app/item'

BeholdEye = extend(Item)

BeholdEye.name = 'Behold of the Eye'

function BeholdEye:init()
	Item.init(self)

	self.type = 'Passive'

	self.light = {
		minDis = 50,
		maxDis = 100,
		shape = 'circle',
		intensity = .3,
		falloff = .9,
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