local hardon = require 'lib/hardon'

Collision = class()
Collision.cellSize = 32

function Collision:init()
  local function onCollide(dt, a, b, dx, dy)
    a, b = a.owner, b.owner
    f.exe(a.collision.with and a.collision.with[b.tag], a, b, dx, dy)
    f.exe(b.collision.with and b.collision.with[a.tag], b, a, dx, dy)
  end
  
  self.hc = hardon(self.cellSize, onCollide)
  self.depth = -100
  ovw.view:register(self)
end

function Collision:draw()
  if love.keyboard.isDown(' ') then
    local rect = {
      ovw.view.x,
      ovw.view.y,
      ovw.view.x + ovw.view.w,
      ovw.view.y + ovw.view.h
    }
    for shape in pairs(self.hc:shapesInRange(unpack(rect))) do
      love.graphics.setColor(255, 255, 255, 50)
      shape:draw('fill')
      love.graphics.setColor(255, 255, 255)
      shape:draw('line')
    end
  end
end

function Collision:resolve()
  self.hc:update(tickRate)
end

function Collision:register(obj)
  local shape
  if obj.collision.shape == 'rectangle' then
    shape = self.hc:addRectangle(obj.x, obj.y, obj.width, obj.height)
  elseif obj.collision.shape == 'circle' then
    shape = self.hc:addCircle(obj.x, obj.y, obj.radius)
  end

  if obj.collision.static then
    self.hc:setPassive(shape)
  end

  obj.shape = shape
  shape.owner = obj

  return shape
end

function Collision:unregister(obj)
  self.hc:remove(obj.shape)
end

function Collision:pointTest(x, y, tag, all)
  local res = all and {} or nil
  for _, shape in pairs(self.hc:shapesAt(x, y)) do
    if (not tag) or shape.owner.tag == tag then
      if all then table.insert(res, shape.owner)
      else res = shape.owner break end
    end
  end
  return res
end

function Collision:lineTest(x1, y1, x2, y2, tag, all, first)
  local res = all and {} or nil
  local dis = math.distance(x1, y1, x2, y2)
  local mindis = first and math.huge or nil
  local _x1, _y1 = math.min(x1, x2), math.min(y1, y2)
  local _x2, _y2 = math.max(x1, x2), math.max(y1, y2)
  for shape in pairs(self.hc:shapesInRange(_x1, _y1, _x2, _y2)) do
    if (not tag) or shape.owner.tag == tag then
      local intersects, d = shape:intersectsRay(x1, y1, x2 - x1, y2 - y1)
      if intersects and d >= 0 and d <= 1 then
        if not first then
          if all then table.insert(res, shape.owner)
          else res = shape.owner break end
        elseif d * dis < mindis then
          mindis = d * dis
          res = shape.owner
        end
      end
    end
  end
  
  return res, mindis
end
