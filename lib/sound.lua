Sound = class()

require 'lib/slam/slam'

Sound.musics = {
        default = 'horror_ambient.wav',
        miniboss = 'violin_ambient_modified.wav'
      }

function Sound:init() --currently loads sounds dynamically. consider static loading.
 	self.muted = false
	self.sounds = {}
	self.volumes = {
		ambience = .8,
		fx = .8,
		music = 1,
		master = 1
	}

	self.music = self:play(self.musics.default)
	self.musicState = 'default'
	self.music:setLooping(true)
	self.music:setVolume(self.volumes.music)

	self.miniBossCount = 0
end

function Sound:update()
	if self.miniBossCount > 0 then
		if self.musicState ~= 'miniboss' then
			self.music:stop()
			self.music = self:play(self.musics.miniboss)
			self.musicState = 'miniboss'
			self.music:setLooping(true)
			self.music:setVolume(self.volumes.music)
		end
	elseif self.musicState ~= 'default' then
		self.music:stop()
		self.music = self:play(self.musics.default)
		self.musicState = 'default'
		self.music:setLooping(true)
		self.music:setVolume(self.volumes.music)
	end
end

function Sound:stop()
	love.audio.stop()
end

function Sound:reset()
	self:stop()
	self.music = self:play(self.musics.default)
	self.musicState = 'default'
	self.music:setLooping(true)
	self.music:setVolume(self.volumes.music)
end

function Sound:play(name) --name is a filepath that includes type within media/sounds
	if self.muted then return end

	if not self.sounds[name] and love.filesystem.exists('media/sounds/' .. name) then
		self.sounds[name] = love.audio.newSource('media/sounds/' .. name)
	end

	assert(self.sounds[name], 'File doesn\'t exist or wasn\'t loaded correctly!')
	local sound = self.sounds[name]:play()
	return sound
end

function Sound:loop(name) --plays the sound, as well.
	local sound = self:play(name)
	sound:setLooping(true)
	return sound
end

function Sound:pause(name)
	if self.sounds[name] then self.sounds[name]:pause() end
end

function Sound:resume(name)
	if self.sounds[name] then self.sounds[name]:resume() end
end

function Sound:mute(name) --name can be sound name or sound source object
	if self.sounds[name] then
		local min, max = self.sounds[name]:getVolumeLimits()
		max = max == 1 and 0 or 1
		self.sounds[name]:setVolumeLimits(min, max)
	else
		local min, max = name:getVolumeLimits()
		max = max == 1 and 0 or 1
		name:setVolumeLimits(min, max)
	end
end

--function Sound:mute()
--	self.muted = not self.muted
--	love.audio.tags.all.setVolume(self.muted and 0 or 1)
--end

--expand to include tags for sound types (fx, music [?], ambient, other [?])