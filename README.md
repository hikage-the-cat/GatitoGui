# Gatito GUI Library

Roblox executor UI library with configurable homepage widgets and config saving.

## Load

```lua
local Gatito = loadstring(game:HttpGet("https://raw.githubusercontent.com/hikage-the-cat/GatitoGui/refs/heads/main/gui.lua"))()
```

## Quick Start

```lua
local Gatito = loadstring(game:HttpGet("https://raw.githubusercontent.com/hikage-the-cat/GatitoGui/refs/heads/main/gui.lua"))()

local Window = Gatito:CreateWindow({
    Title = "My Hub",
    ConfigName = "MyHub",
    AutoSave = true
})

local Tab = Window:CreateTab({Name = "Main", Icon = "⚔️"})

Tab:Toggle({Name = "Speed", Flag = "SpeedEnabled", Callback = function(v) end})
Tab:Slider({Name = "Speed Value", Flag = "SpeedValue", Min = 16, Max = 200, Callback = function(v) end})
```

## Window Options

```lua
Gatito:CreateWindow({
    Title = "Hub Name",
    Subtitle = "v1.0",
    User = "Username",
    Size = UDim2.new(0, 700, 0, 460),
    Icon = "🐱",
    ShowHome = true,
    Splash = true,
    SplashDuration = 2,
    ConfigName = "MyConfig",
    ConfigFolder = "GatitoConfigs",
    AutoSave = true,
    Tutorial = true,
    TutorialTips = {
        Welcome = "Welcome to my hub!",
        Tabs = "Click icons on the left to switch tabs.",
        Drag = "Drag the icon to move the menu.",
        Settings = "Settings save automatically!",
        Keybind = "Press RightShift to toggle the menu.",
        Custom = {
            {Title = "Tip", Content = "Custom tip here"}
        }
    },
    Home = { ... }
})
```

**Drag**: Click and drag the top-left icon to move the window.

**Discord Reminder**: Every 5 minutes shows clickable notification to join Discord.

**Tutorial**: Interactive tutorial with highlights. Click highlighted elements to proceed. Skip button available.

## Config System

Add `Flag` to any element to make it saveable:

```lua
Tab:Toggle({Name = "Speed Boost", Flag = "SpeedBoost", Default = false, Callback = function(v) end})
Tab:Slider({Name = "Walk Speed", Flag = "WalkSpeed", Min = 16, Max = 200, Callback = function(v) end})
Tab:Dropdown({Name = "Mode", Flag = "Mode", Options = {"A", "B"}, Callback = function(v) end})
Tab:Textbox({Name = "Name", Flag = "PlayerName", Callback = function(v) end})
Tab:Keybind({Name = "Toggle", Flag = "ToggleKey", Default = Enum.KeyCode.F, Callback = function() end})
```

**Auto Save**: When `AutoSave = true`, settings save automatically on change.

**Manual Save/Load Buttons**:
```lua
Tab:SaveButton({Name = "Save Settings"})
Tab:LoadButton({Name = "Load Settings"})
```

**Manual Save/Load Methods**:
```lua
Window:SaveConfig()
Window:LoadConfig()
```

Config files are stored in: `GatitoConfigs/ConfigName.json`

## Home Widgets

```lua
Home = {
    UserInfo = {Access = "Premium", Executions = 451, Expires = "Lifetime"},
    Avatar = true,
    Updates = {List = {{Title = "v1.0", Changes = {"Initial release"}}}},
    Games = {List = {{Name = "Game", Status = "working", Tag = "NEW"}}},
    Widgets = {{Title = "Notice", Content = "Text here"}}
}
```

Disable widgets: `UserInfo = false`, `Avatar = false`, etc.

## Components

```lua
Tab:Section("Section Name")

Tab:Button({Name = "Button", Callback = function() end})

Tab:Toggle({Name = "Toggle", Flag = "MyToggle", Default = false, Callback = function(v) end})

Tab:Slider({Name = "Slider", Flag = "MySlider", Min = 0, Max = 100, Default = 50, Callback = function(v) end})

Tab:Dropdown({Name = "Dropdown", Flag = "MyDropdown", Options = {"A", "B"}, Default = "A", Callback = function(v) end})

Tab:Textbox({Name = "Input", Flag = "MyInput", Placeholder = "Enter...", Callback = function(t) end})

Tab:Keybind({Name = "Keybind", Flag = "MyKeybind", Default = Enum.KeyCode.F, Callback = function() end})

Tab:Label("Text")

Tab:SaveButton({Name = "Save"})
Tab:LoadButton({Name = "Load"})
Tab:TutorialButton({Name = "Restart Tutorial"})
```

## Notifications

```lua
Window:Notify({Title = "Title", Content = "Message", Duration = 5, Type = "Success"})
```

## Methods

```lua
Window:Toggle()
Window:Destroy()
Window:SaveConfig()
Window:LoadConfig()
```

---

© 2025 Hikage - All Rights Reserved
