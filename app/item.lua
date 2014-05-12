Item = class()

function Item:init()
  self.selected = false
end

function Item:destroy()

end

function Item:update()

end

function Item:draw()

end

Item.mousepressed = f.empty
Item.mousereleased = f.empty
