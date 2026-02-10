--[[
    SKEET.CC LIBRARY V2 - FIXED VERSION
    Complete UI Library for Roblox
    No loading issues, fully self-contained
]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Create library table
local SkeetLib = {}
SkeetLib.__index = SkeetLib

-- Configuration
SkeetLib.Config = {
    RainbowSpeed = 0.005,
    AnimationSpeed = 0.2,
    AccentColor = Color3.fromRGB(163, 200, 5),
    BackgroundColor = Color3.fromRGB(20, 20, 20),
    InnerBgColor = Color3.fromRGB(30, 30, 30),
    TextColor = Color3.fromRGB(220, 220, 220),
    BorderColor = Color3.fromRGB(60, 60, 60),
    Font = Enum.Font.Code
}

-- Utility: Make Draggable
function SkeetLib:MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Utility: Create Rainbow Gradient
function SkeetLib:CreateRainbowGradient()
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 255))
    })
    return gradient
end

-- Utility: Animate Rainbow
function SkeetLib:AnimateRainbow(gradient)
    task.spawn(function()
        while gradient and gradient.Parent do
            for i = 0, 1, self.Config.RainbowSpeed do
                if not gradient or not gradient.Parent then break end
                gradient.Offset = Vector2.new(i - 0.5, 0)
                task.wait(0.01)
            end
        end
    end)
end

-- Main: Create Window
function SkeetLib:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Skeet.cc"
    local Size = config.Size or UDim2.new(0, 600, 0, 400)
    
    -- Cleanup
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "SkeetUI_" .. Title then
            v:Destroy()
        end
    end
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkeetUI_" .. Title
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainWindow"
    MainFrame.Size = Size
    MainFrame.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    MainFrame.BackgroundColor3 = self.Config.BackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Borders
    local OuterStroke = Instance.new("UIStroke")
    OuterStroke.Thickness = 1
    OuterStroke.Color = Color3.fromRGB(0, 0, 0)
    OuterStroke.Parent = MainFrame
    
    local MiddleStroke = Instance.new("UIStroke")
    MiddleStroke.Thickness = 1
    MiddleStroke.Color = self.Config.BorderColor
    MiddleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MiddleStroke.Parent = MainFrame
    
    -- Rainbow Bar
    local GradientBar = Instance.new("Frame")
    GradientBar.Size = UDim2.new(1, 0, 0, 2)
    GradientBar.Position = UDim2.new(0, 0, 0, 0)
    GradientBar.BorderSizePixel = 0
    GradientBar.ZIndex = 10
    GradientBar.Parent = MainFrame
    
    local RainbowGrad = self:CreateRainbowGradient()
    RainbowGrad.Parent = GradientBar
    self:AnimateRainbow(RainbowGrad)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.Position = UDim2.new(0, 0, 0, 2)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = self.Config.Font
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextStrokeTransparency = 0
    TitleLabel.Parent = Header
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 140, 1, -32)
    TabContainer.Position = UDim2.new(0, 0, 0, 32)
    TabContainer.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = Color3.fromRGB(12, 12, 12)
    TabStroke.Thickness = 1
    TabStroke.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -140, 1, -32)
    ContentContainer.Position = UDim2.new(0, 140, 0, 32)
    ContentContainer.BackgroundColor3 = self.Config.InnerBgColor
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    local ContentStroke = Instance.new("UIStroke")
    ContentStroke.Color = Color3.fromRGB(12, 12, 12)
    ContentStroke.Thickness = 1
    ContentStroke.Parent = ContentContainer
    
    -- Make Draggable
    self:MakeDraggable(MainFrame, Header)
    
    -- Tab Function
    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName = tabConfig.Name or "Tab"
        
        local Tab = {}
        Tab.Sections = {}
        Tab.Active = false
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        TabButton.BorderSizePixel = 0
        TabButton.Font = SkeetLib.Config.Font
        TabButton.Text = "  " .. TabName
        TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabContainer
        
        local TabButtonStroke = Instance.new("UIStroke")
        TabButtonStroke.Color = Color3.fromRGB(40, 40, 40)
        TabButtonStroke.Thickness = 1
        TabButtonStroke.Transparency = 0.5
        TabButtonStroke.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = TabName .. "_Content"
        TabContent.Size = UDim2.new(1, -10, 1, -10)
        TabContent.Position = UDim2.new(0, 5, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = SkeetLib.Config.AccentColor
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 8)
        TabLayout.Parent = TabContent
        
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab Switching
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.CurrentTab = Tab
        end)
        
        -- Hover
        TabButton.MouseEnter:Connect(function()
            if not Tab.Active then
                TweenService:Create(TabButton, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                }):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not Tab.Active then
                TweenService:Create(TabButton, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                }):Play()
            end
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        table.insert(Window.Tabs, Tab)
        
        -- Auto-select first
        if #Window.Tabs == 1 then
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Tab.Active = true
            Window.CurrentTab = Tab
        end
        
        -- Section Function
        function Tab:Section(sectionConfig)
            sectionConfig = sectionConfig or {}
            local SectionName = sectionConfig.Name or "Section"
            
            local Section = {}
            Section.Elements = {}
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = SectionName
            SectionFrame.Size = UDim2.new(1, -10, 0, 25)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SectionFrame.BorderSizePixel = 0
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = TabContent
            
            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = Color3.fromRGB(45, 45, 45)
            SectionStroke.Thickness = 1
            SectionStroke.Parent = SectionFrame
            
            local SectionHeader = Instance.new("TextLabel")
            SectionHeader.Size = UDim2.new(1, 0, 0, 20)
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Font = SkeetLib.Config.Font
            SectionHeader.Text = SectionName
            SectionHeader.TextColor3 = SkeetLib.Config.AccentColor
            SectionHeader.TextSize = 12
            SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
            SectionHeader.TextStrokeTransparency = 0.5
            SectionHeader.Parent = SectionFrame
            
            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingLeft = UDim.new(0, 8)
            SectionPadding.PaddingTop = UDim.new(0, 2)
            SectionPadding.Parent = SectionHeader
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.Position = UDim2.new(0, 0, 0, 22)
            SectionContent.BackgroundTransparency = 1
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.Parent = SectionFrame
            
            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 4)
            ContentLayout.Parent = SectionContent
            
            local ContentPadding = Instance.new("UIPadding")
            ContentPadding.PaddingLeft = UDim.new(0, 8)
            ContentPadding.PaddingRight = UDim.new(0, 8)
            ContentPadding.PaddingBottom = UDim.new(0, 6)
            ContentPadding.Parent = SectionContent
            
            -- BUTTON
            function Section:Button(config)
                config = config or {}
                local Name = config.Name or "Button"
                local Callback = config.Callback or function() end
                
                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Size = UDim2.new(1, 0, 0, 22)
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Font = SkeetLib.Config.Font
                ButtonFrame.Text = Name
                ButtonFrame.TextColor3 = SkeetLib.Config.TextColor
                ButtonFrame.TextSize = 12
                ButtonFrame.Parent = SectionContent
                
                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(50, 50, 50)
                BtnStroke.Thickness = 1
                BtnStroke.Parent = ButtonFrame
                
                ButtonFrame.MouseEnter:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    }):Play()
                    TweenService:Create(BtnStroke, TweenInfo.new(0.15), {
                        Color = SkeetLib.Config.AccentColor
                    }):Play()
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                    }):Play()
                    TweenService:Create(BtnStroke, TweenInfo.new(0.15), {
                        Color = Color3.fromRGB(50, 50, 50)
                    }):Play()
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    pcall(Callback)
                end)
            end
            
            table.insert(Tab.Sections, Section)
            return Section
        end
        
        return Tab
    end
    
    -- Intro Animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.BackgroundTransparency = 1
    
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = Size,
        BackgroundTransparency = 0
    }):Play()
    
    return Window
end

-- Return the library
return SkeetLib
