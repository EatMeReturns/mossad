require 'app/weapon'

Crossbow = extend(Weapon)

Crossbow.name = 'Crossbow'
Crossbow.pickupMessage = '\"You\'re gonna have a much bigger problem than a gunshot wound.\"\n\nDaryl Dixon'

Crossbow.damage = 30
Crossbow.fireMode = 'Single'
Crossbow.fireSpeed = 0
Crossbow.reloadSpeed = 1.5
Crossbow.clip = 1
Crossbow.ammo = 12

Crossbow.spread = 1

Crossbow.weight = 3 --used to calculate melee info