BodyPart = class()

function BodyPart:init(name, index)
	self.name = name
	self.index = index
	self.crippled = false
	self.wounded = false
	self.hasKit = false

	self.timers = {}
	self.timers.heal = 3
	self.timers.kill = 5
	self.healSoundState = 0

	self.killSpeed = 15
	self.healSpeed = 3
	self.currentHealth = 15
	self.maxHealth = 15

	self.image = Item.image
end

function BodyPart:update()
	if self.hasKit then --if healing then
		local currentHealSound = math.ceil(self.timers.heal / ((10 / (10 + ovw.player:getStat('agility', true))) / (5 / 6)))
		if currentHealSound ~= self.healSoundState then
			self.healSoundState = currentHealSound
			local healSound = ovw.sound:play('first_aid_' .. currentHealSound .. '.wav')
			healSound:setVolume(ovw.sound.volumes.fx)
		end
		self.timers.heal = timer.rot(self.timers.heal, function()
			self.hasKit = false
			self.timers.heal = self.healSpeed * (10 / (10 + ovw.player:getStat('agility', true)))
			self:heal()
			ovw.player.firstAid.healPart = 0
		end)
	else
		self.timers.heal = self.healSpeed * (10 / (10 + ovw.player:getStat('agility', true)))

		if self.wounded then --if killing then
			self.timers.kill = timer.rot(self.timers.kill, function()
				ovw:restart() --self is kill
			end)
		else
			self.timers.kill = self.killSpeed
		end
	end
end

function BodyPart:startHeal()
	self.hasKit = true
	ovw.player.kits = ovw.player.kits - 1
	self.healSoundState = 0
end

function BodyPart:cancelHeal()
	self.hasKit = false
	ovw.player.kits = ovw.player.kits + 1
	self.healSoundState = 0
end

function BodyPart:damage(amt)
	self.currentHealth = self.currentHealth - math.max(1, math.floor(amt * (10 / (10 + ovw.player:getStat('armor', true)))))
	if self.currentHealth <= 0 then
		if self.crippled and not self.wounded then
			--mortally wound!
			self:wound()
	        ovw.hud.fader:add('Mossad starts writing my name in his notebook...')
	        --ovw.house.targetAmbient = {0, 0, 0}
		elseif not self.crippled then 
			--cripple!
			self:cripple()
			ovw.hud.fader:add('I need healing...')
			local crunch = ovw.sound:play('bone_cripple.wav')
			crunch:setVolume(ovw.sound.volumes.fx)
			--ovw.house.targetAmbient = {255, 160, 160}
		else
			--already wounded
		end
	end
end

function BodyPart:heal()
	if self.wounded then
		self.wounded = false
		self.currentHealth = self.maxHealth
    	ovw.hud.fader:add('ty raka')
	elseif self.crippled then
		self.crippled = false
		self.currentHealth = self.maxHealth
    	ovw.hud.fader:add('ty raka')
    	--ovw.house.targetAmbient = {255, 255, 255}
		local debuff = ovw.player.firstAid.debuffs[self.index]
		local parent = debuff.val == 'maxDis' and ovw.player.light or ovw.player
		parent[debuff.val] = parent[debuff.val] + debuff.modifier
	elseif self.currentHealth < self.maxHealth then
		self.currentHealth = self.maxHealth
    	ovw.hud.fader:add('ty raka')
	end
end

function BodyPart:cripple()
	self.currentHealth = self.maxHealth
	self.crippled = true
end

function BodyPart:wound()
	--you gon' die
	self.currentHealth = 0
	self.wounded = true
	self.timers.kill = self.killSpeed
end

function BodyPart:regen()
	--passive health regen when not  crippled/wounded
	if not self.crippled and self.currentHealth < self.maxHealth then
		self.currentHealth = self.currentHealth + ovw.player.healthRegen * tickRate
		if self.currentHealth > self.maxHealth then self.currentHealth = self.maxHealth end
	end
end

function BodyPart:val()
  if self.hasKit and self.timers.heal > 0 then return self.timers.heal / (self.healSpeed * (10 / (10 + ovw.player:getStat('agility', true)))) end
  if self.wounded and self.timers.kill > 0 then return self.timers.kill / self.killSpeed end
  return self.currentHealth / self.maxHealth
end