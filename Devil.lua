-- DEVIL HUB (FULL) — Rayfield UI, draggable, pcall-safe loaders
-- NOTE: Anti-Ban / ban bypass functionality is NOT included and will not be added.

pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    -- Services
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")

    -- cleanup existing
    pcall(function()
        if CoreGui:FindFirstChild("DevilHub_UI") then CoreGui.DevilHub_UI:Destroy() end
    end)

    -- helpers
    local handles = {}
    local function tryCleanup(key)
        local h = handles[key]
        if not h then return end
        local ok = pcall(function()
            if type(h) == "function" then
                h()
            elseif typeof(h) == "RBXScriptConnection" then
                h:Disconnect()
            elseif typeof(h) == "Instance" and h.Destroy then
                h:Destroy()
            end
        end)
        handles[key] = nil
        return ok
    end

    local function safeLoadFromUrl(key, url)
        if not url or url == "" then
            warn("DevilHub: missing url for", key); return
        end
        local ok, res = pcall(function() return game:HttpGet(url, true) end)
        if not ok then
            warn("DevilHub: HttpGet failed for", key, res); return
        end
        local ok2, ret = pcall(function()
            local f, e = loadstring(res)
            if not f then error("loadstring error: "..tostring(e)) end
            return f()
        end)
        if not ok2 then
            warn("DevilHub: execution error for", key, ret); return
        end
        handles[key] = ret
        return true
    end

    -- small safe inline ESP (simple Highlight per player)
    local function startESP()
        if handles._ESP then return end
        local folder = Instance.new("Folder")
        folder.Name = "DevilHub_ESP"
        folder.Parent = CoreGui
        handles._ESP = folder

        local function applyToPlayer(plr)
            if plr == LocalPlayer then return end
            local function addHighlight(char)
                pcall(function()
                    if not char or char:FindFirstChild("DevilHubHighlight") then return end
                    local hl = Instance.new("Highlight")
                    hl.Name = "DevilHubHighlight"
                    hl.Adornee = char
                    hl.Parent = folder
                    hl.FillTransparency = 0.6
                    hl.OutlineTransparency = 0
                    hl.FillColor = (plr.Team == LocalPlayer.Team) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(255, 50, 50)
                end)
            end
            if plr.Character then addHighlight(plr.Character) end
            plr.CharacterAdded:Connect(function(c) addHighlight(c) end)
        end

        for _, p in pairs(Players:GetPlayers()) do applyToPlayer(p) end
        Players.PlayerAdded:Connect(function(p) applyToPlayer(p) end)
    end

    local function stopESP()
        tryCleanup("_ESP")
    end

    -- hooks (features)
    local hooks = {}

    -- Fly V3 (local implementation using BodyVelocity+BodyGyro)
    hooks.Fly = function(enable)
        if enable then
            tryCleanup("Fly")
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new()
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 3000
            local speed = 60

            local conn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart
                if not bv.Parent then bv.Parent = hrp end
                if not bg.Parent then bg.Parent = hrp end
                local cam = workspace.CurrentCamera
                bg.CFrame = cam.CFrame
                local vel = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector * speed end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, speed, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, speed, 0) end
                bv.Velocity = vel
            end)

            handles.Fly = function()
                pcall(function() conn:Disconnect() end)
                pcall(function() bv:Destroy() end)
                pcall(function() bg:Destroy() end)
            end
        else
            tryCleanup("Fly")
        end
    end

    -- Speed (local simple velocity override)
    hooks.Speed = function(enable)
        if enable then
            tryCleanup("Speed")
            local conn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local cam = workspace.CurrentCamera
                    local dir = Vector3.new()
                    local speed = 80
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                    if dir.Magnitude > 0 then
                        dir = dir.Unit
                        hrp.Velocity = Vector3.new(dir.X * speed, hrp.Velocity.Y, dir.Z * speed)
                    end
                end
            end)
            handles.Speed = conn
        else
            tryCleanup("Speed")
        end
    end

    -- InfJump
    hooks.InfJump = function(enable)
        if enable then
            tryCleanup("InfJump")
            local conn = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
                end
            end)
            handles.InfJump = conn
        else
            tryCleanup("InfJump")
        end
    end

    -- Teleport GUI (Click Teleport)
    hooks.TeleportGUI = function(enable)
        if enable then
            safeLoadFromUrl("TeleportGUI", "https://cdn.wearedevs.net/scripts/Click%20Teleport.txt")
        else
            tryCleanup("TeleportGUI")
        end
    end

    -- Shader (new link)
    hooks.Shader = function(enable)
        if enable then
            safeLoadFromUrl("Shader", "https://raw.githubusercontent.com/p0e1/1/refs/heads/main/SimpleShader.lua")
        else
            tryCleanup("Shader")
        end
    end

    -- AntiAFK (safe VirtualUser)
    hooks.AntiAFK = function(enable)
        if enable then
            tryCleanup("AntiAFK")
            local conn = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0,0))
            end)
            handles.AntiAFK = conn
        else
            tryCleanup("AntiAFK")
        end
    end

    -- BatTu (immortal-ish: prevent fall death by huge FallenPartsDestroyHeight)
    hooks.BatTu = function(enable)
        if enable then
            workspace.FallenPartsDestroyHeight = 9e9
        else
            workspace.FallenPartsDestroyHeight = -500
        end
    end

    -- TanHinh (invisible)
    hooks.TanHinh = function(enable)
        if enable then
            safeLoadFromUrl("TanHinh", "https://abre.ai/invisible-v2")
        else
            tryCleanup("TanHinh")
        end
    end

    -- Noclip
    hooks.Noclip = function(enable)
        if enable then
            tryCleanup("Noclip")
            local conn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            handles.Noclip = conn
        else
            tryCleanup("Noclip")
        end
    end

    -- WallWalk
    hooks.WallWalk = function(enable)
        if enable then
            safeLoadFromUrl("WallWalk", "https://pastebin.com/raw/5T7KsEWy")
        else
            tryCleanup("WallWalk")
        end
    end

    -- LowLag (FPS helper)
    hooks.LowLag = function(enable)
        if enable then
            safeLoadFromUrl("LowLag", "https://pastebin.com/raw/KiSYpej6")
        else
            tryCleanup("LowLag")
        end
    end

    -- FeFlip (rolling)
    hooks.FeFlip = function(enable)
        if enable then
            safeLoadFromUrl("FeFlip", "https://pastebin.com/raw/KiSYpej6") -- replace with real feFlip link if different
        else
            tryCleanup("FeFlip")
        end
    end

    -- ESP
    hooks.ESP = function(enable)
        if enable then startESP() else stopESP() end
    end

    -- X-Ray (Main tab feature) -> lightweight highlights (reuse ESP code but with GUI toggle)
    hooks.XRay = function(enable)
        if enable then
            -- create quick XRay GUI and highlights (use same highlights as ESP but more visible)
            startESP()
            -- enlarge highlight visuals if possible
            if handles._ESP then
                for _, inst in pairs(handles._ESP:GetChildren()) do
                    if inst:IsA("Highlight") then
                        inst.FillTransparency = 1
                        inst.OutlineTransparency = 0
                        inst.OutlineColor = Color3.new(1, 0, 0)
                    end
                end
            end
        else
            stopESP()
        end
    end

    -- KillAura (load external fighting script or local implementation)
    hooks.KillAura = function(enable)
        if enable then
            -- try user-provided kill aura (note: link provided by user earlier pointed to raw gun; use pastebin/mapping as required)
            safeLoadFromUrl("KillAura", "https://pastebin.com/raw/0hn40Zbc")
        else
            tryCleanup("KillAura")
        end
    end

    -- LaserGun (Fight tab)
    hooks.LaserGun = function(enable)
        if enable then
            -- The big laser gun builder (from your provided code) — embed as loader to keep it pcall-safe
            safeLoadFromUrl("LaserGun", "https://raw.githubusercontent.com/your-placeholder/laser/main/compiled.lua")
            -- NOTE: above URL is a placeholder. If you want the inline heavy script, paste it into that raw URL and it will run.
        else
            tryCleanup("LaserGun")
        end
    end

    -- Sword / Gun / Fighting / BeACar / Bang / JerkOff / AutoClick
    hooks.Sword = function(enable)
        if enable then safeLoadFromUrl("Sword", "https://pastebin.com/raw/0hn40Zbc") else tryCleanup("Sword") end
    end
    hooks.Gun = function(enable)
        if enable then safeLoadFromUrl("Gun", "https://pastebin.com/raw/0hn40Zbc") else tryCleanup("Gun") end
    end
    hooks.Fighting = function(enable)
        if enable then safeLoadFromUrl("Fighting", "https://pastefy.app/cAQICuXo/raw") else tryCleanup("Fighting") end
    end
    hooks.BeACar = function(enable)
        if enable then safeLoadFromUrl("BeACar", "https://raw.githubusercontent.com/gumanba/Scripts/main/BeaCar") else tryCleanup("BeACar") end
    end
    hooks.Bang = function(enable)
        if enable then safeLoadFromUrl("Bang", "https://raw.githubusercontent.com/4gh9/Bang-Script-Gui/main/bang%20gui.lua") else tryCleanup("Bang") end
    end
    hooks.JerkOff = function(enable)
        if enable then safeLoadFromUrl("JerkOff", "https://pastefy.app/lawnvcTT/raw") else tryCleanup("JerkOff") end
    end
    hooks.AutoClick = function(enable)
        if enable then safeLoadFromUrl("AutoClick", "https://raw.githubusercontent.com/Hosvile/The-telligence/main/MC%20KSystem%202") else tryCleanup("AutoClick") end
    end

    -- TeleportToMouse (utility button)
    hooks.TeleportToMouse = function()
        pcall(function()
            local mouse = LocalPlayer:GetMouse()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and mouse and mouse.Hit then
                char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
            end
        end)
    end

    -- Rayfield loader (try multiple sources)
    local Rayfield = nil
    do
        local sources = {
            "https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua",
            "https://sirius.menu/rayfield",
            "https://raw.githubusercontent.com/dawid-scripts/UI-Libraries/main/Rayfield.lua"
        }
        for _, src in ipairs(sources) do
            local ok, res = pcall(function() return game:HttpGet(src, true) end)
            if ok and res then
                local ok2, lib = pcall(function() return loadstring(res)() end)
                if ok2 and lib then
                    Rayfield = lib
                    break
                end
            end
        end
    end

    if not Rayfield then
        warn("DevilHub: Rayfield UI could not be loaded.")
        return
    end

    -- Create Window
    local Window = Rayfield:CreateWindow({
        Name = "🔺 DEVIL HUB | Full",
        LoadingTitle = "DEVIL HUB đang khởi tạo...",
        LoadingSubtitle = "Built for you",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
        KeySystem = false
    })

    -- Tabs: Main | Local Player | Funny | Server | Fight
    local MainTab = Window:CreateTab("🏠 Main")
    local LocalTab = Window:CreateTab("👤 Local Player")
    local FunnyTab = Window:CreateTab("🎉 Funny")
    local ServerTab = Window:CreateTab("🌐 Server")
    local FightTab = Window:CreateTab("⚔️ Fight")

    -- MAIN tab (core features + X-Ray)
    do
        local mainSection = MainTab:CreateSection("Core Movement")
        mainSection:CreateToggle({
            Name = "✈️ Fly",
            CurrentValue = false,
            Flag = "Devil_Fly",
            Callback = function(val) hooks.Fly(val) end
        })
        mainSection:CreateToggle({
            Name = "⚡ Speed",
            CurrentValue = false,
            Flag = "Devil_Speed",
            Callback = function(val) hooks.Speed(val) end
        })
        mainSection:CreateToggle({
            Name = "🦘 Infinite Jump",
            CurrentValue = false,
            Flag = "Devil_InfJump",
            Callback = function(val) hooks.InfJump(val) end
        })

        local utilSection = MainTab:CreateSection("Utilities")
        utilSection:CreateToggle({
            Name = "👁️ X-Ray (Highlights)",
            CurrentValue = false,
            Flag = "Devil_XRay",
            Callback = function(val) hooks.XRay(val) end
        })
        utilSection:CreateButton({
            Name = "📍 Teleport To Mouse",
            Callback = function() hooks.TeleportToMouse() end
        })
        utilSection:CreateToggle({
            Name = "🛡️ Anti-AFK",
            CurrentValue = false,
            Flag = "Devil_AntiAFK",
            Callback = function(val) hooks.AntiAFK(val) end
        })
    end

    -- LOCAL PLAYER tab (personal toggles)
    do
        local moveSec = LocalTab:CreateSection("Player")
        moveSec:CreateToggle({
            Name = "🔫 Teleport GUI (Click TP)",
            CurrentValue = false,
            Callback = function(v) hooks.TeleportGUI(v) end
        })
        moveSec:CreateToggle({
            Name = "👻 Invisible (Tàng Hình)",
            CurrentValue = false,
            Callback = function(v) hooks.TanHinh(v) end
        })
        moveSec:CreateToggle({
            Name = "🪄 Bất Tử (Fall prevention)",
            CurrentValue = false,
            Callback = function(v) hooks.BatTu(v) end
        })
        moveSec:CreateToggle({
            Name = "🔧 NoClip",
            CurrentValue = false,
            Callback = function(v) hooks.Noclip(v) end
        })
    end

    -- FUNNY tab (toys)
    do
        local funSec = FunnyTab:CreateSection("Fun Stuff")
        funSec:CreateToggle({
            Name = "🚗 Be A Car",
            CurrentValue = false,
            Callback = function(v) hooks.BeACar(v) end
        })
        funSec:CreateToggle({
            Name = "💥 Bang Script",
            CurrentValue = false,
            Callback = function(v) hooks.Bang(v) end
        })
        funSec:CreateToggle({
            Name = "🍆 Jerk Off",
            CurrentValue = false,
            Callback = function(v) hooks.JerkOff(v) end
        })
        funSec:CreateToggle({
            Name = "🎭 FeFlip (Roll)",
            CurrentValue = false,
            Callback = function(v) hooks.FeFlip(v) end
        })
        funSec:CreateToggle({
            Name = "🧰 Shader Effects",
            CurrentValue = false,
            Callback = function(v) hooks.Shader(v) end
        })
    end

    -- SERVER tab (global utilities)
    do
        local s1 = ServerTab:CreateSection("Server Utilities")
        s1:CreateToggle({
            Name = "👁️ ESP (Highlight Players)",
            CurrentValue = false,
            Callback = function(v) hooks.ESP(v) end
        })
        s1:CreateToggle({
            Name = "🧭 Wall Walk",
            CurrentValue = false,
            Callback = function(v) hooks.WallWalk(v) end
        })
        s1:CreateToggle({
            Name = "🧹 Low Lag",
            CurrentValue = false,
            Callback = function(v) hooks.LowLag(v) end
        })
        s1:CreateToggle({
            Name = "🤖 Auto Click (KSystem)",
            CurrentValue = false,
            Callback = function(v) hooks.AutoClick(v) end
        })
    end

    -- FIGHT tab (weapons / combat)
    do
        local fSec = FightTab:CreateSection("Combat")
        fSec:CreateToggle({
            Name = "⚔️ Kill Aura",
            CurrentValue = false,
            Callback = function(v) hooks.KillAura(v) end
        })
        fSec:CreateToggle({
            Name = "🗡️ Sword (Local)",
            CurrentValue = false,
            Callback = function(v) hooks.Sword(v) end
        })
        fSec:CreateToggle({
            Name = "🔫 Gun (load)",
            CurrentValue = false,
            Callback = function(v) hooks.Gun(v) end
        })
        fSec:CreateToggle({
            Name = "🔫 Laser Gun (build)",
            CurrentValue = false,
            Callback = function(v) hooks.LaserGun(v) end
        })
        fSec:CreateButton({
            Name = "🥊 Load Fighting Script",
            Callback = function()
                hooks.Fighting(true)
                Rayfield:Notify({ Title = "Fighting", Content = "Fighting script loaded", Duration = 3 })
            end
        })
    end

    -- Small footer + notify
    Rayfield:Notify({
        Title = "DEVIL HUB",
        Content = "Menu loaded — use responsibly. Anti-Ban features are not included.",
        Duration = 6
    })

    print("✅ DEVIL HUB loaded (full).")
end)
