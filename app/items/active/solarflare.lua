SolarFlare = extend(Item)

SolarFlare.name = 'Solar Flare'
SolarFlare.pickupMessage = '\"Truth is like the sun. You can shut it out for a time, but it ain\'t goin\' away.\"\n\nElvis Presley'

function SolarFlare:init()
	Item.init(self)

	self.type = 'Active' --Toggle?
end

function SolarFlare:activate()
	if ovw.player.energy >= .5 and not self.active then
		ovw.player.energy = ovw.player.energy - .5
		ovw.spells:add(SolarFlareSpell(self.index))
		ovw.hud.fader:add('Let there be light!')
		self.active = true
	end
end

function SolarFlare:update()
	if not love.keyboard.isDown(self.index) then self.active = false end
end

---

SolarFlareSpell = extend(Spell)

function SolarFlareSpell:init(index)
	self.type = 'Active'
	self.x, self.y = ovw.player.x, ovw.player.y
	self.light = {
		minDis = -50,
		maxDis = 150,
		shape = 'ring',
		intensity = 1.5,
		falloff = 1,
		flicker = 1,
		color = {255, 255, 100, 5}, --the fourth value is color intensity, not alpha
		x = self.x,
		y = self.y,
		penetrateWalls = true
	}

	self.health = 2
	self.maxHealth = self.health

	self.active = true

	self.index = index
end

function SolarFlareSpell:update()
	Spell.update(self)
	local dir = math.sign(self.health - 1)

	if self.health <= 0 then
		ovw.view.scaleModifier = 0
	else
		ovw.view.scaleModifier = -1 * math.abs(1 - math.abs(self.health - 1))
	end
	
	self.light.x, self.light.y = ovw.player.x, ovw.player.y
	
	if self.health > 1.2 then
		self.light.minDis = self.light.minDis + House.cellSize * 18 * tickRate * dir
		self.light.maxDis = self.light.maxDis + House.cellSize * 18 * tickRate * dir
	elseif self.active and love.keyboard.isDown(self.index) then
		self.health = .6
		ovw.player.energy = ovw.player.energy - tickRate * .5
	elseif self.health < .6 then
		self.light.minDis = self.light.minDis + House.cellSize * 24 * tickRate * dir
		self.light.maxDis = self.light.maxDis + House.cellSize * 24 * tickRate * dir 
	end

	if ovw.player.energy < tickRate * .5 or not love.keyboard.isDown(self.index) then
		self.active = false
	end

	ovw.house:applyLight(self.light, 'dynamic')
end

function SolarFlareSpell:draw()
	--
end