MuzzleFlash = class()

MuzzleFlash.image = love.graphics.newImage('media/graphics/muzzleFlash.png')
MuzzleFlash.bulletAnim = newAnimation(love.graphics.newImage('media/graphics/blackSmoke.png'), 164, 164, .2 / 40, 40, 1)
MuzzleFlash.bulletAnim:setMode('once')

MuzzleFlash.bulletShader = love.graphics.newShader(
  [[
  vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
  {
     return vec4(Texel(tex,tc).r * 5, Texel(tex,tc).g * 2, Texel(tex,tc).b * 2, Texel(tex,tc).r * 4 + Texel(tex,tc).g * 5 + Texel(tex,tc).b * 5);
  }]])
  
function MuzzleFlash:init(dis, dir, pos, size)
  self.light = {
    minDis = 0,
    maxDis = 64,
    intensity = .75,
    falloff = 1,
    posterization = 1
  }

  self.lineW = size / 5

  self.x, self.y = pos.x, pos.y
  self.dir = dir
  self.endX, self.endY = self.x + math.dx(dis, dir), self.y + math.dy(dis, dir)
  --self.bulletAnim = newAnimation(love.graphics.newImage('media/graphics/purpleSmoke.png'), 80, 80, .2 / 30, 30)
  self.bulletAnim = table.copy(MuzzleFlash.bulletAnim)
  for d = 0, dis, 15 do
    local x, y = self.x + math.dx(d, dir), self.y + math.dy(d, dir)
    self.light.x, self.light.y = x, y
    ovw.house:applyLight(self.light, 'dynamic')
    self.light.intensity = self.light.intensity - .015
    if self.light.intensity <= 0 then break end
  end

  self.health = .2
  self.depth = -5
  ovw.view:register(self)
end

function MuzzleFlash:destroy()
  ovw.view:unregister(self)
end

function MuzzleFlash:update()
  self.health = timer.rot(self.health, function()
    ovw.particles:remove(self)
  end)

  self.bulletAnim:update(tickRate)
end

function MuzzleFlash:draw()
  local v = (math.clamp(self.health, 0, .2) - 0) / .2 * 255
  love.graphics.setColor(255, 255, 255, v)
  love.graphics.setLineWidth(self.lineW)
  --love.graphics.line(self.x, self.y, self.endX, self.endY)
  love.graphics.draw(self.image, self.x, self.y, self.dir, 1, .75, self.image:getWidth() / 4, self.image:getHeight() / 2)
  --love.graphics.circle('fill', self.endX, self.endY, 2)
  love.graphics.setLineWidth(1)
  v = self.health / .2 * 255
  love.graphics.setColor(255, 255, 255, v)
  love.graphics.setShader(MuzzleFlash.bulletShader)
  self.bulletAnim:draw(self.endX - self.bulletAnim:getWidth() / 2, self.endY - self.bulletAnim:getHeight() + 15, 0, 1, 1)
  love.graphics.setShader()
end
