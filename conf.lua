function love.conf(t)
	t.window.title = 'Labyrinth'
	t.window.width = 800
	t.window.height = 600
	t.window.fullscreen = true
	t.window.fullscreentype = 'desktop'
	t.console = true

	t.identity = 'labyrinth'

	t.modules.audio = true
	t.modules.event = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = true
	t.modules.system = false
	t.modules.timer = true
	t.modules.window = true
	t.modules.thread = false
end
