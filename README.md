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
    Widgets = { ... }
}
```

Disable widgets: `UserInfo = false`, `Avatar = false`, etc.

### Widget Types

**Text Widget** (default):
```lua
{Type = "Text", Title = "Notice", Icon = "📢", Content = "Text here"}
```

**Stats Widget** (key-value grid):
```lua
{
    Type = "Stats", Title = "Stats", Icon = "📊",
    Stats = {
        {Label = "FPS", Value = "60", Color = Color3.fromRGB(100,255,100)},
        {Label = "Ping", Value = "45ms"}
    }
}
```

**Buttons Widget** (inline buttons):
```lua
{
    Type = "Buttons", Title = "Actions", Icon = "⚡",
    Buttons = {
        {Name = "Discord", Color = Color3.fromRGB(114,137,218), Link = "https://discord.gg/xxx"},
        {Name = "Reset", Color = Color3.fromRGB(255,100,100), Callback = function() end}
    }
}
```

**Links Widget** (clickable list):
```lua
{
    Type = "Links", Title = "Links", Icon = "🔗",
    Links = {
        {Name = "Discord", Icon = "💬", Link = "https://discord.gg/xxx"},
        {Name = "Docs", Icon = "📖", Callback = function() end}
    }
}
```

**Credits Widget**:
```lua
{
    Type = "Credits", Title = "Credits", Icon = "⭐",
    Credits = {
        {Role = "Developer", Name = "Username", Color = Color3.fromRGB(255,180,100)},
        {Role = "UI Design", Name = "Someone"}
    }
}
```

**Progress Widget** (progress bars):
```lua
{
    Type = "Progress", Title = "Progress", Icon = "📈",
    Progress = {
        {Label = "Features", Value = 100, Color = Color3.fromRGB(100,255,100)},
        {Label = "Docs", Value = 60}
    }
}
```

**Server Widget** (auto-filled server info):
```lua
{Type = "Server", Title = "Server Info", Icon = "🌐"}
```

**Keybinds Widget** (keybind display):
```lua
{
    Type = "Keybinds", Title = "Keybinds", Icon = "⌨️",
    Keybinds = {
        {Action = "Toggle Menu", Key = "RShift"},
        {Action = "Fly", Key = "F"}
    }
}
```

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
Window:Notify({Title = "Click Me", Content = "With callback", OnClick = function() print("clicked") end})
```

## Modals

**Confirm Dialog**:
```lua
Window:Confirm({
    Title = "Are you sure?",
    Content = "This action cannot be undone.",
    Icon = "⚠️",
    ConfirmText = "Yes",
    CancelText = "No",
    ConfirmColor = Color3.fromRGB(255,80,80),
    Callback = function(confirmed)
        if confirmed then print("Confirmed!") end
    end
})
```

**Prompt Dialog**:
```lua
Window:Prompt({
    Title = "Enter Name",
    Content = "What should we call you?",
    Placeholder = "Name...",
    Default = "",
    Callback = function(text)
        if text then print("Entered:", text) end
    end
})
```

## Visibility Conditions

Show/hide elements based on flags:
```lua
Tab:Toggle({Name = "Enable Advanced", Flag = "AdvancedMode", Callback = function(v) end})
Tab:Slider({Name = "Advanced Setting", Flag = "AdvSetting", VisibleIf = "AdvancedMode", ...})
```

The slider only shows when the toggle is ON.

## Keybind System

**Global Keybinds**:
```lua
Window:BindKey(Enum.KeyCode.G, function() print("G pressed") end, "MyBind")
Window:UnbindKey("MyBind")
```

**Element Keybinds**:
```lua
Tab:Toggle({Name = "Speed", Flag = "Speed", Keybind = Enum.KeyCode.V, Callback = function(v) end})
Tab:Button({Name = "Reset", Keybind = Enum.KeyCode.R, Callback = function() end})
```

## Theme Customization

**Set Theme**:
```lua
Window:SetTheme({
    Accent = Color3.fromRGB(100, 150, 255),
    Background = Color3.fromRGB(20, 20, 25)
})
```

**Set Accent Only**:
```lua
Window:SetAccent(Color3.fromRGB(255, 100, 150))
```

**Built-in Theme Tab**:
```lua
Window:CreateThemeTab()
```

Adds a "Theme" tab with accent color, UI scale, and keybind settings.

## UI Scale

```lua
Window:SetScale(1.2)  -- 0.6 to 1.5
```

## Update Loop

For performance-safe loops:
```lua
local connection = Window:OnUpdate(function(dt)
    -- runs every frame, throttled
    print("Delta:", dt)
end, "MyLoop")

connection:Disconnect()  -- stop the loop
```

## Pop-out Tabs

Detach a tab into its own floating window:
```lua
Window:PopoutTab("Settings")
```

## Per-Tab Search

Search within current tab, auto-scroll and highlight:
```lua
Window:SearchTab("speed")
```

## Custom Widgets (Plugin System)

Register custom widgets globally:
```lua
Gatito:RegisterWidget("ColorPicker", function(Tab, cfg, page, Theme)
    -- build your widget here
    return myWidget
end)
```

Use in tabs:
```lua
Tab:Custom("ColorPicker", {Name = "Pick Color", Default = Color3.new(1,0,0)})
```

## Safe API

Access sandboxed API without touching internals:
```lua
Window.API.Notify({Title = "Hello"})
Window.API.SetAccent(Color3.fromRGB(100, 200, 255))
Window.API.SetFlag("SpeedEnabled", true)
local val = Window.API.GetFlag("SpeedValue")
```

## Methods

```lua
Window:Toggle()                -- Toggle visibility
Window:Toggle(true)            -- Show
Window:Toggle(false)           -- Hide
Window:Destroy()               -- Clean up
Window:SaveConfig()            -- Manual save
Window:LoadConfig()            -- Manual load
Window:SetTheme(themeTable)    -- Override theme colors
Window:SetAccent(color)        -- Set accent color
Window:SetScale(scale)         -- Set UI scale (0.6-1.5)
Window:BindKey(key, cb, name)  -- Bind global keybind
Window:UnbindKey(name)         -- Unbind keybind
Window:OnUpdate(callback, name)-- Add update loop
Window:Confirm(cfg)            -- Show confirm dialog
Window:Prompt(cfg)             -- Show text input dialog
Window:SearchTab(query)        -- Search current tab
Window:PopoutTab(tabName)      -- Detach tab to window
Window:CreateThemeTab()        -- Add built-in theme tab
```

---

© 2025 Hikage - All Rights Reserved
