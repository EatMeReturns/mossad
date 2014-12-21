House.tileImage = love.graphics.newImage('media/graphics/newTiles.png')
local w, h = House.tileImage:getDimensions()
local function t(x, y) return love.graphics.newQuad(1 + (x * 35), 1 + (y * 35), 32, 32, w, h) end
House.tilemap = {}
House.tilemap.Main = {}
House.tilemap.Main.c = t(1, 4)
House.tilemap.Main.n = t(1, 3)
House.tilemap.Main.s = t(1, 5)
House.tilemap.Main.e = t(2, 4)
House.tilemap.Main.w = t(0, 4)
House.tilemap.Main.nw = t(0, 3)
House.tilemap.Main.ne = t(2, 3)
House.tilemap.Main.sw = t(0, 5)
House.tilemap.Main.se = t(2, 5)
House.tilemap.Main.inw = t(3, 3)
House.tilemap.Main.ine = t(4, 3)
House.tilemap.Main.isw = t(3, 4)
House.tilemap.Main.ise = t(4, 4)

House.tilemap.Gray = {}
House.tilemap.Gray.c = t(1, 1)
House.tilemap.Gray.n = t(1, 0)
House.tilemap.Gray.s = t(1, 2)
House.tilemap.Gray.e = t(2, 1)
House.tilemap.Gray.w = t(0, 1)
House.tilemap.Gray.nw = t(0, 0)
House.tilemap.Gray.ne = t(2, 0)
House.tilemap.Gray.sw = t(0, 2)
House.tilemap.Gray.se = t(2, 2)
House.tilemap.Gray.inw = t(3, 0)
House.tilemap.Gray.ine = t(4, 0)
House.tilemap.Gray.isw = t(3, 1)
House.tilemap.Gray.ise = t(4, 1)

House.ambientColor = {255, 255, 255}
House.targetAmbient = {255, 255, 255}

Tile = class()

function Tile:init(type, x, y, room)
  self.type = type
  self.tile = nil
  self.x = x
  self.y = y
  self.posX = self.x * 32 --self.x * ovw.house.cellSize
  self.posY = self.y * 32 --self.y * ovw.house.cellSize
  self.sc = 32 / 32 --ovw.house.cellSize / 32
  self.ambient = 0
  self.dynamic = 0
  self.Brightness = 0
  self.colors = {{255, 255, 255, 1}}
  self.drawColor = {255, 255, 255}
  self.lastColor = {255, 255, 255}
  self.color = {255, 255, 255, 255}
  self.lastTouched = tick

  if room then
    table.insert(room.tiles, self)
    self.roomID = room.id
  end

  self.visible = false
  self.seen = false
end

function Tile:destroy()
  ovw.house.tiles[self.x][self.y] = nil
end

function Tile:update()
  local drawColor = {0, 0, 0}
  local colorIntensityDivider = 0
  table.each(self.colors, function(color, key)
    colorIntensityDivider = colorIntensityDivider + color[4]
    for i = 1, 3 do
      drawColor[i] = drawColor[i] + (color[i] * color[4])
    end
  end)
  for i = 1, 3 do
    drawColor[i] = drawColor[i] / colorIntensityDivider
    self.drawColor[i] = math.lerp(self.lastColor[i], drawColor[i], 0.1)
    self.lastColor[i] = self.drawColor[i]
  end
  self.colors = {{255, 255, 255, 1}}
  self.Brightness = self:brightness()
  for i = 1, 3 do
    self.color[i] = self.Brightness * (House.ambientColor[i] / 255 * self.drawColor[i]) / 255
  end
end

function Tile:draw()
  if self.Brightness > .01 then
    local a = House.ambientColor
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    local quad = House.tilemap[self.type][self.tile]
    love.graphics.draw(House.tileImage, quad, self.posX, self.posY, 0, self.sc, self.sc)
  end
end

function Tile:brightness()
  local base = (self.ambient + self.dynamic) * love.math.random() * .05 + .2
  return math.min(base + self.ambient + self.dynamic, 255)
end

function Tile:updateLight()
  local factor = (tick - self.lastTouched) * tickRate
  if factor == 0 then return end

  if ovw.boss then
    local target = self.type == 'boss' and 100 or 0
    self.ambient = math.lerp(self.ambient, target, math.min(2 * factor, 1))
  else
    self.ambient = math.lerp(self.ambient, 0, math.min(1 * factor, 1))
  end

  self.dynamic = math.lerp(self.dynamic, 0, math.min(5 * factor,1))
  self.lastTouched = tick
end
        
function Tile:applyLight(light, type)
  
  --self:updateLight()

  local selfX, selfY = self.x * ovw.house.cellSize, self.y * ovw.house.cellSize
  local disToPlayer = math.distance(ovw.player.x, ovw.player.y, selfX, selfY)
  local inShape = false

  local valueMult = 1

  if disToPlayer <= 500 then
    if light.shape then
      if light.shape == 'circle' then
        if math.distance(selfX, selfY, light.x, light.y) <= light.maxDis then inShape = true end
      elseif light.shape == 'cone' then
        local dir = math.direction(light.x, light.y, selfX, selfY)
        if light.dir < -math.pi / 2 and dir > 0 then dir = dir - math.pi * 2 end
        if light.dir > math.pi / 2 and dir < 0 then dir = dir + math.pi * 2 end
        if dir >= light.dir - light.angle / 2 and dir <= light.dir + light.angle / 2 then
          inShape = true
        elseif dir >= light.dir - light.angle and dir <= light.dir + light.angle then
          inShape = true
          valueMult = 2 / 3
        end
      end
    else
      inShape = true
    end

    if inShape then
      local xx, yy = light.x - ovw.house.cellSize / 2, light.y - ovw.house.cellSize / 2
      local dis = ovw.house:snap(math.distance(xx, yy, ovw.house:pos(self.x, self.y)))
      dis = math.clamp(dis ^ light.falloff, light.minDis, light.maxDis)
      dis = math.clamp((1 - (dis / light.maxDis)) * light.intensity, 0, 1)
      local color = table.copy(light.color) or {255, 255, 255, 1 * dis}
      color[4] = color[4] * (dis ^ 2)
      local value = math.round(dis * 255 / light.posterization) * light.posterization * valueMult
      local factor = type == 'ambient' and 5 * tickRate or 1

      local hitX, hitY = selfX, selfY
      if hitX + 17 < light.x then hitX = hitX + 35 end
      if hitY + 17 < light.y then hitY = hitY + 35 end
      local wall, d = ovw.collision:lineTest(light.x, light.y, hitX, hitY, 'wall', false, true)
      if wall then self.visible = false else self.visible = true end

      if self.visible then
        self[type] = math.lerp(self[type], math.max(self[type], value), factor)
        table.insert(self.colors, color)
      end
    end
  end
end
