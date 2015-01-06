Item = class()

Item.image = love.graphics.newImage('media/graphics/icons/icon.png')
Item.scaling = {x = .5, y = .5}

Item.name = 'Item' --stacked item names must be their class name (spaces allowed!)

function Item:init()
  self.active = false
  self.type = 'Passive' --Passive, Consumable, Active, Weapon, Base, Mod
end

function Item:destroy()

end

function Item:update()

end

function Item:draw()

end

Item.activate = f.empty
