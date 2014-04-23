Path = class()

function Path:init(level, x, y, size)
	self.level = level
	self.x = x
	self.y = y
	self.size = size
end

function Path:sweep()
	self.level.walls = table.filter(self.level.walls, function(wall) if math.distance(wall.x, wall.y, self.x, self.y) < self.size then wall:destroy() return false else return true end end)
end