-- RED MENU ALL-IN-ONE (Full 20+ functions, Collapsible + Menu Toggle + Safe)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove old GUI
if PlayerGui:FindFirstChild("RedMenuAll") then
    PlayerGui.RedMenuAll:Destroy()
end

-- State & handles
local state = {
    FlyV3=false, InfJump=false, Speed=false, Noclip=false, WallWalk=false,
    BatTu=false, TanHinh=false, KillAura=false, Sword=false, Gun=false,
    Fighting=false, FeFlip=false, ESP=false, AntiAFK=false, BeACar=false,
    Bang=false, JerkOff=false, Shader=false, TeleportGUI=false, LowLag=false
}
local handles = {}

-- Safe loadstring
local function safeLoad(key, url)
    if handles[key] then return end
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not ok then warn(key.." HttpGet failed: "..tostring(res)) return end
    local ok2, ret = pcall(function()
        local f, err = loadstring(res)
        if not f then error(err) end
        return f()
    end)
    if not ok2 then warn(key.." execution failed: "..tostring(ret)) return end
    handles[key] = ret
end

local function tryCleanup(key)
    local h = handles[key]
    if not h then return end
    if type(h)=="function" then pcall(h)
    elseif typeof(h)=="Instance" and h.Destroy then pcall(function() h:Destroy() end) end
    handles[key]=nil
end

-- Hooks with URLs (replace with real URLs)
local hooksURLs = {
    FlyV3="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    InfJump="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    Speed="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    Noclip="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    WallWalk="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    BatTu="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    TanHinh="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    KillAura="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    Sword="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    Gun="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    Fighting="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    FeFlip="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    ESP="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    AntiAFK="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    BeACar="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    Bang="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    JerkOff="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    Shader="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    TeleportGUI="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua",
    LowLag="https://raw.githubusercontent.com/lucphuong/Minhpro/refs/heads/main/Minhproprime.lua"
}

local hooks = {}
for k,v in pairs(hooksURLs) do
    hooks[k] = function(enable)
        if enable then safeLoad(k,v) else tryCleanup(k) end
    end
end

-- Menu groups
local menuGroups = {
    ["Local Player"] = { "FlyV3", "InfJump", "Speed", "Noclip", "WallWalk", "BatTu", "TanHinh" },
    ["Combat"] = { "KillAura", "Sword", "Gun", "Fighting", "FeFlip" },
    ["Fun / Support"] = { "ESP", "AntiAFK", "BeACar", "Bang", "JerkOff", "Shader", "TeleportGUI", "LowLag" }
}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name="RedMenuAll"
gui.ResetOnSpawn=false
gui.Parent=PlayerGui

local frameWidth = 360
local frame = Instance.new("Frame")
frame.Size=UDim2.new(0, frameWidth,0,30)
frame.Position=UDim2.new(0.5,-frameWidth/2,0.5,-15)
frame.BackgroundColor3=Color3.fromRGB(145,20,20)
frame.Parent=gui

-- Toggle menu
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size=UDim2.new(1,0,0,30)
toggleBtn.Text="🔴 Red Menu [SHOW]"
toggleBtn.BackgroundColor3=Color3.fromRGB(190,30,30)
toggleBtn.TextColor3=Color3.new(1,1,1)
toggleBtn.Font=Enum.Font.GothamBold
toggleBtn.TextSize=16
toggleBtn.Parent=frame

local menuOpen=false
toggleBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    toggleBtn.Text = menuOpen and "🔴 Red Menu [HIDE]" or "🔴 Red Menu [SHOW]"
    for _,child in ipairs(frame:GetChildren()) do
        if child:IsA("Frame") then child.Visible = menuOpen end
    end
end)

-- Collapsible branches
local startY = 30
for groupName, keys in pairs(menuGroups) do
    local branchOpen=false
    local branchFrame = Instance.new("Frame")
    branchFrame.Size=UDim2.new(1,0,0,30)
    branchFrame.Position=UDim2.new(0,0,0,startY)
    branchFrame.BackgroundTransparency=1
    branchFrame.Visible=false
    branchFrame.Parent=frame

    local branchBtn = Instance.new("TextButton")
    branchBtn.Size=UDim2.new(1,0,0,30)
    branchBtn.Position=UDim2.new(0,0,0,0)
    branchBtn.Text="► "..groupName
    branchBtn.BackgroundColor3=Color3.fromRGB(150,50,50)
    branchBtn.TextColor3=Color3.new(1,1,1)
    branchBtn.Font=Enum.Font.GothamBold
    branchBtn.TextSize=14
    branchBtn.Parent=branchFrame

    local childButtons={}
    for i,key in ipairs(keys) do
        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,0,30)
        btn.Position=UDim2.new(0,0,0,30*i)
        btn.Text=key.." [OFF]"
        btn.BackgroundColor3=Color3.fromRGB(140,10,10)
        btn.TextColor3=Color3.new(1,1,1)
        btn.Font=Enum.Font.GothamBold
        btn.TextSize=14
        btn.Visible=false
        btn.Parent=branchFrame

        btn.MouseButton1Click:Connect(function()
            state[key] = not state[key]
            btn.BackgroundColor3 = state[key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
            btn.Text = key.." ["..(state[key] and "ON" or "OFF").."]"
            pcall(function() hooks[key](state[key]) end)
        end)
        table.insert(childButtons, btn)
    end

    branchBtn.MouseButton1Click:Connect(function()
        branchOpen = not branchOpen
        for _,btn in ipairs(childButtons) do btn.Visible = branchOpen and menuOpen end
        branchBtn.Text = (branchOpen and "▼ " or "► ")..groupName
    end)

    startY = startY + 30
end

print("✅ RedMenuAll loaded with full 20+ functions, collapsible branches, pcall-safe loadstring")
