require 'app/weapon'

Pistol = extend(Weapon)

Pistol.name = 'Pistol'
Pistol.pickupMessage = 'How fortunate, a pistol.'

Pistol.damage = 10
Pistol.fireMode = 'Semiautomatic'
Pistol.fireSpeed = 0
Pistol.reloadSpeed = 2
Pistol.clip = 8
Pistol.ammo = 32

Pistol.spread = 1

Pistol.weight = 1 --used to calculate melee info