require 'require'

function love.load()
  Overwatch:add(Game)

  love.update = Overwatch.update
  love.draw = Overwatch.draw
  love.sync = Overwatch.sync
  love.quit = Overwatch.quit
  
  love.handlers = {}
  setmetatable(love.handlers, {__index = Overwatch})
end
