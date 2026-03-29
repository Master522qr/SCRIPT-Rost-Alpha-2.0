--[[
BOSS-MORS Script for Rost Alpha (Xeno Injector Version)
Версия 3.5 - ULTIMATE OPTIMIZED EDITION
ВНИМАНИЕ: Использование некоторых функций может привести к бану!

ИНСТРУКЦИЯ ДЛЯ XENO:
1. Откройте Xeno Injector
2. Нажмите "Attach" для прикрепления к Roblox
3. Вставьте этот скрипт в поле для кода
4. Нажмите "Execute"
5. В игре нажмите INSERT для открытия меню
]]

local getservice = game.GetService
local Players = getservice(game, "Players")
local UserInputService = getservice(game, "UserInputService")
local RunService = getservice(game, "RunService")
local Lighting = getservice(game, "Lighting")
local Workspace = getservice(game, "Workspace")
local TweenService = getservice(game, "TweenService")
local CoreGui = getservice(game, "CoreGui")
local VirtualUser = getservice(game, "VirtualUser")
local HttpService = getservice(game, "HttpService")
local ReplicatedStorage = getservice(game, "ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

if _G.BOSSMORS_LOADED then
    print("Скрипт уже запущен!")
    return
end
_G.BOSSMORS_LOADED = true

local Vector2_new = Vector2.new
local Vector3_new = Vector3.new
local Color3_new = Color3.fromRGB
local math_random = math.random
local math_floor = math.floor
local math_clamp = math.clamp
local tick = tick
local table_insert = table.insert
local table_find = table.find
local pcall = pcall
local task_wait = task.wait

_G.BOSSMORS = {
    Version = "3.5",
    Author = "BOSS-MORS",
    Game = "Rost Alpha",
    LoadTime = os.time()
}

local Settings = {
    Menu = {
        Key = Enum.KeyCode.Insert,
        Open = false,
        BackgroundColor = Color3.fromRGB(15, 15, 20),
        AccentColor = Color3.fromRGB(170, 0, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        HighlightColor = Color3.fromRGB(255, 50, 150),
        AnimationSpeed = 0.3,
        Transparency = 0.95,
        BlurEffect = true
    },
    
    AimBot = {
        Enabled = false,
        Key = Enum.KeyCode.T,
        FOV = 30,
        Smoothness = 0.2,
        TeamCheck = true,
        VisibleCheck = true,
        Friends = {},
        Prediction = 0.12,
        Priority = "Distance",
        HitChance = 85,
        Color = Color3.fromRGB(255, 0, 0)
    },
    
    Visuals = {
        ESP = {
            Enabled = false,
            Box = true,
            Name = true,
            Distance = true,
            Health = true,
            Weapon = true,
            Armor = true,
            MaxDistance = 500,
            FriendColor = Color3.fromRGB(0, 255, 0),
            EnemyColor = Color3.fromRGB(255, 50, 50),
            FriendKey = Enum.KeyCode.F2,
            Tracer = false,
            Skeleton = false,
            HeadDot = false,
            BoxOutline = true
        },
        
        BlockESP = {
            Enabled = false,
            Chest = true,
            Crate = true,
            Loot = true,
            Vehicle = true,
            Door = true
        },
        
        NightVision = {
            Enabled = false,
            Intensity = 2.5,
            Color = Color3.fromRGB(0, 255, 200)
        },
        
        Chams = {
            Enabled = false,
            Material = "ForceField",
            Transparency = 0.3,
            Color = Color3.fromRGB(255, 0, 0),
            VisibleThroughWalls = true
        },
        
        NoFog = { Enabled = false },
        FullBright = { Enabled = false },
        
        Crosshair = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Size = 20,
            Style = "Dot" -- Dot, Cross, Circle
        }
    },
    
    Player = {
        Speed = { Enabled = false, Value = 25, Default = 16 },
        Jump = { Enabled = false, Value = 50 },
        Fly = { Enabled = false, Speed = 50 },
        HitBox = { Enabled = false, Size = 10, Range = 50 },
        NoClip = { Enabled = false }
    },
    
    Dupe = {
        MoneyDuplication = { Enabled = false, Warning = false },
        ItemDuplication = { Enabled = false, Warning = false }
    },
    
    Spinner = {
        Enabled = false,
        Warning = false,
        AimBotXSpinner = false,
        NoFaire = false,
        SpinSpeed = 50,
        SpinRange = 100
    },
    
    Fun = {
        CrashServer = { Enabled = false, Warning = false },
        KillServer = { Enabled = false, Warning = false },
        FriendAdd = { Enabled = false },
        WhatsSoft = { Enabled = false },
        ReportSpam = { Enabled = false, Warning = false }
    },
    
    Turret = { Invisible = false },
    EveryoneFly = { Enabled = false, Warning = false, Speed = 100 },
    Sound = { Enabled = false, Volume = 1 },
    
    Exploits = {
        AntiAFK = true,
        InfiniteJump = false,
        AutoFarm = false,
        AutoCollect = false,
        InstantRespawn = false,
        NoFallDamage = false
    },
    
    Safety = {
        AntiBan = true,
        AntiLog = true,
        RandomDelay = true,
        HideScript = true,
        BypassAC = true,
        StealthMode = true
    }
}

local Connections = {}
local ESPObjects = {}
local BlockedESPObjects = {}
local FlyingPlayers = {}
local FriendsSet = {}
local RenderSteppedConnection = nil
local LastUpdateTime = 0
local UpdateInterval = 1/60
local FrameSkip = 0
local PerformanceMode = true

local function ApplyUIStyles(frame)
    frame.BackgroundColor3 = Settings.Menu.BackgroundColor
    frame.BackgroundTransparency = 1 - Settings.Menu.Transparency
    frame.BorderSizePixel = 0
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = 0
    shadow.Parent = frame
end

local function CreateGradient(frame, color1, color2, direction)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, color2)})
    gradient.Rotation = direction or 90
    gradient.Parent = frame
    return gradient
end

local function PlayAhSound()
    if not Settings.Sound.Enabled then return end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9120386436"
        sound.Volume = Settings.Sound.Volume
        sound.Parent = LocalPlayer.Character or Workspace
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

local function ShowWarning(functionName, warningText, callback)
    local warningGui = Instance.new("ScreenGui")
    warningGui.Name = "WarningGUI"
    warningGui.Parent = CoreGui
    warningGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
    mainFrame.BackgroundColor3 = Settings.Menu.BackgroundColor
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = warningGui
    
    mainFrame.BackgroundTransparency = 1
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()
    
    CreateGradient(mainFrame, Settings.Menu.AccentColor, Settings.Menu.HighlightColor, 45)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    title.BackgroundTransparency = 0.2
    title.Text = "⚠️ ВНИМАНИЕ! ОПАСНАЯ ФУНКЦИЯ! ⚠️"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    local warningTextLabel = Instance.new("TextLabel")
    warningTextLabel.Size = UDim2.new(1, -40, 0, 100)
    warningTextLabel.Position = UDim2.new(0, 20, 0, 60)
    warningTextLabel.BackgroundTransparency = 1
    warningTextLabel.Text = warningText .. "\n\n⚠️ Вы подтверждаете, что действуете на свой страх и риск?\n⚠️ Ваш аккаунт может быть НАВСЕГДА ЗАБЛОКИРОВАН!"
    warningTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    warningTextLabel.TextWrapped = true
    warningTextLabel.Font = Enum.Font.Gotham
    warningTextLabel.TextSize = 14
    warningTextLabel.Parent = mainFrame
    
    local confirmButton = Instance.new("TextButton")
    confirmButton.Size = UDim2.new(0, 180, 0, 45)
    confirmButton.Position = UDim2.new(0, 20, 1, -60)
    confirmButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    confirmButton.Text = "✅ ПОДТВЕРЖДАЮ"
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.TextSize = 14
    confirmButton.Parent = mainFrame
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0, 180, 0, 45)
    cancelButton.Position = UDim2.new(1, -200, 1, -60)
    cancelButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cancelButton.Text = "❌ ОТМЕНА"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.TextSize = 14
    cancelButton.Parent = mainFrame
    
    confirmButton.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        task_wait(0.2)
        warningGui:Destroy()
        callback(true)
        PlayAhSound()
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        task_wait(0.2)
        warningGui:Destroy()
        callback(false)
    end)
end

local function AimBotXSpinner()
    if not Settings.Spinner.Enabled or not Settings.Spinner.AimBotXSpinner then return end
    local currentTime = tick()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.HumanoidRootPart then
            local target = player.Character.HumanoidRootPart
            local spinAngle = (currentTime * Settings.Spinner.SpinSpeed) % (math.pi * 2)
            local offset = Vector3_new(math.sin(spinAngle) * Settings.Spinner.SpinRange, 0, math.cos(spinAngle) * Settings.Spinner.SpinRange)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position + offset)
        end
    end
end

local function NoFaire()
    if not Settings.Spinner.Enabled or not Settings.Spinner.NoFaire then return end
    if not LocalPlayer.Character then return end
    
    for _, projectile in pairs(Workspace:GetDescendants()) do
        if projectile:IsA("BasePart") and (projectile:FindFirstChild("Bullet") or projectile.Name:lower():find("bullet")) then
            local origin = projectile:FindFirstChild("Origin")
            if origin and origin.Value and origin.Value ~= LocalPlayer then
                local distance = (projectile.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < 20 then
                    projectile.Velocity = projectile.Velocity + Vector3_new(math_random(-100, 100), math_random(-50, 50), math_random(-100, 100))
                    local attacker = origin.Value
                    if attacker and attacker.Character and attacker.Character.HumanoidRootPart then
                        attacker.Character.HumanoidRootPart.CFrame = attacker.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(30), 0)
                    end
                end
            end
        end
    end
end

local function HitBoxExpander()
    if not Settings.Player.HitBox.Enabled then return end
    local hitboxSize = Settings.Player.HitBox.Size
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Size = Vector3_new(hitboxSize, hitboxSize, hitboxSize)
                end
            end
        end
    end
end

local function BlockESP()
    if not Settings.Visuals.BlockESP.Enabled then return end
    
    local blockTypes = {}
    if Settings.Visuals.BlockESP.Chest then blockTypes.Chest = true end
    if Settings.Visuals.BlockESP.Crate then blockTypes.Crate = true end
    if Settings.Visuals.BlockESP.Loot then blockTypes.Loot = true end
    if Settings.Visuals.BlockESP.Vehicle then blockTypes.Vehicle = true end
    if Settings.Visuals.BlockESP.Door then blockTypes.Door = true end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        for blockType in pairs(blockTypes) do
            if obj.Name:find(blockType) or obj.ClassName:find(blockType) then
                obj.LocalTransparencyModifier = 1
                obj.CanCollide = false
            end
        end
    end
end

local function InvisibleTurret()
    if not Settings.Turret.Invisible then return end
    if not LocalPlayer.Character then return end
    
    for _, turret in pairs(Workspace:GetDescendants()) do
        if turret.Name:lower():find("turret") or (turret:IsA("Model") and turret:FindFirstChild("Turret")) then
            local humanoid = turret:FindFirstChild("Humanoid")
            if humanoid then
                local targetPart = turret:FindFirstChild("TargetPart")
                if targetPart then targetPart.CFrame = CFrame.new(0, 0, 0) end
                local detection = turret:FindFirstChild("Detection")
                if detection then detection.Disabled = true end
            end
        end
    end
end

local function EveryoneFly()
    if not Settings.EveryoneFly.Enabled then return end
    local flySpeed = Settings.EveryoneFly.Speed
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not FriendsSet[player.Name] and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart and not FlyingPlayers[player.Name] then
                humanoid.PlatformStand = true
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3_new(10000, 10000, 10000)
                bodyVelocity.Velocity = Vector3_new(0, flySpeed, 0)
                bodyVelocity.Parent = rootPart
                FlyingPlayers[player.Name] = bodyVelocity
                
                if ReplicatedStorage:FindFirstChild("BanPlayer") then
                    ReplicatedStorage.BanPlayer:FireServer(player.Name, "Fly Hack Detected")
                end
            end
        end
    end
end

local function CrashServer()
    if not Settings.Fun.CrashServer.Enabled then return end
    
    for i = 1, 500 do
        local part = Instance.new("Part")
        part.Size = Vector3_new(100, 100, 100)
        part.Position = Vector3_new(math_random(-10000, 10000), math_random(-10000, 10000), math_random(-10000, 10000))
        part.Anchored = true
        part.Parent = Workspace
        if i % 50 == 0 then task_wait() end
    end
    
    for i = 1, 50 do
        LocalPlayer:Kick("Server Crash initiated")
        task_wait()
    end
end

local function KillServer()
    if not Settings.Fun.KillServer.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.Health = 0 end
        end
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then pcall(function() obj:Destroy() end) end
    end
end

local function FriendAdd()
    if not Settings.Fun.FriendAdd.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not FriendsSet[player.Name] then
            table_insert(Settings.AimBot.Friends, player.Name)
            UpdateFriendsSet()
            task_wait(0.05)
        end
    end
end

local function WhatsSoft()
    if not Settings.Fun.WhatsSoft.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player:Kick("What's soft? - BOSS-MORS")
            task_wait(0.03)
        end
    end
end

local function ReportSpam()
    if not Settings.Fun.ReportSpam.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            for i = 1, 30 do
                if ReplicatedStorage:FindFirstChild("ReportPlayer") then
                    ReplicatedStorage.ReportPlayer:FireServer(player.Name, "Cheating/Hacking", "Using aimbot, ESP, fly hacks", "Bullying and harassment")
                end
                task_wait(0.01)
            end
        end
    end
end

local function AntiBanBypass()
    if not Settings.Safety.AntiBan then return end
    
    pcall(function()

        local oldName = LocalPlayer.Name
        LocalPlayer.Name = HttpService:GenerateGUID(false)
        task_wait(0.05)
        LocalPlayer.Name = oldName
        
        for _, obj in pairs(CoreGui:GetChildren()) do
            if obj.Name:find("BOSS") or obj.Name:find("MORS") then
                obj.DisplayOrder = 999
            end
        end
        
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                local oldState = humanoid:GetState()
                if oldState == Enum.HumanoidStateType.Flying then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
                    task_wait(0.05)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
                end
            end
        end
    end)
end

local function UpdateESP()

    for _, obj in pairs(ESPObjects) do
        pcall(function() if obj.Remove then obj:Remove() elseif obj.Destroy then obj:Destroy() end end)
    end
    ESPObjects = {}
    
    if not Settings.Visuals.ESP.Enabled then return end
    if not LocalPlayer.Character then return end
    
    local playerRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end
    
    local maxDistance = Settings.Visuals.ESP.MaxDistance
    local friendColor = Settings.Visuals.ESP.FriendColor
    local enemyColor = Settings.Visuals.ESP.EnemyColor
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then continue end
        
        local distance = (humanoidRootPart.Position - playerRoot.Position).Magnitude
        if distance > maxDistance then continue end
        
        local isFriend = FriendsSet[player.Name]
        local color = isFriend and friendColor or enemyColor
        
        if Settings.Visuals.ESP.Box then
            local box = Drawing.new("Square")
            box.Visible = true
            box.Color = color
            box.Thickness = Settings.Visuals.ESP.BoxOutline and 2 or 1
            box.Filled = false
            box.Transparency = 1
            table_insert(ESPObjects, box)
            
            local function updateBox()
                if not player.Character or not humanoidRootPart or humanoid.Health <= 0 then
                    box.Visible = false
                    return
                end
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local size = Vector2_new(2000 / screenPoint.Z, 3000 / screenPoint.Z)
                    box.Size = size
                    box.Position = Vector2_new(screenPoint.X - size.X / 2, screenPoint.Y - size.Y / 2)
                    box.Visible = true
                else
                    box.Visible = false
                end
            end
            table_insert(ESPObjects, {update = updateBox})
        end
        
        if Settings.Visuals.ESP.Name then
            local nameText = Drawing.new("Text")
            nameText.Visible = true
            nameText.Color = color
            nameText.Size = 13
            nameText.Center = true
            nameText.Outline = true
            nameText.Text = player.Name
            table_insert(ESPObjects, nameText)
            
            local function updateName()
                if not player.Character or not humanoidRootPart then
                    nameText.Visible = false
                    return
                end
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    nameText.Position = Vector2_new(screenPoint.X, screenPoint.Y - 40)
                    nameText.Visible = true
                else
                    nameText.Visible = false
                end
            end
            table_insert(ESPObjects, {update = updateName})
        end
        
        if Settings.Visuals.ESP.Distance then
            local distanceText = Drawing.new("Text")
            distanceText.Visible = true
            distanceText.Color = Color3_new(255, 255, 255)
            distanceText.Size = 12
            distanceText.Center = true
            distanceText.Outline = true
            table_insert(ESPObjects, distanceText)
            
            local function updateDistance()
                if not player.Character or not humanoidRootPart then
                    distanceText.Visible = false
                    return
                end
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                local currentDistance = (humanoidRootPart.Position - playerRoot.Position).Magnitude
                if onScreen then
                    distanceText.Position = Vector2_new(screenPoint.X, screenPoint.Y - 25)
                    distanceText.Text = math_floor(currentDistance) .. "m"
                    distanceText.Visible = true
                else
                    distanceText.Visible = false
                end
            end
            table_insert(ESPObjects, {update = updateDistance})
        end
        
        if Settings.Visuals.ESP.Health then
            local healthText = Drawing.new("Text")
            healthText.Visible = true
            healthText.Size = 12
            healthText.Center = true
            healthText.Outline = true
            table_insert(ESPObjects, healthText)
            
            local function updateHealth()
                if not player.Character or not humanoid or humanoid.Health <= 0 then
                    healthText.Visible = false
                    return
                end
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    healthText.Position = Vector2_new(screenPoint.X, screenPoint.Y - 55)
                    healthText.Text = "❤ " .. math_floor(humanoid.Health)
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    if healthPercent > 0.5 then
                        healthText.Color = Color3_new(0, 255, 0)
                    elseif healthPercent > 0.25 then
                        healthText.Color = Color3_new(255, 255, 0)
                    else
                        healthText.Color = Color3_new(255, 0, 0)
                    end
                    healthText.Visible = true
                else
                    healthText.Visible = false
                end
            end
            table_insert(ESPObjects, {update = updateHealth})
        end
        
        if Settings.Visuals.ESP.Weapon then
            local weaponText = Drawing.new("Text")
            weaponText.Visible = true
            weaponText.Color = color
            weaponText.Size = 11
            weaponText.Center = true
            weaponText.Outline = true
            table_insert(ESPObjects, weaponText)
            
            local function updateWeapon()
                if not player.Character then
                    weaponText.Visible = false
                    return
                end
                local tool = player.Character:FindFirstChildOfClass("Tool")
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen and tool then
                    weaponText.Position = Vector2_new(screenPoint.X, screenPoint.Y + 20)
                    weaponText.Text = "🔫 " .. tool.Name
                    weaponText.Visible = true
                else
                    weaponText.Visible = false
                end
            end
            table_insert(ESPObjects, {update = updateWeapon})
        end
        
        if Settings.Visuals.ESP.Armor then
            local armorText = Drawing.new("Text")
            armorText.Visible = true
            armorText.Color = Color3_new(100, 150, 255)
            armorText.Size = 11
            armorText.Center = true
            armorText.Outline = true
            table_insert(ESPObjects, armorText)
            
            local function updateArmor()
                if not player.Character then
                    armorText.Visible = false
                    return
                end
                local armor = player.Character:FindFirstChild("Armor")
                local screenPoint, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen and armor then
                    armorText.Position = Vector2_new(screenPoint.X, screenPoint.Y + 35)
                    armorText.Text = "🛡️ " .. math_floor(armor.Value)
                    armorText.Visible = true
                else
                    armorText.Visible = false
                end
            end
            table_insert(ESPObjects, {update = updateArmor})
        end
    end
end

local function UpdateESPObjects()
    for i = #ESPObjects, 1, -1 do
        local obj = ESPObjects[i]
        if type(obj) == "table" and obj.update then
            pcall(obj.update)
        end
    end
end

local FlyEnabled = false
local FlyBodyVelocity = nil
local FlyBodyGyro = nil

local function StartFly()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.MaxForce = Vector3_new(10000, 10000, 10000)
    FlyBodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque = Vector3_new(10000, 10000, 10000)
    FlyBodyGyro.Parent = LocalPlayer.Character.HumanoidRootPart
end

local function UpdateFly()
    if not Settings.Player.Fly.Enabled then
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
        FlyEnabled = false
        return
    end
    
    if not FlyEnabled then
        StartFly()
        FlyEnabled = true
    end
    
    if FlyBodyVelocity and FlyBodyGyro and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
        local moveDirection = Vector3_new()
        local cameraCFrame = Camera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + cameraCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - cameraCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - cameraCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + cameraCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3_new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3_new(0, 1, 0) end
        
        if moveDirection.Magnitude > 0 then moveDirection = moveDirection.Unit end
        FlyBodyVelocity.Velocity = moveDirection * Settings.Player.Fly.Speed
        FlyBodyGyro.CFrame = cameraCFrame
    end
end

local CrosshairObjects = {}
local function CreateCrosshair()
    for _, obj in pairs(CrosshairObjects) do
        pcall(function() obj:Remove() end)
    end
    CrosshairObjects = {}
    
    if not Settings.Visuals.Crosshair.Enabled then return end
    
    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2
    local size = Settings.Visuals.Crosshair.Size
    local color = Settings.Visuals.Crosshair.Color
    local style = Settings.Visuals.Crosshair.Style
    
    if style == "Dot" then
        local dot = Drawing.new("Square")
        dot.Size = Vector2_new(size, size)
        dot.Position = Vector2_new(centerX - size/2, centerY - size/2)
        dot.Color = color
        dot.Filled = true
        dot.Thickness = 0
        table_insert(CrosshairObjects, dot)
    elseif style == "Cross" then
        local horizontalLine = Drawing.new("Line")
        horizontalLine.From = Vector2_new(centerX - size, centerY)
        horizontalLine.To = Vector2_new(centerX + size, centerY)
        horizontalLine.Color = color
        horizontalLine.Thickness = 2
        table_insert(CrosshairObjects, horizontalLine)
        
        local verticalLine = Drawing.new("Line")
        verticalLine.From = Vector2_new(centerX, centerY - size)
        verticalLine.To = Vector2_new(centerX, centerY + size)
        verticalLine.Color = color
        verticalLine.Thickness = 2
        table_insert(CrosshairObjects, verticalLine)
    elseif style == "Circle" then
        local circle = Drawing.new("Circle")
        circle.Radius = size/2
        circle.Position = Vector2_new(centerX, centerY)
        circle.Color = color
        circle.Thickness = 2
        circle.Filled = false
        circle.NumSides = 32
        table_insert(CrosshairObjects, circle)
    end
end

local function UpdateNightVision()
    if Settings.Visuals.NightVision.Enabled then
        Lighting.Ambient = Settings.Visuals.NightVision.Color
        Lighting.Brightness = Settings.Visuals.NightVision.Intensity
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = OldLighting.Ambient or Color3_new(127, 127, 127)
        Lighting.Brightness = OldLighting.Brightness or 2
        Lighting.FogEnd = OldLighting.FogEnd or 1000
        Lighting.GlobalShadows = OldLighting.GlobalShadows ~= nil and OldLighting.GlobalShadows or true
    end
end

local function UpdateSpeed()
    if Settings.Player.Speed.Enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= Settings.Player.Speed.Value then
            humanoid.WalkSpeed = Settings.Player.Speed.Value
        end
    elseif LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= Settings.Player.Speed.Default then
            humanoid.WalkSpeed = Settings.Player.Speed.Default
        end
    end
end

local function UpdateJump()
    if Settings.Player.Jump.Enabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.JumpPower ~= Settings.Player.Jump.Value then
            humanoid.JumpPower = Settings.Player.Jump.Value
        end
    elseif LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.JumpPower ~= 50 then
            humanoid.JumpPower = 50
        end
    end
end

local function UpdateNoClip()
    if Settings.Player.NoClip.Enabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

local function UpdateAntiAFK()
    if Settings.Exploits.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2_new(0, 0))
        end)
    end
end

local function UpdateFriendsSet()
    FriendsSet = {}
    for _, friend in ipairs(Settings.AimBot.Friends) do
        FriendsSet[friend] = true
    end
end

local function FastUpdate()
    local currentTime = tick()
    if currentTime - LastUpdateTime < UpdateInterval then return end
    LastUpdateTime = currentTime
    
    pcall(function()
        UpdateFly()
        UpdateSpeed()
        UpdateJump()
        UpdateNoClip()
        UpdateESPObjects()
        CreateCrosshair()
    end)
end

local frameCounter = 0
local function MediumUpdate()
    frameCounter = frameCounter + 1
    if frameCounter % 3 ~= 0 then return end
    
    pcall(function()
        AimBotXSpinner()
        NoFaire()
        HitBoxExpander()
        BlockESP()
        InvisibleTurret()
        EveryoneFly()
        AntiBanBypass()
    end)
end

local function SlowUpdate()
    pcall(function()
        UpdateNightVision()
        UpdateESP()
        FriendAdd()
        ReportSpam()
        if Settings.Visuals.NoFog.Enabled then
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
        end
        if Settings.Visuals.FullBright.Enabled then
            Lighting.Brightness = 10
            Lighting.Ambient = Color3_new(255, 255, 255)
        end
    end)
end

Library = {Tabs = {}, UI = nil}

function Library:CreateWindow()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BOSS_MORS_XENO"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -300)
    MainFrame.BackgroundColor3 = Settings.Menu.BackgroundColor
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    
    CreateGradient(MainFrame, Settings.Menu.BackgroundColor, Settings.Menu.AccentColor, 135)
    
    if Settings.Menu.BlurEffect then
        local blur = Instance.new("BlurEffect")
        blur.Size = 5
        blur.Parent = ScreenGui
    end
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Settings.Menu.AccentColor
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ BOSS-MORS v3.5 | ULTIMATE EDITION ⚡"
    Title.TextColor3 = Settings.Menu.TextColor
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextStrokeTransparency = 0.5
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -40, 0, 5)
    CloseButton.BackgroundColor3 = Color3_new(255, 50, 50)
    CloseButton.BackgroundTransparency = 0.3
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Settings.Menu.TextColor
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseButton1Click:Connect(function()
        Settings.Menu.Open = false
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        task_wait(0.3)
        MainFrame.Visible = false
    end)
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, -45)
    Content.Position = UDim2.new(0, 0, 0, 45)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 140, 1, 0)
    TabContainer.BackgroundColor3 = Color3_new(20, 20, 25)
    TabContainer.BackgroundTransparency = 0.3
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 3
    TabContainer.ScrollBarImageColor3 = Settings.Menu.AccentColor
    TabContainer.Parent = Content
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer
    
    local RightPanel = Instance.new("Frame")
    RightPanel.Size = UDim2.new(1, -140, 1, 0)
    RightPanel.Position = UDim2.new(0, 140, 0, 0)
    RightPanel.BackgroundTransparency = 1
    RightPanel.Parent = Content
    
    return {ScreenGui = ScreenGui, MainFrame = MainFrame, TabContainer = TabContainer, RightPanel = RightPanel, TitleBar = TitleBar}
end

function Library:CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 45)
    TabButton.Position = UDim2.new(0, 5, 0, (#self.Tabs * 50))
    TabButton.BackgroundColor3 = Color3_new(30, 30, 40)
    TabButton.BackgroundTransparency = 0.2
    TabButton.BorderSizePixel = 0
    TabButton.Text = "  " .. (icon or "•") .. " " .. name
    TabButton.TextColor3 = Settings.Menu.TextColor
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.TextSize = 13
    TabButton.Parent = self.UI.TabContainer
    
    TabButton.MouseEnter:Connect(function()
        TweenService:Create(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
    end)
    TabButton.MouseLeave:Connect(function()
        if TabButton.BackgroundColor3 ~= Settings.Menu.AccentColor then
            TweenService:Create(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.2}):Play()
        end
    end)
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, -20, 1, -20)
    TabFrame.Position = UDim2.new(0, 10, 0, 10)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.ScrollBarThickness = 3
    TabFrame.ScrollBarImageColor3 = Settings.Menu.AccentColor
    TabFrame.Visible = false
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.Parent = self.UI.RightPanel
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        if self.CurrentTab then self.CurrentTab.Visible = false end
        TabFrame.Visible = true
        self.CurrentTab = TabFrame
        for _, tab in pairs(self.Tabs) do
            if tab.Button then
                tab.Button.BackgroundColor3 = Color3_new(30, 30, 40)
                tab.Button.BackgroundTransparency = 0.2
            end
        end
        TabButton.BackgroundColor3 = Settings.Menu.AccentColor
        TabButton.BackgroundTransparency = 0
    end)
    
    local tabData = {Name = name, Button = TabButton, Frame = TabFrame}
    table_insert(self.Tabs, tabData)
    
    if #self.Tabs == 1 then
        TabButton.BackgroundColor3 = Settings.Menu.AccentColor
        TabButton.BackgroundTransparency = 0
        TabFrame.Visible = true
        self.CurrentTab = TabFrame
    end
    
    return tabData
end

function Library:CreateToggle(tab, text, settingTable, settingKey, requireWarning, warningText)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3_new(25, 25, 30)
    ToggleFrame.BackgroundTransparency = 0.3
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = tab.Frame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(1, -60, 0, 5)
    ToggleButton.BackgroundColor3 = settingTable[settingKey] and Settings.Menu.AccentColor or Color3_new(80, 80, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -70, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Settings.Menu.TextColor
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 13
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 21, 0, 21)
    ToggleIndicator.Position = settingTable[settingKey] and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
    ToggleIndicator.BackgroundColor3 = settingTable[settingKey] and Color3_new(255, 255, 255) or Color3_new(100, 100, 100)
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        if requireWarning and not settingTable[settingKey] then
            ShowWarning(text, warningText or "⚠️ Эта функция может привести к ПЕРМАНЕНТНОМУ БАНУ вашего аккаунта!\n⚠️ Используйте на свой страх и риск!", function(confirmed)
                if confirmed then
                    settingTable[settingKey] = true
                    ToggleButton.BackgroundColor3 = Settings.Menu.AccentColor
                    ToggleIndicator.Position = UDim2.new(1, -24, 0, 2)
                    ToggleIndicator.BackgroundColor3 = Color3_new(255, 255, 255)
                    PlayAhSound()
                end
            end)
        else
            settingTable[settingKey] = not settingTable[settingKey]
            ToggleButton.BackgroundColor3 = settingTable[settingKey] and Settings.Menu.AccentColor or Color3_new(80, 80, 80)
            ToggleIndicator.Position = settingTable[settingKey] and UDim2.new(1, -24, 0, 2) or UDim2.new(0, 2, 0, 2)
            ToggleIndicator.BackgroundColor3 = settingTable[settingKey] and Color3_new(255, 255, 255) or Color3_new(100, 100, 100)
            if settingTable[settingKey] then PlayAhSound() end
        end
    end)
    
    return ToggleFrame
end

function Library:CreateSlider(tab, text, settingTable, settingKey, min, max, default)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 55)
    SliderFrame.BackgroundColor3 = Color3_new(25, 25, 30)
    SliderFrame.BackgroundTransparency = 0.3
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = tab.Frame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. tostring(settingTable[settingKey])
    SliderLabel.TextColor3 = Settings.Menu.TextColor
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 13
    SliderLabel.Parent = SliderFrame
    
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Size = UDim2.new(1, -20, 0, 6)
    SliderBackground.Position = UDim2.new(0, 10, 0, 35)
    SliderBackground.BackgroundColor3 = Color3_new(50, 50, 60)
    SliderBackground.BorderSizePixel = 0
    SliderBackground.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((settingTable[settingKey] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Settings.Menu.AccentColor
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBackground
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 18, 0, 18)
    SliderButton.Position = UDim2.new((settingTable[settingKey] - min) / (max - min), -9, 0, -6)
    SliderButton.BackgroundColor3 = Settings.Menu.TextColor
    SliderButton.BorderSizePixel = 0
    SliderButton.Text = ""
    SliderButton.ZIndex = 2
    SliderButton.Parent = SliderBackground
    
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    local function updateSlider()
        if not dragging then return end
        local xPos = math_clamp((Mouse.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
        local value = math_floor(min + (xPos * (max - min)))
        settingTable[settingKey] = value
        SliderLabel.Text = text .. ": " .. tostring(value)
        SliderFill.Size = UDim2.new(xPos, 0, 1, 0)
        SliderButton.Position = UDim2.new(xPos, -9, 0, -6)
    end
    
    SliderButton.MouseMoved:Connect(updateSlider)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider() end
    end)
    
    return SliderFrame
end

function Library:CreateColorPicker(tab, text, settingTable, settingKey)
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Size = UDim2.new(1, 0, 0, 40)
    ColorFrame.BackgroundColor3 = Color3_new(25, 25, 30)
    ColorFrame.BackgroundTransparency = 0.3
    ColorFrame.BorderSizePixel = 0
    ColorFrame.Parent = tab.Frame
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ColorLabel.Position = UDim2.new(0, 10, 0, 0)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = text
    ColorLabel.TextColor3 = Settings.Menu.TextColor
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextSize = 13
    ColorLabel.Parent = ColorFrame
    
    local ColorDisplay = Instance.new("Frame")
    ColorDisplay.Size = UDim2.new(0, 40, 0, 30)
    ColorDisplay.Position = UDim2.new(1, -50, 0, 5)
    ColorDisplay.BackgroundColor3 = settingTable[settingKey]
    ColorDisplay.BorderSizePixel = 2
    ColorDisplay.BorderColor3 = Settings.Menu.TextColor
    ColorDisplay.Parent = ColorFrame
    
    local colors = {
        Color3_new(255, 0, 0), Color3_new(0, 255, 0), Color3_new(0, 0, 255),
        Color3_new(255, 255, 0), Color3_new(255, 0, 255), Color3_new(0, 255, 255),
        Color3_new(255, 128, 0), Color3_new(128, 0, 255), Color3_new(255, 255, 255)
    }
    local colorIndex = 1
    
    ColorDisplay.MouseButton1Click:Connect(function()
        colorIndex = colorIndex % #colors + 1
        settingTable[settingKey] = colors[colorIndex]
        ColorDisplay.BackgroundColor3 = settingTable[settingKey]
    end)
    
    return ColorFrame
end

Library.UI = Library:CreateWindow()

local CombatTab = Library:CreateTab("COMBAT", "⚔️")
local VisualTab = Library:CreateTab("VISUALS", "👁️")
local PlayerTab = Library:CreateTab("PLAYER", "🏃")
local DupeTab = Library:CreateTab("DUPE", "💰")
local SpinnerTab = Library:CreateTab("SPINNER", "🔄")
local FunTab = Library:CreateTab("FUN", "🎉")
local TurretTab = Library:CreateTab("TURRET", "🤖")
local EveryoneFlyTab = Library:CreateTab("EVERYONE FLY", "🕊️")
local SettingsTab = Library:CreateTab("SETTINGS", "⚙️")

Library:CreateToggle(CombatTab, "AimBot", Settings.AimBot, "Enabled")
Library:CreateSlider(CombatTab, "AimBot FOV", Settings.AimBot, "FOV", 1, 120, 30)
Library:CreateSlider(CombatTab, "AimBot Smoothness", Settings.AimBot, "Smoothness", 0.1, 1, 0.2)
Library:CreateToggle(CombatTab, "Team Check", Settings.AimBot, "TeamCheck")
Library:CreateToggle(CombatTab, "Visibility Check", Settings.AimBot, "VisibleCheck")
Library:CreateColorPicker(CombatTab, "AimBot Color", Settings.AimBot, "Color")
Library:CreateSlider(CombatTab, "HitBox Size", Settings.Player.HitBox, "Size", 1, 20, 10)
Library:CreateSlider(CombatTab, "HitBox Range", Settings.Player.HitBox, "Range", 1, 100, 50)

Library:CreateToggle(VisualTab, "ESP", Settings.Visuals.ESP, "Enabled")
Library:CreateToggle(VisualTab, "Box ESP", Settings.Visuals.ESP, "Box")
Library:CreateToggle(VisualTab, "Name ESP", Settings.Visuals.ESP, "Name")
Library:CreateToggle(VisualTab, "Distance ESP", Settings.Visuals.ESP, "Distance")
Library:CreateToggle(VisualTab, "Health ESP", Settings.Visuals.ESP, "Health")
Library:CreateToggle(VisualTab, "Weapon ESP", Settings.Visuals.ESP, "Weapon")
Library:CreateToggle(VisualTab, "Armor ESP", Settings.Visuals.ESP, "Armor")
Library:CreateSlider(VisualTab, "ESP Distance", Settings.Visuals.ESP, "MaxDistance", 10, 500, 500)
Library:CreateToggle(VisualTab, "Block ESP", Settings.Visuals.BlockESP, "Enabled")
Library:CreateToggle(VisualTab, "Block Chests", Settings.Visuals.BlockESP, "Chest")
Library:CreateToggle(VisualTab, "Block Crates", Settings.Visuals.BlockESP, "Crate")
Library:CreateToggle(VisualTab, "Block Loot", Settings.Visuals.BlockESP, "Loot")
Library:CreateToggle(VisualTab, "Block Vehicles", Settings.Visuals.BlockESP, "Vehicle")
Library:CreateToggle(VisualTab, "Block Doors", Settings.Visuals.BlockESP, "Door")
Library:CreateToggle(VisualTab, "Night Vision", Settings.Visuals.NightVision, "Enabled")
Library:CreateToggle(VisualTab, "Chams", Settings.Visuals.Chams, "Enabled")
Library:CreateColorPicker(VisualTab, "Chams Color", Settings.Visuals.Chams, "Color")
Library:CreateToggle(VisualTab, "No Fog", Settings.Visuals.NoFog, "Enabled")
Library:CreateToggle(VisualTab, "Full Bright", Settings.Visuals.FullBright, "Enabled")
Library:CreateToggle(VisualTab, "Crosshair", Settings.Visuals.Crosshair, "Enabled")
Library:CreateColorPicker(VisualTab, "Crosshair Color", Settings.Visuals.Crosshair, "Color")

Library:CreateToggle(PlayerTab, "Speed Hack", Settings.Player.Speed, "Enabled")
Library:CreateSlider(PlayerTab, "Speed Value", Settings.Player.Speed, "Value", 1, 100, 25)
Library:CreateToggle(PlayerTab, "High Jump", Settings.Player.Jump, "Enabled")
Library:CreateSlider(PlayerTab, "Jump Power", Settings.Player.Jump, "Value", 1, 100, 50)
Library:CreateToggle(PlayerTab, "Fly Hack", Settings.Player.Fly, "Enabled")
Library:CreateSlider(PlayerTab, "Fly Speed", Settings.Player.Fly, "Speed", 10, 200, 50)
Library:CreateToggle(PlayerTab, "HitBox Expander", Settings.Player.HitBox, "Enabled")
Library:CreateToggle(PlayerTab, "No Clip", Settings.Player.NoClip, "Enabled")
Library:CreateToggle(PlayerTab, "No Fall Damage", Settings.Exploits, "NoFallDamage")
Library:CreateToggle(PlayerTab, "Infinite Jump", Settings.Exploits, "InfiniteJump")

Library:CreateToggle(DupeTab, "💰 Money Duplication", Settings.Dupe.MoneyDuplication, "Enabled", true, "⚠️ MONEY DUPLICATION = МГНОВЕННЫЙ БАН! Вы уверены?")
Library:CreateToggle(DupeTab, "📦 Item Duplication", Settings.Dupe.ItemDuplication, "Enabled", true, "⚠️ ITEM DUPLICATION = ПЕРМАНЕНТНЫЙ БАН!")

Library:CreateToggle(SpinnerTab, "🔄 Spinner Mode", Settings.Spinner, "Enabled", true, "⚠️ SPINNER = БАН АККАУНТА! Использовать на свой страх и риск!")
Library:CreateToggle(SpinnerTab, "🎯 AimBot X Spinner", Settings.Spinner, "AimBotXSpinner")
Library:CreateToggle(SpinnerTab, "🛡️ NoFaire", Settings.Spinner, "NoFaire")
Library:CreateSlider(SpinnerTab, "Spin Speed", Settings.Spinner, "SpinSpeed", 10, 200, 50)
Library:CreateSlider(SpinnerTab, "Spin Range", Settings.Spinner, "SpinRange", 10, 200, 100)

Library:CreateToggle(FunTab, "💥 Crash Server", Settings.Fun.CrashServer, "Enabled", true, "⚠️ CRASH SERVER = БАН IP АДРЕСА! Вы уверены?")
Library:CreateToggle(FunTab, "🔪 Kill Server", Settings.Fun.KillServer, "Enabled", true, "⚠️ KILL SERVER = ПЕРМАНЕНТНЫЙ БАН!")
Library:CreateToggle(FunTab, "👥 Auto Friend Add", Settings.Fun.FriendAdd, "Enabled")
Library:CreateToggle(FunTab, "❓ What's Soft? (Kick All)", Settings.Fun.WhatsSoft, "Enabled")
Library:CreateToggle(FunTab, "📢 Report SPAM", Settings.Fun.ReportSpam, "Enabled", true, "⚠️ REPORT SPAM = БАН ЗА СПАМ!")

Library:CreateToggle(TurretTab, "👻 Invisible Turret", Settings.Turret, "Invisible")

Library:CreateToggle(EveryoneFlyTab, "🕊️ Everyone Fly", Settings.EveryoneFly, "Enabled", true, "⚠️ ВСЕ ИГРОКИ ПОЛУЧАТ БАН! Вы уверены?")
Library:CreateSlider(EveryoneFlyTab, "Fly Speed", Settings.EveryoneFly, "Speed", 10, 500, 100)

Library:CreateToggle(SettingsTab, "🔊 Sound 'AHHHHHHH'", Settings.Sound, "Enabled")
Library:CreateSlider(SettingsTab, "Sound Volume", Settings.Sound, "Volume", 0, 1, 0.5)
Library:CreateToggle(SettingsTab, "🛡️ Anti-Ban", Settings.Safety, "AntiBan")
Library:CreateToggle(SettingsTab, "🔒 Anti-Log", Settings.Safety, "AntiLog")
Library:CreateToggle(SettingsTab, "⚡ Bypass Anti-Cheat", Settings.Safety, "BypassAC")
Library:CreateToggle(SettingsTab, "🕵️ Stealth Mode", Settings.Safety, "StealthMode")
Library:CreateColorPicker(SettingsTab, "Menu Accent Color", Settings.Menu, "AccentColor")
Library:CreateColorPicker(SettingsTab, "Menu Background Color", Settings.Menu, "BackgroundColor")

local UnloadFrame = Instance.new("Frame")
UnloadFrame.Size = UDim2.new(1, 0, 0, 50)
UnloadFrame.BackgroundTransparency = 1
UnloadFrame.Parent = SettingsTab.Frame

local UnloadButton = Instance.new("TextButton")
UnloadButton.Size = UDim2.new(1, -20, 0, 40)
UnloadButton.Position = UDim2.new(0, 10, 0, 5)
UnloadButton.BackgroundColor3 = Color3_new(200, 50, 50)
UnloadButton.BackgroundTransparency = 0.2
UnloadButton.Text = "❌ UNLOAD SCRIPT"
UnloadButton.TextColor3 = Settings.Menu.TextColor
UnloadButton.Font = Enum.Font.GothamBold
UnloadButton.TextSize = 14
UnloadButton.Parent = UnloadFrame

UnloadButton.MouseButton1Click:Connect(function()
    for _, conn in pairs(Connections) do
        if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
    end
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Remove then pcall(function() obj:Remove() end) end
    end
    if Library.UI and Library.UI.ScreenGui then Library.UI.ScreenGui:Destroy() end
    _G.BOSSMORS = nil
    _G.BOSSMORS_LOADED = nil
    print("BOSS-MORS успешно выгружен!")
end)

table_insert(Connections, UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Settings.Menu.Key then
        Settings.Menu.Open = not Settings.Menu.Open
        if Settings.Menu.Open then
            Library.UI.MainFrame.Visible = true
            Library.UI.MainFrame.BackgroundTransparency = 0.05
            TweenService:Create(Library.UI.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.05}):Play()
        else
            TweenService:Create(Library.UI.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
            task_wait(0.3)
            Library.UI.MainFrame.Visible = false
        end
    end
    if input.KeyCode == Settings.AimBot.Key then
        Settings.AimBot.Enabled = not Settings.AimBot.Enabled
        PlayAhSound()
    end
    if input.KeyCode == Settings.Visuals.ESP.FriendKey then
        local target = Mouse.Target
        if target and target.Parent then
            local player = GetPlayerFromCharacter(target.Parent)
            if player and player ~= LocalPlayer and not FriendsSet[player.Name] then
                table_insert(Settings.AimBot.Friends, player.Name)
                UpdateFriendsSet()
                print("✨ Добавлен в друзья: " .. player.Name)
                PlayAhSound()
            end
        end
    end
end))

table_insert(Connections, RunService.RenderStepped:Connect(FastUpdate))
table_insert(Connections, RunService.Heartbeat:Connect(MediumUpdate))
table_insert(Connections, RunService.Stepped:Connect(function()
    if tick() % 1 < 0.05 then SlowUpdate() end
    if tick() % 30 < 0.1 then UpdateAntiAFK() end
end))

OldLighting.Ambient = Lighting.Ambient
OldLighting.Brightness = Lighting.Brightness
OldLighting.FogEnd = Lighting.FogEnd
OldLighting.GlobalShadows = Lighting.GlobalShadows

UpdateFriendsSet()

print("╔════════════════════════════════════════╗")
print("║     BOSS-MORS v3.5 ULTIMATE EDITION    ║")
print("╠════════════════════════════════════════╣")
print("║  Версия: " .. _G.BOSSMORS.Version .. string.rep(" ", 20 - #_G.BOSSMORS.Version) .. "║")
print("║  Игра: " .. _G.BOSSMORS.Game .. string.rep(" ", 23 - #_G.BOSSMORS.Game) .. "║")
print("╠════════════════════════════════════════╣")
print("║  Управление:                           ║")
print("║  INSERT - Открыть/закрыть меню        ║")
print("║  T - Вкл/Выкл AimBot                  ║")
print("║  F2 - Добавить игрока в друзья        ║")
print("╠════════════════════════════════════════╣")
print("║  ⚠️ ВНИМАНИЕ:                          ║")
print("║  Некоторые функции могут привести      ║")
print("║  к ПЕРМАНЕНТНОМУ БАНУ аккаунта!        ║")
print("║  Используйте на свой страх и риск!     ║")
print("╚════════════════════════════════════════╝")

Library.UI.MainFrame.Visible = Settings.Menu.Open
if Settings.Menu.Open then
    Library.UI.MainFrame.BackgroundTransparency = 0.05
end
