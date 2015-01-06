Notebook = class()

local g = love.graphics
local w, h = 800, 600

function Notebook:init()
	self.font = g.newFont('media/fonts/pixel.ttf', 8)
	self.titleFont = g.newFont('media/fonts/pixel.ttf', 24)
	self.subTitleFont = g.newFont('media/fonts/pixel.ttf', 16)

	local NBSP = '\194\160'

	self.notes = {'\n\n\n\n\n\n' .. NBSP:rep(13) .. 'JERICHO\'S FIELD NOTEBOOK\n\n' .. NBSP:rep(15) .. '[Backspace] : Previous\n' .. NBSP:rep(23) .. '[N] : Toggle\n' .. NBSP:rep(21) .. '[Enter] : Next'}
	--TODO: load all unlocked notes
	self.currentNote = 1 --if 0, then you dun goofed.

	self.open = false --if true, then display notes.

	self.x = 20 + .5
	self.y = 300 + .5
	self.w = 240
	self.h = 280

	self.depth = -1

	ovw.view:register(self)
end

function Notebook:add(text)
	if not table.has(text) then table.insert(self.notes, text) end
	--TODO: save all unlocked notes
end

function Notebook:next()
	self.currentNote = self.currentNote + 1
	if self.currentNote > table.count(self.notes) then self.currentNote = 1 end
end

function Notebook:back()
	self.currentNote = self.currentNote - 1
	if self.currentNote < 1 then self.currentNote = table.count(self.notes) end
end

function Notebook:toggle()
	if ovw.tutorial.state == 'Done' then self.open = not self.open end

	if self.open then
		--TODO: disable the tutorial... not necessary?
	else
		--TODO: enable the tutorial... not necessary?
	end
end

function Notebook:gui()
	--I'm drawing the notes.
	if started and self.open and ovw.tutorial.state == 'Done' then
		g.setColor(235, 213, 179, 50)
		g.rectangle('fill', self.x, self.y, self.w, self.h)
		g.setColor(255, 255, 255, 255)
		g.rectangle('line', self.x, self.y, self.w, self.h)

		g.print('Notebook', self.x + 1, self.y - 13)
		g.printf(self.currentNote .. '/' .. table.count(self.notes), self.x + self.w - 30, self.y - 13, 30, 'right')

		if self.currentNote ~= 0 and self.currentNote <= table.count(self.notes) then
			g.printf(self.notes[self.currentNote], self.x + 3, self.y, self.w - 6)
		else
			g.printf('Find a piece of paper? Mad scribblings? A crude doodle? It will get printed here in your notebook.', self.x + 3, self.y, self.w - 6)
		end
	end
end