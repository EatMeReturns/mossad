House.tileImage = love.graphics.newImage('media/graphics/newTiles.png')
local w, h = House.tileImage:getDimensions()
local function t(x, y) return love.graphics.newQuad(1 + (x * 35), 1 + (y * 35), 32, 32, w, h) end
House.tilemap = {}
House.tilemap.main = {}
House.tilemap.main.c = t(1, 4)
House.tilemap.main.n = t(1, 3)
House.tilemap.main.s = t(1, 5)
House.tilemap.main.e = t(2, 4)
House.tilemap.main.w = t(0, 4)
House.tilemap.main.nw = t(0, 3)
House.tilemap.main.ne = t(2, 3)
House.tilemap.main.sw = t(0, 5)
House.tilemap.main.se = t(2, 5)
House.tilemap.main.inw = t(3, 3)
House.tilemap.main.ine = t(4, 3)
House.tilemap.main.isw = t(3, 4)
House.tilemap.main.ise = t(4, 4)

House.tilemap.boss = {}
House.tilemap.boss.c = t(1, 1)
House.tilemap.boss.n = t(1, 0)
House.tilemap.boss.s = t(1, 2)
House.tilemap.boss.e = t(2, 1)
House.tilemap.boss.w = t(0, 1)
House.tilemap.boss.nw = t(0, 0)
House.tilemap.boss.ne = t(2, 0)
House.tilemap.boss.sw = t(0, 2)
House.tilemap.boss.se = t(2, 2)
House.tilemap.boss.inw = t(3, 0)
House.tilemap.boss.ine = t(4, 0)
House.tilemap.boss.isw = t(3, 1)
House.tilemap.boss.ise = t(4, 1)

House.ambientColor = {255, 255, 255}
House.targetAmbient = {255, 255, 255}

Tile = class()
function Tile:init(type, x, y)
  self.type = type
  self.tile = nil
  self.x = x
  self.y = y
  self.ambient = 0
  self.dynamic = 0
  self.lastTouched = tick
end

function Tile:draw()
  local v = self:brightness()
  if v > .01 then
    local a = House.ambientColor
    love.graphics.setColor(v * a[1] / 255, v * a[2] / 255, v * a[3] / 255)
    local quad = House.tilemap[self.type][self.tile]
    local sc = ovw.house.cellSize / 32
    love.graphics.draw(House.tileImage, quad, self.x * ovw.house.cellSize, self.y * ovw.house.cellSize, 0, sc, sc)
  end
end

function Tile:brightness()
  return math.min(self.ambient + self.dynamic, 255)
end

function Tile:updateLight()
  local factor = (tick - self.lastTouched) * tickRate
  if factor == 0 then return end

  if ovw.boss then
    local target = self.type == 'boss' and 100 or 0
    self.ambient = math.lerp(self.ambient, target, math.min(2 * factor, 1))
  else
    self.ambient = math.lerp(self.ambient, 0, math.min(.08 * factor, 1))
  end

  self.dynamic = math.lerp(self.dynamic, 0, math.min(5 * factor,1))
  self.lastTouched = tick
end
        
function Tile:applyLight(light, type)
  local xx, yy = light.x - ovw.house.cellSize / 2, light.y - ovw.house.cellSize / 2
  
  self:updateLight()

  local dis = ovw.house:snap(math.distance(xx, yy, ovw.house:pos(self.x, self.y)))
  dis = math.clamp(dis ^ light.falloff, light.minDis, light.maxDis)
  dis = math.clamp((1 - (dis / light.maxDis)) * light.intensity, 0, 1)
  local value = math.round(dis * 255 / light.posterization) * light.posterization
  local factor = type == 'ambient' and 5 * tickRate or 1

  if light.shape then
    if light.shape == 'circle' then
      self[type] = math.lerp(self[type], math.max(self[type], value), factor)
    elseif light.shape == 'cone' then
      local dir = math.direction(light.x, light.y, self.x * ovw.house.cellSize, self.y * ovw.house.cellSize)
      if light.dir < -math.pi / 2 and dir > 0 then dir = dir - math.pi * 2 end
      if light.dir > math.pi / 2 and dir < 0 then dir = dir + math.pi * 2 end
      if dir >= light.dir - light.angle and dir <= light.dir + light.angle then
        self[type] = math.lerp(self[type], math.max(self[type], value / 2), factor / 2)
        if dir >= light.dir - light.angle / 2 and dir <= light.dir + light.angle / 2 then
          self[type] = math.lerp(self[type], math.max(self[type], value), factor)
        end
      end
    end
  else
    self[type] = math.lerp(self[type], math.max(self[type], value), factor)
  end
end
