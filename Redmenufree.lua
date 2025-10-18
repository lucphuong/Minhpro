-- RED MENU (SAFE) with draggable GUI & real loadstring links
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove old menu if exists
if PlayerGui:FindFirstChild("RedMenuSafe") then
    PlayerGui.RedMenuSafe:Destroy()
end

-- Menu frame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RedMenuSafe"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 550) -- tăng chiều cao nếu nhiều nút
frame.Position = UDim2.new(0.02,0,0.12,0)
frame.BackgroundColor3 = Color3.fromRGB(145,20,20)
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,48)
title.BackgroundColor3 = Color3.fromRGB(190,30,30)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Text = "🔴 RED MENU (SAFE)"
title.Parent = frame

-- Function state
local state = {
    InfJump = false,
    FlyV3 = false,
    Shader = false,
    TeleportGUI = false,
    Speed = false,
    AntiAFK = false,
    AntiBan = false,
    WallWalk = false,
    NoClip = false,
    Flip = false,
    Screen = false,
    GodMode = false,
    LowLag = false
}

-- Function hooks
local hooks = {}

-- Utility: safe load external script
local function safeLoadFromUrl(url)
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok then
        pcall(function()
            local f, err = loadstring(res)
            if f then f() end
        end)
    else
        warn("HttpGet failed:", url, res)
    end
end

-- Hooks
hooks.InfJump = function(enable)
    if enable then
        local conn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:ChangeState("Jumping") end) end
            end
        end)
        state._infConn = conn
    else
        if state._infConn then state._infConn:Disconnect(); state._infConn=nil end
    end
end

hooks.FlyV3 = function(enable) if enable then safeLoadFromUrl("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt") end end
hooks.Shader = function(enable) if enable then safeLoadFromUrl("https://pastefy.app/xXkUxA0P/raw") end end
hooks.TeleportGUI = function(enable) if enable then safeLoadFromUrl("https://raw.githubusercontent.com/lucphuong/Minhhub/main/TeleportGUI.lua") end end
hooks.Speed = function(enable) if enable then safeLoadFromUrl("https://raw.githubusercontent.com/MrScripterrFr/Speed-Changer/main/Speed%20Changer") end end
hooks.AntiAFK = function(enable)
    if enable then
        if state._afkConn then return end
        state._afkConn = LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0,0))
        end)
    else
        if state._afkConn then state._afkConn:Disconnect(); state._afkConn=nil end
    end
end
hooks.AntiBan = function(enable) warn("Anti-Ban not allowed") end
hooks.WallWalk = function(enable) if enable then safeLoadFromUrl("https://pastebin.com/raw/5T7KsEWy") end end
hooks.NoClip = function(enable)
    if enable then
        local Clip=false
        local nc
        nc = game:GetService("RunService").Stepped:Connect(function()
            if not Clip and LocalPlayer.Character then
                for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide=false end
                end
            end
        end)
        state._nc=nc
    else
        if state._nc then state._nc:Disconnect(); state._nc=nil end
    end
end
hooks.Flip = function(enable) if enable then safeLoadFromUrl("https://pastebin.com/raw/abcd1234") end end
hooks.Screen = function(enable) if enable then safeLoadFromUrl("https://abre.ai/invisible-v2") end end
hooks.GodMode = function(enable) workspace.FallenPartsDestroyHeight = enable and 0/0 or -1000 end
hooks.LowLag = function(enable) if enable then safeLoadFromUrl("https://pastebin.com/raw/KiSYpej6") end end

-- UI MENU
local items={
    {key="InfJump", label="InfJump"},
    {key="FlyV3", label="Fly V3"},
    {key="Shader", label="Shader"},
    {key="TeleportGUI", label="Teleport GUI"},
    {key="Speed", label="Speed"},
    {key="AntiAFK", label="Anti-AFK"},
    {key="AntiBan", label="Anti-Ban"},
    {key="WallWalk", label="Đi bộ trên tường"},
    {key="NoClip", label="NoClip"},
    {key="Flip", label="Lăn (feFlip)"},
    {key="Screen", label="Tàng hình"},
    {key="GodMode", label="Bất tử"},
    {key="LowLag", label="Giảm lag"}
}

for i,info in ipairs(items) do
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,44)
    btn.Position=UDim2.new(0,10,0,54+(i-1)*50)
    btn.BackgroundColor3=state[info.key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
    btn.TextColor3=Color3.new(1,1,1)
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=16
    btn.Text=info.label..(state[info.key] and " [ON]" or " [OFF]")
    btn.Parent=frame
    btn.MouseButton1Click:Connect(function()
        state[info.key]=not state[info.key]
        btn.BackgroundColor3=state[info.key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
        btn.Text=info.label..(state[info.key] and " [ON]" or " [OFF]")
        pcall(function() hooks[info.key](state[info.key]) end)
    end)
end

-- Drag support
local dragging=false
local dragStart,startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true
        dragStart=input.Position
        startPos=frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=input.Position-dragStart
        frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
                                 startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

print("✅ RedMenuSafe loaded (drag enabled, all loadstrings pcall).")
