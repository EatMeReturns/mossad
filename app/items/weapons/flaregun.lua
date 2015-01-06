Flaregun = extend(Weapon)

Flaregun.name = 'Flaregun'
Flaregun.pickupMessage = '\"I love the smell of napalm in the morning.\"\n\nLieutenant Colonel Bill Kilgore'

Flaregun.image = love.graphics.newImage('media/graphics/icons/flaregun.png')
Flaregun.scaling = {x = .8, y = .8}

Flaregun.damage = 10
Flaregun.fireMode = 'Semiautomatic'
Flaregun.fireSpeed = 0
Flaregun.reloadSpeed = 3
Flaregun.clip = 6
Flaregun.ammo = 24

Flaregun.spread = 1

Flaregun.weight = 1 --used to calculate melee info

function Flaregun:fire()
	local x, y = ovw.player.x + self.tipOffset.getX(), ovw.player.y + self.tipOffset.getY()
	for i = 0, self.spread - 1 do 
	    local dAngle = ovw.player.angle + i * (love.math.random() * 0.075 - 0.0375)
	    ovw.spells:add(FlareSpell(dAngle, x, y, self.damage))
	end
end