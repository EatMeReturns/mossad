require 'app/weapon'

Crossbow = extend(Weapon)

Crossbow.name = 'Crossbow'

Crossbow.damage = 30
Crossbow.fireMode = 'Single'
Crossbow.fireSpeed = 0
Crossbow.reloadSpeed = 1.5
Crossbow.clip = 1
Crossbow.ammo = 12

Crossbow.spread = 1