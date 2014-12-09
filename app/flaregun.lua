require 'app/weapon'

Flaregun = extend(Weapon)

Flaregun.name = 'Flaregun'

Flaregun.damage = 10
Flaregun.fireMode = 'Semiautomatic'
Flaregun.fireSpeed = 0
Flaregun.reloadSpeed = 3
Flaregun.clip = 6
Flaregun.ammo = 24

Flaregun.spread = 1