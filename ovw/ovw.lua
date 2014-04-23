Overwatch = {
	ovws = {},
	toRemove = {}
}

function Overwatch:add(obj, ...)
	local oldovw = ovw
	local o = obj(...)
	table.insert(self.ovws, o)
	ovw = o
	f.exe(ovw.load, ovw, ...)
	ovw = oldovw
	return o
end

function Overwatch:remove(ovw)
	table.insert(self.toRemove, ovw)
end

function Overwatch:clear()
	table.each(self.ovws, f.cur(self.remove, self))
end

setmetatable(Overwatch, {
	__index = function(t, k)
		return function(...)
			local i = 1
			while i <= #t.ovws do
				ovw = t.ovws[i]
				if k == 'update' and table.has(t.toRemove, ovw) then
					f.exe(ovw.unload, ovw)
					table.remove(t.ovws, i)
				else
					if ovw[k] then ovw[k](ovw, ...) end
					i = i + 1
				end
				ovw = nil
			end
		end
	end
})