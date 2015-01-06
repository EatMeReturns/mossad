Shotgun = extend(Weapon)

Shotgun.name = 'Shotgun'
Shotgun.pickupMessage = 'Pull!'

Shotgun.image = love.graphics.newImage('media/graphics/icons/shotgun.png')
Shotgun.scaling = {x = 1.2, y = 1.2}

Shotgun.damage = 3
Shotgun.fireMode = 'Single'
Shotgun.fireSpeed = 1
Shotgun.reloadSpeed = 0.5
Shotgun.clip = 6
Shotgun.ammo = 24

Shotgun.spread = 12

Shotgun.weight = 2 --used to calculate melee info