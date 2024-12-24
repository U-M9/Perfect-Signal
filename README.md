# PerfectSignal

**PerfectSignal** is a powerful, yield-safe, and memory-efficient event handling module for Roblox. Designed to replicate and extend the functionality of `RBXScriptSignal`, it introduces advanced features such as debouncing, throttling, and conditional event filtering. PerfectSignal is the ultimate tool for creating and managing custom events in your game, ensuring performance and maintainability.

---

## Features

- **Safe and Efficient**: Handlers run in isolated threads to ensure yield-safety.
- **Flexible Connections**:
  - Attach (`Connect`) and detach (`Disconnect`) handlers.
  - Automatically disconnect after first trigger (`Once`).
- **Advanced Event Handling**:
  - Filter connections to react only to specific events (`FilterConnect`).
  - Debounced and throttled event firing (`DebouncedFire`, `ThrottleFire`).
- **Debugging and Maintenance**:
  - Reconnect previously disconnected handlers.
  - Retrieve active connections and their count.
  - Prevent memory leaks with `DisconnectAll` and `Destroy` methods.

---

## Installation

1. Clone or download this repository.
2. Place the `PerfectSignal` module in your game's `ReplicatedStorage` or another shared directory.
3. Require it in your scripts:

```lua
local Signal = require(game.ReplicatedStorage.PerfectSignal)
```

---

## Usage

### Basic Example

```lua
local Signal = require(game.ReplicatedStorage.PerfectSignal)

-- Create a new signal
local mySignal = Signal.new()

-- Connect a handler
local connection = mySignal:Connect(function(message)
    print("Handler received:", message)
end)

-- Fire the signal
mySignal:Fire("Hello, Signal!")

-- Disconnect the handler
connection:Disconnect()
```

### Advanced Features

- **Debounced Fire**: Prevent rapid, consecutive firings of the same event.
- **Throttle Fire**: Limit event firings to a fixed rate.
- **Filtered Connections**: Only trigger a handler when conditions are met.
- **Reconnect Handlers**: Temporarily disable and re-enable event handlers.

### See Full Documentation
For detailed examples and use cases, check the [documentation](./signal_documentation.md).

---

## Use Cases

### Game Events
- Notify other systems when players join, leave, or interact with the game world.

### UI and UX Enhancements
- Handle button clicks or other rapid user interactions without overwhelming event handlers.

### Module Communication
- Use signals to decouple systems, allowing independent modules to communicate without direct dependencies.

---

## Contributing

Contributions are welcome! Please submit issues and pull requests on the GitHub repository to suggest new features or improvements.

---

## License

This project is open-sourced under the MIT License. See the [LICENSE](./LICENSE) file for details.

