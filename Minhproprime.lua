-- RED MENU ALL-IN-ONE (Collapsible + Menu Toggle)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove old GUI
if PlayerGui:FindFirstChild("RedMenuAll") then
    PlayerGui.RedMenuAll:Destroy()
end

-- State table
local state = {
    FlyV3=false, InfJump=false, Speed=false, Noclip=false, WallWalk=false,
    BatTu=false, TanHinh=false, KillAura=false, Sword=false, Gun=false,
    Fighting=false, FeFlip=false, ESP=false, AntiAFK=false, BeACar=false,
    Bang=false, JerkOff=false, Shader=false, TeleportGUI=false, LowLag=false
}

local handles = {}
local function tryCleanup(key)
    local h = handles[key]
    if not h then return end
    if type(h)=="function" then pcall(h)
    elseif typeof(h)=="Instance" and h.Destroy then pcall(function() h:Destroy() end) end
    handles[key]=nil
end

local function safeLoadFromUrl(key,url)
    if not url or url=="" then warn("Missing URL for "..tostring(key)) return end
    local ok,res = pcall(function() return game:HttpGet(url,true) end)
    if not ok then warn(("HttpGet failed %s : %s"):format(key,tostring(res))) return end
    local ok2,ret = pcall(function()
        local f,err = loadstring(res)
        if not f then error(err) end
        return f()
    end)
    if not ok2 then warn(("Execution failed %s : %s"):format(key,tostring(ret))) return end
    handles[key]=ret
end

-- Example hooks (replace with your actual scripts)
local hooks = {}
hooks.FlyV3 = function(enable) print("FlyV3", enable) end
hooks.InfJump = function(enable) print("InfJump", enable) end
hooks.Speed = function(enable) print("Speed", enable) end
hooks.Noclip = function(enable) print("Noclip", enable) end
hooks.KillAura = function(enable) print("KillAura", enable) end
hooks.Sword = function(enable) print("Sword", enable) end
hooks.Gun = function(enable) print("Gun", enable) end
hooks.ESP = function(enable) print("ESP", enable) end
hooks.AntiAFK = function(enable) print("AntiAFK", enable) end
hooks.BeACar = function(enable) print("BeACar", enable) end
hooks.Bang = function(enable) print("Bang", enable) end
hooks.JerkOff = function(enable) print("JerkOff", enable) end
hooks.Shader = function(enable) print("Shader", enable) end
hooks.TeleportGUI = function(enable) print("TeleportGUI", enable) end
hooks.LowLag = function(enable) print("LowLag", enable) end
hooks.BatTu = function(enable) print("BatTu", enable) end
hooks.TanHinh = function(enable) print("TanHinh", enable) end
hooks.Fighting = function(enable) print("Fighting", enable) end
hooks.FeFlip = function(enable) print("FeFlip", enable) end
-- Add other hooks as needed

-- Menu Groups
local menuGroups = {
    ["Local Player"] = {
        {key="FlyV3", label="Fly V3"},
        {key="InfJump", label="InfJump"},
        {key="Speed", label="Speed"},
        {key="Noclip", label="Noclip"},
        {key="WallWalk", label="Wall Walk"},
        {key="BatTu", label="Immortal"},
        {key="TanHinh", label="Invisible"}
    },
    ["Combat"] = {
        {key="KillAura", label="KillAura"},
        {key="Sword", label="Sword"},
        {key="Gun", label="Gun"},
        {key="Fighting", label="Fighting"},
        {key="FeFlip", label="FeFlip"}
    },
    ["Fun / Support"] = {
        {key="ESP", label="ESP"},
        {key="AntiAFK", label="AntiAFK"},
        {key="BeACar", label="BeACar"},
        {key="Bang", label="Bang"},
        {key="JerkOff", label="JerkOff"},
        {key="Shader", label="Shader"},
        {key="TeleportGUI", label="TeleportGUI"},
        {key="LowLag", label="LowLag"}
    }
}

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name="RedMenuAll"
gui.ResetOnSpawn=false
gui.Parent=PlayerGui

local frameWidth = 360
local frame = Instance.new("Frame")
frame.Size=UDim2.new(0,frameWidth,0,30)
frame.Position=UDim2.new(0.5,-frameWidth/2,0.5,-15)
frame.BackgroundColor3=Color3.fromRGB(145,20,20)
frame.Parent=gui

-- Toggle button
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
        if child:IsA("Frame") then
            child.Visible = menuOpen
        end
    end
end)

-- Collapsible branches
local startY = 30
for groupName, groupItems in pairs(menuGroups) do
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
    for i,info in ipairs(groupItems) do
        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,0,30)
        btn.Position=UDim2.new(0,0,0,30*i)
        btn.Text=info.label.." [OFF]"
        btn.BackgroundColor3=Color3.fromRGB(140,10,10)
        btn.TextColor3=Color3.new(1,1,1)
        btn.Font=Enum.Font.GothamBold
        btn.TextSize=14
        btn.Visible=false
        btn.Parent=branchFrame

        btn.MouseButton1Click:Connect(function()
            state[info.key] = not state[info.key]
            btn.BackgroundColor3 = state[info.key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
            btn.Text = info.label.." ["..(state[info.key] and "ON" or "OFF").."]"
            pcall(function() hooks[info.key](state[info.key]) end)
        end)
        table.insert(childButtons,btn)
    end

    branchBtn.MouseButton1Click:Connect(function()
        branchOpen = not branchOpen
        for _,btn in ipairs(childButtons) do btn.Visible = branchOpen and menuOpen end
        branchBtn.Text = (branchOpen and "▼ " or "► ")..groupName
    end)

    startY = startY + 30
end

print("✅ RedMenuAll loaded with menu toggle + collapsible branches")
