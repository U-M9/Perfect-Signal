# Signal Module Documentation

## Overview
The Signal module is a yield-safe and efficient custom event handler implementation. It replicates the behavior of Roblox's built-in events (`RBXScriptSignal`) while adding features for filtering, debouncing, throttling, and more. Signals are designed to manage event-driven programming effectively, ensuring memory safety and ease of use.

---

## Features

### Signal Methods

#### **Connect**
Attach a function to the signal. This function will be invoked whenever the signal is fired.

**Syntax:**
```lua
Signal:Connect(fn: (...any) -> ()) -> Connection
```

**Example:**
```lua
local connection = mySignal:Connect(function(message)
    print("Received message:", message)
end)
```

---

#### **DisconnectAll**
Disconnect all handlers connected to the signal.

**Syntax:**
```lua
Signal:DisconnectAll()
```

**Example:**
```lua
mySignal:DisconnectAll()
```

---

#### **Fire**
Trigger the signal, invoking all connected handlers.

**Syntax:**
```lua
Signal:Fire(...any)
```

**Example:**
```lua
mySignal:Fire("Hello, Signal!")
```

---

#### **Wait**
Pause execution until the signal is fired. Returns the arguments passed to the signal.

**Syntax:**
```lua
Signal:Wait() -> (...any)
```

**Example:**
```lua
spawn(function()
    local message = mySignal:Wait()
    print("Signal triggered with:", message)
end)

mySignal:Fire("Hello, Wait!")
```

---

#### **Once**
Attach a function that disconnects automatically after being called once.

**Syntax:**
```lua
Signal:Once(fn: (...any) -> ()) -> Connection
```

**Example:**
```lua
mySignal:Once(function(message)
    print("This will print only once:", message)
end)

mySignal:Fire("Hello, Once!")
```

---

#### **GetConnections**
Retrieve all active connections for the signal.

**Syntax:**
```lua
Signal:GetConnections() -> {Connection}
```

**Example:**
```lua
local connections = mySignal:GetConnections()
print("Active connections:", #connections)
```

---

#### **IsConnected**
Check if a specific connection is still active.

**Syntax:**
```lua
Signal:IsConnected(connection: Connection) -> boolean
```

**Example:**
```lua
if mySignal:IsConnected(connection) then
    print("The connection is active")
end
```

---

#### **GetConnectionCount**
Retrieve the total number of active connections.

**Syntax:**
```lua
Signal:GetConnectionCount() -> number
```

**Example:**
```lua
print("Total connections:", mySignal:GetConnectionCount())
```

---

#### **FilterConnect**
Attach a function to the signal that only triggers if a condition is met.

**Syntax:**
```lua
Signal:FilterConnect(filter: (...any) -> boolean, fn: (...any) -> ()) -> Connection
```

**Example:**
```lua
mySignal:FilterConnect(function(message)
    return message:find("Hello")
end, function(message)
    print("Filtered handler received:", message)
end)

mySignal:Fire("Hello, Filter!") -- Triggers
mySignal:Fire("Goodbye, Filter!") -- Does not trigger
```

---

#### **DebouncedFire**
Trigger the signal, ignoring rapid consecutive calls within the given timeout.

**Syntax:**
```lua
Signal:DebouncedFire(timeout: number, ...any)
```

**Example:**
```lua
mySignal:DebouncedFire(1, "Debounced Message")
mySignal:DebouncedFire(1, "Ignored Message") -- Ignored
wait(1.1)
mySignal:DebouncedFire(1, "Allowed Message")
```

---

#### **ThrottleFire**
Trigger the signal only if sufficient time has passed since the last trigger.

**Syntax:**
```lua
Signal:ThrottleFire(interval: number, ...any)
```

**Example:**
```lua
mySignal:ThrottleFire(2, "Throttled Message")
mySignal:ThrottleFire(2, "Ignored Message") -- Ignored
wait(2.1)
mySignal:ThrottleFire(2, "Allowed Message")
```

---

#### **Reconnect**
Re-enable a previously disconnected connection.

**Syntax:**
```lua
Signal:Reconnect(connection: Connection)
```

**Example:**
```lua
local connection = mySignal:Connect(function(message)
    print("Handler received:", message)
end)

connection:Disconnect()
mySignal:Reconnect(connection)
mySignal:Fire("Hello again!")
```

---

#### **HasHandlers**
Check if the signal has any active handlers.

**Syntax:**
```lua
Signal:HasHandlers() -> boolean
```

**Example:**
```lua
if mySignal:HasHandlers() then
    print("Signal has active handlers")
end
```

---

### Connection Methods

#### **Disconnect**
Manually disconnect the connection.

**Syntax:**
```lua
Connection:Disconnect()
```

**Example:**
```lua
connection:Disconnect()
```

---

#### **Destroy**
Alias for `Disconnect`. Disconnects the connection.

**Syntax:**
```lua
Connection:Destroy()
```

**Example:**
```lua
connection:Destroy()
```

---

## Notes

1. **Thread Safety**: Each handler runs in its own coroutine, ensuring yield-safety and preventing blocking.
2. **Performance**: Efficiently handles large numbers of connections, with robust support for conditional and time-based handling.
3. **Error Handling**: Attempts to access invalid properties or improperly use the module will throw descriptive errors to aid debugging.

---

