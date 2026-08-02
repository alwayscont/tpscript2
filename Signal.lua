local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

--- Constructs a new signal.
function Signal.new()
	local self = setmetatable({}, Signal)

	self._bindableEvent = Instance.new("BindableEvent")
	self._argData = nil
	self._argCount = nil
	self._waiting = false

	return self
end

--- Verifica se um objeto é um Signal
function Signal.isSignal(object)
	return typeof(object) == 'table' and getmetatable(object) == Signal
end

--- Fire the event with the given arguments.
function Signal:Fire(...)
	self._argData = {...}
	self._argCount = select("#", ...)
	self._bindableEvent:Fire()
end

--- Connect a new handler to the event.
function Signal:Connect(handler)
	if not self._bindableEvent then
		error("Signal has been destroyed", 2)
	end

	if not (type(handler) == "function") then
		error(("connect(%s)"):format(typeof(handler)), 2)
	end

	local connection
	connection = self._bindableEvent.Event:Connect(function()
		if self._argData then
			handler(unpack(self._argData, 1, self._argCount))
		end
	end)

	return connection
end

--- Wait for fire to be called, and return the arguments.
function Signal:Wait()
	if not self._bindableEvent then
		error("Signal has been destroyed", 2)
	end

	self._waiting = true
	self._bindableEvent.Event:Wait()
	self._waiting = false
	
	local attempts = 0
	while not self._argData and attempts < 50 do
		task.wait(0.01)
		attempts = attempts + 1
	end
	
	if not self._argData then
		error("Timeout: No data received in Wait()", 2)
	end
	
	local results = {unpack(self._argData, 1, self._argCount)}
	
	self._argData = nil
	self._argCount = nil
	
	return unpack(results, 1, #results)
end

--- Disconnects all connected events. Voids the signal as unusable.
function Signal:Destroy()
	if self._bindableEvent then
		self._bindableEvent:Destroy()
		self._bindableEvent = nil
	end

	self._argData = nil
	self._argCount = nil
	self._waiting = false
end

return Signal
