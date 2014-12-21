require 'app/weapon'

Flaregun = extend(Weapon)

Flaregun.name = 'Flaregun'
Flaregun.pickupMessage = '\"I love the smell of napalm in the morning.\"\n\nLieutenant Colonel Bill Kilgore'

Flaregun.damage = 10
Flaregun.fireMode = 'Semiautomatic'
Flaregun.fireSpeed = 0
Flaregun.reloadSpeed = 3
Flaregun.clip = 6
Flaregun.ammo = 24

Flaregun.spread = 1

Flaregun.weight = 1 --used to calculate melee info