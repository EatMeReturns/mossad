Item = class()

Item.image = love.graphics.newImage('media/graphics/icons/icon.png')

function Item:init()
  self.active = false
  self.type = 'Passive' --Passive, Consumable, Active, Weapon
end

function Item:destroy()

end

function Item:update()

end

function Item:draw()

end

Item.activate = f.empty
