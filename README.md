# Gatito GUI Library

Roblox executor UI library with configurable homepage widgets.

## Load

```lua
local Gatito = loadstring(game:HttpGet("https://raw.githubusercontent.com/hikage-the-cat/GatitoGui/refs/heads/main/gui.lua"))()
```

## Quick Start

```lua
local Gatito = loadstring(game:HttpGet("https://raw.githubusercontent.com/hikage-the-cat/GatitoGui/refs/heads/main/gui.lua"))()

local Window = Gatito:CreateWindow({
    Title = "My Hub",
    ShowHome = true,
    Home = {
        UserInfo = {Access = "Premium", Executions = 100, Expires = "Lifetime"},
        Games = {List = {{Name = "Game", Status = "working"}}}
    }
})

local Tab = Window:CreateTab({Name = "Main", Icon = "⚔️"})
Tab:Button({Name = "Click", Callback = function() end})
```

## Window Options

```lua
Gatito:CreateWindow({
    Title = "Hub Name",
    Subtitle = "v1.0",
    User = "Username",
    Size = UDim2.new(0, 700, 0, 460),
    ShowHome = true,
    Home = { ... }
})
```

## Home Widgets

```lua
Home = {
    UserInfo = {
        Access = "Premium",
        Executions = 451,
        Expires = "Infinite/Lifetime"
    },
    Avatar = true,
    Updates = {
        List = {
            {Title = "Update Title", Changes = {"Change 1", "Change 2"}}
        }
    },
    Games = {
        List = {
            {Name = "Game Name", Status = "working"},
            {Name = "Game 2", Status = "issues", Tag = "BETA", TagColor = Color3.fromRGB(200,80,80)},
            {Name = "Game 3", Status = "broken"}
        }
    },
    Widgets = {
        {Title = "Custom", Content = "Any text here"}
    }
}
```

Disable widgets: `UserInfo = false`, `Avatar = false`, `Updates = false`, `Games = false`

Disable homepage entirely: `ShowHome = false`

## Tabs

```lua
local Tab = Window:CreateTab({Name = "Tab Name", Icon = "🎮"})
```

## Components

```lua
Tab:Section("Section Name")

Tab:Button({Name = "Button", Callback = function() end})

Tab:Toggle({Name = "Toggle", Default = false, Callback = function(enabled) end})

Tab:Slider({Name = "Slider", Min = 0, Max = 100, Default = 50, Increment = 1, Callback = function(value) end})

Tab:Dropdown({Name = "Dropdown", Options = {"A", "B", "C"}, Default = "A", Callback = function(selected) end})

Tab:Textbox({Name = "Input", Placeholder = "Enter...", Default = "", Callback = function(text) end})

Tab:Keybind({Name = "Keybind", Default = Enum.KeyCode.F, Callback = function() end})

Tab:Label("Text here")
```

## Notifications

```lua
Window:Notify({Title = "Title", Content = "Message", Duration = 5, Type = "Success"})
```

Types: `Info`, `Success`, `Warning`, `Error`

## Methods

```lua
Window:Toggle()
Window:Toggle(true)
Window:Toggle(false)
Window:Destroy()
```

## Game Status Values

| Status | Color |
|--------|-------|
| working | Green |
| issues | Yellow |
| broken | Red |

---

© 2025 Hikage - All Rights Reserved
