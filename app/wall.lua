Wall = class()
Wall.tag = 'wall' --for collision

Wall.collision = {
  shape = 'rectangle',
  static = true
}

function Wall:init(x, y, w, h)
  ovw.level.wallCount = ovw.level.wallCount + 1
  self.x = x
  self.y = y
  self.width = w
  self.height = h

  self.alpha = .2
  
  ovw.collision:register(self)
  self.shape:moveTo(x + w / 2, y + h / 2)
end

function Wall:setRoom(room)
  self.room = room
end

function Wall:destroy()
  ovw.level.wallCount = ovw.level.wallCount - 1
  self.room.walls = table.filter(self.room.walls, function(wall) if wall == self then return false else return true end end)
  ovw.collision.hc:remove(self.shape)
end

function Wall:draw()
  love.graphics.setColor(100, 100, 100, 100 * self.alpha)
  self.shape:draw('fill')
  love.graphics.setColor(100, 100, 100, 255 * self.alpha)
  self.shape:draw('line')
end
