--[[
    SKEET.CC KEY SYSTEM V2
    Enhanced Authentication System
    API: https://keyvsys.netlify.app/
    Style: Gamesense / Skeet.cc
]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- // CONFIGURATION // --
local CONFIG = {
    Title = "SKEET.CC",
    Subtitle = "Key Authentication System",
    AccentColor = Color3.fromRGB(163, 200, 5),
    KeyEndpoint = "https://keyvsys.netlify.app/.netlify/functions/check-key?key=",
    GetKeyURL = "https://keyvsys.netlify.app/",
    KeyPrefix = "KEYV-"
}

-- // CLEANUP // --
for _, v in pairs(CoreGui:GetChildren()) do
    if v.Name == "SkeetKeySystem" then
        v:Destroy()
    end
end

-- // UTILITY FUNCTIONS // --
local function MakeDraggable(frame, handle)
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

-- // UI CREATION // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkeetKeySystem"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Background Blur
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = game:GetService("Lighting")

TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 12}):Play()

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Shadow Effect
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- Outer Border
local OuterStroke = Instance.new("UIStroke")
OuterStroke.Thickness = 1
OuterStroke.Color = Color3.fromRGB(0, 0, 0)
OuterStroke.Parent = MainFrame

-- Inner Border
local InnerBorder = Instance.new("Frame")
InnerBorder.Size = UDim2.new(1, -2, 1, -2)
InnerBorder.Position = UDim2.new(0, 1, 0, 1)
InnerBorder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
InnerBorder.BorderSizePixel = 0
InnerBorder.Parent = MainFrame

local InnerStroke = Instance.new("UIStroke")
InnerStroke.Thickness = 1
InnerStroke.Color = Color3.fromRGB(60, 60, 60)
InnerStroke.Parent = InnerBorder

-- Rainbow Gradient Bar (Top)
local GradientBar = Instance.new("Frame")
GradientBar.Size = UDim2.new(1, 0, 0, 2)
GradientBar.Position = UDim2.new(0, 0, 0, 0)
GradientBar.BorderSizePixel = 0
GradientBar.ZIndex = 10
GradientBar.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 255))
})
UIGradient.Parent = GradientBar

-- Animate Rainbow
task.spawn(function()
    while GradientBar and GradientBar.Parent do
        for i = 0, 1, 0.005 do
            if not GradientBar or not GradientBar.Parent then break end
            UIGradient.Offset = Vector2.new(i - 0.5, 0)
            task.wait(0.01)
        end
    end
end)

-- Header Section
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.Position = UDim2.new(0, 0, 0, 2)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, 0)
HeaderLine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

-- Logo/Icon
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 40, 0, 40)
Logo.Position = UDim2.new(0, 15, 0, 10)
Logo.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Logo.BorderSizePixel = 0
Logo.Font = Enum.Font.Code
Logo.Text = "SK"
Logo.TextColor3 = CONFIG.AccentColor
Logo.TextSize = 20
Logo.TextStrokeTransparency = 0
Logo.Parent = Header

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(60, 60, 60)
LogoStroke.Thickness = 1
LogoStroke.Parent = Logo

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 25)
Title.Position = UDim2.new(0, 60, 0, 8)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.Code
Title.Text = CONFIG.Title
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextStrokeTransparency = 0
Title.Parent = Header

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -70, 0, 15)
Subtitle.Position = UDim2.new(0, 60, 0, 33)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Enum.Font.Code
Subtitle.Text = CONFIG.Subtitle
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextTransparency = 0.3
Subtitle.Parent = Header

-- Content Background
local ContentBg = Instance.new("Frame")
ContentBg.Size = UDim2.new(1, -20, 1, -80)
ContentBg.Position = UDim2.new(0, 10, 0, 70)
ContentBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentBg.BorderSizePixel = 0
ContentBg.Parent = MainFrame

local ContentStroke = Instance.new("UIStroke")
ContentStroke.Color = Color3.fromRGB(40, 40, 40)
ContentStroke.Thickness = 1
ContentStroke.Parent = ContentBg

-- Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 30)
InfoLabel.Position = UDim2.new(0, 10, 0, 10)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.Code
InfoLabel.Text = "Enter your license key to continue"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.TextSize = 12
InfoLabel.TextWrapped = true
InfoLabel.Parent = ContentBg

-- Key Input Container
local InputContainer = Instance.new("Frame")
InputContainer.Size = UDim2.new(1, -20, 0, 32)
InputContainer.Position = UDim2.new(0, 10, 0, 45)
InputContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
InputContainer.BorderSizePixel = 0
InputContainer.Parent = ContentBg

local InputStroke = Instance.new("UIStroke")
InputStroke.Color = Color3.fromRGB(50, 50, 50)
InputStroke.Thickness = 1
InputStroke.Parent = InputContainer

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Font = Enum.Font.Code
KeyInput.PlaceholderText = "KEYV-XXXX-XXXX-XXXX"
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(220, 220, 220)
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
KeyInput.TextSize = 13
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = InputContainer

-- Input Focus Effects
KeyInput.Focused:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.2), {
        Color = CONFIG.AccentColor
    }):Play()
end)

KeyInput.FocusLost:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(50, 50, 50)
    }):Play()
end)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 85)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Code
StatusLabel.Text = "• Waiting for input"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTransparency = 0.5
StatusLabel.Parent = ContentBg

-- Button Container
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, -20, 0, 32)
ButtonContainer.Position = UDim2.new(0, 10, 1, -42)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = ContentBg

-- Get Key Button
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.48, 0, 1, 0)
GetKeyBtn.Position = UDim2.new(0, 0, 0, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
GetKeyBtn.BorderSizePixel = 0
GetKeyBtn.Font = Enum.Font.SourceSansBold
GetKeyBtn.Text = "GET KEY"
GetKeyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
GetKeyBtn.TextSize = 13
GetKeyBtn.Parent = ButtonContainer

local GetKeyStroke = Instance.new("UIStroke")
GetKeyStroke.Color = Color3.fromRGB(60, 60, 60)
GetKeyStroke.Thickness = 1
GetKeyStroke.Parent = GetKeyBtn

local GetKeyGrad = Instance.new("UIGradient")
GetKeyGrad.Rotation = 90
GetKeyGrad.Color = ColorSequence.new(
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(200, 200, 200)
)
GetKeyGrad.Parent = GetKeyBtn

-- Submit Button
local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.48, 0, 1, 0)
SubmitBtn.Position = UDim2.new(0.52, 0, 0, 0)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SubmitBtn.BorderSizePixel = 0
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.Text = "AUTHENTICATE"
SubmitBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
SubmitBtn.TextSize = 13
SubmitBtn.Parent = ButtonContainer

local SubmitStroke = Instance.new("UIStroke")
SubmitStroke.Color = Color3.fromRGB(60, 60, 60)
SubmitStroke.Thickness = 1
SubmitStroke.Parent = SubmitBtn

local SubmitGrad = Instance.new("UIGradient")
SubmitGrad.Rotation = 90
SubmitGrad.Color = ColorSequence.new(
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(200, 200, 200)
)
SubmitGrad.Parent = SubmitBtn

-- Loading Animation
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(0, 20, 0, 20)
LoadingFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
LoadingFrame.BackgroundTransparency = 1
LoadingFrame.Visible = false
LoadingFrame.ZIndex = 20
LoadingFrame.Parent = MainFrame

local LoadingCircle = Instance.new("ImageLabel")
LoadingCircle.Size = UDim2.new(1, 0, 1, 0)
LoadingCircle.BackgroundTransparency = 1
LoadingCircle.Image = "rbxassetid://4965945816"
LoadingCircle.ImageColor3 = CONFIG.AccentColor
LoadingCircle.Parent = LoadingFrame

-- Draggable
MakeDraggable(MainFrame, Header)

-- // BUTTON LOGIC // --

-- Hover Effects
GetKeyBtn.MouseEnter:Connect(function()
    TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    }):Play()
    TweenService:Create(GetKeyStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(0, 150, 255)
    }):Play()
end)

GetKeyBtn.MouseLeave:Connect(function()
    TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    }):Play()
    TweenService:Create(GetKeyStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(60, 60, 60)
    }):Play()
end)

SubmitBtn.MouseEnter:Connect(function()
    TweenService:Create(SubmitBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    }):Play()
    TweenService:Create(SubmitStroke, TweenInfo.new(0.2), {
        Color = CONFIG.AccentColor
    }):Play()
end)

SubmitBtn.MouseLeave:Connect(function()
    TweenService:Create(SubmitBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    }):Play()
    TweenService:Create(SubmitStroke, TweenInfo.new(0.2), {
        Color = Color3.fromRGB(60, 60, 60)
    }):Play()
end)

-- Get Key Button Click
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard(CONFIG.GetKeyURL)
    StatusLabel.Text = "• Link copied to clipboard!"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    StatusLabel.TextTransparency = 0
    
    task.wait(2)
    StatusLabel.Text = "• Waiting for input"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusLabel.TextTransparency = 0.5
end)

-- Submit Button Click
SubmitBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    
    -- Validation
    if not key or key == "" then
        StatusLabel.Text = "• Please enter a key"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        StatusLabel.TextTransparency = 0
        return
    end
    
    if not string.find(key, CONFIG.KeyPrefix) then
        StatusLabel.Text = "• Invalid format (Must start with KEYV-)"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        StatusLabel.TextTransparency = 0
        return
    end
    
    -- Show Loading
    LoadingFrame.Visible = true
    StatusLabel.Text = "• Authenticating..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    StatusLabel.TextTransparency = 0
    SubmitBtn.Text = "VALIDATING..."
    
    -- Rotate Loading Animation
    local loadingTween = TweenService:Create(
        LoadingCircle,
        TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {Rotation = 360}
    )
    loadingTween:Play()
    
    task.wait(0.5)
    
    -- Server Check
    local success, response = pcall(function()
        return game:HttpGet(CONFIG.KeyEndpoint .. key)
    end)
    
    loadingTween:Cancel()
    LoadingFrame.Visible = false
    
    if success then
        local data = HttpService:JSONDecode(response)
        
        if data.valid == true then
            -- Success
            StatusLabel.Text = "• Authentication successful!"
            StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            SubmitBtn.Text = "✓ VERIFIED"
            SubmitStroke.Color = Color3.fromRGB(80, 255, 80)
            
            task.wait(0.5)
            
            -- Exit Animation
            TweenService:Create(BlurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
            
            task.wait(0.5)
            ScreenGui:Destroy()
            BlurEffect:Destroy()
            
            -- ==================================================
            --                 LOAD MAIN SCRIPT
            -- ==================================================
            
            -- Load your main script here
            loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL_HERE"))()
            
            -- Or use the SkeetLib library:
            --[[
            local SkeetLib = loadstring(game:HttpGet("YOUR_SKEETLIB_URL"))()
            
            local Window = SkeetLib:CreateWindow({
                Title = "My Skeet Menu",
                Size = UDim2.new(0, 650, 0, 450)
            })
            
            local Tab1 = Window:Tab({Name = "Main"})
            local Section1 = Tab1:Section({Name = "Features"})
            
            Section1:Toggle({
                Name = "Example Toggle",
                Default = false,
                Callback = function(value)
                    print("Toggle:", value)
                end
            })
            ]]--
            
        else
            StatusLabel.Text = "• Invalid or expired key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            SubmitBtn.Text = "✗ FAILED"
            SubmitStroke.Color = Color3.fromRGB(255, 80, 80)
            
            task.wait(1.5)
            SubmitBtn.Text = "AUTHENTICATE"
            SubmitStroke.Color = Color3.fromRGB(60, 60, 60)
        end
    else
        StatusLabel.Text = "• Connection error - Check network"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        SubmitBtn.Text = "✗ ERROR"
        
        warn("Key Validation Error:", response)
        
        task.wait(1.5)
        SubmitBtn.Text = "AUTHENTICATE"
    end
end)

-- // INTRO ANIMATION // --
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundTransparency = 1

for _, v in pairs(MainFrame:GetDescendants()) do
    if v:IsA("GuiObject") and v ~= MainFrame then
        v.Visible = false
    end
end

task.wait(0.2)

TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 420, 0, 260),
    Position = UDim2.new(0.5, -210, 0.5, -130),
    BackgroundTransparency = 0
}):Play()

task.wait(0.3)

for _, v in pairs(MainFrame:GetDescendants()) do
    if v:IsA("GuiObject") and v ~= MainFrame then
        v.Visible = true
    end
end

-- Typewriter effect for title
local originalText = CONFIG.Title
Title.Text = ""
for i = 1, #originalText do
    Title.Text = string.sub(originalText, 1, i)
    task.wait(0.05)
end
