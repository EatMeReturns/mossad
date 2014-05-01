local function load(dir)
  for _, file in pairs(love.filesystem.getDirectoryItems(dir)) do
    local path = dir .. '/' .. file
    if string.find(path, '%.lua') and not string.find(path, '%..+%.lua') then
      require(path:gsub('%.lua', ''))
    end
  end
  
  if love.filesystem.exists(dir .. '.lua') then require(dir) end
end

load 'lib/lutil'
load 'lib'
load 'ovw'
load 'app/house'
load 'app'
