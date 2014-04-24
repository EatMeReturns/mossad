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
 
  self.rooms = Manager(room)
  self.rooms:add(self.baseRoom)

  self.projectiles = {}
  self.enemies = {}

  self.depth = 5
  ovw.view:register(self)
end

function Level:update()
  self.rooms:update()
  table.with(self.projectiles, 'update')
  table.with(self.enemies, 'update')
end

function Level:draw()
  self.rooms:draw()
  table.with(self.projectiles, 'draw')
  table.with(self.enemies, 'draw')
end
