-- This script demonstrates the usage of the PerfectSignal module.
-- It includes examples for basic connections, filtered connections, debounced and throttled fires, reconnecting handlers, cleanup, and all available functions.

-- Import the PerfectSignal module
local Signal = require(game.ReplicatedStorage.PerfectSignal)

-- Create a new signal
type SignalType = typeof(Signal.new())
local mySignal: SignalType = Signal.new()

-- Example 1: Basic Connection
-- Demonstrates connecting a handler to the signal and firing it.
local connection = mySignal:Connect(function(message: string)
	print("Received message:", message)
end)
-- Fire the signal, triggering all connected handlers
mySignal:Fire("Hello, PerfectSignal!") -- Prints: "Received message: Hello, PerfectSignal!"

-- Example 2: One-Time Connection
-- Demonstrates connecting a handler that disconnects automatically after a single trigger.
mySignal:Once(function(message: string)
	print("This will only trigger once:", message)
end)
mySignal:Fire("Trigger once") -- Prints: "This will only trigger once: Trigger once"
mySignal:Fire("Ignored") -- Does nothing

-- Example 3: Filtered Connection
-- Demonstrates connecting a handler with a condition to filter events.
mySignal:FilterConnect(function(message: string)
	if type(message) ~= "string" then return false end -- Ensure the message is a string
	return message:find("Allowed") ~= nil -- Only allow messages containing the word "Allowed"
end, function(message: string)
	print("Filtered message received:", message)
end)
mySignal:Fire("Allowed message") -- Prints: "Filtered message received: Allowed message"
mySignal:Fire("Blocked message") -- Does nothing

-- Example 4: Debounced Fire
-- Demonstrates debouncing to prevent rapid consecutive triggers.
mySignal:Connect(function()
	print("Debounced handler triggered")
end)
-- Fire the signal, but debounce prevents rapid consecutive calls
mySignal:DebouncedFire(1) -- Triggers the handler
mySignal:DebouncedFire(1) -- Ignored due to debounce
wait(1.1)
mySignal:DebouncedFire(1) -- Triggers the handler again

-- Example 5: Throttled Fire
-- Demonstrates throttling to limit the frequency of event triggers.
mySignal:ThrottleFire(2, "Throttled message") -- Prints: "Throttled message"
mySignal:ThrottleFire(2, "Ignored message") -- Ignored due to throttle
wait(2.1)
mySignal:ThrottleFire(2, "Allowed again") -- Prints: "Allowed again"

-- Example 6: Waiting for Signal
-- Demonstrates waiting for a signal to be fired before continuing.
spawn(function()
	local message = mySignal:Wait()
	print("Waited for signal and received:", message)
end)
mySignal:Fire("Wait test") -- Prints: "Waited for signal and received: Wait test"

-- Example 7: Reconnecting Handlers
-- Demonstrates disconnecting and reconnecting a handler.
local reconnectableConnection = mySignal:Connect(function(message: string)
	print("Reconnected handler received:", message)
end)
-- Disconnect the handler
reconnectableConnection:Disconnect()
mySignal:Fire("Disconnected") -- Does nothing since the handler is disconnected
-- Reconnect the handler
mySignal:Reconnect(reconnectableConnection)
mySignal:Fire("Reconnected") -- Prints: "Reconnected handler received: Reconnected"

-- Example 8: Get Active Connections
-- Demonstrates retrieving and inspecting all active connections.
local connections = mySignal:GetConnections()
for _, conn in ipairs(connections) do
	print("Active connection found:", conn)
end

-- Example 9: Check Connection Status
-- Demonstrates checking if a specific connection is still active.
if mySignal:IsConnected(reconnectableConnection) then
	print("Reconnectable connection is active")
else
	print("Reconnectable connection is not active")
end

-- Example 10: Get Connection Count
-- Demonstrates retrieving the total number of active connections.
local connectionCount = mySignal:GetConnectionCount()
print("Total active connections:", connectionCount)

-- Example 11: Check If Signal Has Handlers
-- Demonstrates checking if the signal has any handlers connected.
if mySignal:HasHandlers() then
	print("Signal has active handlers")
else
	print("Signal has no active handlers")
end

-- Example 12: Cleanup
-- Demonstrates disconnecting all handlers to clean up resources.
mySignal:DisconnectAll()
mySignal:Fire("No handlers should trigger") -- Does nothing since all handlers are disconnected

local connectionCount = mySignal:GetConnectionCount()
print("Total active connections:", connectionCount)

if mySignal:HasHandlers() then
	print("Signal has active handlers")
else
	print("Signal has no active handlers")
end
