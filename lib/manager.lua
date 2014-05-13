Manager = class()

function Manager:init()
  self.objects = {}
end

function Manager:add(object)
  self.objects[object] = object
  return object
end

function Manager:remove(object)
  if not object then return end
  f.exe(object.destroy, object)
  self.objects[object] = nil
end

function Manager:clear()
  table.each(self.objects, function(o)
    self:remove(o)
  end)
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
