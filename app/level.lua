Level = class()

function Level:init()
	level = self

	self.roomColors = {Room = gray, Base = green, Shop = yellow, Boss = red, Event = purple}

	self.doorCount = 0
	self.wallCount = 0
	self.enemyCount = 0
	self.baseDoors = {Door(400, 300 - 100 / 2, 270),
					  Door(400, 300 + 100 / 2, 90),
					  Door(400 + 100 / 2, 300, 0),
					  Door(400 - 100 / 2, 300, 180)
					}
	self.baseRoom = Room('Base', 0, 400, 300, 100, 100,
			  		{Wall(400 - 100 / 2, 300 - 100 / 2, 100, 10),
					 Wall(400 + 100 / 2 - 10, 300 - 100 / 2, 10, 100),
					 Wall(400 - 100 / 2, 300 + 100 / 2 - 10, 100, 10),
					 Wall(400 - 100 / 2, 300 - 100 / 2, 10, 100)
					},
			  		self.baseDoors,
			  		{})
  	self.rooms = {self.baseRoom}
  	self.newRooms = {}

  	self.projectiles = {}
  	self.enemies = {}
  	--self.walkers = {Walker(self, 400, 300, 270, 1, 10, --position/vector
	--						10, 10, 0) --rooms
  	--				}
	--print('cleaning doors...')
	--table.each(self.rooms, function(room) self.doors = {} end)
end

function Level:update()
  -- Logic for moving staircases maybe.
  table.with(self.rooms, 'update')
  table.with(self.projectiles, 'update')
  table.with(self.enemies, 'update')
end

function Level:draw()
  table.with(self.rooms, 'draw')
  table.with(self.projectiles, 'draw')
  table.with(self.enemies, 'draw')
end