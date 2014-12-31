LaceAgate = extend(Item)

LaceAgate.name = 'Lace Agate'
LaceAgate.pickupMessage = '... and also more?'

function LaceAgate:init(level, materials)
	Item.init(self)

	self.type = 'Passive'
	self.style = ''

	local mat = materials[1] == 'Agate' and materials[2] or materials[1]

	if mat == 'Pure Element Double Green' then self.style = {'double', 'MossAgate'}
	elseif mat == 'Pure Element Double Purple' then self.style = {'double', 'ImperialAgate'}
	elseif mat == 'Pure Element Double Orange' then self.style = {'double', 'TigerAgate'}
	elseif mat == 'Pure Element Green Purple' then self.style = {'single', 'HybridSteal'}
	elseif mat == 'Pure Element Green Orange' then self.style = {'single', 'FreeRun'}
	else self.style = {'single', 'ChargeMelee'} end --Purple Orange

	self.amount = .25 * (level and (level > 1 and (level ^ (1 + level / 10)) or 1) or 1)
end

function LaceAgate:update()
	ovw.player.ammoMultiplier = ovw.player.ammoMultiplier + self.amount
	if self.style[1] == 'double' then
		_G[self.style[2]].update(self)
		_G[self.style[2]].update(self)
	else --hybridsteal or charging melee or free running
		if self.style[2] == 'HybridSteal' then
			ovw.player.lifeStealMultiplier = ovw.player.lifeStealMultiplier + self.amount / 10
			ovw.player.energyStealMultiplier = ovw.player.energyStealMultiplier + self.amount
		elseif self.style[2] == 'FreeRun' then
			ovw.player.hasFreeRun = true
		else
			ovw.player.hasChargeMelee = true
		end
	end
end