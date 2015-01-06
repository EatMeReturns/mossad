FlareSpell = extend(Spell)

FlareSpell.collision = {
  shape = 'circle',
  static = false,
  with = {
    wall = function(self, other, dx, dy)
   	  self.dir = math.bounce(self.dir, dx, dy)
      self:setPosition(self.x + dx, self.y + dy)
      self.speed = self.speed * 3 / 5
    end,

    enemy = function(self, other, dx, dy)
      other:hurt(self.damage * self.speed / 275)
      self.speed = self.speed * 2 / 3
    end
  }
}

function FlareSpell:init(dir, x, y, damage)
	Spell.init(self)

	self.type = 'Projectile'

	self.x, self.y = x, y
	self.dir = dir
	self.speed = 275
	self.damage = damage

	self.depth = DrawDepths.sitters

	self.radius = 10
	self.rotation = 0

	self.light = {
	    minDis = 30,
	    maxDis = 350,
    	shape = 'circle',
	    intensity = 1,
	    falloff = 1,
	    posterization = 10,
	    flicker = 0.5,
	    x = self.x,
	    y = self.y,
	    color = {255, 0, 0, 10} --the fourth value is color intensity, not alpha
	}

	self.health = 10
	self.maxHealth = self.health
	ovw.collision:register(self)
end

function FlareSpell:destroy()
  Spell.destroy(self)
  ovw.collision:unregister(self)
end

function FlareSpell:update()
	Spell.update(self)

	self:setPosition(self.x + math.cos(self.dir) * (self.speed * tickRate), self.y + math.sin(self.dir) * (self.speed * tickRate))
	if self.speed > 0 then self.speed = self.speed - math.max(2, self.speed * .8 * tickRate) else self.speed = 0 end
	self.light.x, self.light.y = self.x, self.y
	self.light.intensity = self.light.intensity - (0.5 / self.maxHealth * tickRate)
	ovw.house:applyLight(self.light, 'ambient')
end

function FlareSpell:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.circle('line', self.x, self.y, 10)
end

function FlareSpell:val()
  return self.health / self.maxHealth
end

function FlareSpell:maxVal()
  return self.maxHealth
end

function FlareSpell:setPosition(x, y)
  self.x, self.y = x, y
  self.shape:moveTo(x, y)
end