function love.run()
  if love.math then
  	love.math.setRandomSeed(os.time())
  end
  tick = 0
  tickRate = .02
  tickDelta = 0

  love.load(arg)

  delta = 0

  while true do
    love.timer.step()
    delta = love.timer.getDelta()

    tickDelta = tickDelta + delta
    while tickDelta >= tickRate do
      tick = tick + 1
      tickDelta = tickDelta - tickRate
      
      love.event.pump()
      local releases = {}
      for e, a, b, c, d in love.event.poll() do
        if e == 'quit' then f.exe(love.quit) love.audio.stop() return
        else love.handlers[e](a, b, c, d) end
      end
      
      love.update()
    end
    
    love.graphics.clear()
    love.draw()
    love.graphics.present()
    
    love.timer.sleep(.001)
  end
end

local function error_printer(msg, layer)
  print((debug.traceback('Error: ' .. tostring(msg), 1 + (layer or 1)):gsub('\n[^\n]+$', '')))
end

function love.errhand(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isCreated() then
		if not pcall(love.window.setMode, 800, 600) then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick then
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration() -- Stop all joystick vibrations.
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	love.graphics.setBackgroundColor(35, 35, 35)
	local font = love.graphics.setNewFont('media/fonts/pixel.ttf', 8)

	love.graphics.setColor(255, 255, 255, 255)

	local trace = debug.traceback()

	love.graphics.clear()
	love.graphics.origin()

	local err = {}

	for l in string.gmatch(trace, '(.-)\n') do
		if not string.match(l, 'boot.lua') then
			l = string.gsub(l, 'stack traceback:', 'more details:\n')
			table.insert(err, l)
		end
	end

	local p = table.concat(err, '\n')

	p = string.gsub(p, '\t', '')
	p = string.gsub(p, '%[string "(.-)"%]', '%1')

	local _, lines = font:getWrap(p, love.graphics.getWidth() - 140)

	local function draw()
		love.graphics.clear()
		love.graphics.setColor(255, 255, 255, 128)
		love.graphics.print('Mossad is angry\n\nhere\'s why:', 64, 64)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf(msg, 64, 64 + font:getHeight() * 4, love.graphics.getWidth() - 64)
		love.graphics.setColor(255, 255, 255, 128)
		love.graphics.printf(p, 64, 64 + font:getHeight() * 6, love.graphics.getWidth() - 64)
		love.graphics.present()
	end

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			end
			if e == "keypressed" and a == "escape" then
				return
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end

function love.graphics.rectangleCenter(style, x, y, w, h, pix)
  local ox, oy = math.round(x - (w / 2)), math.round(y - (h / 2))
  if pix then ox = ox + .5 oy = oy + .5 end
  love.graphics.rectangle(style, ox, oy, w, h)
end

function love.graphics.printCenter(str, x, y, h, v)
  local xx = x - ((h or (h == nil)) and (love.graphics.getFont():getWidth(str) / 2) or 0)
  local yy = y - ((v or (v == nil)) and (love.graphics.getFont():getHeight() / 2) or 0)
  love.graphics.print(str, xx, yy)
end

function love.graphics.width(x) x = x or 1 return love.window.getWidth() * x end
function love.graphics.height(x) x = x or 1 return love.window.getHeight() * x end
function love.graphics.minUnit(x) return math.min(love.graphics.width(x), love.graphics.height(x)) end