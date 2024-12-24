type Connection = {
	_connected: boolean,
	_signal: Signal,
	_fn: (...any) -> (),
	_next: Connection | false,
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> ()
}

type Signal = {
	_handlerListHead: Connection | false,
	_debounce: boolean?,
	_lastFireTime: number?,
	Connect: (self: Signal, fn: (...any) -> ()) -> Connection,
	DisconnectAll: (self: Signal) -> (),
	Destroy: (self: Signal) -> (),
	Fire: (self: Signal, ...any) -> (),
	Wait: (self: Signal) -> (...any),
	Once: (self: Signal, fn: (...any) -> ()) -> Connection,
	GetConnections: (self: Signal) -> {Connection},
	IsConnected: (self: Signal, connection: Connection) -> boolean,
	GetConnectionCount: (self: Signal) -> number,
	FilterConnect: (self: Signal, filter: (...any) -> boolean, fn: (...any) -> ()) -> Connection,
	DebouncedFire: (self: Signal, timeout: number, ...any) -> (),
	ThrottleFire: (self: Signal, interval: number, ...any) -> (),
	Reconnect: (self: Signal, connection: Connection) -> (),
	HasHandlers: (self: Signal) -> boolean
}

local freeRunnerThread

local function acquireRunnerThreadAndCallEventHandler(fn: (...any) -> (), ...: any)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	freeRunnerThread = acquiredRunnerThread
end

local function runEventHandlerInFreeThread()
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local Connection = {}
Connection.__index = Connection

function Connection.new(signal: Signal, fn: (...any) -> ())
	return setmetatable({
		_connected = true,
		_signal = signal,
		_fn = fn,
		_next = false,
	}, Connection)
end

function Connection:Disconnect()
	self._connected = false

	if self._signal._handlerListHead == self then
		self._signal._handlerListHead = self._next
	else
		local prev = self._signal._handlerListHead
		while prev and prev._next ~= self do
			prev = prev._next
		end
		if prev then
			prev._next = self._next
		end
	end
end
Connection.Destroy = Connection.Disconnect

setmetatable(Connection, {
	__index = function(_, key)
		error(("Attempt to get Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_, key, _)
		error(("Attempt to set Connection::%s (not a valid member)"):format(tostring(key)), 2)
	end
})

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_handlerListHead = false,
		_debounce = false,
		_lastFireTime = 0,
	}, Signal)
end

function Signal:Connect(fn: (...any) -> ()): Connection
	local connection = Connection.new(self, fn)
	if self._handlerListHead then
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	else
		self._handlerListHead = connection
	end
	return connection
end

function Signal:DisconnectAll()
	self._handlerListHead = false
end
Signal.Destroy = Signal.DisconnectAll

function Signal:Fire(...: any)
	local item = self._handlerListHead
	while item do
		if item._connected then
			if not freeRunnerThread then
				freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
				coroutine.resume(freeRunnerThread)
			end
			task.spawn(freeRunnerThread, item._fn, ...)
		end
		item = item._next
	end
end

function Signal:Wait()
	local waitingCoroutine = coroutine.running()
	local cn: Connection? = nil
	cn = self:Connect(function(...: any)
		if cn then
			cn:Disconnect()
		end
		task.spawn(waitingCoroutine, ...)
	end)
	return coroutine.yield()
end

function Signal:Once(fn: (...any) -> ())
	local cn: Connection? = nil
	cn = self:Connect(function(...: any)
		if cn and cn._connected then
			cn:Disconnect()
		end
		fn(...)
	end)
	return cn
end

function Signal:GetConnections(): {Connection}
	local connections = {}
	local current = self._handlerListHead
	while current do
		if current._connected then
			table.insert(connections, current)
		end
		current = current._next
	end
	return connections
end

function Signal:IsConnected(connection: Connection): boolean
	return connection and connection._connected or false
end

function Signal:GetConnectionCount(): number
	local count = 0
	local current = self._handlerListHead
	while current do
		if current._connected then
			count += 1
		end
		current = current._next
	end
	return count
end

function Signal:FilterConnect(filter: (...any) -> boolean, fn: (...any) -> ())
    return self:Connect(function(...)
        local args = { ... }
        if filter(unpack(args)) then
            fn(unpack(args))
        end
    end)
end


function Signal:DebouncedFire(timeout: number, ...: any)
	if not self._debounce then
		self._debounce = true
		self:Fire(...)
		task.delay(timeout, function()
			self._debounce = false
		end)
	end
end

function Signal:ThrottleFire(interval: number, ...: any)
	local now = os.clock()
	self._lastFireTime = self._lastFireTime or 0
	if (now - self._lastFireTime >= interval) then
		self._lastFireTime = now
		self:Fire(...)
	end
end


function Signal:Reconnect(connection: Connection)
	if not connection._connected then
		connection._connected = true
		connection._next = self._handlerListHead
		self._handlerListHead = connection
	end
end

function Signal:HasHandlers(): boolean
	return self._handlerListHead ~= false
end

setmetatable(Signal, {
	__index = function(_, key)
		error(("Attempt to get Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end,
	__newindex = function(_, key, _)
		error(("Attempt to set Signal::%s (not a valid member)"):format(tostring(key)), 2)
	end
})

return Signal
