Camera = extend(Weapon)

Camera.name = 'Camera'
Camera.pickupMessage = 'I think this counts as a semiautomatic weapon?'

Camera.damage = 0
Camera.fireMode = 'Semiautomatic'
Camera.fireSpeed = 0
Camera.reloadSpeed = 1
Camera.clip = 36
Camera.ammo = 108

Camera.spread = 1

Camera.weight = .25 --used to calculate melee info

function Camera:fire()
	local x, y = ovw.player.x + self.tipOffset.getX(), ovw.player.y + self.tipOffset.getY()
	for i = 0, self.spread - 1 do 
	    local dAngle = ovw.player.angle + i * (love.math.random() * 0.075 - 0.0375)

	    local pictureRange = 300
	    local pictureArcW = math.pi / 3

	    local p = ovw.player

        table.each(ovw.collision:arcTest(p.x, p.y, pictureRange, p.angle, pictureArcW, 'enemy', true, false), function(enemy, key)
        	local hasBuff = false
        	table.each(ovw.buffs.objects, function(buff, key) if buff.enemyName and buff.enemyName == enemy.name.pluralized then buff.health = buff.maxHealth hasBuff = true end end)
        	if not hasBuff then ovw.buffs:add(CameraBuff(enemy.name.pluralized)) end
        	enemy:hurt(self.damage)
    	end)

        ovw.particles:add(MeleeFlash(pictureRange, p.angle, {x = p.x, y = p.y}, pictureArcW))
	end
end

---

CameraBuff = extend(Buff)

function CameraBuff:init(enemyName)
	self.enemyName = enemyName
	self.name = 'Damage to ' .. enemyName
	self.damageMultiplier = 1.5
end