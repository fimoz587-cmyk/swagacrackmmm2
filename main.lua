local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Swaga Hub | Murder Mystery 2",
    Author = "Create by @AnalogyScript",        
    Theme = "Sky", 
    Icon = "rbxassetid://13936134740",
    Size = UDim2.fromOffset(580, 460),
    ToggleKey = Enum.KeyCode.RightShift
})

-- Сервисы и глобальные переменные
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local originalProperties = {}
local graphicsEnabled = false
local shaderConnection = nil

-- ==========================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ И ХУКИ
-- ==========================================

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            local hasKnife = char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
            if hasKnife then
                return player
            end
        end
    end
    return nil
end

-- Безопасный Silent Aim (не ломает камеру)
getgenv().SilentAim = false
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if getgenv().SilentAim and not checkcaller() and method == "Raycast" and self == Workspace then
        local origin = args[1]
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Фильтр: перехватывать только лучи, исходящие близко от нашего персонажа (стрельба)
        if hrp and origin and (origin - hrp.Position).Magnitude < 15 then
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart") 
                    or murderer.Character:FindFirstChild("UpperTorso") 
                    or murderer.Character:FindFirstChild("Head")
                
                if targetPart then
                    args[2] = (targetPart.Position - origin).Unit * 1000
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- Сброс кастомного скина (Tung Tung / Nugget)
local function resetCustomCharacter()
    if getgenv().TrollRenderConn then
        getgenv().TrollRenderConn:Disconnect()
        getgenv().TrollRenderConn = nil
    end
    if getgenv().TrollMesh then
        getgenv().TrollMesh:Destroy()
        getgenv().TrollMesh = nil
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "CustomTrollMesh" or obj.Name == "Adi_LocalMesh" then
            obj:Destroy()
        end
    end

    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Workspace.CurrentCamera.CameraSubject = humanoid
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 0
            end
        end
    end
end

-- Функция применения кастомной модели
local function applyCustomMesh(assetId)
    resetCustomCharacter()

    local char = LocalPlayer.Character
    if not char then return end

    local oldRoot = char:WaitForChild("HumanoidRootPart", 5)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not oldRoot or not humanoid then return end

    humanoid.Died:Connect(resetCustomCharacter)

    local success, result = pcall(function() 
        return game:GetObjects("rbxassetid://" .. tostring(assetId)) 
    end)

    if success and result then
        local loadedObjects = type(result) == "table" and result or {result}
        local customPart = nil

        for _, obj in ipairs(loadedObjects) do
            if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") or obj:IsA("BasePart") or obj:IsA("Model") then
                customPart = obj
                break
            end
        end

        if customPart then
            customPart.Name = "CustomTrollMesh"
            
            if customPart:IsA("Model") then
                local primary = customPart.PrimaryPart or customPart:FindFirstChildWhichIsA("BasePart")
                if primary then
                    for _, p in ipairs(customPart:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                            p.Anchored = false
                        end
                    end
                end
            else
                customPart.CanCollide = false
                customPart.Anchored = true
            end

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = 1
                end
            end

            customPart.Parent = Workspace
            getgenv().TrollMesh = customPart
            Workspace.CurrentCamera.CameraSubject = customPart

            getgenv().TrollRenderConn = RunService.RenderStepped:Connect(function()
                if char and char.Parent and oldRoot and oldRoot.Parent and humanoid.Health > 0 and customPart and customPart.Parent then
                    if customPart:IsA("Model") then
                        customPart:PivotTo(oldRoot.CFrame)
                    else
                        customPart.CFrame = oldRoot.CFrame
                    end
                else
                    resetCustomCharacter()
                end
            end)
        end
    end
end

-- ==========================================
-- СОЗДАНИЕ ВКЛАДОК (TABS)
-- ==========================================

local SherifTab = Window:Tab({ Title = "Sherif", Icon = "shield" })
local MurderTab = Window:Tab({ Title = "Murder", Icon = "skull" })
local CosmeticTab = Window:Tab({ Title = "Cosmetic", Icon = "sparkles" })
local HighlightsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "component" })
local TrollTab = Window:Tab({ Title = "Troll", Icon = "laugh" })
local RageTab = Window:Tab({ Title = "Rage", Icon = "zap" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ==========================================
-- 1. ВКЛАДКА SHERIF
-- ==========================================

SherifTab:Toggle({
    Title = "Silent Aim (Raycast)",
    Callback = function(state)
        getgenv().SilentAim = state
        WindUI:Notify({
            Title = "Silent Aim",
            Content = state and "Включен (Наводка на Murderer)" or "Выключен",
            Duration = 2
        })
    end
})

SherifTab:Toggle({
    Title = "Auto Pick Gun",
    Callback = function(state)
        getgenv().AutoPickGun = state
        
        task.spawn(function()
            while getgenv().AutoPickGun do
                task.wait(0.1)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "GunDrop" then
                            local gunPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if gunPart then
                                if firetouchinterest then
                                    firetouchinterest(hrp, gunPart, 0)
                                    firetouchinterest(hrp, gunPart, 1)
                                else
                                    local oldCF = hrp.CFrame
                                    hrp.CFrame = gunPart.CFrame
                                    task.wait(0.1)
                                    hrp.CFrame = oldCF
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
})

-- ==========================================
-- 2. ВКЛАДКА MURDER
-- ==========================================

MurderTab:Button({
    Title = "Kill All",
    Callback = function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        
        local knife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))

        if not knife then
            WindUI:Notify({
                Title = "Error",
                Content = "There is no knife",
                Duration = 3
            })
            return
        end

        if knife.Parent == backpack and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):EquipTool(knife)
            task.wait(0.05)
        end

        local events = knife:FindFirstChild("Events")
        local stabRemote = events and events:FindFirstChild("KnifeStabbed")
        local throwRemote = events and events:FindFirstChild("KnifeThrown")
        local touchRemote = events and events:FindFirstChild("HandleTouched")

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetChar = player.Character
                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso")

                if targetHum and targetHum.Health > 0 and targetHRP then
                    if stabRemote then
                        pcall(function()
                            stabRemote:FireServer(targetHum)
                            stabRemote:FireServer(targetHRP)
                            stabRemote:FireServer(targetChar)
                        end)
                    end
                    if touchRemote then
                        pcall(function()
                            touchRemote:FireServer(targetHRP)
                        end)
                    end
                    if throwRemote then
                        pcall(function()
                            throwRemote:FireServer(targetHRP.CFrame, targetHRP.Position)
                        end)
                    end
                end
            end
        end

        WindUI:Notify({
            Title = "Successful",
            Content = "All Player Killed",
            Duration = 3
        })
    end
})

-- ==========================================
-- 3. ВКЛАДКА COSMETIC
-- ==========================================

CosmeticTab:Toggle({
    Title = "Shaders (Black Sky)",
    Value = false,
    Callback = function(state)
        graphicsEnabled = state

        if shaderConnection then
            shaderConnection:Disconnect()
            shaderConnection = nil
        end

        for _, v in ipairs(Lighting:GetChildren()) do
            if v.Name:find("Swaga") then
                v:Destroy()
            end
        end

        if state then
            pcall(function()
                local sky = Instance.new("Sky")
                sky.Name = "SwagaSky"
                local SKY_ID = "rbxassetid://7158024342"
                sky.SkyboxBk = SKY_ID; sky.SkyboxDn = SKY_ID; sky.SkyboxFt = SKY_ID
                sky.SkyboxLf = SKY_ID; sky.SkyboxRt = SKY_ID; sky.SkyboxUp = SKY_ID
                sky.StarCount = 3000
                sky.SunAngularSize = 8
                sky.MoonAngularSize = 6
                sky.Parent = Lighting

                Lighting.Brightness = 3.8
                Lighting.ExposureCompensation = 0.2
                Lighting.GlobalShadows = true
                Lighting.EnvironmentDiffuseScale = 0.22
                Lighting.EnvironmentSpecularScale = 1
                Lighting.Ambient = Color3.fromRGB(95, 98, 110)
                Lighting.OutdoorAmbient = Color3.fromRGB(145, 150, 165)
                Lighting.ClockTime = 15.4

                local atmosphere = Instance.new("Atmosphere")
                atmosphere.Name = "SwagaAtmosphere"
                atmosphere.Density = 0.055
                atmosphere.Color = Color3.fromRGB(210, 220, 240)
                atmosphere.Decay = Color3.fromRGB(65, 70, 90)
                atmosphere.Parent = Lighting

                local cc = Instance.new("ColorCorrectionEffect")
                cc.Name = "SwagaColor"
                cc.Brightness = 0.1
                cc.Contrast = 0.52
                cc.Saturation = 0.08
                cc.TintColor = Color3.fromRGB(230, 235, 255)
                cc.Parent = Lighting

                local bloom = Instance.new("BloomEffect")
                bloom.Name = "SwagaBloom"
                bloom.Intensity = 0.8
                bloom.Size = 36
                bloom.Threshold = 0.65
                bloom.Parent = Lighting

                local rays = Instance.new("SunRaysEffect")
                rays.Name = "SwagaSunRays"
                rays.Intensity = 0.12
                rays.Spread = 0.9
                rays.Parent = Lighting

                local blur = Instance.new("BlurEffect")
                blur.Name = "SwagaBlur"
                blur.Size = 2
                blur.Parent = Lighting
            end)

            local function enhanceEffects(object)
                if not graphicsEnabled then return end
                if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") then
                    object.LightEmission = 1
                    object.LightInfluence = 0
                end
            end

            for _, object in ipairs(Workspace:GetDescendants()) do
                enhanceEffects(object)
            end

            shaderConnection = Workspace.DescendantAdded:Connect(function(object)
                task.defer(function() enhanceEffects(object) end)
            end)
        end
    end
})
-- ==========================================
-- 4. ВКЛАДКА VISUALS / HIGHLIGHTS
-- ==========================================

HighlightsTab:Toggle({
    Title = "Highlights Coins",
    Callback = function(state)
        getgenv().AdvancedCoinESP = state

        if state then
            getgenv().CoinConnections = getgenv().CoinConnections or {}

            local function addHighlight(obj)
                if not getgenv().AdvancedCoinESP or not obj then return end
                if not (obj:IsA("BasePart") or obj:IsA("Model")) then return end
                if obj:FindFirstChild("CoinHighlight") then return end

                local highlight = Instance.new("Highlight")
                highlight.Name = "CoinHighlight"
                highlight.FillColor = Color3.fromRGB(255, 215, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.35
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = obj
            end

            local function checkObject(obj)
                if not getgenv().AdvancedCoinESP or not obj then return end
                if string.lower(obj.Name):find("coin") then
                    addHighlight(obj)
                end
            end

            for _, desc in ipairs(Workspace:GetDescendants()) do checkObject(desc) end

            local conn = Workspace.DescendantAdded:Connect(checkObject)
            table.insert(getgenv().CoinConnections, conn)
        else
            if getgenv().CoinConnections then
                for _, conn in ipairs(getgenv().CoinConnections) do conn:Disconnect() end
                getgenv().CoinConnections = nil
            end

            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name == "CoinHighlight" then desc:Destroy() end
            end
        end
    end
})

-- Исправленный Gun Drop (работает сразу во всех раундах)
HighlightsTab:Toggle({
    Title = "Highlights Gun Dropped",
    Callback = function(state)
        getgenv().GunDropESP = state

        if state then
            getgenv().GunDropConn = getgenv().GunDropConn or {}

            local function applyHighlight(target)
                if not target or target:FindFirstChild("GunDropHighlight") then return end
                local hl = Instance.new("Highlight")
                hl.Name = "GunDropHighlight"
                hl.FillColor = Color3.fromRGB(255, 140, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.3
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = target
            end

            local function scanObject(obj)
                if not getgenv().GunDropESP or not obj then return end
                if obj.Name == "GunDrop" then
                    applyHighlight(obj)
                elseif obj:FindFirstChild("GunDrop") then
                    applyHighlight(obj.GunDrop)
                end
            end

            for _, desc in ipairs(Workspace:GetDescendants()) do scanObject(desc) end

            local conn = Workspace.DescendantAdded:Connect(scanObject)
            table.insert(getgenv().GunDropConn, conn)
        else
            if getgenv().GunDropConn then
                for _, conn in ipairs(getgenv().GunDropConn) do conn:Disconnect() end
                getgenv().GunDropConn = nil
            end

            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name == "GunDropHighlight" then desc:Destroy() end
            end
        end
    end
})

-- Исправленный Role ESP (мгновенный динамический трекинг)
HighlightsTab:Toggle({
    Title = "Highlights Roles",
    Callback = function(state)
        getgenv().RoleESPState = state

        if state then
            local function getRole(player)
                if not player or not player.Character then return "Innocent", Color3.fromRGB(0, 255, 100) end
                local char = player.Character
                local backpack = player:FindFirstChild("Backpack")
                
                local hasKnife = char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
                local hasGun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") or (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))
                
                if hasKnife then
                    return "Murderer", Color3.fromRGB(255, 50, 50)
                elseif hasGun then
                    return "Sheriff", Color3.fromRGB(50, 150, 255)
                else
                    return "Innocent", Color3.fromRGB(0, 255, 100)
                end
            end

            local function createESP(player)
                if player == LocalPlayer then return end

                local function apply()
                    local char = player.Character or player.CharacterAdded:Wait()
                    local head = char:WaitForChild("Head", 5)
                    if not head then return end

                    if char:FindFirstChild("RoleESP") then char.RoleESP:Destroy() end
                    if char:FindFirstChild("RoleHighlight") then char.RoleHighlight:Destroy() end

                    local bb = Instance.new("BillboardGui")
                    bb.Name = "RoleESP"
                    bb.Adornee = head
                    bb.Size = UDim2.new(0, 150, 0, 40)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.AlwaysOnTop = true

                    local txt = Instance.new("TextLabel")
                    txt.Parent = bb
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    txt.TextStrokeTransparency = 0
                    txt.TextSize = 14
                    txt.Font = Enum.Font.SourceSansBold

                    local hl = Instance.new("Highlight")
                    hl.Name = "RoleHighlight"
                    hl.Parent = char
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0

                    bb.Parent = char

                    local conn
                    conn = RunService.RenderStepped:Connect(function()
                        if not getgenv().RoleESPState or not char or not char.Parent or not head.Parent then
                            conn:Disconnect()
                            return
                        end
                        local roleName, color = getRole(player)
                        txt.Text = player.Name .. "\n[" .. roleName .. "]"
                        txt.TextColor3 = color
                        hl.FillColor = color
                        hl.OutlineColor = color
                    end)
                end

                if player.Character then task.spawn(apply) end
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    apply()
                end)
            end

            for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
            getgenv().RolePlayerAddedConn = Players.PlayerAdded:Connect(createESP)
        else
            getgenv().RoleESPState = false
            if getgenv().RolePlayerAddedConn then
                getgenv().RolePlayerAddedConn:Disconnect()
                getgenv().RolePlayerAddedConn = nil
            end

            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    if player.Character:FindFirstChild("RoleESP") then player.Character.RoleESP:Destroy() end
                    if player.Character:FindFirstChild("RoleHighlight") then player.Character.RoleHighlight:Destroy() end
                end
            end
        end
    end
})

-- ==========================================
-- 5. ВКЛАДКИ MISC, TROLL, RAGE, SETTINGS
-- ==========================================

MiscTab:Toggle({
    Title = "Разные Функции (Misc)",
    Callback = function(state) end
})

TrollTab:Button({
    Title = "Tung Tung Sahur Character",
    Desc = "Превращение в Tung Tung Sahur",
    Callback = function()
        applyCustomMesh(138151705692565)
        WindUI:Notify({ Title = "Troll", Content = "Активирован Tung Tung Sahur", Duration = 2 })
    end
})

TrollTab:Button({
    Title = "Nugget Character",
    Desc = "Превращение в Nugget",
    Callback = function()
        applyCustomMesh(16643676840)
        WindUI:Notify({ Title = "Troll", Content = "Активирован Nugget Character", Duration = 2 })
    end
})

TrollTab:Button({
    Title = "Reset Skin to Normal",
    Desc = "Сбросить кастомный скин",
    Callback = function()
        resetCustomCharacter()
        WindUI:Notify({ Title = "Troll", Content = "Скин сброшен к стандартному", Duration = 2 })
    end
})

-- Исправленный Anti Aim Spin (полная блокировка AutoRotate и сброс)
RageTab:Toggle({
    Title = "Anti Aim Spin",
    Desc = "Вращение персонажа",
    Callback = function(state)
        getgenv().SpinState = state

        if getgenv().SpinConn then
            getgenv().SpinConn:Disconnect()
            getgenv().SpinConn = nil
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if state then
            if hum then hum.AutoRotate = false end

            getgenv().SpinConn = RunService.RenderStepped:Connect(function()
                local curChar = LocalPlayer.Character
                local curRoot = curChar and curChar:FindFirstChild("HumanoidRootPart")
                local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")

                if getgenv().SpinState and curRoot and curHum then
                    curHum.AutoRotate = false
                    curRoot.CFrame = curRoot.CFrame * CFrame.Angles(0, math.rad(30), 0)
                else
                    if curHum then curHum.AutoRotate = true end
                    if getgenv().SpinConn then
                        getgenv().SpinConn:Disconnect()
                        getgenv().SpinConn = nil
                    end
                end
            end)
        else
            if hum then hum.AutoRotate = true end
            if root then root.CFrame = CFrame.new(root.CFrame.Position) end
        end
    end
})

SettingsTab:Dropdown({
    Title = "Выбрать theme interface",
    Values = {
        "Dark", "Light", "Sky", "Rose", "Plant", "Red", "Indigo", 
        "Violet", "Amber", "Emerald", "Midnight", "Crimson", 
        "MonokaiPro", "CottonCandy", "Mellowsi", "Rainbow"
    },
    Value = "Sky",
    Callback = function(selectedTheme)
        WindUI:SetTheme(selectedTheme)
        WindUI:Notify({
            Title = "Interface",
            Content = "Установлена тема: " .. selectedTheme,
            Duration = 2
        })
    end
})

WindUI:Notify({
    Title = "Successfully loaded Swaga Hub.",
    Content = "@AnalogyScript",
    Time = 20
})
