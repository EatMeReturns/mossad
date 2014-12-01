require 'app/enemy'

Shade = extend(Enemy)

Shade.collision = setmetatable({}, {__index = Enemy.collision})
Shade.collision.shape = 'circle'
Shade.radius = 16

Shade.image = love.graphics.newImage('media/graphics/wraith.png')

function Shade:init(...)
  Enemy.init(self, ...)

  self.state = 'roam'

  self.sight = 300
  self.target = nil
  self.scanTimer = 0
  
  self.runSpeed = 110
  self.walkSpeed = 50

  self.damage = 5

  self.windupTime = .3 -- Time it takes to deal damage
  self.windupTimer = 0
  self.windupRange = 140

  self.attackTime = .21 -- Time it takes to lunge
  self.attackTimer = 0
  self.attackRange = 35 -- Damage is dealt if player is this close after lunging

  self.fatigueTime = 1 -- Time it stands still after attacking
  self.fatigueTimer = 0

  self.health = love.math.random(18, 30)
end

function Shade:destroy()
  Enemy.destroy(self)
  local function make(i) ovw.pickups:add(Pickup({x = self.x, y = self.y, itemType = i})) end
  ovw.player:learn(9 + math.ceil(love.math.random() * 10))

  local probs = {
    {Glowstick, .25},
    {FirstAidKit, .2},
    {Ammo, .7},
    {Torch, .1}
  }

  table.shuffle(probs)
  
  local x = love.math.random()

  for _, t in ipairs(probs) do
    local item, chance = unpack(t)
    if x < chance then
      make(item)
      x = x + love.math.random() * (1 - chance) ^ 2
    end
  end
end

function Shade:update()
  self.prevX = self.x
  self.prevY = self.y

  self[self.state](self)

  self:setPosition(self.x, self.y)
  self.angle = math.anglerp(self.angle, self.targetAngle, math.clamp(6 * tickRate, 0, 1))
end

function Shade:draw()
  local x, y = math.lerp(self.prevX, self.x, tickDelta / tickRate), math.lerp(self.prevY, self.y, tickDelta / tickRate)
  local tx, ty = ovw.house:cell(self.x, self.y)
  local v = ovw.house.tiles[tx][ty]:brightness()
  if self.attackTimer > 0 then
    local a = .4
    local d = self.angle
    for i = 10, 40, 10 do
      love.graphics.setColor(255, 255, 255, v * a * (self.attackTimer / self.attackTime))
      love.graphics.draw(self.image, x + math.dx(i, d), y + math.dy(i, d), self.angle, 1, 1, 29, 14)
      a = a - .1
    end
  end
  love.graphics.setColor(255, 255, 255, v)
  love.graphics.draw(self.image, x, y, self.angle, 1, 1, 29, 14)
end

function Shade:scan()
  self.target = nil
  local dis, dir = math.vector(self.x, self.y, ovw.player.x, ovw.player.y)
  if dis < self.sight and math.abs(math.anglediff(dir, self.angle)) < math.pi / 2 then
    local blocked = ovw.collision:lineTest(self.x, self.y, ovw.player.x, ovw.player.y, 'wall')
    if not blocked then
      self.target = ovw.player
      self.state = 'chase'
    end
  end

  if not self.target then
    self.targetAngle = self.targetAngle + (love.math.random() * 60 - 30)
    self.state = 'roam'
  end

  self.scanTimer = 1
end

----------------
-- States
----------------
function Shade:roam()
  self.scanTimer = self.scanTimer - tickRate
  
  if self.scanTimer <= 0 then
    self:scan()
  end
  
  self.x = self.x + math.dx(self.walkSpeed * tickRate, self.angle)
  self.y = self.y + math.dy(self.walkSpeed * tickRate, self.angle)
end

function Shade:chase()
  self.scanTimer = self.scanTimer - tickRate
  
  if self.scanTimer <= 0 then
    self:scan()
  end

  if self.target ~= nil then
    local dis, dir = math.vector(self.x, self.y, self.target.x, self.target.y)
    local minDis = math.max(dis - (self.radius + self.target.radius), 0)
    self.targetAngle = dir
    self.x = self.x + math.dx(math.min(self.runSpeed * tickRate, minDis), self.angle)
    self.y = self.y + math.dy(math.min(self.runSpeed * tickRate, minDis), self.angle)

    if dis < self.windupRange and self.attackTimer == 0 and self.windupTimer == 0 and self.fatigueTimer == 0 then
      self.state = 'windup'
      self.windupTimer = self.windupTime
    end
  else
    self.state = 'roam'
  end
end

function Shade:windup()
  self.targetAngle = math.direction(self.x, self.y, self.target.x, self.target.y)
  self.windupTimer = timer.rot(self.windupTimer, function()
    self.state = 'attack'
    self.attackTimer = self.attackTime
  end)
end

function Shade:attack()
  local dis, dir = math.vector(self.x, self.y, self.target.x, self.target.y)
  local speed = self.windupRange / self.attackTime * tickRate
  speed = math.min(speed, math.max(dis - (self.radius + self.target.radius), 0))
  self.x = self.x + math.dx(speed, self.angle)
  self.y = self.y + math.dy(speed, self.angle)
  
  self.attackTimer = timer.rot(self.attackTimer, function()
    if math.distance(self.x, self.y, ovw.player.x, ovw.player.y) < self.attackRange then
      ovw.player:hurt(self.damage)
    end
    self.state = 'fatigue'
    self.fatigueTimer = self.fatigueTime
  end)

  -- Let it change its direction slightly while lunging
  self.targetAngle = math.anglerp(self.targetAngle, dir, 4 * tickRate)
end

function Shade:fatigue()

  -- Turn slower
  local dir = math.direction(self.x, self.y, self.target.x, self.target.y)
  self.targetAngle = math.anglerp(self.targetAngle, dir, 2 * tickRate)

  self.fatigueTimer = timer.rot(self.fatigueTimer, function()
    self.state = 'chase'
  end)
end
