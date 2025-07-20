-- Wait for the player's character to be added
game.Players.LocalPlayer.CharacterAdded:Wait()

-- Require the UI library module
local GameSenseUI = require(script.GameSenseUI)

-- You can optionally set a new title for the window
GameSenseUI:SetTitle("My Awesome Script")

-- =================================================================
-- Create Tabs
-- Creating a tab returns a 'tab object' that you can add controls to.
-- =================================================================

local VisualsTab = GameSenseUI:CreateTab("Visuals")
local CombatTab = GameSenseUI:CreateTab("Combat")
local MiscTab = GameSenseUI:CreateTab("Misc")


-- =================================================================
-- Populate the 'Visuals' Tab
-- =================================================================

-- A label to group settings
VisualsTab:CreateLabel("Player ESP")

-- A checkbox control. The function is called a 'callback'.
-- It runs every time the checkbox is clicked, passing the new state (true/false).
VisualsTab:CreateCheckbox("Enable ESP", function(value)
	print("ESP Enabled set to:", value)
    -- Your logic here, e.g., getgenv().ESP_Enabled = value
end)

VisualsTab:CreateCheckbox("Show Boxes", function(value)
	print("ESP Boxes set to:", value)
end)

VisualsTab:CreateCheckbox("Show Names", function(value)
	print("ESP Names set to:", value)
end)

-- A slider control. The callback runs when the slider value changes.
-- It receives the new numerical value.
VisualsTab:CreateSlider("Render Distance", 50, 1000, 250, function(value)
    -- The value is a number, so we round it for display/use
	print("Render Distance set to:", math.floor(value))
end)


-- =================================================================
-- Populate the 'Combat' Tab
-- =================================================================

CombatTab:CreateLabel("Aimbot")

CombatTab:CreateCheckbox("Enable Aimbot", function(value)
	print("Aimbot set to:", value)
end)

-- A dropdown control. The callback runs when an option is selected.
-- It receives the text of the selected option.
local aimbotParts = {"Head", "Torso", "HumanoidRootPart"}
CombatTab:CreateDropdown("Target Part", aimbotParts, function(value)
	print("Aimbot Target Part set to:", value)
end)

CombatTab:CreateSlider("FOV", 10, 300, 50, function(value)
	print("Aimbot FOV set to:", math.floor(value))
end)

CombatTab:CreateSlider("Smoothness", 1, 20, 5, function(value)
	print("Aimbot Smoothness set to:", math.floor(value))
end)


-- =================================================================
-- Populate the 'Misc' Tab
-- =================================================================

MiscTab:CreateLabel("World")

MiscTab:CreateCheckbox("Fullbright", function(value)
	print("Fullbright set to:", value)
    if value then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
    else
        game:GetService("Lighting").Brightness = 1 -- Or your default
        game:GetService("Lighting").ClockTime = 10 -- Or your default
    end
end)

local walkspeedOptions = {"Default", "16 (Normal)", "32 (Fast)", "50 (Godspeed)"}
MiscTab:CreateDropdown("WalkSpeed", walkspeedOptions, function(value)
    -- Example of parsing the value from the dropdown
    local speed = tonumber(string.match(value, "%d+")) or 16 -- Default to 16 if "Default" is chosen
	print("Walkspeed set to:", speed)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speed
    end
end)
