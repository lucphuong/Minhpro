-- RED MENU ALL-IN-ONE (SAFE) 4-COLUMN, DRAGGABLE, COMPACT, WITH ESP
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove old menu
if PlayerGui:FindFirstChild("RedMenuAll") then
    PlayerGui.RedMenuAll:Destroy()
end

-- Function states
local state = {
    InfJump=false, FlyV3=false, Shader=false, TeleportGUI=false,
    Speed=false, AntiAFK=false, BatTu=false, TanHinh=false,
    Noclip=false, WallWalk=false, LowLag=false, FeFlip=false, ESP=false
}

local handles = {}

local function tryCleanup(key)
    local h = handles[key]
    if not h then return end
    if type(h)=="function" then
        pcall(h)
    elseif typeof(h)=="Instance" and h.Destroy then
        pcall(function() h:Destroy() end)
    end
    handles[key] = nil
end

local function safeLoadFromUrl(key,url)
    if not url then return end
    local ok,res = pcall(function() return game:HttpGet(url,true) end)
    if ok then
        pcall(function()
            local f = loadstring(res)
            if f then handles[key]=f() end
        end)
    end
end

-- Hooks
local hooks = {}

hooks.InfJump=function(enable)
    if enable then
        if handles.InfJump then return end
        local conn=UserInputService.JumpRequest:Connect(function()
            local char=LocalPlayer.Character
            if char then
                local hum=char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:ChangeState("Jumping") end) end
            end
        end)
        handles.InfJump=function() conn:Disconnect() end
    else tryCleanup("InfJump") end
end

hooks.FlyV3=function(enable)
    if enable then safeLoadFromUrl("FlyV3","https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt")
    else tryCleanup("FlyV3") end
end

hooks.Shader=function(enable)
    if enable then safeLoadFromUrl("Shader","https://pastefy.app/xXkUxA0P/raw")
    else tryCleanup("Shader") end
end

hooks.TeleportGUI=function(enable)
    if enable then safeLoadFromUrl("TeleportGUI","https://raw.githubusercontent.com/lucphuong/Minhhub/main/TeleportGUI.lua")
    else tryCleanup("TeleportGUI") end
end

hooks.Speed=function(enable)
    if enable then safeLoadFromUrl("Speed","https://raw.githubusercontent.com/MrScripterrFr/Speed-Changer/main/Speed%20Changer")
    else tryCleanup("Speed") end
end

hooks.AntiAFK=function(enable)
    if enable then
        if handles._afkConn then return end
        local conn=LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
        handles._afkConn=conn
    else tryCleanup("_afkConn") end
end

hooks.BatTu=function(enable) workspace.FallenPartsDestroyHeight=enable and 0/0 or -1000 end
hooks.TanHinh=function(enable)
    if enable then safeLoadFromUrl("TanHinh","https://abre.ai/invisible-v2")
    else tryCleanup("TanHinh") end
end
hooks.Noclip=function(enable)
    if enable then
        local Clip=false
        local Noclip
        Noclip=RunService.Stepped:Connect(function()
            if not Clip and LocalPlayer.Character then
                for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide=false end
                end
            end
        end)
        handles.Noclip=function() Noclip:Disconnect() end
    else tryCleanup("Noclip") end
end
hooks.WallWalk=function(enable)
    if enable then safeLoadFromUrl("WallWalk","https://pastebin.com/raw/5T7KsEWy")
    else tryCleanup("WallWalk") end
end
hooks.LowLag=function(enable)
    if enable then safeLoadFromUrl("LowLag","https://pastebin.com/raw/KiSYpej6")
    else tryCleanup("LowLag") end
end
hooks.FeFlip=function(enable)
    if enable then safeLoadFromUrl("FeFlip","https://pastebin.com/raw/abcd1234")
    else tryCleanup("FeFlip") end
end

-- ESP Hook
hooks.ESP=function(enable)
    if enable then
        if handles.ESP then return end
        local espFolder = Instance.new("Folder", game.CoreGui)
        espFolder.Name="ESP_HOLDER"
        handles.ESP = espFolder

        local function applyESP(plr)
            if plr == LocalPlayer then return end
            if not plr.Character or plr.Character:FindFirstChild("Highlight") then return end
            local h = Instance.new("Highlight")
            h.Adornee = plr.Character
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillColor = (plr.TeamColor == LocalPlayer.TeamColor) and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
            h.Parent = espFolder
        end

        for _,p in pairs(Players:GetPlayers()) do
            applyESP(p)
            p.CharacterAdded:Connect(function() applyESP(p) end)
        end
        Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() applyESP(p) end) end)
    else
        tryCleanup("ESP")
    end
end

-- Menu
local function createMenu()
    local gui=Instance.new("ScreenGui")
    gui.Name="RedMenuAll"
    gui.ResetOnSpawn=false
    gui.Parent=PlayerGui

    local frame=Instance.new("Frame")
    local frameWidth = 320
    frame.Size=UDim2.new(0,frameWidth,0,480)
    frame.Position=UDim2.new(0.5,-frameWidth/2,0.5,-240)
    frame.BackgroundColor3=Color3.fromRGB(145,20,20)
    frame.Parent=gui

    local title=Instance.new("TextLabel")
    title.Size=UDim2.new(1,0,0,40)
    title.BackgroundColor3=Color3.fromRGB(190,30,30)
    title.TextColor3=Color3.new(1,1,1)
    title.Font=Enum.Font.GothamBold
    title.TextSize=18
    title.Text="🔴 RED MENU ALL-IN-ONE"
    title.Parent=frame

    -- Items
    local items={
        {key="FlyV3", label="Fly V3"},{key="InfJump", label="InfJump"},
        {key="Shader", label="Shader"},{key="TeleportGUI", label="Teleport GUI"},
        {key="Speed", label="Speed"},{key="AntiAFK", label="Anti-AFK"},
        {key="BatTu", label="Bất tử"},{key="TanHinh", label="Tàn hình"},
        {key="Noclip", label="Noclip"},{key="WallWalk", label="Đi bộ trên tường"},
        {key="LowLag", label="Giảm lag"},{key="FeFlip", label="Lăn (feFlip)"},
        {key="ESP", label="ESP"}
    }

    local btnPadding = 8
    local btnHeight = 36
    local btnWidth = (frameWidth - btnPadding*5)/4

    for i,info in ipairs(items) do
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(0,btnWidth,0,btnHeight)
        local col=(i-1)%4
        local row=math.floor((i-1)/4)
        btn.Position=UDim2.new(0,btnPadding+col*(btnWidth+btnPadding),
                               0,44+btnPadding+row*(btnHeight+btnPadding))
        btn.BackgroundColor3=state[info.key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
        btn.TextColor3=Color3.new(1,1,1)
        btn.Font=Enum.Font.GothamBold
        btn.TextSize=14
        btn.Text=info.label..(state[info.key] and " [ON]" or " [OFF]")
        btn.Parent=frame

        btn.MouseButton1Click:Connect(function()
            state[info.key]=not state[info.key]
            btn.BackgroundColor3=state[info.key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
            btn.Text=info.label..(state[info.key] and " [ON]" or " [OFF]")
            pcall(function() hooks[info.key](state[info.key]) end)
        end)
    end

    -- Drag setup
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    title.InputBegan:Connect(function(input)
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

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

createMenu()
print("✅ RedMenuAll loaded (4-column, compact, draggable, with ESP)")
