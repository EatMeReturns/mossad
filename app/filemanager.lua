--love.filesystem.write
--love.filesystem.read
--love.filesystem.newFile
--love.filesystem.newFileData

FileManager = class()

--optionsData:
--	fullscreen = true
--  tutorial = true
--	lastCharacter = {points = 3, agility = 0, armor = 0, stamina = 0}

function FileManager:init()
	self.file = nil

	self.optionsFile = love.filesystem.newFile('config.txt')

	if love.filesystem.exists('config.txt') then
		self.optionsFile:open('r')
		self.optionsData = Tserial.unpack(self.optionsFile:read())
		self.optionsFile:close()
	else
		self.optionsData = {fullscreen = true,
							tutorial = true,
							lastCharacter = {3, 0, 0, 0}
							} --generate FileData
		self.optionsFile:open('w')
		self.optionsFile:write(Tserial.pack(self.optionsData)) --save to File
		self.optionsFile:close()
	end

	self:loadOptions()
end

function FileManager:loadOptions()
	love.window.setFullscreen(self.optionsData.fullscreen)
	Tile.lightingShader:send('windowScale', {love.window.getWidth() / 800, love.window.getHeight() / 600})
	ovw.tutorial.state = self.optionsData.tutorial and 'Begin' or 'Done'
end

function FileManager:saveOptions()
	self.optionsFile:open('w')
	self.optionsFile:write(Tserial.pack(self.optionsData))
	self.optionsFile:close()
end

function FileManager:resetOptions()
	--
end