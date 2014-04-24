Manager = class()

function Manager:init()
  self.objects = {}
end

function Manager:add(object)
  self.objects[object] = object
  return object
end

function Manager:remove(object)
  self.objects[object] = nil
end

function Manager:each(fn)
  table.each(self.objects, fn)
end

function Manager:filter(fn)
  self.objects = table.filter(self.objects, fn)
end

function Manager:update()
  self:run('update')
end

function Manager:draw()
  self:run('draw')
end

function Manager:run(method, ...)
  table.with(self.objects, method, ...)
end
