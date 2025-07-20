-- GameSenseUI | A Roblox UI Library
-- Inspired by the CS:GO "GameSense" cheat UI aesthetic.

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- //////////////////////////////
-- /// CONFIGURATION
-- //////////////////////////////
local Config = {
    Title = "GameSense",
    ToggleKey = Enum.KeyCode.RightShift,

    Colors = {
        Accent = Color3.fromRGB(0, 120, 255),
        AccentText = Color3.fromRGB(255, 255, 255),
        
        Background = Color3.fromRGB(20, 20, 20),
        Content = Color3.fromRGB(30, 30, 30),
        Header = Color3.fromRGB(25, 25, 25),
        
        Text = Color3.fromRGB(220, 220, 220),
        TextMuted = Color3.fromRGB(150, 150, 150),

        Control = Color3.fromRGB(45, 45, 45),
        ControlHover = Color3.fromRGB(55, 55, 55),
    },

    Fonts = {
        Main = Enum.Font.SourceSans,
    },

    Sizes = {
        Window = Vector2.new(550, 400),
        TabButton = UDim2.new(1, 0, 0, 35),
        ControlHeight = 25,
        Padding = 10,
    }
}


-- Internal State
local State = {
    Visible = true,
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
    ActiveTab = nil,
    Tabs = {},
    Pages = {}
}

-- //////////////////////////////
-- /// CORE UI CREATION
-- //////////////////////////////

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameSenseUIRoot"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Main Window Frame
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.fromOffset(Config.Sizes.Window.X, Config.Sizes.Window.Y)
Window.Position = UDim2.new(0.5, -Config.Sizes.Window.X / 2, 0.5, -Config.Sizes.Window.Y / 2)
Window.BackgroundColor3 = Config.Colors.Background
Window.BorderSizePixel = 0
Window.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 5)
WindowCorner.Parent = Window

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Config.Colors.Header
Header.BorderSizePixel = 0
Header.Parent = Window

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Name = "Title"
HeaderTitle.Size = UDim2.new(1, -2 * Config.Sizes.Padding, 1, 0)
HeaderTitle.Position = UDim2.fromOffset(Config.Sizes.Padding, 0)
HeaderTitle.BackgroundColor3 = Config.Colors.Header
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Font = Config.Fonts.Main
HeaderTitle.Text = Config.Title
HeaderTitle.TextColor3 = Config.Colors.Text
HeaderTitle.TextSize = 16
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

-- Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -Header.AbsoluteSize.Y)
Content.Position = UDim2.fromOffset(0, Header.AbsoluteSize.Y)
Content.BackgroundColor3 = Config.Colors.Content
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.Parent = Window

-- Tab Container (Left Side)
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 120, 1, 0)
TabContainer.BackgroundColor3 = Config.Colors.Content
TabContainer.BorderSizePixel = 0
TabContainer.Parent = Content

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Vertical
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = TabContainer

-- Page Container (Right Side)
local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -TabContainer.AbsoluteSize.X - Config.Sizes.Padding, 1, 0)
PageContainer.Position = UDim2.fromOffset(TabContainer.AbsoluteSize.X, 0)
PageContainer.BackgroundColor3 = Config.Colors.Content
PageContainer.BorderSizePixel = 0
PageContainer.ClipsDescendants = true
PageContainer.Parent = Content

-- //////////////////////////////
-- /// UTILITY FUNCTIONS
-- //////////////////////////////

local function Create(instanceType, properties)
    local inst = Instance.new(instanceType)
    for prop, value in pairs(properties) do
        inst[prop] = value
    end
    return inst
end

local function SetActiveTab(tabButton, page)
    -- Deactivate old tab
    if State.ActiveTab and State.ActiveTab.Button and State.ActiveTab.Button:IsA("TextButton") then
        TweenService:Create(State.ActiveTab.Button, TweenInfo.new(0.2), { BackgroundColor3 = Config.Colors.Content }):Play()
        TweenService:Create(State.ActiveTab.Button, TweenInfo.new(0.2), { TextColor3 = Config.Colors.TextMuted }):Play()
        State.ActiveTab.Page.Visible = false
    end
    
    -- Activate new tab
    TweenService:Create(tabButton, TweenInfo.new(0.2), { BackgroundColor3 = Config.Colors.Accent }):Play()
    TweenService:Create(tabButton, TweenInfo.new(0.2), { TextColor3 = Config.Colors.AccentText }):Play()
    page.Visible = true

    State.ActiveTab = { Button = tabButton, Page = page }
end

-- //////////////////////////////
-- /// API METHODS
-- //////////////////////////////

function Library:SetTitle(title)
    Config.Title = title
    HeaderTitle.Text = title
end

function Library:CreateTab(tabName)
    local tabObject = {}
    
    -- Create the page (a scrolling frame for content)
    local Page = Create("ScrollingFrame", {
        Name = tabName .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.fromOffset(Config.Sizes.Padding, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        Parent = PageContainer,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarImageColor3 = Config.Colors.Accent,
        ScrollBarThickness = 4,
    })

    local PageListLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, Config.Sizes.Padding),
        Parent = Page
    })

    -- Create the tab button
    local TabButton = Create("TextButton", {
        Name = tabName,
        Text = tabName,
        Size = Config.Sizes.TabButton,
        BackgroundColor3 = Config.Colors.Content,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Config.Fonts.Main,
        TextColor3 = Config.Colors.TextMuted,
        TextSize = 14,
        Parent = TabContainer,
    })

    -- Manage active tab state
    table.insert(State.Tabs, TabButton)
    table.insert(State.Pages, Page)
    if not State.ActiveTab then
        SetActiveTab(TabButton, Page)
    end

    TabButton.MouseButton1Click:Connect(function()
        SetActiveTab(TabButton, Page)
    end)
    
    -- Automatic scrolling canvas size
    PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(0, PageListLayout.AbsoluteContentSize.Y)
    end)
    
    -- Methods for the returned tab object
    
    function tabObject:CreateLabel(text)
        Create("TextLabel", {
            Text = text,
            Font = Config.Fonts.Main,
            TextColor3 = Config.Colors.Text,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Parent = Page,
        })
    end
    
    function tabObject:CreateCheckbox(text, callback)
        local toggled = false
        callback = callback or function() end
        
        local Container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, Config.Sizes.ControlHeight),
            BackgroundTransparency = 1,
            Parent = Page,
        })
        
        local Label = Create("TextLabel", {
            Text = text,
            Font = Config.Fonts.Main,
            TextColor3 = Config.Colors.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -30, 1, 0),
            BackgroundTransparency = 1,
            Parent = Container,
        })
        
        local Box = Create("TextButton", {
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(1, -20, 0.5, -10),
            BackgroundColor3 = Config.Colors.Control,
            Text = "",
            AutoButtonColor = false,
            Parent = Container,
        })
        
        local BoxCorner = Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Box })
        local Fill = Create("Frame", {
            Size = UDim2.fromOffset(12, 12),
            Position = UDim2.new(0.5, -6, 0.5, -6),
            BackgroundColor3 = Config.Colors.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = Box,
        })
        local FillCorner = Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = Fill })

        Box.MouseButton1Click:Connect(function()
            toggled = not toggled
            Fill.Visible = toggled
            pcall(callback, toggled)
        end)
    end
    
    function tabObject:CreateSlider(text, min, max, default, callback)
        callback = callback or function() end
        local value = default or min
        
        local Container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, Config.Sizes.ControlHeight + 15),
            BackgroundTransparency = 1,
            Parent = Page,
        })
        
        local Label = Create("TextLabel", {
            Text = text,
            Font = Config.Fonts.Main,
            TextColor3 = Config.Colors.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.5, 0, 0, 20),
            BackgroundTransparency = 1,
            Parent = Container,
        })
        
        local ValueLabel = Create("TextLabel", {
            Text = tostring(math.floor(value)),
            Font = Config.Fonts.Main,
            TextColor3 = Config.Colors.TextMuted,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.5, 0, 0, 20),
            BackgroundTransparency = 1,
            Parent = Container,
        })
        
        local Track = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0, 20),
            BackgroundColor3 = Config.Colors.Control,
            BorderSizePixel = 0,
            Parent = Container,
        })
        local TrackCorner = Create("UICorner", { Parent = Track })
        
        local Fill = Create("Frame", {
            Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = Config.Colors.Accent,
            BorderSizePixel = 0,
            Parent = Track,
        })
        local FillCorner = Create("UICorner", { Parent = Fill })
        
        local dragging = false
        local function updateSlider(input)
            local pos = input.Position.X
            local start = Track.AbsolutePosition.X
            local width = Track.AbsoluteSize.X
            local alpha = math.clamp((pos - start) / width, 0, 1)
            
            value = min + (max - min) * alpha
            Fill.Size = UDim2.new(alpha, 0, 1, 0)
            ValueLabel.Text = tostring(math.floor(value))
            pcall(callback, value)
        end

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
    
    function tabObject:CreateDropdown(text, options, callback)
        callback = callback or function() end
        local isOpen = false
        
        local Container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, Config.Sizes.ControlHeight),
            BackgroundTransparency = 1,
            Parent = Page,
            ZIndex = 2
        })
        
        local Label = Create("TextLabel", {
            Text = text,
            Font = Config.Fonts.Main, TextColor3 = Config.Colors.Text, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(0.4, 0, 1, 0), BackgroundTransparency = 1, Parent = Container
        })
        
        local DropdownButton = Create("TextButton", {
            Text = options[1] or "Select...",
            Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0.4, 0, 0, 0),
            BackgroundColor3 = Config.Colors.Control, Font = Config.Fonts.Main,
            TextColor3 = Config.Colors.Text, TextSize = 14, AutoButtonColor = false,
            Parent = Container, ZIndex = 3
        })
        local DdCorner = Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = DropdownButton })
        
        local OptionsList = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 1, 5),
            BackgroundColor3 = Config.Colors.Control, BorderSizePixel = 0,
            ClipsDescendants = true, Visible = false, Parent = DropdownButton, ZIndex = 4
        })
        local OptCorner = Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = OptionsList })
        local OptListLayout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = OptionsList
        })
        
        for i, optionText in ipairs(options) do
            local OptionButton = Create("TextButton", {
                Text = optionText, Size = UDim2.new(1, 0, 0, Config.Sizes.ControlHeight),
                BackgroundColor3 = Config.Colors.Control, BorderSizePixel = 0,
                Font = Config.Fonts.Main, TextColor3 = Config.Colors.Text,
                TextSize = 14, AutoButtonColor = false, Parent = OptionsList,
                ZIndex = 5
            })
            
            OptionButton.MouseEnter:Connect(function()
                TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Config.Colors.ControlHover}):Play()
            end)
            OptionButton.MouseLeave:Connect(function()
                TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Config.Colors.Control}):Play()
            end)
            OptionButton.MouseButton1Click:Connect(function()
                DropdownButton.Text = optionText
                isOpen = false
                OptionsList.Visible = false
                Container.Size = UDim2.new(1, 0, 0, Config.Sizes.ControlHeight)
                PageListLayout.Parent = Page -- force relayout
                pcall(callback, optionText)
            end)
        end
        
        DropdownButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            OptionsList.Visible = isOpen
            if isOpen then
                local totalHeight = #options * Config.Sizes.ControlHeight
                OptionsList:TweenSize(UDim2.new(1, 0, 0, totalHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                Container.Size = UDim2.new(1, 0, 0, Config.Sizes.ControlHeight + totalHeight + 5)
            else
                OptionsList:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true, function()
                    Container.Size = UDim2.new(1, 0, 0, Config.Sizes.ControlHeight)
                end)
            end
             PageListLayout.Parent = Page -- force relayout
        end)
    end
    
    return tabObject
end


-- //////////////////////////////
-- /// INPUT & TOGGLE HANDLING
-- //////////////////////////////

-- Window Dragging
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.Dragging = true
        State.DragStart = input.Position
        State.StartPos = Window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                State.Dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and State.Dragging then
        local delta = input.Position - State.DragStart
        Window.Position = UDim2.new(State.StartPos.X.Scale, State.StartPos.X.Offset + delta.X, State.StartPos.Y.Scale, State.StartPos.Y.Offset + delta.Y)
    end
end)

-- Toggle Visibility
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Config.ToggleKey then
        State.Visible = not State.Visible
        ScreenGui.Enabled = State.Visible
    end
end)

return Library
