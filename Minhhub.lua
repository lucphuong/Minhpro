local player = game.Players.LocalPlayer
local character = player.Character
local mouse = player:GetMouse()

-- Declare flags for each feature
local espEnabled = false
local autoFarmEnabled = false
local autoQuestEnabled = false
local teleportEnabled = false
local autoRaidEnabled = false
local autoBountyHuntEnabled = false

-- Create the GUI (Menu)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "minhhub"
ScreenGui.Parent = player.PlayerGui

-- Create the main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Parent = ScreenGui

-- Create the title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "minhhub - Blox Fruits"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.TextAlign = Enum.TextXAlignment.Center
title.Parent = mainFrame

-- Function to create buttons
function createButton(name, yPosition, toggleFunction)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, yPosition)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Parent = mainFrame

    button.MouseButton1Click:Connect(function()
        toggleFunction()
        -- Toggle button color to indicate activation
        if button.BackgroundColor3 == Color3.fromRGB(70, 70, 70) then
            button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        else
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
    end)
end

-- Create buttons for each function
createButton("Toggle Auto Farm", 40, function()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        spawn(autoFarm)
    end
end)

createButton("Toggle Auto Quest", 80, function()
    autoQuestEnabled = not autoQuestEnabled
    if autoQuestEnabled then
        spawn(autoQuest)
    end
end)

createButton("Toggle ESP", 120, function()
    espEnabled = not espEnabled
    if espEnabled then
        spawn(esp)
    end
end)

createButton("Toggle Teleport", 160, function()
    teleportEnabled = not teleportEnabled
end)

createButton("Toggle Auto Raid", 200, function()
    autoRaidEnabled = not autoRaidEnabled
    if autoRaidEnabled then
        spawn(autoRaid)
    end
end)

createButton("Toggle Auto Bounty Hunt", 240, function()
    autoBountyHuntEnabled = not autoBountyHuntEnabled
    if autoBountyHuntEnabled then
        spawn(autoBountyHunt)
    end
end)

-- Utility function to teleport to a target position
function teleportTo(position)
    character:SetPrimaryPartCFrame(CFrame.new(position))
end

-- Auto Farm function (level and mastery)
function autoFarm()
    while autoFarmEnabled do
        -- Add your farming logic here (targeting mobs, farming level, etc.)
        wait(1)
    end
end

-- Auto Quest function (accept and complete quests)
function autoQuest()
    while autoQuestEnabled do
        -- Add your quest logic here (accept and complete quests)
        wait(1)
    end
end

-- ESP function (show player, boss, and chest positions)
function esp()
    while espEnabled do
        -- Add ESP logic here (display positions of players, bosses, chests, etc.)
        wait(1)
    end
end

-- Auto Raid function (enter raid and complete it)
function autoRaid()
    while autoRaidEnabled do
        -- Add raid logic here (entering and completing raid)
        wait(1)
    end
end

-- Auto Bounty Hunt function (hunt bounties)
function autoBountyHunt()
    while autoBountyHuntEnabled do
        -- Add bounty hunt logic here (hunt other players)
        wait(1)
    end
end

-- Main loop (you can add more logic here as needed)
while true do
    if teleportEnabled then
        -- Handle teleport logic here
    end
    wait(1)
end
