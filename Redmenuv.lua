-- RED MENU ALL-IN-ONE (FINAL) - 4-COLUMN, DRAGGABLE, SAFE (pcall)
-- NOTE: Anti-Ban is NOT included. Use scripts at your own risk.

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
        handles.InfJump = function() if conn then conn:Disconnect(); conn = nil end end
    else
        tryCleanup("InfJump")
    end
end

-- FLY V3
hooks.FlyV3 = function(enable)
    if enable then
        safeLoadFromUrl("FlyV3", "https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt")
    else
        tryCleanup("FlyV3")
    end
end

-- SHADER (updated link)
hooks.Shader = function(enable)
    if enable then
        safeLoadFromUrl("Shader", "https://raw.githubusercontent.com/p0e1/1/refs/heads/main/SimpleShader.lua")
    else
        tryCleanup("Shader")
    end
end

-- TELEPORT GUI (updated)
hooks.TeleportGUI = function(enable)
    if enable then
        safeLoadFromUrl("TeleportGUI", "https://cdn.wearedevs.net/scripts/Click%20Teleport.txt")
    else
        tryCleanup("TeleportGUI")
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

-- ANTI AFK (local VirtualUser fallback)
hooks.AntiAFK = function(enable)
    if enable then
        if handles._afkConn then return end
        local conn = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
        handles._afkConn = conn
    else
        tryCleanup("_afkConn")
    end
end

-- BAT TU (immortal)
hooks.BatTu = function(enable)
    if enable then
        workspace.FallenPartsDestroyHeight = 0/0
    else
        workspace.FallenPartsDestroyHeight = -1000
    end
end

-- TAN HINH
hooks.TanHinh = function(enable)
    if enable then
        safeLoadFromUrl("TanHinh", "https://abre.ai/invisible-v2")
    else
        tryCleanup("TanHinh")
    end
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
                        pcall(function() part.CanCollide = false end)
                    end
                end
            end
        end)
        handles.Noclip = function() if conn then conn:Disconnect() end end
    else
        tryCleanup("Noclip")
    end
end

-- WALL WALK
hooks.WallWalk = function(enable)
    if enable then
        safeLoadFromUrl("WallWalk", "https://pastebin.com/raw/5T7KsEWy")
    else
        tryCleanup("WallWalk")
    end
end

-- LOW LAG (performance)
hooks.LowLag = function(enable)
    if enable then
        safeLoadFromUrl("LowLag", "https://pastebin.com/raw/KiSYpej6")
    else
        tryCleanup("LowLag")
    end
end

-- FEFLIP (lăn) - user provided link placeholder; replace if wrong
hooks.FeFlip = function(enable)
    if enable then
        safeLoadFromUrl("FeFlip", "https://pastebin.com/raw/KiSYpej6") -- replace with actual feFlip raw if needed
    else
        tryCleanup("FeFlip")
    end
end

-- ESP
hooks.ESP = function(enable)
    if enable then
        if handles.ESP then return end
        local folder = Instance.new("Folder", game.CoreGui); folder.Name = "ESP_HOLDER"
        handles.ESP = folder
        local function apply(p)
            if p == LocalPlayer then return end
            p.CharacterAdded:Connect(function()
                pcall(function()
                    if p.Character and not p.Character:FindFirstChild("HighlightFromRedMenu") then
                        local h = Instance.new("Highlight")
                        h.Name = "HighlightFromRedMenu"
                        h.Adornee = p.Character
                        h.FillTransparency = 0.5
                        h.FillColor = (p.TeamColor == LocalPlayer.TeamColor) and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = folder
                    end
                end)
            end)
            -- apply immediately if character exists
            if p.Character and not p.Character:FindFirstChild("HighlightFromRedMenu") then
                pcall(function()
                    local h = Instance.new("Highlight")
                    h.Name = "HighlightFromRedMenu"
                    h.Adornee = p.Character
                    h.FillTransparency = 0.5
                    h.FillColor = (p.TeamColor == LocalPlayer.TeamColor) and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = folder
                end)
            end
        end
        for _,p in pairs(Players:GetPlayers()) do pcall(apply,p) end
        Players.PlayerAdded:Connect(function(p) pcall(apply,p) end)
    else
        tryCleanup("ESP")
    end
end

-- KILL AURA (INLINE support)
-- NOTE: your obfuscated KillAura code can be pasted into KILLAURA_CODE below
hooks.KillAura = function(enable)
    if enable then
        if handles.KillAura then return end
        -- Option A: if you have a raw URL, use safeLoadFromUrl("KillAura", "<url>")
        -- Option B: paste your inline code as the string KILLAURA_CODE, then this pcall will run it.
        local KILLAURA_CODE = [[
-- Paste your kill aura code here (the obfuscated lua you provided).
-- Example: loadstring("...")() or raw lua statements.
]]
        local ok, err = pcall(function()
            if KILLAURA_CODE and KILLAURA_CODE:match("%S") then
                local f, e = loadstring(KILLAURA_CODE)
                if not f then error(e) end
                handles.KillAura = f()
            end
        end)
        if not ok then warn("KillAura failed: "..tostring(err)) end
    else
        tryCleanup("KillAura")
    end
end

-- Be a Car
hooks.BeACar = function(enable)
    if enable then
        if handles.BeACar then return end
        local ok, err = pcall(function()
            handles.BeACar = loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/BeaCar"))()
        end)
        if not ok then warn("BeACar failed: "..tostring(err)) end
    else
        tryCleanup("BeACar")
    end
end

-- Bang
hooks.Bang = function(enable)
    if enable then
        if handles.Bang then return end
        local ok, err = pcall(function()
            handles.Bang = loadstring(game:HttpGet("https://raw.githubusercontent.com/4gh9/Bang-Script-Gui/main/bang%20gui.lua"))()
        end)
        if not ok then warn("Bang failed: "..tostring(err)) end
    else
        tryCleanup("Bang")
    end
end

-- Jerk Off
hooks.JerkOff = function(enable)
    if enable then
        if handles.JerkOff then return end
        local ok, err = pcall(function()
            handles.JerkOff = loadstring(game:HttpGet("https://pastefy.app/lawnvcTT/raw", true))()
        end)
        if not ok then warn("JerkOff failed: "..tostring(err)) end
    else
        tryCleanup("JerkOff")
    end
end

-- Fighting (user-provided remote)
hooks.Fighting = function(enable)
    if enable then
        if handles.Fighting then return end
        local ok, err = pcall(function()
            handles.Fighting = loadstring(game:HttpGet("https://pastefy.app/cAQICuXo/raw", true))()
        end)
        if not ok then warn("Fighting failed: "..tostring(err)) end
    else
        tryCleanup("Fighting")
    end
end

-- Gun (user-provided remote)
hooks.Gun = function(enable)
    if enable then
        if handles.Gun then return end
        local ok, err = pcall(function()
            handles.Gun = loadstring(game:HttpGet("https://pastebin.com/raw/0hn40Zbc"))()
        end)
        if not ok then warn("Gun failed: "..tostring(err)) end
    else
        tryCleanup("Gun")
    end
end

-- Sword (kiếm) - safer local version (no fling)
hooks.Sword = function(enable)
    if enable then
        if handles.Sword then return end
        local ok, err = pcall(function()
            -- create a simple sword tool and put in backpack
            local plr = LocalPlayer
            if not plr then return end
            local tool = Instance.new("Tool")
            tool.Name = "ClassicSword_RedMenu"
            tool.RequiresHandle = true
            tool.CanBeDropped = true
            tool.Parent = plr.Backpack

            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(1,0.6,3)
            handle.CanCollide = false
            handle.Parent = tool

            local mesh = Instance.new("SpecialMesh", handle)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxasset://fonts/sword.mesh"
            mesh.TextureId = "rbxasset://textures/SwordTexture.png"
            mesh.Scale = Vector3.new(1,1,1)

            local swingSound = Instance.new("Sound", handle)
            swingSound.SoundId = "rbxassetid://12222216"
            swingSound.Volume = 1

            local damage = 25
            local cooldown = false

            tool.Activated:Connect(function()
                if cooldown then return end
                cooldown = true
                pcall(function() swingSound:Play() end)
                -- simple hit detection
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, part in pairs(workspace:GetDescendants()) do
                        if part:IsA("BasePart") and part.Parent and part.Parent:FindFirstChild("Humanoid") then
                            local hum = part.Parent:FindFirstChild("Humanoid")
                            local hrp = part.Parent:FindFirstChild("HumanoidRootPart")
                            if hum and hrp and char:FindFirstChild("HumanoidRootPart") then
                                local dist = (hrp.Position - char.HumanoidRootPart.Position).Magnitude
                                if dist <= 5 and part.Parent ~= char then
                                    pcall(function() hum:TakeDamage(damage) end)
                                end
                            end
                        end
                    end
                end
                wait(0.6)
                cooldown = false
            end)

            handles.Sword = function()
                pcall(function()
                    if tool and tool.Parent then tool:Destroy() end
                end)
            end
        end)
        if not ok then warn("Sword failed: "..tostring(err)) end
    else
        tryCleanup("Sword")
    end
end

-- Menu creation (4 columns, centered, draggable)
local function createMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name = "RedMenuAll"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local frameWidth = 320
    local frameHeight = 480

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
    frame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
    frame.BackgroundColor3 = Color3.fromRGB(145,20,20)
    frame.Parent = gui
    frame.AnchorPoint = Vector2.new(0,0)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,40)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundColor3 = Color3.fromRGB(190,30,30)
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Text = "🔴 RED MENU ALL-IN-ONE"
    title.Parent = frame

    local items = {
        {key="FlyV3", label="Fly V3"},{key="InfJump", label="InfJump"},
        {key="Shader", label="Shader"},{key="TeleportGUI", label="Teleport GUI"},
        {key="Speed", label="Speed"},{key="AntiAFK", label="Anti-AFK"},
        {key="BatTu", label="Bất tử"},{key="TanHinh", label="Tàn hình"},
        {key="Noclip", label="Noclip"},{key="WallWalk", label="Đi bộ trên tường"},
        {key="LowLag", label="Giảm lag"},{key="FeFlip", label="Lăn (feFlip)"},
        {key="ESP", label="ESP"},{key="KillAura", label="KillAura"},
        {key="BeACar", label="Be a Car"},{key="Bang", label="Bang"},
        {key="JerkOff", label="Jerk Off"},{key="Fighting", label="Fighting"},
        {key="Gun", label="Gun"},{key="Sword", label="Sword"}
    }

    local btnPadding = 8
    local btnHeight = 36
    local btnWidth = math.floor((frameWidth - btnPadding*5)/4)

    for i, info in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, btnWidth, 0, btnHeight)
        local col = (i-1) % 4
        local row = math.floor((i-1)/4)
        btn.Position = UDim2.new(0, btnPadding + col * (btnWidth + btnPadding),
                                 0, 44 + btnPadding + row * (btnHeight + btnPadding))
        btn.BackgroundColor3 = state[info.key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Text = info.label .. (state[info.key] and " [ON]" or " [OFF]")
        btn.Parent = frame

        btn.MouseButton1Click:Connect(function()
            state[info.key] = not state[info.key]
            btn.BackgroundColor3 = state[info.key] and Color3.fromRGB(20,140,20) or Color3.fromRGB(140,10,10)
            btn.Text = info.label .. (state[info.key] and " [ON]" or " [OFF]")
            pcall(function()
                if type(hooks[info.key]) == "function" then
                    hooks[info.key](state[info.key])
                else
                    warn("Hook missing for "..tostring(info.key))
                end
            end)
        end)
    end

    -- Drag setup (the snippet you asked to add)
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
print("✅ RedMenuAll final loaded (4-column, draggable, pcall-wrapped).")
