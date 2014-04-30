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

  self.alpha = 0
  
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

function Wall:draw(color)
  love.graphics.setColor(color[1], color[2], color[3], color[4] * self.alpha)
  self.shape:draw('fill')
  love.graphics.setColor(color[1], color[2], color[3], 255 * self.alpha)
  self.shape:draw('line')
end
