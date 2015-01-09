House.tileImage = love.graphics.newImage('media/graphics/newTiles2.png')
local w, h = House.tileImage:getDimensions()
local function t(x, y) return love.graphics.newQuad(1 + (x * 35), 1 + (y * 35), 32, 32, w, h) end
House.tilemap = {}

-------------------------------------------------------------------------------------

House.tilemap.Main = {}
House.tilemap.Main.rectangle = {}
House.tilemap.Main.rectangle.c = t(1, 4)
House.tilemap.Main.rectangle.n = t(1, 3)
House.tilemap.Main.rectangle.s = t(1, 5)
House.tilemap.Main.rectangle.e = t(2, 4)
House.tilemap.Main.rectangle.w = t(0, 4)
House.tilemap.Main.rectangle.nw = t(0, 3)
House.tilemap.Main.rectangle.ne = t(2, 3)
House.tilemap.Main.rectangle.sw = t(0, 5)
House.tilemap.Main.rectangle.se = t(2, 5)
House.tilemap.Main.rectangle.inw = t(3, 3)
House.tilemap.Main.rectangle.ine = t(4, 3)
House.tilemap.Main.rectangle.isw = t(3, 4)
House.tilemap.Main.rectangle.ise = t(4, 4)

House.tilemap.Main.diamond = {}
House.tilemap.Main.diamond.c = t(1, 4)
House.tilemap.Main.diamond.n = t(1, 3)
House.tilemap.Main.diamond.s = t(1, 5)
House.tilemap.Main.diamond.e = t(2, 4)
House.tilemap.Main.diamond.w = t(0, 4)
House.tilemap.Main.diamond.nw = t(0, 3)
House.tilemap.Main.diamond.ne = t(2, 3)
House.tilemap.Main.diamond.sw = t(0, 5)
House.tilemap.Main.diamond.se = t(2, 5)
House.tilemap.Main.diamond.inw = t(3, 3)
House.tilemap.Main.diamond.ine = t(4, 3)
House.tilemap.Main.diamond.isw = t(3, 4)
House.tilemap.Main.diamond.ise = t(4, 4)

House.tilemap.Main.circle = {}
House.tilemap.Main.circle.c = t(1, 4)
House.tilemap.Main.circle.n = t(1, 3)
House.tilemap.Main.circle.s = t(1, 5)
House.tilemap.Main.circle.e = t(2, 4)
House.tilemap.Main.circle.w = t(0, 4)
House.tilemap.Main.circle.nw = t(5, 3)
House.tilemap.Main.circle.ne = t(6, 3)
House.tilemap.Main.circle.sw = t(5, 4)
House.tilemap.Main.circle.se = t(6, 4)
House.tilemap.Main.circle.inw = t(3, 3)
House.tilemap.Main.circle.ine = t(4, 3)
House.tilemap.Main.circle.isw = t(3, 4)
House.tilemap.Main.circle.ise = t(4, 4)

-------------------------------------------------------------------------------------

House.tilemap.Gray = {}
House.tilemap.Gray.rectangle = {}
House.tilemap.Gray.rectangle.c = t(1, 1)
House.tilemap.Gray.rectangle.n = t(1, 0)
House.tilemap.Gray.rectangle.s = t(1, 2)
House.tilemap.Gray.rectangle.e = t(2, 1)
House.tilemap.Gray.rectangle.w = t(0, 1)
House.tilemap.Gray.rectangle.nw = t(0, 0)
House.tilemap.Gray.rectangle.ne = t(2, 0)
House.tilemap.Gray.rectangle.sw = t(0, 2)
House.tilemap.Gray.rectangle.se = t(2, 2)
House.tilemap.Gray.rectangle.inw = t(3, 0)
House.tilemap.Gray.rectangle.ine = t(4, 0)
House.tilemap.Gray.rectangle.isw = t(3, 1)
House.tilemap.Gray.rectangle.ise = t(4, 1)

-------------------------------------------------------------------------------------

House.tilemap.Tower = {} --7, 0 TO 11, 2
House.tilemap.Tower.diamond = {}
House.tilemap.Tower.diamond.c = t(8, 1)
House.tilemap.Tower.diamond.n = t(8, 0)
House.tilemap.Tower.diamond.s = t(8, 2)
House.tilemap.Tower.diamond.e = t(9, 1)
House.tilemap.Tower.diamond.w = t(7, 1)
House.tilemap.Tower.diamond.nw = t(7, 0)
House.tilemap.Tower.diamond.ne = t(9, 0)
House.tilemap.Tower.diamond.sw = t(7, 2)
House.tilemap.Tower.diamond.se = t(9, 2)
House.tilemap.Tower.diamond.inw = t(10, 0)
House.tilemap.Tower.diamond.ine = t(11, 0)
House.tilemap.Tower.diamond.isw = t(10, 1)
House.tilemap.Tower.diamond.ise = t(11, 1)

House.tilemap.Tower.rectangle = {}
House.tilemap.Tower.rectangle.c = t(8, 1)
House.tilemap.Tower.rectangle.n = t(8, 0)
House.tilemap.Tower.rectangle.s = t(8, 2)
House.tilemap.Tower.rectangle.e = t(9, 1)
House.tilemap.Tower.rectangle.w = t(7, 1)
House.tilemap.Tower.rectangle.nw = t(7, 0)
House.tilemap.Tower.rectangle.ne = t(9, 0)
House.tilemap.Tower.rectangle.sw = t(7, 2)
House.tilemap.Tower.rectangle.se = t(9, 2)
House.tilemap.Tower.rectangle.inw = t(10, 0)
House.tilemap.Tower.rectangle.ine = t(11, 0)
House.tilemap.Tower.rectangle.isw = t(10, 1)
House.tilemap.Tower.rectangle.ise = t(11, 1)

House.tilemap.Tower.circle = {}
House.tilemap.Tower.circle.c = t(8, 1)
House.tilemap.Tower.circle.n = t(8, 0)
House.tilemap.Tower.circle.s = t(8, 2)
House.tilemap.Tower.circle.e = t(9, 1)
House.tilemap.Tower.circle.w = t(7, 1)
House.tilemap.Tower.circle.nw = t(7, 0)
House.tilemap.Tower.circle.ne = t(9, 0)
House.tilemap.Tower.circle.sw = t(7, 2)
House.tilemap.Tower.circle.se = t(9, 2)
House.tilemap.Tower.circle.inw = t(10, 0)
House.tilemap.Tower.circle.ine = t(11, 0)
House.tilemap.Tower.circle.isw = t(10, 1)
House.tilemap.Tower.circle.ise = t(11, 1)

-------------------------------------------------------------------------------------

House.tilemap.Main.rectangle.none = t(0, 7)
House.tilemap.Main.circle.none = t(0, 7)
House.tilemap.Main.diamond.none = t(0, 7)
House.tilemap.Gray.rectangle.none = t(0, 7)
House.tilemap.Tower.diamond.none = t(0, 7)
House.tilemap.Tower.rectangle.none = t(0, 7)
House.tilemap.Tower.circle.none = t(0, 7)

House.ambientColor = {255, 255, 255}
House.targetAmbient = {255, 255, 255}

Tile = class()

Tile.lightingShader = love.graphics.newShader(
  [[
    extern vec2 playerPosOnScreen;
    extern vec4 tileColor;
    extern vec2 windowScale;

  vec4 effect(vec4 color, Image tex, vec2 tc, vec2 pc)
  {
    number dis = distance(playerPosOnScreen, pc / windowScale);
    dis = 1 - dis / 2000;
    return tileColor / 255 * vec4(dis, dis, dis, dis) / sqrt(sqrt(sqrt(sqrt(1 - dis)))) * Texel(tex, tc);
  }]])

Tile.lightingShader:send('windowScale', {love.window.getWidth() / 800, love.window.getHeight() / 600})

Tile.font = love.graphics.newFont('media/fonts/pixel.ttf', 6)

function Tile:init(type, x, y, room)
  self.type = type
  self.tile = 'none'
  self.x = x
  self.y = y
  self.posX = self.x * House.cellSize
  self.posY = self.y * House.cellSize
  self.sc = House.cellSize / 32
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
    self.buildShape = room.buildShape
  else
    self.buildShape = 'rectangle'
  end

  self.visible = false
  self.seen = false
end

function Tile:destroy()
  if ovw.house.tiles[self.x] then
    ovw.house.tiles[self.x][self.y] = nil
  end
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
    if useShader then
      Tile.lightingShader:send('tileColor', self.color)
      Tile.lightingShader:send('playerPosOnScreen', ovw.view:playerPosOnScreen())
      love.graphics.setShader(Tile.lightingShader)
    end
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    local quad = House.tilemap[self.type][self.buildShape][self.tile]
    love.graphics.draw(House.tileImage, quad, self.posX, self.posY, 0, self.sc, self.sc)
    love.graphics.setShader()
  end

  if devMode then
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(self.font)
    love.graphics.print(self.tile .. '\n' .. self.x .. ',' .. self.y, self.posX + 2, self.posY + 2)
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

  --local selfX, selfY = self.x * ovw.house.cellSize, self.y * ovw.house.cellSize
  local ranges = ovw.house.drawRanges
  local inShape = false

  local valueMult = 1

  local dir = 0

  if ranges.xMin <= self.x and self.x <= ranges.xMax and ranges.yMin <= self.y and self.y <= ranges.yMax then
    local disToPlayer = math.distance(ovw.player.x, ovw.player.y, self.posX, self.posY)
    if light.shape then
      if light.shape == 'circle' then
        if math.distance(self.posX, self.posY, light.x, light.y) <= light.maxDis then inShape = true end
      elseif light.shape == 'cone' then
        dir = math.direction(light.x, light.y, self.posX, self.posY)
        if light.dir < -math.pi / 2 and dir > 0 then dir = dir - math.pi * 2 end
        if light.dir > math.pi / 2 and dir < 0 then dir = dir + math.pi * 2 end
        if dir >= light.dir - light.angle and dir <= light.dir + light.angle then
          inShape = true
        end
      elseif light.shape == 'ring' then
        local ringDis = math.distance(self.posX, self.posY, light.x, light.y)
        if ringDis <= light.maxDis and ringDis >= light.minDis then inShape = true end
      end
    else
      inShape = true
    end

    if inShape then
      local xx, yy = light.x - House.halfCell, light.y - House.halfCell
      local dis = ovw.house:snap(math.distance(xx, yy, ovw.house:pos(self.x, self.y)))
      if light.shape then
        if light.shape == 'ring' then
          local midDis = (light.maxDis + light.minDis) / 2
          dis = math.clamp(dis ^ light.falloff, light.minDis, light.maxDis)
          dis = math.clamp((1 - (math.abs(dis - midDis) / (light.maxDis - midDis))) * light.intensity, 0, 1)
        elseif light.shape == 'cone' then
          dis = math.clamp(dis ^ light.falloff, light.minDis, light.maxDis)
          --dis = math.clamp((1 - (dis / light.maxDis)) * light.intensity, 0, 1)
          dis = math.clamp((1 - (math.abs(dir - light.dir) / light.angle)) * light.intensity, 0, 1)
        elseif light.shape == 'circle' then
          dis = math.clamp(dis ^ light.falloff, light.minDis, light.maxDis)
          dis = math.clamp((1 - (dis / light.maxDis)) * light.intensity, 0, 1)
        elseif light.shape == 'distancedcone' then
          dis = math.clamp(dis ^ light.falloff, light.minDis, light.maxDis)
          dis = math.clamp((1 - (dis / light.maxDis)) * light.intensity, 0, 1)
          dis = (dis + math.clamp((1 - (math.abs(dir - light.dir) / light.angle)) * light.intensity, 0, 1)) / 2
        else
          dis = 1
        end
      else --basic distance formula. useful for when the light source hand-picks the tiles, like in muzzleflash.lua.
        dis = math.clamp(dis ^ light.falloff, light.minDis, light.maxDis)
        dis = math.clamp((1 - (dis / light.maxDis)) * light.intensity, 0, 1)
      end
      local color = table.copy(light.color) or {255, 255, 255, dis}
      color[4] = color[4] * (dis ^ 2)
      --local value = math.round(dis * 255 / light.posterization) * light.posterization * valueMult
      local value = dis * 255 * valueMult
      local factor = type == 'ambient' and 5 * tickRate or 1

      local hitX, hitY = self.posX, self.posY --pick the corner of the tile closest to the light
      if hitX + 17 < light.x then hitX = hitX + 35 end
      if hitY + 17 < light.y then hitY = hitY + 35 end
      local wall, d = ovw.collision:lineTest(light.x, light.y, hitX, hitY, 'wall', false, true)

      if light.penetrateWalls or not wall then
        self[type] = math.lerp(self[type], math.max(self[type], value), factor)
        table.insert(self.colors, color)
      end
    end
  end
end
