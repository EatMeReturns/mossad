Menu = class()

local g = love.graphics
local gw, gh = 800, 600

function Menu:init()
	self.font = g.newFont('media/fonts/pixel.ttf', 8)
	self.titleFont = g.newFont('media/fonts/pixel.ttf', 24)
	self.subTitleFont = g.newFont('media/fonts/pixel.ttf', 16)

	self.state = 'Main'
	self.ready = true

	self.menus = {}
	self.menus.Main = {
						buttonHeight = 50,
						buttonWidth = 200,
						buttons = {
							Button('Play', 'p', function(button) ovw.menu.state = 'Character' local pStats = ovw.fileManager.optionsData.lastCharacter local charTexts = ovw.menu.menus.Character.texts for i = 1, 4 do charTexts[i * 2] = pStats[i] end end),
							Button('Options', 'p', function(button) ovw.menu.state = 'Options' end),
							Button('About', 'p', function(button) ovw.menu.state = 'About' end),
							Button('Exit', 'p', function(button) ovw:quit() end)
						}
					}
	self.menus.Options = {
						buttonHeight = 50,
						buttonWidth = 200,
						buttons = {
							Button('Fullscreen', 'p', function(button) ovw:fullscreen() end),
							Button('Tutorial', 'p', function(button) local current = ovw.fileManager.optionsData.tutorial ovw.fileManager.optionsData.tutorial = not current ovw.tutorial.state = not current and 'Begin' or 'Done' end),
							Button('Back', 'p', function(button) ovw.menu.state = started and 'Paused' or 'Main' end)
						}
					}
	self.menus.Paused = {
						buttonHeight = 50,
						buttonWidth = 200,
						buttons = {
							Button('Resume', 'p', function(button) ovw:pause() end),
							Button('Options', 'p', function(button) ovw.menu.state = 'Options' end),
							Button('Quit', 'p', function(button) ovw:restart() end)
						}
					}
	self.menus.About = {
						buttonHeight = 50,
						buttonWidth = 200,
						buttons = {
							Button('Back', 'p', function(button) ovw.menu.state = 'Main' end)
						},
						textY = 330,
						textWidth = 500,
						texts = {
							'Thank you for participating in the digital crowd-exploration of the House.\nMade by EatMeReturns.\n\n\nMossad is watching.'
						}
					}
	self.menus.Character = {
						buttonHeight = 50,
						buttonWidth = 200,
						buttons = {
							Button('Agility', 'p', function(button) local texts = ovw.menu.menus.Character.texts if texts[2] > 0 then texts[4] = texts[4] + 1 texts[2] = texts[2] - 1 end end),
							Button('Armor', 'p', function(button) local texts = ovw.menu.menus.Character.texts if texts[2] > 0 then texts[6] = texts[6] + 1 texts[2] = texts[2] - 1 end end),
							Button('Stamina', 'p', function(button) local texts = ovw.menu.menus.Character.texts if texts[2] > 0 then texts[8] = texts[8] + 1 texts[2] = texts[2] - 1 end end),
							Button('Start', 'p', function(button) local texts = ovw.menu.menus.Character.texts if texts[2] == 0 then ovw:start(texts[4], texts[6], texts[8]) ovw.fileManager.optionsData.lastCharacter = {texts[2], texts[4], texts[6], texts[8]} end end),
							Button('Reset', 'p', function(button) local texts = ovw.menu.menus.Character.texts texts[2] = 3 texts[4], texts[6], texts[8] = 0, 0, 0 end),
							Button('Back', 'p', function(button) local texts = ovw.menu.menus.Character.texts texts[2] = 3 texts[4], texts[6], texts[8] = 0, 0, 0 ovw.menu.state = 'Main' end)
						},
						textY = 490,
						textWidth = 400,
						texts = { --2 is points, 4 is agility, 6 is armor, 8 is stamina
							'What type of explorer will enter the House?\n',
							3,
							' Points to allocate.\n\n',
							0,
							' Agility will make your actions require less time.\n',
							0,
							' Armor will reduce the damage you take.\n',
							0,
							' Stamina will increase your energy reserves for... activities.'
						}
					}

	ovw.view:register(self)
end

function Menu:gui()
	if not started or paused then
		self:mouse()

		local menu = self.menus[self.state]
		local w = menu.buttonWidth
		local h = menu.buttonHeight
		local count = #menu.buttons

		table.each(menu.buttons, function(button, index)
			local x = gw / 2 - 100
			local y = gh / 2 + ((h + 10) * (index - (count / 2) - 1))

			g.setColor(button.color[1], button.color[2], button.color[3], button.color[4])
			g.rectangle('fill', x, y, w, h)
			g.setColor(255, 255, 255, 255)
			g.rectangle('line', x, y, w, h)
			g.setFont(self.titleFont)
			g.printf(button.text, x, y, w, 'center')
			g.setFont(self.font)
		end)

		if menu.texts then
			local texts = menu.texts
			local count = #texts
			local text = ''

			for i = 1, count do
				text = text .. texts[i]
			end

			g.setColor(255, 255, 255, 255)
			g.printf(text, gw / 2 - menu.textWidth / 2, menu.textY, menu.textWidth, 'center')
		end
	end
	self.ready = true
end

function Menu:mouse()
	local w = self.menus[self.state].buttonWidth
	local h = self.menus[self.state].buttonHeight
	local count = #self.menus[self.state].buttons
	local v = love.mouse.isDown('l') and 255 or 150

	table.each(self.menus[self.state].buttons, function(button, index)
		local x = gw / 2 - 100
		local y = gh / 2 + ((h + 10) * (index - (count / 2) - 1))

		if self:mouseOverButton(x, y, w, h) then
			--mouse is in the button
			button.color[4] = v
		else
			button.color[4] = 50
		end
	end)
end
function Menu:mouseOverButton(x, y, w, h)
  return love.mouse.inBox(x * love.graphics.getWidth() / gw, y * love.graphics.getHeight() / gh, w * love.graphics.getWidth() / gw, h * love.graphics.getHeight() / gh)
end

function Menu:mousereleased(x, y, button)
	local w = self.menus[self.state].buttonWidth
	local h = self.menus[self.state].buttonHeight
	local count = #self.menus[self.state].buttons
	local v = love.mouse.isDown('l') and 255 or 150

	table.each(self.menus[self.state].buttons, function(button, index)
		local x = gw / 2 - 100
		local y = gh / 2 + ((h + 10) * (index - (count / 2) - 1))

		if self:mouseOverButton(x, y, w, h) and self.ready then
			self.ready = false
			button.activate(button)
		end
	end)
end

function Menu:keypressed(key)
	--
end

---------------------------------------------------------------------------------------

Button = class()

function Button:init(text, key, activate)
	self.text = text
	self.key = key

	self.activate = activate

	self.color = {love.math.random() * 100, love.math.random() * 100, love.math.random() * 100, 50}
end