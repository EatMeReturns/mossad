require 'app/weapon'

Shotgun = extend(Weapon)

Shotgun.name = 'Shotgun'

Shotgun.damage = 2
Shotgun.fireMode = 'Single'
Shotgun.fireSpeed = 1
Shotgun.reloadSpeed = 0.5
Shotgun.clip = 6
Shotgun.ammo = 24

Shotgun.spread = 12

Shotgun.weight = 2 --used to calculate melee info