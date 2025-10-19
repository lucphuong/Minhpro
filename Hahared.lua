-- RED MENU ALL-IN-ONE (FINAL) - 3 NHÁNH, DRAGGABLE, SAFE
-- NOTE: Anti-Ban không bao gồm. Dùng tự chịu rủi ro.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- remove old
if PlayerGui:FindFirstChild("RedMenuAll") then
    PlayerGui.RedMenuAll:Destroy()
end

-- states
local state = {
    FlyV3=false, InfJump=false, Shader=false, TeleportGUI=false,
    Speed=false, AntiAFK=false, BatTu=false, TanHinh=false,
    Noclip=false, WallWalk=false, LowLag=false, FeFlip=false,
    ESP=false, KillAura=false, BeACar=false, Bang=false,
    JerkOff=false, Fighting=false, Gun=false, Sword=false
}

local handles = {}
local function tryCleanup(key)
    local h = handles[key]
    if not h then return end
    if type(h) == "function" then
        pcall(h)
    elseif typeof(h) == "Instance" and h.Destroy then
        pcall(function() h:Destroy() end)
    end
    handles[key] = nil
end

local function safeLoadFromUrl(key, url)
    if not url or url == "" then warn("safeLoadFromUrl missing url for "..tostring(key)); return end
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if not ok then
        warn(("HttpGet failed for %s : %s"):format(key, tostring(res)))
        return
    end
    local ok2, ret = pcall(function()
        local f, err = loadstring(res)
        if not f then error(err) end
        return f()
    end)
    if not ok2 then
        warn(("Execution failed for %s : %s"):format(key, tostring(ret)))
        return
    end
    handles[key] = ret
    print(("Loaded %s (handle: %s)"):format(key, tostring(ret)))
end

local hooks = {}

-- ========== BASIC HOOKS EXAMPLES ==========
-- INFJUMP
hooks.InfJump = function(enable)
    if enable then
        if handles.InfJump then return end
        local conn = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:ChangeState("Jumping") end) end
            end
        end)
        handles.InfJump = function() if conn then conn:Disconnect(); conn=nil end end
    else
        tryCleanup("InfJump")
    end
end

-- SPEED
hooks.Speed = function(enable)
    if enable then
        safeLoadFromUrl("Speed", "https://raw.githubusercontent.com/MrScripterrFr/Speed-Changer/main/Speed%20Changer")
    else
        tryCleanup("Speed")
    end
end

-- BAT TU
hooks.BatTu = function(enable)
    if enable then workspace.FallenPartsDestroyHeight = 0/0
    else workspace.FallenPartsDestroyHeight = -1000 end
end

-- NOCOLIP
hooks.Noclip = function(enable)
    if enable then
        if handles.Noclip then return end
        local conn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide=false end)
                    end
                end
            end
        end)
        handles.Noclip = function() if conn then conn:Disconnect() end end
    else
        tryCleanup("Noclip")
    end
end

-- ESP
hooks.ESP = function(enable)
    if enable then
        if handles.ESP then return end
        local folder = Instance.new("Folder", game.CoreGui); folder.Name="ESP_HOLDER"
        handles.ESP = folder
        local function apply(p)
            if p==LocalPlayer then return end
            p.CharacterAdded:Connect(function()
                pcall(function()
                    if p.Character and not p.Character:FindFirstChild("HighlightFromRedMenu") then
                        local h = Instance.new("Highlight")
                        h.Name="HighlightFromRedMenu"
                        h.Adornee = p.Character
                        h.FillTransparency=0.5
                        h.FillColor=(p.TeamColor==LocalPlayer.TeamColor) and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
                        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent=folder
                    end
                end)
            end)
            if p.Character and not p.Character:FindFirstChild("HighlightFromRedMenu") then
                local h = Instance.new("Highlight")
                h.Name="HighlightFromRedMenu"
                h.Adornee = p.Character
                h.FillTransparency=0.5
                h.FillColor=(p.TeamColor==LocalPlayer.TeamColor) and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
                h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent=folder
            end
        end
        for _,p in pairs(Players:GetPlayers()) do pcall(apply,p) end
        Players.PlayerAdded:Connect(function(p) pcall(apply,p) end)
    else
        tryCleanup("ESP")
    end
end

-- Thêm các hooks khác giống code trước (Shader, Sword, KillAura, Gun, etc.)

-- ========== MENU NHÁNH 3 ==========

local menuGroups = {
    ["Nhân vật"] = {
        {key="FlyV3", label="Fly V3"},
        {key="InfJump", label="InfJump"},
        {key="Speed", label="Speed"},
        {key="Noclip", label="Noclip"},
        {key="WallWalk", label="Đi bộ trên tường"},
        {key="BatTu", label="Bất tử"},
        {key="TanHinh", label="Tàn hình"}
    },
    ["Chiến đấu"] = {
        {key="KillAura", label="KillAura"},
        {key="Sword", label="Sword"},
        {key="Gun", label="Gun"},
        {key="Fighting", label="Fighting"},
        {key="FeFlip", label="Lăn (FeFlip)"}
    },
    ["Hỗ trợ / Fun / Đồ họa"] = {
        {key="ESP", label="ESP"},
        {key="AntiAFK", label="Anti-AFK"},
        {key="BeACar", label="Be a Car"},
        {key="Bang", label="Bang"},
        {key="JerkOff", label="Jerk Off"},
        {key="Shader", label="Shader"},
        {key="TeleportGUI", label="Teleport GUI"},
        {key="LowLag", label="Giảm lag"}
    }
}

-- GUI
local function createMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name="RedMenuAll"
    gui.ResetOnSpawn=false
    gui.Parent=PlayerGui

    local frameWidth = 360
    local frameHeight = 500

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
    frame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
    frame.BackgroundColor3 = Color3.fromRGB(145,20,20)
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,40)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundColor3 = Color3.fromRGB(190,30,30)
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Text="🔴 RED MENU ALL-IN-ONE"
    title.Parent=frame

    local startY = 44
    local btnPadding=8
    local btnHeight=36
    local btnWidth = math.floor((frameWidth - btnPadding*5)/4)

    for groupName, groupItems in pairs(menuGroups) do
        local groupLabel = Instance.new("TextLabel")
        groupLabel.Size = UDim2.new(1,0,0,24)
        groupLabel.Position = UDim2.new(0,0,0,startY)
        groupLabel.BackgroundColor3 = Color3.fromRGB(150,50,50)
        groupLabel.TextColor3 = Color3.new(1,1,1)
        groupLabel.Font = Enum.Font.GothamBold
        groupLabel.TextSize = 14
        groupLabel.Text = "► "..groupName
        groupLabel.Parent = frame
        startY = startY + 28

        for i, info in ipairs(groupItems) do
            local col = (i-1)%4
            local row = math.floor((i-1)/4)
            local btn = Instance.new("TextButton")
            btn.Size=UDim2.new(0,btnWidth,0,btnHeight)
            btn.Position=UDim2.new(0,btnPadding + col*(btnWidth+btnPadding),0,startY+row*(btnHeight+btnPadding))
            btn.BackgroundColor3=state[info.key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize=14
            btn.Text = info.label..(state[info.key] and " [ON]" or " [OFF]")
            btn.Parent=frame

            btn.MouseButton1Click:Connect(function()
                state[info.key] = not state[info.key]
                btn.BackgroundColor3=state[info.key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
                btn.Text=info.label..(state[info.key] and " [ON]" or " [OFF]")
                pcall(function() hooks[info.key](state[info.key]) end)
            end)
        end
        startY = startY + math.ceil(#groupItems/4)*(btnHeight+btnPadding)+8
    end

    -- Drag setup
    local dragging=false
    local dragStart=Vector2.new()
    local startPos=UDim2.new()
    title.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            dragStart=input.Position
            startPos=frame.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)
end

createMenu()
print("✅ RedMenuAll final loaded (3 nhánh, draggable, pcall-wrapped).")
