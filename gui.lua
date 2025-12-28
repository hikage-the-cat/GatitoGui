-- © 2025 Hikage
-- All Rights Reserved.
--
-- Permission is granted to use and redistribute this software
-- in unmodified form for personal use only.
--
-- You may NOT:
-- - modify the code
-- - remove this notice
-- - claim this work as your own
-- - sell or monetize this software
--
-- Any violation terminates this permission immediately.

local Gatito = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(24, 24, 30),
    Card = Color3.fromRGB(30, 30, 38),
    CardHover = Color3.fromRGB(38, 38, 48),
    Accent = Color3.fromRGB(200, 80, 80),
    AccentDark = Color3.fromRGB(160, 60, 60),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(140, 140, 150),
    TextMuted = Color3.fromRGB(90, 90, 100),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(220, 180, 50),
    Error = Color3.fromRGB(200, 80, 80),
    Divider = Color3.fromRGB(45, 45, 55)
}

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in pairs(children or {}) do c.Parent = inst end
    return inst
end

local function Tween(inst, props, dur, style, dir)
    local tween = TweenService:Create(inst, TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function Corner(inst, r)
    return Create("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = inst})
end

local function Stroke(inst, c, t)
    return Create("UIStroke", {Color = c or Theme.Divider, Thickness = t or 1, Transparency = 0.5, Parent = inst})
end

local function Padding(inst, p)
    return Create("UIPadding", {PaddingTop = UDim.new(0,p), PaddingBottom = UDim.new(0,p), PaddingLeft = UDim.new(0,p), PaddingRight = UDim.new(0,p), Parent = inst})
end

function Gatito:CreateWindow(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "Hub"
    local subtitle = cfg.Subtitle or ""
    local user = cfg.User or Player.Name
    local showHome = cfg.ShowHome ~= false
    local homeConfig = cfg.Home or {}
    local size = cfg.Size or UDim2.new(0, 680, 0, 440)
    local showSplash = cfg.Splash ~= false
    local splashDuration = cfg.SplashDuration or 2
    local configName = cfg.ConfigName or title:gsub("%s+", "") .. "_config"
    local autoSave = cfg.AutoSave ~= false
    local configFolder = cfg.ConfigFolder or "GatitoConfigs"
    local logoIcon = cfg.Icon or "🐱"
    local discordLink = "https://discord.gg/UnC2N29mjq"
    local showTutorial = cfg.Tutorial ~= false
    local tutorialTips = cfg.TutorialTips or {}
    local tutorialConfigKey = configName .. "_tutorial_done"
    
    if CoreGui:FindFirstChild("GatitoLib") then
        CoreGui:FindFirstChild("GatitoLib"):Destroy()
    end
    
    local Gui = Create("ScreenGui", {Name = "GatitoLib", Parent = CoreGui, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    
    local Flags = {}
    local FlagCallbacks = {}
    
    local function GetConfigPath()
        return configFolder .. "/" .. configName .. ".json"
    end
    
    local function EnsureFolder()
        if isfolder and not isfolder(configFolder) then
            makefolder(configFolder)
        end
    end
    
    local function SaveConfig()
        local data = {}
        for flag, obj in pairs(Flags) do
            local val = obj:Get()
            if typeof(val) == "EnumItem" then
                data[flag] = {type = "keycode", value = val.Name}
            else
                data[flag] = {type = typeof(val), value = val}
            end
        end
        EnsureFolder()
        if writefile then
            writefile(GetConfigPath(), HttpService:JSONEncode(data))
        end
    end
    
    local function LoadConfig()
        EnsureFolder()
        if isfile and isfile(GetConfigPath()) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(GetConfigPath()))
            end)
            if success and data then
                for flag, info in pairs(data) do
                    if Flags[flag] then
                        if info.type == "keycode" then
                            Flags[flag]:Set(Enum.KeyCode[info.value])
                        else
                            Flags[flag]:Set(info.value)
                        end
                    end
                end
                return true
            end
        end
        return false
    end
    
    local function IsTutorialDone()
        EnsureFolder()
        local path = configFolder .. "/" .. tutorialConfigKey .. ".txt"
        if isfile and isfile(path) then
            return readfile(path) == "done"
        end
        return false
    end
    
    local function SetTutorialDone(done)
        EnsureFolder()
        local path = configFolder .. "/" .. tutorialConfigKey .. ".txt"
        if writefile then
            writefile(path, done and "done" or "")
        end
    end
    
    local tutorialActive = false
    local tutorialSkipped = false
    
    local Splash
    if showSplash then
        Splash = Create("Frame", {Name = "Splash", BackgroundColor3 = Theme.Background, Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), Size = UDim2.new(0, 300, 0, 180), Parent = Gui})
        Corner(Splash, 12)
        Stroke(Splash, Theme.Accent, 2)
        
        local SplashLogo = Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0,30), AnchorPoint = Vector2.new(0.5,0), Size = UDim2.new(0,60,0,60), Font = Enum.Font.GothamBold, Text = "🐱", TextSize = 48, Parent = Splash})
        
        local SplashTitle = Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0,95), AnchorPoint = Vector2.new(0.5,0), Size = UDim2.new(1,0,0,25), Font = Enum.Font.GothamBold, Text = title, TextSize = 20, TextColor3 = Theme.Text, Parent = Splash})
        
        local SplashSub = Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0,118), AnchorPoint = Vector2.new(0.5,0), Size = UDim2.new(1,0,0,16), Font = Enum.Font.Gotham, Text = "Loading...", TextSize = 12, TextColor3 = Theme.TextDim, Parent = Splash})
        
        local ProgressBg = Create("Frame", {BackgroundColor3 = Theme.Divider, Position = UDim2.new(0.5,0,1,-30), AnchorPoint = Vector2.new(0.5,0.5), Size = UDim2.new(0.7,0,0,6), Parent = Splash})
        Corner(ProgressBg, 3)
        
        local ProgressFill = Create("Frame", {BackgroundColor3 = Theme.Accent, Size = UDim2.new(0,0,1,0), Parent = ProgressBg})
        Corner(ProgressFill, 3)
        
        Splash.BackgroundTransparency = 1
        Splash.Size = UDim2.new(0, 280, 0, 160)
        SplashLogo.TextTransparency = 1
        SplashTitle.TextTransparency = 1
        SplashSub.TextTransparency = 1
        ProgressBg.BackgroundTransparency = 1
        ProgressFill.BackgroundTransparency = 1
        
        Tween(Splash, {BackgroundTransparency = 0, Size = UDim2.new(0, 300, 0, 180)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(SplashLogo, {TextTransparency = 0}, 0.3)
        task.delay(0.1, function() Tween(SplashTitle, {TextTransparency = 0}, 0.3) end)
        task.delay(0.2, function() Tween(SplashSub, {TextTransparency = 0}, 0.3) end)
        task.delay(0.3, function() 
            Tween(ProgressBg, {BackgroundTransparency = 0}, 0.2)
            Tween(ProgressFill, {BackgroundTransparency = 0}, 0.2)
            Tween(ProgressFill, {Size = UDim2.new(1,0,1,0)}, splashDuration - 0.5, Enum.EasingStyle.Linear)
        end)
    end
    
    local Main = Create("Frame", {Name = "Main", BackgroundColor3 = Theme.Background, Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), Size = size, ClipsDescendants = true, Visible = not showSplash, Parent = Gui})
    Corner(Main, 10)
    Stroke(Main, Theme.Accent, 1)
    
    if showSplash then
        Main.Size = UDim2.new(0, 0, 0, 0)
        Main.BackgroundTransparency = 1
    end
    
    local Sidebar = Create("Frame", {Name = "Sidebar", BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0,55,1,0), Parent = Main})
    
    Create("Frame", {BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0,55,0,10), Position = UDim2.new(0,0,1,-10), Parent = Main})
    
    local Logo = Create("TextButton", {BackgroundTransparency = 1, Position = UDim2.new(0,0,0,8), Size = UDim2.new(1,0,0,38), Font = Enum.Font.GothamBold, Text = logoIcon, TextSize = 22, TextColor3 = Theme.Accent, AutoButtonColor = false, Parent = Sidebar})
    
    local NavScroll = Create("ScrollingFrame", {Name = "NavScroll", BackgroundTransparency = 1, Position = UDim2.new(0,0,0,55), Size = UDim2.new(1,0,1,-55), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.Y, Parent = Sidebar})
    Padding(NavScroll, 8)
    
    local NavLayout = Create("UIListLayout", {Padding = UDim.new(0,5), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = NavScroll})
    NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        NavScroll.CanvasSize = UDim2.new(0,0,0,NavLayout.AbsoluteContentSize.Y + 16)
    end)
    
    local ContentArea = Create("Frame", {Name = "Content", BackgroundTransparency = 1, Position = UDim2.new(0,55,0,0), Size = UDim2.new(1,-55,1,0), ClipsDescendants = true, Parent = Main})
    
    local Window = {Tabs = {}, Pages = {}, CurrentTab = nil, Theme = Theme, Gui = Gui, Frame = Main, HomeEnabled = showHome, Flags = Flags}
    
    local isDragging = false
    local dragStart, startPos
    
    Logo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    
    Logo.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    local function CreateNavButton(name, icon, isHome)
        local btn = Create("TextButton", {Name = name, BackgroundColor3 = Theme.Card, BackgroundTransparency = 1, Size = UDim2.new(0,40,0,40), Text = "", AutoButtonColor = false, Parent = NavScroll})
        Corner(btn, 10)
        local ico = Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Font = Enum.Font.GothamBold, Text = icon, TextSize = 18, TextColor3 = Theme.TextDim, Parent = btn})
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0}, 0.15)
            Tween(ico, {TextColor3 = Theme.Text}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= name then
                Tween(btn, {BackgroundTransparency = 1}, 0.15)
                Tween(ico, {TextColor3 = Theme.TextDim}, 0.15)
            end
        end)
        
        return btn, ico
    end
    
    local function SelectTab(name)
        if Window.CurrentTab == name then return end
        
        for n, t in pairs(Window.Tabs) do
            if n == name then
                Tween(t.Button, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent}, 0.15)
                Tween(t.Icon, {TextColor3 = Theme.Text}, 0.15)
                t.Page.Visible = true
                t.Page.Position = UDim2.new(0.05, 0, 0, 0)
                t.Page.BackgroundTransparency = 1
                Tween(t.Page, {Position = UDim2.new(0,0,0,0)}, 0.25)
            else
                Tween(t.Button, {BackgroundTransparency = 1, BackgroundColor3 = Theme.Card}, 0.15)
                Tween(t.Icon, {TextColor3 = Theme.TextDim}, 0.15)
                t.Page.Visible = false
            end
        end
        Window.CurrentTab = name
    end
    
    if showHome then
        local homeBtn, homeIco = CreateNavButton("Home", "🏠", true)
        
        local homePage = Create("ScrollingFrame", {Name = "Home", BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, Visible = true, Parent = ContentArea})
        Padding(homePage, 20)
        
        local homeLayout = Create("UIListLayout", {Padding = UDim.new(0,15), Parent = homePage})
        homeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            homePage.CanvasSize = UDim2.new(0,0,0,homeLayout.AbsoluteContentSize.Y + 40)
        end)
        
        local topBar = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40), Parent = homePage})
        
        local searchFrame = Create("Frame", {BackgroundColor3 = Theme.Card, Position = UDim2.new(1,-200,0,0), Size = UDim2.new(0,200,0,35), Parent = topBar})
        Corner(searchFrame, 8)
        
        Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0), Size = UDim2.new(0,20,1,0), Font = Enum.Font.GothamBold, Text = "🔍", TextSize = 14, TextColor3 = Theme.TextDim, Parent = searchFrame})
        
        Create("TextBox", {BackgroundTransparency = 1, Position = UDim2.new(0,35,0,0), Size = UDim2.new(1,-45,1,0), Font = Enum.Font.Gotham, PlaceholderText = "Search...", PlaceholderColor3 = Theme.TextMuted, Text = "", TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = searchFrame})
        
        local greeting = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,70), Parent = homePage})
        
        local greetText = "Good " .. (tonumber(os.date("%H")) < 12 and "morning" or tonumber(os.date("%H")) < 18 and "afternoon" or "evening")
        Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,-80,0,28), Font = Enum.Font.GothamBold, Text = greetText .. ", @" .. user .. "!", TextSize = 22, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = greeting})
        
        if homeConfig.UserInfo ~= false then
            local info = homeConfig.UserInfo or {}
            local infoFrame = Create("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0,0,0,32), Size = UDim2.new(1,0,0,38), Parent = greeting})
            Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,20), Parent = infoFrame})
            
            local function InfoItem(label, value, color)
                local item = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X, Parent = infoFrame})
                Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,6), VerticalAlignment = Enum.VerticalAlignment.Center, Parent = item})
                Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,16), AutomaticSize = Enum.AutomaticSize.X, Font = Enum.Font.Gotham, Text = "• " .. label .. ":", TextSize = 13, TextColor3 = Theme.TextDim, Parent = item})
                Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,16), AutomaticSize = Enum.AutomaticSize.X, Font = Enum.Font.GothamBold, Text = value, TextSize = 13, TextColor3 = color or Theme.Accent, Parent = item})
            end
            
            InfoItem("Access", info.Access or "Free", Theme.Accent)
            InfoItem("Executions", tostring(info.Executions or 0), Theme.Text)
            InfoItem("Expires", info.Expires or "Never", Theme.Success)
        end
        
        if homeConfig.Avatar ~= false then
            local avatar = Create("ImageLabel", {BackgroundColor3 = Theme.Card, Position = UDim2.new(1,-60,0,5), Size = UDim2.new(0,60,0,60), Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=150&height=150&format=png", Parent = greeting})
            Corner(avatar, 30)
        end
        
        local columns = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = homePage})
        Create("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,15), Parent = columns})
        
        if homeConfig.Updates ~= false then
            local updates = homeConfig.Updates or {}
            local updatesCard = Create("Frame", {BackgroundColor3 = Theme.Card, Size = UDim2.new(0.48,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = columns})
            Corner(updatesCard, 8)
            Padding(updatesCard, 15)
            
            Create("UIListLayout", {Padding = UDim.new(0,10), Parent = updatesCard})
            
            local updatesHeader = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,24), Parent = updatesCard})
            Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0,20,1,0), Font = Enum.Font.GothamBold, Text = "🔄", TextSize = 16, Parent = updatesHeader})
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,28,0,0), Size = UDim2.new(1,-28,1,0), Font = Enum.Font.GothamBold, Text = "Updates", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = updatesHeader})
            
            for _, update in ipairs(updates.List or {}) do
                local updateItem = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = updatesCard})
                Create("UIListLayout", {Padding = UDim.new(0,4), Parent = updateItem})
                
                if update.Title then
                    Create("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,18), Font = Enum.Font.GothamMedium, Text = update.Title, TextSize = 13, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = updateItem})
                end
                
                for _, line in ipairs(update.Changes or {}) do
                    Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = "• " .. line, TextSize = 12, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = updateItem})
                end
            end
        end
        
        if homeConfig.Games ~= false then
            local games = homeConfig.Games or {}
            local gamesCard = Create("Frame", {BackgroundColor3 = Theme.Card, Size = UDim2.new(0.48,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = columns})
            Corner(gamesCard, 8)
            Padding(gamesCard, 15)
            
            Create("UIListLayout", {Padding = UDim.new(0,8), Parent = gamesCard})
            
            local gamesHeader = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,24), Parent = gamesCard})
            Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0,20,1,0), Font = Enum.Font.GothamBold, Text = "🎮", TextSize = 16, Parent = gamesHeader})
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,28,0,0), Size = UDim2.new(1,-28,1,0), Font = Enum.Font.GothamBold, Text = "Supported Games", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = gamesHeader})
            
            local legend = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,50), Parent = gamesCard})
            Create("UIListLayout", {Padding = UDim.new(0,3), Parent = legend})
            
            local function LegendItem(color, text)
                local item = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,14), Parent = legend})
                local dot = Create("Frame", {BackgroundColor3 = color, Position = UDim2.new(0,0,0.5,0), AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,8,0,8), Parent = item})
                Corner(dot, 4)
                Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,14,0,0), Size = UDim2.new(1,-14,1,0), Font = Enum.Font.Gotham, Text = "→ " .. text, TextSize = 11, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left, Parent = item})
            end
            
            LegendItem(Theme.Success, "Maintained & Updated")
            LegendItem(Theme.Warning, "Has Issues")
            LegendItem(Theme.Error, "Offline / Broken")
            
            for _, game in ipairs(games.List or {}) do
                local gameItem = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Parent = gamesCard})
                local statusColor = game.Status == "working" and Theme.Success or game.Status == "issues" and Theme.Warning or Theme.Error
                local dot = Create("Frame", {BackgroundColor3 = statusColor, Position = UDim2.new(0,0,0.5,0), AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,8,0,8), Parent = gameItem})
                Corner(dot, 4)
                Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,16,0,0), Size = UDim2.new(1,-16,1,0), Font = Enum.Font.Gotham, Text = game.Name, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = gameItem})
                if game.Tag then
                    Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,0,0,0), AnchorPoint = Vector2.new(1,0), Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X, Font = Enum.Font.GothamBold, Text = "[" .. game.Tag .. "]", TextSize = 10, TextColor3 = game.TagColor or Theme.Accent, Parent = gameItem})
                end
            end
        end
        
        if homeConfig.Widgets then
            for _, widget in ipairs(homeConfig.Widgets) do
                local card = Create("Frame", {BackgroundColor3 = Theme.Card, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = homePage})
                Corner(card, 8)
                Padding(card, 15)
                Create("UIListLayout", {Padding = UDim.new(0,8), Parent = card})
                
                if widget.Title then
                    Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Font = Enum.Font.GothamBold, Text = widget.Title, TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = card})
                end
                if widget.Content then
                    Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = widget.Content, TextSize = 12, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = card})
                end
            end
        end
        
        Window.Tabs["Home"] = {Button = homeBtn, Icon = homeIco, Page = homePage}
        Window.CurrentTab = "Home"
        Tween(homeBtn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent}, 0)
        Tween(homeIco, {TextColor3 = Theme.Text}, 0)
        
        homeBtn.MouseButton1Click:Connect(function() SelectTab("Home") end)
    end
    
    if showSplash then
        task.delay(splashDuration, function()
            Tween(Splash, {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 160)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            for _, child in pairs(Splash:GetDescendants()) do
                if child:IsA("TextLabel") then Tween(child, {TextTransparency = 1}, 0.2) end
                if child:IsA("Frame") then Tween(child, {BackgroundTransparency = 1}, 0.2) end
            end
            
            task.wait(0.35)
            Splash:Destroy()
            
            Main.Visible = true
            Main.BackgroundTransparency = 1
            Main.Size = UDim2.new(0, size.X.Offset - 50, 0, size.Y.Offset - 50)
            
            Tween(Main, {BackgroundTransparency = 0, Size = size}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            for _, child in pairs(Main:GetDescendants()) do
                if child:IsA("Frame") and child.BackgroundTransparency < 1 then
                    local orig = child.BackgroundTransparency
                    child.BackgroundTransparency = 1
                    Tween(child, {BackgroundTransparency = orig}, 0.3)
                end
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    local orig = child.TextTransparency or 0
                    child.TextTransparency = 1
                    Tween(child, {TextTransparency = orig}, 0.3)
                end
                if child:IsA("ImageLabel") then
                    local orig = child.ImageTransparency or 0
                    child.ImageTransparency = 1
                    Tween(child, {ImageTransparency = orig}, 0.3)
                end
            end
            
            task.wait(0.5)
            LoadConfig()
            
            if showTutorial and not IsTutorialDone() then
                Window:RunTutorial()
            end
            
            task.spawn(function()
                while Gui and Gui.Parent do
                    task.wait(300)
                    print("[Gatito] Enjoying the menu? Join our Discord: " .. discordLink)
                    Window:DiscordNotify()
                end
            end)
        end)
    else
        task.delay(0.5, function()
            LoadConfig()
            
            if showTutorial and not IsTutorialDone() then
                Window:RunTutorial()
            end
            
            task.spawn(function()
                while Gui and Gui.Parent do
                    task.wait(300)
                    print("[Gatito] Enjoying the menu? Join our Discord: " .. discordLink)
                    Window:DiscordNotify()
                end
            end)
        end)
    end
    
    function Window:RunTutorial()
        if tutorialActive then return end
        tutorialActive = true
        tutorialSkipped = false
        
        local overlay = Create("Frame", {Name = "TutorialOverlay", BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 100, Parent = Gui})
        
        local highlight = Create("Frame", {Name = "Highlight", BackgroundTransparency = 1, ZIndex = 101, Parent = Gui})
        local highlightStroke = Create("UIStroke", {Color = Theme.Accent, Thickness = 3, Parent = highlight})
        Corner(highlight, 10)
        
        local bubble = Create("Frame", {Name = "Bubble", BackgroundColor3 = Theme.Card, Size = UDim2.new(0, 280, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 102, Visible = false, Parent = Gui})
        Corner(bubble, 10)
        Stroke(bubble, Theme.Accent, 2)
        
        local bubbleContent = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = bubble})
        Padding(bubbleContent, 15)
        Create("UIListLayout", {Padding = UDim.new(0,8), Parent = bubbleContent})
        
        local bubbleTitle = Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Font = Enum.Font.GothamBold, Text = "", TextSize = 16, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102, Parent = bubbleContent})
        local bubbleText = Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = "", TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 102, Parent = bubbleContent})
        local bubbleHint = Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,16), Font = Enum.Font.GothamMedium, Text = "👆 Click the highlighted area to continue", TextSize = 11, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102, Parent = bubbleContent})
        
        local skipBtn = Create("TextButton", {BackgroundColor3 = Theme.Error, Position = UDim2.new(1,-70,0,10), Size = UDim2.new(0,60,0,24), Font = Enum.Font.GothamBold, Text = "Skip", TextSize = 11, TextColor3 = Theme.Text, AutoButtonColor = false, ZIndex = 103, Parent = bubble})
        Corner(skipBtn, 6)
        
        local stepIndex = 0
        local stepComplete = false
        local tutorialSteps = {}
        
        table.insert(tutorialSteps, {
            Target = Logo,
            Title = "Drag the Menu",
            Text = tutorialTips.Drag or "Click and drag this icon to move the window around!",
            Position = "right"
        })
        
        local firstTab = nil
        for _, child in pairs(NavScroll:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "Home" then
                firstTab = child
                break
            end
        end
        if firstTab then
            table.insert(tutorialSteps, {
                Target = firstTab,
                Title = "Switch Tabs",
                Text = tutorialTips.Tabs or "Click these icons to switch between different tabs!",
                Position = "right"
            })
        end
        
        if Window.Tabs["Home"] then
            table.insert(tutorialSteps, {
                Target = Window.Tabs["Home"].Button,
                Title = "Home Tab",
                Text = "This is the home tab. Click it to see updates and info!",
                Position = "right"
            })
        end
        
        if tutorialTips.Custom then
            for _, tip in ipairs(tutorialTips.Custom) do
                if tip.Target then
                    table.insert(tutorialSteps, tip)
                end
            end
        end
        
        local function showStep(index)
            if index > #tutorialSteps then
                Tween(overlay, {BackgroundTransparency = 1}, 0.3)
                Tween(bubble, {BackgroundTransparency = 1}, 0.3)
                highlight.Visible = false
                bubble.Visible = false
                task.delay(0.3, function()
                    overlay:Destroy()
                    highlight:Destroy()
                    bubble:Destroy()
                end)
                SetTutorialDone(true)
                tutorialActive = false
                Window:Notify({Title = "Tutorial Complete!", Content = "You're all set! Enjoy the menu.", Duration = 4, Type = "Success"})
                return
            end
            
            local step = tutorialSteps[index]
            local target = step.Target
            
            if not target or not target.Parent then
                showStep(index + 1)
                return
            end
            
            stepComplete = false
            
            bubbleTitle.Text = step.Title or ("Step " .. index)
            bubbleText.Text = step.Text or ""
            
            local targetPos = target.AbsolutePosition
            local targetSize = target.AbsoluteSize
            
            highlight.Position = UDim2.new(0, targetPos.X - 4, 0, targetPos.Y - 4)
            highlight.Size = UDim2.new(0, targetSize.X + 8, 0, targetSize.Y + 8)
            highlight.Visible = true
            
            Tween(highlightStroke, {Color = Theme.Accent}, 0.3)
            task.spawn(function()
                while not stepComplete and highlight and highlight.Parent do
                    Tween(highlightStroke, {Color = Theme.Warning}, 0.5)
                    task.wait(0.5)
                    if stepComplete then break end
                    Tween(highlightStroke, {Color = Theme.Accent}, 0.5)
                    task.wait(0.5)
                end
            end)
            
            local bubbleX, bubbleY
            if step.Position == "right" then
                bubbleX = targetPos.X + targetSize.X + 15
                bubbleY = targetPos.Y
            elseif step.Position == "left" then
                bubbleX = targetPos.X - 295
                bubbleY = targetPos.Y
            elseif step.Position == "bottom" then
                bubbleX = targetPos.X
                bubbleY = targetPos.Y + targetSize.Y + 15
            else
                bubbleX = targetPos.X + targetSize.X + 15
                bubbleY = targetPos.Y
            end
            
            bubble.Position = UDim2.new(0, bubbleX, 0, bubbleY)
            bubble.Visible = true
            bubble.BackgroundTransparency = 1
            Tween(bubble, {BackgroundTransparency = 0}, 0.3)
        end
        
        local function nextStep()
            if stepComplete then return end
            stepComplete = true
            stepIndex = stepIndex + 1
            showStep(stepIndex)
        end
        
        skipBtn.MouseButton1Click:Connect(function()
            tutorialSkipped = true
            stepComplete = true
            Tween(overlay, {BackgroundTransparency = 1}, 0.3)
            Tween(bubble, {BackgroundTransparency = 1}, 0.3)
            highlight.Visible = false
            task.delay(0.3, function()
                if overlay then overlay:Destroy() end
                if highlight then highlight:Destroy() end
                if bubble then bubble:Destroy() end
            end)
            SetTutorialDone(true)
            tutorialActive = false
            Window:Notify({Title = "Skipped", Content = "Tutorial skipped! Restart anytime from settings.", Duration = 3, Type = "Info"})
        end)
        
        overlay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = UserInputService:GetMouseLocation()
                local targetPos = highlight.AbsolutePosition
                local targetSize = highlight.AbsoluteSize
                
                if mouse.X >= targetPos.X and mouse.X <= targetPos.X + targetSize.X and
                   mouse.Y >= targetPos.Y and mouse.Y <= targetPos.Y + targetSize.Y then
                    nextStep()
                end
            end
        end)
        
        for _, step in ipairs(tutorialSteps) do
            if step.Target and step.Target:IsA("GuiButton") then
                step.Target.MouseButton1Click:Connect(function()
                    if tutorialActive and tutorialSteps[stepIndex] and tutorialSteps[stepIndex].Target == step.Target then
                        nextStep()
                    end
                end)
            end
        end
        
        Tween(overlay, {BackgroundTransparency = 0.7}, 0.3)
        stepIndex = 1
        showStep(1)
    end
    
    function Window:ResetTutorial()
        SetTutorialDone(false)
        Window:Notify({Title = "Tutorial Reset", Content = "Tutorial will show on next load, or click Restart Tutorial.", Duration = 3, Type = "Info"})
    end
    
    function Window:DiscordNotify()
        local holder = Gui:FindFirstChild("Notifs") or Create("Frame", {Name = "Notifs", BackgroundTransparency = 1, Position = UDim2.new(1,-20,1,-20), AnchorPoint = Vector2.new(1,1), Size = UDim2.new(0,280,1,-40), Parent = Gui})
        if not holder:FindFirstChild("UIListLayout") then Create("UIListLayout", {VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0,8), Parent = holder}) end
        
        local notif = Create("TextButton", {BackgroundColor3 = Theme.Card, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, AutoButtonColor = false, Text = "", ClipsDescendants = true, Parent = holder})
        Corner(notif, 8)
        Create("Frame", {BackgroundColor3 = Theme.Success, Size = UDim2.new(0,4,1,0), Parent = notif})
        
        local content = Create("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-20,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = notif})
        Padding(content, 10)
        Create("UIListLayout", {Padding = UDim.new(0,4), Parent = content})
        Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,16), Font = Enum.Font.GothamBold, Text = "🐱 Enjoying this menu?", TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = content})
        Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = "Click here to join our Discord!", TextSize = 12, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = content})
        
        local prog = Create("Frame", {BackgroundColor3 = Theme.Success, Position = UDim2.new(0,0,1,-3), Size = UDim2.new(1,0,0,3), Parent = notif})
        
        notif.Position = UDim2.new(1,0,0,0)
        notif.BackgroundTransparency = 1
        Tween(notif, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(prog, {Size = UDim2.new(0,0,0,3)}, 8, Enum.EasingStyle.Linear)
        
        notif.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(discordLink) end
            if request then
                pcall(function() request({Url = "http://127.0.0.1:6463/rpc?v=1", Method = "POST", Headers = {["Content-Type"] = "application/json", Origin = "https://discord.com"}, Body = HttpService:JSONEncode({cmd = "INVITE_BROWSER", args = {code = "UnC2N29mjq"}, nonce = HttpService:GenerateGUID(false)})}) end)
            end
            Window:Notify({Title = "Discord", Content = "Link copied! Opening Discord...", Duration = 3, Type = "Success"})
            Tween(notif, {Position = UDim2.new(1,0,0,0), BackgroundTransparency = 1}, 0.3)
            task.delay(0.35, function() notif:Destroy() end)
        end)
        
        task.delay(8, function()
            if notif and notif.Parent then
                Tween(notif, {Position = UDim2.new(1,0,0,0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.wait(0.35)
                if notif then notif:Destroy() end
            end
        end)
    end
    
    function Window:CreateTab(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Tab"
        local icon = cfg.Icon or "📁"
        
        local btn, ico = CreateNavButton(name, icon, false)
        
        local page = Create("ScrollingFrame", {Name = name, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent, Visible = false, Parent = ContentArea})
        Padding(page, 20)
        
        local layout = Create("UIListLayout", {Padding = UDim.new(0,10), Parent = page})
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 40)
        end)
        
        Window.Tabs[name] = {Button = btn, Icon = ico, Page = page}
        
        if not showHome and Window.CurrentTab == nil then
            Window.CurrentTab = name
            page.Visible = true
            Tween(btn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent}, 0)
            Tween(ico, {TextColor3 = Theme.Text}, 0)
        end
        
        btn.MouseButton1Click:Connect(function() SelectTab(name) end)
        
        local Tab = {}
        
        function Tab:Section(text)
            local sec = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28), Parent = page})
            Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,16), Font = Enum.Font.GothamBold, Text = text:upper(), TextSize = 11, TextColor3 = Theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Left, Parent = sec})
            Create("Frame", {BackgroundColor3 = Theme.Divider, Position = UDim2.new(0,0,1,-1), Size = UDim2.new(1,0,0,1), Parent = sec})
        end
        
        function Tab:Button(cfg)
            cfg = cfg or {}
            local btn = Create("TextButton", {BackgroundColor3 = Theme.Card, Size = UDim2.new(1,0,0,42), Text = "", AutoButtonColor = false, Parent = page})
            Corner(btn, 8)
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-50,1,0), Font = Enum.Font.GothamMedium, Text = cfg.Name or "Button", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn})
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-35,0,0), Size = UDim2.new(0,20,1,0), Font = Enum.Font.GothamBold, Text = "→", TextSize = 16, TextColor3 = Theme.Accent, Parent = btn})
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Theme.Card}, 0.15) end)
            btn.MouseButton1Click:Connect(cfg.Callback or function() end)
        end
        
        function Tab:Toggle(cfg)
            cfg = cfg or {}
            local flag = cfg.Flag
            local enabled = cfg.Default or false
            local btn = Create("TextButton", {BackgroundColor3 = Theme.Card, Size = UDim2.new(1,0,0,42), Text = "", AutoButtonColor = false, Parent = page})
            Corner(btn, 8)
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-70,1,0), Font = Enum.Font.GothamMedium, Text = cfg.Name or "Toggle", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn})
            
            local switch = Create("Frame", {BackgroundColor3 = enabled and Theme.Accent or Theme.Divider, Position = UDim2.new(1,-55,0.5,0), AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,44,0,24), Parent = btn})
            Corner(switch, 12)
            local circle = Create("Frame", {BackgroundColor3 = Theme.Text, Position = enabled and UDim2.new(1,-22,0.5,0) or UDim2.new(0,4,0.5,0), AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,18,0,18), Parent = switch})
            Corner(circle, 9)
            
            local function update(skipCallback)
                Tween(switch, {BackgroundColor3 = enabled and Theme.Accent or Theme.Divider}, 0.2)
                Tween(circle, {Position = enabled and UDim2.new(1,-22,0.5,0) or UDim2.new(0,4,0.5,0)}, 0.2)
                if not skipCallback and cfg.Callback then cfg.Callback(enabled) end
                if autoSave and flag then SaveConfig() end
            end
            
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Theme.Card}, 0.15) end)
            btn.MouseButton1Click:Connect(function()
                enabled = not enabled
                update()
            end)
            
            local obj = {
                Set = function(_, v, skipCallback) enabled = v update(skipCallback) end,
                Get = function() return enabled end
            }
            
            if flag then Flags[flag] = obj end
            return obj
        end
        
        function Tab:Slider(cfg)
            cfg = cfg or {}
            local flag = cfg.Flag
            local min, max, val = cfg.Min or 0, cfg.Max or 100, cfg.Default or cfg.Min or 0
            local inc = cfg.Increment or 1
            local sliderDragging = false
            
            local frame = Create("Frame", {BackgroundColor3 = Theme.Card, Size = UDim2.new(1,0,0,55), Parent = page})
            Corner(frame, 8)
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,8), Size = UDim2.new(0.6,0,0,18), Font = Enum.Font.GothamMedium, Text = cfg.Name or "Slider", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
            local valLabel = Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-55,0,8), Size = UDim2.new(0,40,0,18), Font = Enum.Font.GothamBold, Text = tostring(val), TextSize = 14, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, Parent = frame})
            
            local bar = Create("TextButton", {BackgroundColor3 = Theme.Divider, Position = UDim2.new(0,15,0,38), Size = UDim2.new(1,-30,0,8), Text = "", AutoButtonColor = false, Parent = frame})
            Corner(bar, 4)
            local fill = Create("Frame", {BackgroundColor3 = Theme.Accent, Size = UDim2.new((val-min)/(max-min),0,1,0), Parent = bar})
            Corner(fill, 4)
            local knob = Create("Frame", {BackgroundColor3 = Theme.Text, Position = UDim2.new((val-min)/(max-min),0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), Size = UDim2.new(0,16,0,16), ZIndex = 5, Parent = bar})
            Corner(knob, 8)
            
            local function updateVisual()
                valLabel.Text = tostring(inc >= 1 and math.floor(val) or val)
                fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
                knob.Position = UDim2.new((val-min)/(max-min),0,0.5,0)
            end
            
            bar.InputBegan:Connect(function(i) 
                if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                    sliderDragging = true
                    local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    val = math.floor((min + (max-min)*p)/inc+0.5)*inc
                    val = math.clamp(val, min, max)
                    updateVisual()
                    if cfg.Callback then cfg.Callback(val) end
                end 
            end)
            
            bar.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliderDragging = false
                    if autoSave and flag then SaveConfig() end
                end
            end)
            
            UserInputService.InputChanged:Connect(function(i)
                if sliderDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    val = math.floor((min + (max-min)*p)/inc+0.5)*inc
                    val = math.clamp(val, min, max)
                    updateVisual()
                    if cfg.Callback then cfg.Callback(val) end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 and sliderDragging then
                    sliderDragging = false
                    if autoSave and flag then SaveConfig() end
                end
            end)
            
            local obj = {
                Set = function(_,v, skipCallback)
                    val = math.clamp(v,min,max)
                    updateVisual()
                    if not skipCallback and cfg.Callback then cfg.Callback(val) end
                end,
                Get = function() return val end
            }
            
            if flag then Flags[flag] = obj end
            return obj
        end
        
        function Tab:Dropdown(cfg)
            cfg = cfg or {}
            local flag = cfg.Flag
            local opts = cfg.Options or {}
            local selected = cfg.Default or opts[1] or ""
            local open = false
            
            local frame = Create("Frame", {BackgroundColor3 = Theme.Card, Size = UDim2.new(1,0,0,70), ClipsDescendants = true, Parent = page})
            Corner(frame, 8)
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,10), Size = UDim2.new(1,-30,0,18), Font = Enum.Font.GothamMedium, Text = cfg.Name or "Dropdown", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
            
            local selBtn = Create("TextButton", {BackgroundColor3 = Theme.Divider, Position = UDim2.new(0,15,0,35), Size = UDim2.new(1,-30,0,28), Text = "", AutoButtonColor = false, Parent = frame})
            Corner(selBtn, 6)
            local selText = Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-35,1,0), Font = Enum.Font.Gotham, Text = selected, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = selBtn})
            local arrow = Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-22,0,0), Size = UDim2.new(0,12,1,0), Font = Enum.Font.GothamBold, Text = "▼", TextSize = 10, TextColor3 = Theme.TextDim, Parent = selBtn})
            
            local optFrame = Create("Frame", {BackgroundColor3 = Theme.Divider, Position = UDim2.new(0,15,0,68), Size = UDim2.new(1,-30,0,#opts*28+8), Parent = frame})
            Corner(optFrame, 6)
            Padding(optFrame, 4)
            Create("UIListLayout", {Padding = UDim.new(0,2), Parent = optFrame})
            
            for _, opt in ipairs(opts) do
                local optBtn = Create("TextButton", {BackgroundColor3 = Theme.Card, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,26), Text = "", AutoButtonColor = false, Parent = optFrame})
                Corner(optBtn, 4)
                Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,8,0,0), Size = UDim2.new(1,-16,1,0), Font = Enum.Font.Gotham, Text = opt, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = optBtn})
                optBtn.MouseEnter:Connect(function() Tween(optBtn, {BackgroundTransparency = 0}, 0.1) end)
                optBtn.MouseLeave:Connect(function() Tween(optBtn, {BackgroundTransparency = 1}, 0.1) end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selText.Text = opt
                    open = false
                    Tween(frame, {Size = UDim2.new(1,0,0,70)}, 0.2)
                    Tween(arrow, {Rotation = 0}, 0.2)
                    if cfg.Callback then cfg.Callback(opt) end
                    if autoSave and flag then SaveConfig() end
                end)
            end
            
            selBtn.MouseButton1Click:Connect(function()
                open = not open
                Tween(frame, {Size = UDim2.new(1,0,0,open and (78+#opts*28+8) or 70)}, 0.2)
                Tween(arrow, {Rotation = open and 180 or 0}, 0.2)
            end)
            
            local obj = {
                Set = function(_,v, skipCallback)
                    selected = v
                    selText.Text = v
                    if not skipCallback and cfg.Callback then cfg.Callback(v) end
                end,
                Get = function() return selected end
            }
            
            if flag then Flags[flag] = obj end
            return obj
        end
        
        function Tab:Textbox(cfg)
            cfg = cfg or {}
            local flag = cfg.Flag
            local frame = Create("Frame", {BackgroundColor3 = Theme.Card, Size = UDim2.new(1,0,0,70), Parent = page})
            Corner(frame, 8)
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,10), Size = UDim2.new(1,-30,0,18), Font = Enum.Font.GothamMedium, Text = cfg.Name or "Textbox", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
            
            local inputFrame = Create("Frame", {BackgroundColor3 = Theme.Divider, Position = UDim2.new(0,15,0,35), Size = UDim2.new(1,-30,0,28), Parent = frame})
            Corner(inputFrame, 6)
            local input = Create("TextBox", {BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-20,1,0), Font = Enum.Font.Gotham, PlaceholderText = cfg.Placeholder or "", PlaceholderColor3 = Theme.TextMuted, Text = cfg.Default or "", TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = inputFrame})
            
            input.FocusLost:Connect(function(enter)
                if enter and cfg.Callback then cfg.Callback(input.Text) end
                if autoSave and flag then SaveConfig() end
            end)
            
            local obj = {
                Set = function(_,t) input.Text = t end,
                Get = function() return input.Text end
            }
            
            if flag then Flags[flag] = obj end
            return obj
        end
        
        function Tab:Keybind(cfg)
            cfg = cfg or {}
            local flag = cfg.Flag
            local key = cfg.Default or Enum.KeyCode.Unknown
            local listening = false
            
            local frame = Create("Frame", {BackgroundColor3 = Theme.Card, Size = UDim2.new(1,0,0,42), Parent = page})
            Corner(frame, 8)
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-100,1,0), Font = Enum.Font.GothamMedium, Text = cfg.Name or "Keybind", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
            
            local keyBtn = Create("TextButton", {BackgroundColor3 = Theme.Divider, Position = UDim2.new(1,-85,0.5,0), AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,70,0,26), Font = Enum.Font.GothamBold, Text = key.Name or "None", TextSize = 11, TextColor3 = Theme.Accent, AutoButtonColor = false, Parent = frame})
            Corner(keyBtn, 6)
            
            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
                Tween(keyBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Background}, 0.15)
            end)
            
            UserInputService.InputBegan:Connect(function(i, gpe)
                if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                    key = i.KeyCode
                    keyBtn.Text = key.Name
                    listening = false
                    Tween(keyBtn, {BackgroundColor3 = Theme.Divider, TextColor3 = Theme.Accent}, 0.15)
                    if autoSave and flag then SaveConfig() end
                elseif not gpe and i.KeyCode == key and cfg.Callback then
                    cfg.Callback()
                end
            end)
            
            local obj = {
                Set = function(_,k) key = k keyBtn.Text = key.Name end,
                Get = function() return key end
            }
            
            if flag then Flags[flag] = obj end
            return obj
        end
        
        function Tab:Label(text)
            Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,24), Font = Enum.Font.Gotham, Text = text, TextSize = 13, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left, Parent = page})
        end
        
        function Tab:SaveButton(cfg)
            cfg = cfg or {}
            local btn = Create("TextButton", {BackgroundColor3 = Theme.Success, Size = UDim2.new(1,0,0,42), Text = "", AutoButtonColor = false, Parent = page})
            Corner(btn, 8)
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-50,1,0), Font = Enum.Font.GothamMedium, Text = cfg.Name or "Save Config", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn})
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-35,0,0), Size = UDim2.new(0,20,1,0), Font = Enum.Font.GothamBold, Text = "💾", TextSize = 16, Parent = btn})
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(100, 220, 140)}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Theme.Success}, 0.15) end)
            btn.MouseButton1Click:Connect(function()
                SaveConfig()
                Window:Notify({Title = "Config Saved", Content = "Your settings have been saved.", Duration = 3, Type = "Success"})
            end)
        end
        
        function Tab:LoadButton(cfg)
            cfg = cfg or {}
            local btn = Create("TextButton", {BackgroundColor3 = Theme.Accent, Size = UDim2.new(1,0,0,42), Text = "", AutoButtonColor = false, Parent = page})
            Corner(btn, 8)
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-50,1,0), Font = Enum.Font.GothamMedium, Text = cfg.Name or "Load Config", TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn})
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-35,0,0), Size = UDim2.new(0,20,1,0), Font = Enum.Font.GothamBold, Text = "📂", TextSize = 16, Parent = btn})
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Theme.AccentDark}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Theme.Accent}, 0.15) end)
            btn.MouseButton1Click:Connect(function()
                if LoadConfig() then
                    Window:Notify({Title = "Config Loaded", Content = "Your settings have been loaded.", Duration = 3, Type = "Success"})
                else
                    Window:Notify({Title = "No Config", Content = "No saved config found.", Duration = 3, Type = "Warning"})
                end
            end)
        end
        
        function Tab:TutorialButton(cfg)
            cfg = cfg or {}
            local btn = Create("TextButton", {BackgroundColor3 = Theme.Warning, Size = UDim2.new(1,0,0,42), Text = "", AutoButtonColor = false, Parent = page})
            Corner(btn, 8)
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-50,1,0), Font = Enum.Font.GothamMedium, Text = cfg.Name or "Restart Tutorial", TextSize = 14, TextColor3 = Theme.Background, TextXAlignment = Enum.TextXAlignment.Left, Parent = btn})
            Create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-35,0,0), Size = UDim2.new(0,20,1,0), Font = Enum.Font.GothamBold, Text = "📖", TextSize = 16, Parent = btn})
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(240, 200, 70)}, 0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Theme.Warning}, 0.15) end)
            btn.MouseButton1Click:Connect(function()
                Window:ResetTutorial()
                Window:RunTutorial()
            end)
        end
        
        return Tab
    end
    
    function Window:SaveConfig()
        SaveConfig()
    end
    
    function Window:LoadConfig()
        return LoadConfig()
    end
    
    function Window:Notify(cfg)
        cfg = cfg or {}
        local color = cfg.Type == "Success" and Theme.Success or cfg.Type == "Warning" and Theme.Warning or cfg.Type == "Error" and Theme.Error or Theme.Accent
        local onClick = cfg.OnClick
        
        local holder = Gui:FindFirstChild("Notifs") or Create("Frame", {Name = "Notifs", BackgroundTransparency = 1, Position = UDim2.new(1,-20,1,-20), AnchorPoint = Vector2.new(1,1), Size = UDim2.new(0,280,1,-40), Parent = Gui})
        if not holder:FindFirstChild("UIListLayout") then Create("UIListLayout", {VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0,8), Parent = holder}) end
        
        local notif = Create("TextButton", {BackgroundColor3 = Theme.Card, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true, Text = "", AutoButtonColor = false, Parent = holder})
        Corner(notif, 8)
        Create("Frame", {BackgroundColor3 = color, Size = UDim2.new(0,4,1,0), Parent = notif})
        
        local content = Create("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-20,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = notif})
        Padding(content, 10)
        Create("UIListLayout", {Padding = UDim.new(0,4), Parent = content})
        Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,16), Font = Enum.Font.GothamBold, Text = "🐱 " .. (cfg.Title or "Notice"), TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = content})
        if cfg.Content then Create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, Text = cfg.Content, TextSize = 12, TextColor3 = Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = content}) end
        
        local prog = Create("Frame", {BackgroundColor3 = color, Position = UDim2.new(0,0,1,-3), Size = UDim2.new(1,0,0,3), Parent = notif})
        
        notif.Position = UDim2.new(1,0,0,0)
        notif.BackgroundTransparency = 1
        Tween(notif, {Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(prog, {Size = UDim2.new(0,0,0,3)}, cfg.Duration or 5, Enum.EasingStyle.Linear)
        
        notif.MouseButton1Click:Connect(function()
            if onClick then onClick() end
            Tween(notif, {Position = UDim2.new(1,0,0,0), BackgroundTransparency = 1}, 0.3)
            task.delay(0.35, function() if notif then notif:Destroy() end end)
        end)
        
        task.delay(cfg.Duration or 5, function()
            if notif and notif.Parent then
                Tween(notif, {Position = UDim2.new(1,0,0,0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.wait(0.35)
                if notif then notif:Destroy() end
            end
        end)
    end
    
    function Window:Toggle(v)
        if v == nil then v = not Main.Visible end
        
        if v then
            Main.Visible = true
            Main.Size = UDim2.new(0, size.X.Offset - 30, 0, size.Y.Offset - 30)
            Main.BackgroundTransparency = 0.5
            Tween(Main, {Size = size, BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            Tween(Main, {Size = UDim2.new(0, size.X.Offset - 30, 0, size.Y.Offset - 30), BackgroundTransparency = 0.5}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.delay(0.25, function()
                Main.Visible = false
            end)
        end
    end
    
    function Window:Destroy()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.35, function()
            Gui:Destroy()
        end)
    end
    
    return Window
end

return Gatito
