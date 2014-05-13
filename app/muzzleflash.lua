MuzzleFlash = class()

function MuzzleFlash:init(dis, dir)
  self.light = {
    minDis = 0,
    maxDis = 64,
    intensity = .75,
    falloff = 1,
    posterization = 1
  }

  self.x, self.y = ovw.player.x, ovw.player.y - 15
  self.endX, self.endY = self.x + math.dx(dis, dir), self.y + math.dy(dis, dir)

  for d = 0, dis, 15 do
    local x, y = self.x + math.dx(d, dir), self.y + math.dy(d, dir)
    self.light.x, self.light.y = x, y
    ovw.house:applyLight(self.light, 'dynamic')
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
end

function MuzzleFlash:draw()
  local v = self.health * 255
  love.graphics.setColor(255, 255, 255, v)
  love.graphics.setLineWidth(2)
  love.graphics.line(self.x, self.y, self.endX, self.endY)
  love.graphics.setLineWidth(1)
end
