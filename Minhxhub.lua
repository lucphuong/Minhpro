-- MINH HUB - ĐÃ THÊM X-RAY VÀ LASER GUN
pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = Players.LocalPlayer

    print("🔧 Đang khởi tạo Minh Hub...")

    -- Clean previous
    pcall(function()
        if game.CoreGui:FindFirstChild("RedHub_Toggle") then 
            game.CoreGui.RedHub_Toggle:Destroy() 
        end
    end)

    -- Handles and cleanup system
    local handles = {}
    local function tryCleanup(key)
        if handles[key] then
            if type(handles[key]) == "function" then
                pcall(handles[key])
            elseif typeof(handles[key]) == "RBXScriptConnection" then
                pcall(function() handles[key]:Disconnect() end)
            elseif typeof(handles[key]) == "Instance" then
                pcall(function() handles[key]:Destroy() end)
            end
            handles[key] = nil
        end
    end

    local function safeLoadFromUrl(key, url)
        if not url or url == "" then return end
        local ok, res = pcall(function() return game:HttpGet(url, true) end)
        if not ok then return end
        local ok2, ret = pcall(function()
            local f = loadstring(res)
            if f then return f() end
        end)
        if ok2 then
            handles[key] = ret
        end
    end

    -- Hooks functions
    local hooks = {}

    -- FLY V3
    hooks.FlyV3 = function(enable)
        print("🔄 FlyV3: " .. tostring(enable))
        if enable then
            tryCleanup("FlyV3")
            
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
            bodyGyro.P = 1000
            
            local flySpeed = 50
            
            local function startFlying()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then 
                    return 
                end
                
                local humanoidRootPart = character.HumanoidRootPart
                bodyVelocity.Parent = humanoidRootPart
                bodyGyro.Parent = humanoidRootPart
                
                local flyConnection = RunService.Heartbeat:Connect(function()
                    if not character or not humanoidRootPart then return end
                    
                    local camera = workspace.CurrentCamera
                    bodyGyro.CFrame = camera.CFrame
                    
                    local velocity = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        velocity = velocity + camera.CFrame.LookVector * flySpeed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        velocity = velocity - camera.CFrame.LookVector * flySpeed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        velocity = velocity - camera.CFrame.RightVector * flySpeed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        velocity = velocity + camera.CFrame.RightVector * flySpeed
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        velocity = velocity + Vector3.new(0, flySpeed, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        velocity = velocity - Vector3.new(0, flySpeed, 0)
                    end
                    
                    bodyVelocity.Velocity = velocity
                end)
                
                handles["FlyV3"] = function()
                    flyConnection:Disconnect()
                    bodyVelocity:Destroy()
                    bodyGyro:Destroy()
                end
            end
            
            startFlying()
            
        else
            tryCleanup("FlyV3")
        end
    end

    -- SPEED
    hooks.Speed = function(enable)
        print("🔄 Speed: " .. tostring(enable))
        if enable then
            tryCleanup("Speed")
            
            local speedConnection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.new(0, 0, 0)
                    local speed = 50
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + cam.CFrame.RightVector
                    end
                    
                    if moveDir.Magnitude > 0 then
                        moveDir = moveDir.Unit
                        hrp.Velocity = Vector3.new(moveDir.X * speed, hrp.Velocity.Y, moveDir.Z * speed)
                    end
                end
            end)
            
            handles["Speed"] = speedConnection
            
        else
            tryCleanup("Speed")
        end
    end

    -- INFINITE JUMP
    hooks.InfJump = function(enable)
        print("🔄 InfJump: " .. tostring(enable))
        if enable then
            tryCleanup("InfJump")
            
            local jumpConnection = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then 
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            
            handles["InfJump"] = jumpConnection
            
        else
            tryCleanup("InfJump")
        end
    end

    -- NOCLIP
    hooks.Noclip = function(enable)
        print("🔄 Noclip: " .. tostring(enable))
        if enable then
            tryCleanup("Noclip")
            
            local noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            
            handles["Noclip"] = noclipConnection
            
        else
            tryCleanup("Noclip")
        end
    end

    -- BAT TU (IMMORTAL)
    hooks.BatTu = function(enable)
        print("🔄 BatTu: " .. tostring(enable))
        if enable then 
            workspace.FallenPartsDestroyHeight = 9e9
        else 
            workspace.FallenPartsDestroyHeight = -500 
        end
    end

    -- TAN HINH (INVISIBLE)
    hooks.TanHinh = function(enable)
        print("🔄 TanHinh: " .. tostring(enable))
        if enable then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = 1
                    end
                end
            end
        else
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                    elseif part:IsA("Decal") then
                        part.Transparency = 0
                    end
                end
            end
        end
    end

    -- ANTI-AFK
    hooks.AntiAFK = function(enable)
        print("🔄 AntiAFK: " .. tostring(enable))
        if enable then
            tryCleanup("AntiAFK")
            
            local afkConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            
            handles["AntiAFK"] = afkConnection
            
        else
            tryCleanup("AntiAFK")
        end
    end

    -- ESP
    hooks.ESP = function(enable)
        print("🔄 ESP: " .. tostring(enable))
        if enable then
            tryCleanup("ESP")
            
            local folder = Instance.new("Folder")
            folder.Name = "MinhHub_ESP"
            if syn and syn.protect_gui then
                syn.protect_gui(folder)
            end
            folder.Parent = game.CoreGui
            
            local function applyESP(player)
                if player == LocalPlayer then return end
                
                local function addHighlight(char)
                    if char and not char:FindFirstChild("MinhHub_Highlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "MinhHub_Highlight"
                        highlight.Adornee = char
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.Parent = folder
                    end
                end
                
                if player.Character then
                    addHighlight(player.Character)
                end
                
                player.CharacterAdded:Connect(addHighlight)
            end
            
            for _, player in pairs(Players:GetPlayers()) do
                applyESP(player)
            end
            
            Players.PlayerAdded:Connect(applyESP)
            
            handles["ESP"] = folder
            
        else
            tryCleanup("ESP")
        end
    end

    -- X-RAY (CHỨC NĂNG MỚI)
    hooks.XRay = function(enable)
        print("🔄 XRay: " .. tostring(enable))
        if enable then
            tryCleanup("XRay")
            
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "MinhHub_XRay"
            if syn and syn.protect_gui then
                syn.protect_gui(screenGui)
            end
            screenGui.Parent = game.CoreGui

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 200, 0, 150)
            frame.Position = UDim2.new(0.5, -100, 0.5, -75)
            frame.BackgroundTransparency = 0.5
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.Draggable = true
            frame.Active = true
            frame.Visible = true
            frame.Parent = screenGui

            local xrayButton = Instance.new("TextButton")
            xrayButton.Size = UDim2.new(0, 180, 0, 50)
            xrayButton.Position = UDim2.new(0, 10, 0, 25)
            xrayButton.BackgroundColor3 = Color3.new(1, 0, 0)
            xrayButton.Text = "Enable X-Ray"
            xrayButton.TextColor3 = Color3.new(1, 1, 1)
            xrayButton.Font = Enum.Font.GothamBold
            xrayButton.TextSize = 14
            xrayButton.Parent = frame

            local disableXrayButton = Instance.new("TextButton")
            disableXrayButton.Size = UDim2.new(0, 180, 0, 50)
            disableXrayButton.Position = UDim2.new(0, 10, 0, 85)
            disableXrayButton.BackgroundColor3 = Color3.new(0, 1, 0)
            disableXrayButton.Text = "Disable X-Ray"
            disableXrayButton.TextColor3 = Color3.new(1, 1, 1)
            disableXrayButton.Font = Enum.Font.GothamBold
            disableXrayButton.TextSize = 14
            disableXrayButton.Visible = false
            disableXrayButton.Parent = frame

            local highlights = {}

            local function highlightPlayers()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local character = player.Character
                        if character then
                            local highlight = Instance.new("Highlight")
                            highlight.Adornee = character
                            highlight.FillTransparency = 1
                            highlight.OutlineTransparency = 0
                            highlight.OutlineColor = Color3.new(1, 0, 0)
                            highlight.Parent = character
                            table.insert(highlights, highlight)
                        end
                    end
                end
            end

            local function removeHighlights()
                for _, highlight in pairs(highlights) do
                    if highlight then
                        highlight:Destroy()
                    end
                end
                highlights = {}
            end

            xrayButton.MouseButton1Click:Connect(function()
                highlightPlayers()
                xrayButton.Visible = false
                disableXrayButton.Visible = true
            end)

            disableXrayButton.MouseButton1Click:Connect(function()
                removeHighlights()
                xrayButton.Visible = true
                disableXrayButton.Visible = false
            end)

            handles["XRay"] = function()
                removeHighlights()
                screenGui:Destroy()
            end
            
        else
            tryCleanup("XRay")
        end
    end

    -- LASER GUN (CHỨC NĂNG MỚI)
    hooks.LaserGun = function(enable)
        print("🔄 LaserGun: " .. tostring(enable))
        if enable then
            tryCleanup("LaserGun")
            
            -- Laser Gun Script
            local function createLaserGun()
                local runDummyScript = function(f,scri)
                    local oldenv = getfenv(f)
                    local newenv = setmetatable({}, {
                        __index = function(_, k)
                            if k:lower() == 'script' then
                                return scri
                            else
                                return oldenv[k]
                            end
                        end
                    })
                    setfenv(f, newenv)
                    pcall(function() f() end)
                end
                
                local cors = {}
                local mas = Instance.new("Model",game:GetService("Lighting")) 
                mas.Name = "CompiledModel"
                
                -- Tạo tool
                local o1 = Instance.new("Tool")
                local o2 = Instance.new("Part")
                local o3 = Instance.new("SpecialMesh")
                local o4 = Instance.new("Sound")
                local o5 = Instance.new("Sound")
                local o6 = Instance.new("PointLight")
                local o8 = Instance.new("LocalScript")
                local o9 = Instance.new("Sound")
                local o10 = Instance.new("LocalScript")
                local o11 = Instance.new("Script")
                
                o1.Name = "LaserGun"
                o1.Parent = mas
                o1.TextureId = "http://www.roblox.com/asset?id=13838639"
                o1.GripPos = Vector3.new(0, -0.100000001, 0.75)
                o1.CanBeDropped = false
                
                o2.Name = "Handle"
                o2.Parent = o1
                o2.Position = Vector3.new(6.44000006, 0.670018971, 89.4400024)
                o2.Rotation = Vector3.new(-180, 0, -180)
                o2.CanCollide = false
                o2.FormFactor = Enum.FormFactor.Custom
                o2.Size = Vector3.new(0.580000222, 1.34000099, 2.48000145)
                o2.CFrame = CFrame.new(6.44000006, 0.670018971, 89.4400024, -1, 0, 0, 0, 1, 0, 0, 0, -1)
                o2.BottomSurface = Enum.SurfaceType.Smooth
                o2.TopSurface = Enum.SurfaceType.Smooth
                
                o3.Parent = o2
                o3.MeshId = "http://www.roblox.com/asset?id=130099641"
                o3.Scale = Vector3.new(0.649999976, 0.649999976, 0.649999976)
                o3.TextureId = "http://www.roblox.com/asset/?id=130267361"
                o3.MeshType = Enum.MeshType.FileMesh
                
                o4.Name = "Fire"
                o4.Parent = o2
                o4.Pitch = 1.2000000476837
                o4.SoundId = "http://www.roblox.com/asset?id=114488148"
                o4.Volume = 1
                
                o5.Name = "Reload"
                o5.Parent = o2
                o5.Pitch = 0.5
                o5.SoundId = "http://www.roblox.com/asset?id=94255248"
                
                o6.Parent = o2
                o6.Color = Color3.new(1, 0, 0)
                o6.Brightness = 50
                o6.Range = 10
                
                -- Tool Script
                o8.Name = "ToolScript"
                o8.Parent = o1
                table.insert(cors,coroutine.create(function()
                    wait()
                    runDummyScript(function()
                        local SHOT_SPEED = 100
                        local SHOT_TIME = 1000
                        local NOZZLE_OFFSET = Vector3.new(0, 0.4, -1.1)
                        
                        local PlayersService = game:GetService('Players')
                        local DebrisService = game:GetService('Debris')
                        
                        local Tool = script.Parent
                        local Handle = Tool:WaitForChild('Handle')
                        local FireSound = Handle:WaitForChild('Fire')
                        local ReloadSound = Handle:WaitForChild('Reload')
                        
                        local Character = nil
                        local Humanoid = nil
                        local Player = nil
                        
                        local BaseShot = Instance.new('Part')
                        BaseShot.Name = 'Effect'
                        BaseShot.FormFactor = Enum.FormFactor.Custom
                        BaseShot.Size = Vector3.new(0.2, 0.2, 3)
                        BaseShot.CanCollide = false
                        BaseShot.BrickColor = BrickColor.new('Really red')
                        BaseShot.Material = Enum.Material.Neon
                        
                        local function OnTouched(shot, otherPart)
                            if otherPart and otherPart.Parent and otherPart.Parent ~= Character then
                                local humanoid = otherPart.Parent:FindFirstChildOfClass('Humanoid')
                                if humanoid then
                                    humanoid:TakeDamage(50)
                                    if shot then
                                        shot:Destroy()
                                    end
                                end
                            end
                        end
                        
                        local function OnEquipped()
                            Character = Tool.Parent
                            Humanoid = Character:WaitForChild('Humanoid')
                            Player = PlayersService:GetPlayerFromCharacter(Character)
                        end
                        
                        local function OnActivated()
                            if Tool.Enabled and Humanoid and Humanoid.Health > 0 then
                                Tool.Enabled = false
                                FireSound:Play()
                                
                                local handleCFrame = Handle.CFrame
                                local firingPoint = handleCFrame.p + handleCFrame:vectorToWorldSpace(NOZZLE_OFFSET)
                                local shotCFrame = CFrame.new(firingPoint, Humanoid.TargetPoint)
                                
                                local laserShotClone = BaseShot:Clone()
                                laserShotClone.CFrame = shotCFrame + (shotCFrame.lookVector * (BaseShot.Size.Z / 2))
                                local bodyVelocity = Instance.new('BodyVelocity')
                                bodyVelocity.velocity = shotCFrame.lookVector * SHOT_SPEED
                                bodyVelocity.Parent = laserShotClone
                                laserShotClone.Touched:connect(function(otherPart)
                                    OnTouched(laserShotClone, otherPart)
                                end)
                                DebrisService:AddItem(laserShotClone, SHOT_TIME)
                                laserShotClone.Parent = Tool
                                
                                wait(0.5)
                                ReloadSound:Play()
                                wait(0.5)
                                Tool.Enabled = true
                            end
                        end
                        
                        Tool.Equipped:connect(OnEquipped)
                        Tool.Activated:connect(OnActivated)
                    end, o8)
                end))
                
                o9.Name = "HitFade"
                o9.Parent = o8
                o9.SoundId = "http://www.roblox.com/asset?id=130113415"
                
                -- Thêm vào backpack
                mas.Parent = workspace
                local mas1 = mas:GetChildren()
                for i=1,#mas1 do
                    mas1[i].Parent = LocalPlayer.Backpack 
                    pcall(function() mas1[i]:MakeJoints() end)
                end
                mas:Destroy()
                
                for i=1,#cors do
                    coroutine.resume(cors[i])
                end
                
                return o1
            end
            
            local gun = createLaserGun()
            handles["LaserGun"] = function()
                if gun then
                    gun:Destroy()
                end
            end
            
        else
            tryCleanup("LaserGun")
        end
    end

    -- CÁC HOOKS KHÁC
    hooks.WallWalk = function(enable)
        if enable then safeLoadFromUrl("WallWalk", "https://pastebin.com/raw/5T7KsEWy")
        else tryCleanup("WallWalk") end
    end

    hooks.LowLag = function(enable)
        if enable then safeLoadFromUrl("LowLag", "https://pastebin.com/raw/KiSYpej6")
        else tryCleanup("LowLag") end
    end

    hooks.TeleportGUI = function(enable)
        if enable then safeLoadFromUrl("TeleportGUI", "https://cdn.wearedevs.net/scripts/Click%20Teleport.txt")
        else tryCleanup("TeleportGUI") end
    end

    hooks.KillAura = function(enable)
        if enable then safeLoadFromUrl("KillAura", "https://pastebin.com/raw/0hn40Zbc")
        else tryCleanup("KillAura") end
    end

    hooks.Sword = function(enable)
        if enable then safeLoadFromUrl("Sword", "https://pastebin.com/raw/0hn40Zbc")
        else tryCleanup("Sword") end
    end

    hooks.Gun = function(enable)
        if enable then safeLoadFromUrl("Gun", "https://pastebin.com/raw/0hn40Zbc")
        else tryCleanup("Gun") end
    end

    hooks.Fighting = function(enable)
        if enable then safeLoadFromUrl("Fighting", "https://pastefy.app/cAQICuXo/raw")
        else tryCleanup("Fighting") end
    end

    hooks.FeFlip = function(enable)
        if enable then safeLoadFromUrl("FeFlip", "https://pastebin.com/raw/KiSYpej6")
        else tryCleanup("FeFlip") end
    end

    hooks.Shader = function(enable)
        if enable then safeLoadFromUrl("Shader", "https://raw.githubusercontent.com/p0e1/1/refs/heads/main/SimpleShader.lua")
        else tryCleanup("Shader") end
    end

    hooks.BeACar = function(enable)
        if enable then safeLoadFromUrl("BeACar", "https://raw.githubusercontent.com/gumanba/Scripts/main/BeaCar")
        else tryCleanup("BeACar") end
    end

    hooks.Bang = function(enable)
        if enable then safeLoadFromUrl("Bang", "https://raw.githubusercontent.com/4gh9/Bang-Script-Gui/main/bang%20gui.lua")
        else tryCleanup("Bang") end
    end

    hooks.JerkOff = function(enable)
        if enable then safeLoadFromUrl("JerkOff", "https://pastefy.app/lawnvcTT/raw")
        else tryCleanup("JerkOff") end
    end

    hooks.TeleportToMouse = function()
        pcall(function()
            local mouse = LocalPlayer:GetMouse()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and mouse and mouse.Hit then
                char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
            end
        end)
    end

    print("✅ Tất cả hooks đã được khởi tạo!")

    -- Load Rayfield
    local Rayfield = nil
    pcall(function()
        local rayfieldSources = {
            "https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua",
            "https://sirius.menu/rayfield",
            "https://raw.githubusercontent.com/dawid-scripts/UI-Libraries/main/Rayfield.lua"
        }
        
        for _, source in ipairs(rayfieldSources) do
            local success, result = pcall(function()
                local response = game:HttpGet(source)
                return loadstring(response)()
            end)
            
            if success and result then
                Rayfield = result
                break
            end
        end
    end)

    if not Rayfield then
        warn("❌ Rayfield không load được")
        return
    end

    print("✅ Rayfield loaded!")

    -- Tạo Window
    local Window = Rayfield:CreateWindow({
        Name = "🔴 MINH HUB | Premium",
        LoadingTitle = "Minh Hub đang tải...",
        LoadingSubtitle = "By Minh",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
        KeySystem = false
    })

    -- TABS
    local PlayerTab = Window:CreateTab("👤 Người Chơi")
    local ServerTab = Window:CreateTab("🌐 Server")
    local CombatTab = Window:CreateTab("⚔️ Chiến Đấu")
    local VisualTab = Window:CreateTab("👁️ Đồ Họa")
    local FunTab = Window:CreateTab("🎉 Vui Vẻ")

    -- State management
    local States = {}

    -- TAB NGƯỜI CHƠI
    local MovementSection = PlayerTab:CreateSection("Di Chuyển")
    
    MovementSection:CreateToggle({
        Name = "🏃‍♂️ Tốc Độ",
        CurrentValue = false,
        Callback = function(Value)
            print("🎯 Speed toggle: " .. tostring(Value))
            States.Speed = Value
            hooks.Speed(Value)
        end,
    })

    MovementSection:CreateToggle({
        Name = "🪽 Bay V3", 
        CurrentValue = false,
        Callback = function(Value)
            print("🎯 FlyV3 toggle: " .. tostring(Value))
            States.FlyV3 = Value
            hooks.FlyV3(Value)
        end,
    })

    MovementSection:CreateToggle({
        Name = "🎯 Infinite Jump",
        CurrentValue = false,
        Callback = function(Value)
            print("🎯 InfJump toggle: " .. tostring(Value))
            States.InfJump = Value
            hooks.InfJump(Value)
        end,
    })

    MovementSection:CreateToggle({
        Name = "👻 NoClip",
        CurrentValue = false,
        Callback = function(Value)
            print("🎯 Noclip toggle: " .. tostring(Value))
            States.Noclip = Value
            hooks.Noclip(Value)
        end,
    })

    MovementSection:CreateToggle({
        Name = "🕷️ Đi Trên Tường",
        CurrentValue = false,
        Callback = function(Value)
            States.WallWalk = Value
            hooks.WallWalk(Value)
        end,
    })

    local ImmortalSection = PlayerTab:CreateSection("Bất Tử & Ẩn Thân")

    ImmortalSection:CreateToggle({
        Name = "💀 Bất Tử",
        CurrentValue = false,
        Callback = function(Value)
            States.BatTu = Value
            hooks.BatTu(Value)
        end,
    })

    ImmortalSection:CreateToggle({
        Name = "🔮 Tàng Hình", 
        CurrentValue = false,
        Callback = function(Value)
            States.TanHinh = Value
            hooks.TanHinh(Value)
        end,
    })

    local UtilitySection = PlayerTab:CreateSection("Tiện Ích")

    UtilitySection:CreateToggle({
        Name = "🛡️ Anti-AFK",
        CurrentValue = false,
        Callback = function(Value)
            States.AntiAFK = Value
            hooks.AntiAFK(Value)
        end,
    })

    UtilitySection:CreateToggle({
        Name = "⚡ Giảm Lag",
        CurrentValue = false,
        Callback = function(Value)
            States.LowLag = Value
            hooks.LowLag(Value)
        end,
    })

    -- TAB SERVER
    local ESPsection = ServerTab:CreateSection("ESP & Highlight")

    ESPsection:CreateToggle({
        Name = "👁️ ESP Người Chơi",
        CurrentValue = false,
        Callback = function(Value)
            States.ESP = Value
            hooks.ESP(Value)
        end,
    })

    -- THÊM X-RAY VÀO TAB SERVER
    ESPsection:CreateToggle({
        Name = "🔍 X-Ray Vision",
        CurrentValue = false,
        Callback = function(Value)
            States.XRay = Value
            hooks.XRay(Value)
        end,
    })

    local TeleportSection = ServerTab:CreateSection("Teleport")

    TeleportSection:CreateButton({
        Name = "📦 Teleport GUI",
        Callback = function()
            hooks.TeleportGUI(true)
            Rayfield:Notify({
                Title = "Teleport GUI",
                Content = "Đã tải Teleport GUI!",
                Duration = 3,
            })
        end,
    })

    TeleportSection:CreateButton({
        Name = "📍 Teleport To Mouse",
        Callback = function()
            hooks.TeleportToMouse()
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Đã teleport đến vị trí chuột!",
                Duration = 2,
            })
        end,
    })

    -- TAB CHIẾN ĐẤU
    local CombatSection = CombatTab:CreateSection("Chiến Đấu Cơ Bản")

    CombatSection:CreateToggle({
        Name = "⚡ Kill Aura",
        CurrentValue = false,
        Callback = function(Value)
            States.KillAura = Value
            hooks.KillAura(Value)
        end,
    })

    CombatSection:CreateToggle({
        Name = "🗡️ Sword (Local)",
        CurrentValue = false,
        Callback = function(Value)
            States.Sword = Value
            hooks.Sword(Value)
        end,
    })

    -- THÊM LASER GUN VÀO TAB CHIẾN ĐẤU
    CombatSection:CreateToggle({
        Name = "🔫 Laser Gun",
        CurrentValue = false,
        Callback = function(Value)
            States.LaserGun = Value
            hooks.LaserGun(Value)
        end,
    })

    CombatSection:CreateButton({
        Name = "🔫 Tải Gun Script",
        Callback = function()
            hooks.Gun(true)
            Rayfield:Notify({
                Title = "Gun Script",
                Content = "Đã tải gun script thành công!",
                Duration = 3,
            })
        end,
    })

    CombatSection:CreateButton({
        Name = "🥊 Tải Fighting Script",
        Callback = function()
            hooks.Fighting(true)
            Rayfield:Notify({
                Title = "Fighting Script",
                Content = "Đã tải fighting script!",
                Duration = 3,
            })
        end,
    })

    CombatSection:CreateToggle({
        Name = "🤸 Lăn (FeFlip)",
        CurrentValue = false,
        Callback = function(Value)
            States.FeFlip = Value
            hooks.FeFlip(Value)
        end,
    })

    -- TAB ĐỒ HỌA
    local VisualSection = VisualTab:CreateSection("Hiệu Ứng Đồ Họa")

    VisualSection:CreateToggle({
        Name = "🎨 Shader Effects",
        CurrentValue = false,
        Callback = function(Value)
            States.Shader = Value
            hooks.Shader(Value)
        end,
    })

    -- TAB VUI VẺ
    local FunSection = FunTab:CreateSection("Tính Năng Vui")

    FunSection:CreateToggle({
        Name = "🚗 Biến Thành Xe",
        CurrentValue = false,
        Callback = function(Value)
            States.BeACar = Value
            hooks.BeACar(Value)
        end,
    })

    FunSection:CreateToggle({
        Name = "💥 Bang Script",
        CurrentValue = false,
        Callback = function(Value)
            States.Bang = Value
            hooks.Bang(Value)
        end,
    })

    FunSection:CreateToggle({
        Name = "🍆 Jerk Off",
        CurrentValue = false,
        Callback = function(Value)
            States.JerkOff = Value
            hooks.JerkOff(Value)
        end,
    })

    -- Notify khi load xong
    Rayfield:Notify({
        Title = "Minh Hub",
        Content = "Menu đã tải thành công! Đã thêm X-Ray và Laser Gun!",
        Duration = 6,
    })

    print("✅ Minh Hub loaded hoàn toàn! Đã thêm X-Ray và Laser Gun!")
end)
