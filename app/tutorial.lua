Tutorial = class()

local g = love.graphics

function Tutorial:init()
	self.font = g.newFont('media/fonts/pixel.ttf', 8)
	self.titleFont = g.newFont('media/fonts/pixel.ttf', 24)
	self.subTitleFont = g.newFont('media/fonts/pixel.ttf', 16)

	self.lastState = 'Begin'
	self.state = 'Begin'
	self.nextState = 'Begin'

	self.text = 'The Tutorial. Wowee!'

	self.x = 20 + .5
	self.y = 300 + .5
	self.w = 320
	self.h = 140

	self.depth = -1

	ovw.view:register(self)
end

function Tutorial:gui()
	if started and self.state ~= 'Done' then
		g.setColor(50, 50, 50, 50)
		g.rectangle('fill', self.x, self.y, self.w, self.h)
		g.setColor(255, 255, 255, 255)
		g.rectangle('line', self.x, self.y, self.w, self.h)

		self[self.state](self)

		g.printf(self.text, self.x + 3, self.y, self.w - 6)
	end
end

function Tutorial:Begin()
	--the tutorial is just getting started.
	g.setColor(255, 255, 0, 255)
	g.rectangle('line', self.x, self.y, self.w, self.h)
	g.setColor(255, 255, 255, 255)

	self.text = 'Welcome to the House.\n\nPlease be still for a moment while we get you situated.\nI will be guiding you through your HUD.\n\nPress [Enter] to move on to the next part of the tutorial.\n[Backspace] will take you back to the previous tutorial page.\nPressing [RShift + Enter] will skip the tutorial at any time.\n\nPress [Enter] to continue.'
	self.nextState = 'Mouse'
	self.lastState = 'Begin'
end

function Tutorial:Mouse()
	--mouse, combat, and arsenal
	g.setColor(255, 255, 0, 255)
	g.rectangle('line', .5, 84 + .5, 44, 86)
	g.setColor(255, 255, 255, 255)

	self.text = 'Your mouse is specifically for combat:\n\n[Aim] your mouse cursor to aim your character.\n[Left Click] to fire.\n[Right Click] to perform a secondary attack, normally melee.\n[Mouse Wheel] to swap your active weapon in the Arsenal.\nIt is the yellow-highlighted column of boxes above.\nWatch your ammo count!\n\nPress [Enter] to continue.'
	self.nextState = 'Movement'
	self.lastState = 'Begin'
end

function Tutorial:Movement()
	--walking, running, rolling, and energy
	g.setColor(255, 255, 0, 255)
	g.rectangle('line', 400 - 50 - 2 + .5, 600 - 90 - 2 + .5, 104, 11)
	g.setColor(255, 255, 255, 255)

	self.text = 'There are several ways to move about the House:\n\nYour energy bar is located bottom-center of the screen.\n[WASD] to walk around.\nHold [LShift] at the same time to run, draining energy.\n[Spacebar] to roll in your current direction.\nThis costs 1 full energy bar section.\nMeleeing also costs some energy.\n\nPress [Enter] to continue.'
	self.nextState = 'Items'
	self.lastState = 'Mouse'
end

function Tutorial:Items()
	--inventory, hotbar, and pickups
	g.setColor(255, 255, 0, 255)
	g.rectangle('line', .5, .5, 42 * 5 + 2, 44)
	g.setColor(255, 255, 255, 255)

	self.text = 'Throughout the House you will find useful items:\n\nAn item on the ground will glow yellow when you are near.\nHold [F] to pick up items. Find and pick up the nearby Pistol.\nIt will be placed in your Arsenal, Hotbar, or Inventory.\nYour Hotbar contains readily usable items, highlighted above.\nPress [1-5] to activate a hotbar item.\nHold [E] to see your inventory with all other items.\n\nPress [Enter] to continue.'
	self.nextState = 'Status'
	self.lastState = 'Movement'
end

function Tutorial:Status()
	--first aid, levels, and experience
	g.setColor(255, 255, 0, 255)
	g.rectangle('line', 400 - 100 - 2 + .5, 600 - 77 - 2 + .5, 204, 9)
	g.setColor(255, 255, 255, 255)

	self.text = 'The House does not take kindly to intruders:\n\nEnemies roam about and will attack you.\nHold [Tab] to see the state of your health.\nPress [1-4] to apply a First Aid Kit.\nKilling enemies will grant experience.\nThe experience bar is highlighted bottom-center.\nPress [Z, X, C] to spend level points earned with experience.\n\nPress [Enter] to continue.'
	self.nextState = 'Buffs'
	self.lastState = 'Items'
end

function Tutorial:Buffs()
	--buffs, flashlight, and interacting
	g.setColor(255, 255, 0, 255)
	g.rectangle('line', .5, 250 - 22 - 2 + .5, 124, 7)
	g.setColor(255, 255, 255, 255)

	self.text = 'The House is very dark and very lonely:\n\nYou brought a flashlight to help you explore.\nPress [LAlt + F] to toggle the flashlight on and off.\nA powered flashlight drains batteries, highlighted above.\nOther buffs and effects will be listed here too.\nSometimes, you may find non-violent entities in the House.\nHold [E] to interact with them.\n\nPress [Enter] to continue.'
	self.nextState = 'Final'
	self.lastState = 'Status'
end

function Tutorial:Final()
	--the tutorial is complete.
	g.setColor(255, 255, 0, 255)
	g.rectangle('line', self.x, self.y, self.w, self.h)
	g.setColor(255, 255, 255, 255)

	self.text = 'This concludes the tutorial:\n\nI hope you were paying attention.\nThe House will not tolerate a brash attitude.\n\n\n[Backspace] to go back to any page in this tutorial.\n\n\nPress [Enter] to exit the tutorial and begin your expedition.'
	self.nextState = 'Done'
	self.lastState = 'Buffs'
end

function Tutorial:Done()
	--the tutorial is completed. Do nothing. This function shouldn't ever be run.
end

function Tutorial:next()
	if love.keyboard.isDown('rshift') then self.state = 'Done' else self.state = self.nextState end
end

function Tutorial:back()
	if self.state ~= 'Done' then self.state = self.lastState end
end