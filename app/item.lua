Item = class()

itemImage = love.graphics.newImage('media/graphics/icon.png')

function Item:init()
  self.active = false
  self.image = itemImage
  self.type = 'Passive' --Passive, Consumable, Active, Weapon
end

function Item:destroy()

end

function Item:update()

end

function Item:draw()

end

Item.activate = f.empty
