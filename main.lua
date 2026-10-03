local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Swaga Hub | Murder Mystery 2",
    Author = "Created by @AnalogyScript",        
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

getgenv().CoinConnections = getgenv().CoinConnections or {}
getgenv().GunDropConnections = getgenv().GunDropConnections or {}
getgenv().RoleConnections = getgenv().RoleConnections or {}
getgenv().SkeletonESPState = false
getgenv().ActiveSkeletons = {}

-- ==========================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ И ХУКИ
-- ==========================================

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
            if hasKnife then
                return player
            end
        end
    end
    return nil
end

-- 100% Безопасный Silent Aim (Фильтр строго по рукоятке оружия)
getgenv().SilentAim = false
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if getgenv().SilentAim and not checkcaller() and method == "Raycast" and self == Workspace then
        local char = LocalPlayer.Character
        local gun = char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))
        local handle = gun and (gun:FindFirstChild("Handle") or gun:FindFirstChildWhichIsA("BasePart"))
        local camera = Workspace.CurrentCamera
        
        if handle and args[1] and args[2] then
            local origin = args[1]
            if typeof(origin) == "Vector3" and camera and (origin - camera.CFrame.Position).Magnitude > 2 then
                if (origin - handle.Position).Magnitude < 4 then
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
        end
    end
    return oldNamecall(self, ...)
end)

-- ==========================================
-- СОЗДАНИЕ ВКЛАДОК
-- ==========================================

local SherifTab = Window:Tab({ Title = "Sherif", Icon = "shield" })
local MurderTab = Window:Tab({ Title = "Murder", Icon = "skull" })
local CosmeticTab = Window:Tab({ Title = "Cosmetic", Icon = "sparkles" })
local HighlightsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "component" })
local RageTab = Window:Tab({ Title = "Rage", Icon = "zap" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ==========================================
-- 1. SHERIF
-- ==========================================

SherifTab:Toggle({
    Title = "Silent Aim (Raycast)",
    Callback = function(state)
        getgenv().SilentAim = state
        WindUI:Notify({
            Title = "Silent Aim",
            Content = state and "Включен (Автонаводка на Murderer)" or "Выключен",
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
-- 2. MURDER
-- ==========================================

MurderTab:Button({
    Title = "Kill All",
    Callback = function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local knife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))

        if not knife then
            WindUI:Notify({ Title = "Ошибка", Content = "Нож не найден!", Duration = 3 })
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
                        pcall(function() touchRemote:FireServer(targetHRP) end)
                    end
                    if throwRemote then
                        pcall(function() throwRemote:FireServer(targetHRP.CFrame, targetHRP.Position) end)
                    end
                end
            end
        end

        WindUI:Notify({ Title = "Успешно", Content = "Все игроки уничтожены", Duration = 3 })
    end
})

-- ==========================================
-- 3. COSMETIC
-- ==========================================

CosmeticTab:Toggle({
    Title = "Black Sky (Темное небо)",
    Value = false,
    Callback = function(state)
        for _, v in ipairs(Lighting:GetChildren()) do
            if v.Name == "SwagaSky" then v:Destroy() end
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
            end)
        end
    end
})

CosmeticTab:Toggle({
    Title = "Shaders & Fog (Шейдеры и туман)",
    Value = false,
    Callback = function(state)
        for _, v in ipairs(Lighting:GetChildren()) do
            if v.Name:find("SwagaShader") or v.Name:find("SwagaAtmosphere") then v:Destroy() end
        end

        if state then
            pcall(function()
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
                atmosphere.Density = 0.15
                atmosphere.Offset = 0.25
                atmosphere.Color = Color3.fromRGB(150, 160, 180)
                atmosphere.Decay = Color3.fromRGB(45, 50, 70)
                atmosphere.Glare = 0.2
                atmosphere.Haze = 1.5
                atmosphere.Parent = Lighting

                local cc = Instance.new("ColorCorrectionEffect")
                cc.Name = "SwagaShaderColor"
                cc.Brightness = 0.1
                cc.Contrast = 0.52
                cc.Saturation = 0.08
                cc.TintColor = Color3.fromRGB(230, 235, 255)
                cc.Parent = Lighting

                local bloom = Instance.new("BloomEffect")
                bloom.Name = "SwagaShaderBloom"
                bloom.Intensity = 0.8
                bloom.Size = 36
                bloom.Threshold = 0.65
                bloom.Parent = Lighting

                local rays = Instance.new("SunRaysEffect")
                rays.Name = "SwagaShaderRays"
                rays.Intensity = 0.12
                rays.Spread = 0.9
                rays.Parent = Lighting

                local blur = Instance.new("BlurEffect")
                blur.Name = "SwagaShaderBlur"
                blur.Size = 2
                blur.Parent = Lighting
            end)
        end
    end
})
-- ==========================================
-- 4. VISUALS / HIGHLIGHTS (С обновленной проверкой через Backpack)
-- ==========================================

HighlightsTab:Toggle({
    Title = "Highlights Coins",
    Callback = function(state)
        getgenv().AdvancedCoinESP = state

        for _, conn in ipairs(getgenv().CoinConnections) do
            if conn and conn.Connected then conn:Disconnect() end
        end
        table.clear(getgenv().CoinConnections)

        if state then
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
                if string.lower(obj.Name):find("coin") then addHighlight(obj) end
            end

            for _, desc in ipairs(Workspace:GetDescendants()) do checkObject(desc) end

            local conn = Workspace.DescendantAdded:Connect(checkObject)
            table.insert(getgenv().CoinConnections, conn)
        else
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name == "CoinHighlight" then desc:Destroy() end
            end
        end
    end
})

HighlightsTab:Toggle({
    Title = "Highlights Gun Dropped",
    Callback = function(state)
        getgenv().GunDropESP = state

        for _, conn in ipairs(getgenv().GunDropConnections) do
            if conn and conn.Connected then conn:Disconnect() end
        end
        table.clear(getgenv().GunDropConnections)

        if state then
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
            table.insert(getgenv().GunDropConnections, conn)
        else
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name == "GunDropHighlight" then desc:Destroy() end
            end
        end
    end
})

HighlightsTab:Toggle({
    Title = "Highlights Roles",
    Callback = function(state)
        getgenv().RoleESPState = state

        for _, conn in ipairs(getgenv().RoleConnections) do
            if conn and conn.Connected then conn:Disconnect() end
        end
        table.clear(getgenv().RoleConnections)

        local function cleanupAll()
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("RoleHighlight") then
                    player.Character.RoleHighlight:Destroy()
                end
            end
        end

        cleanupAll()

        if state then
            local function getRoleColor(player)
                if not player then return Color3.fromRGB(0, 255, 100) end
                local char = player.Character
                local backpack = player:FindFirstChild("Backpack")
                
                local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
                local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))
                
                if hasKnife then
                    return Color3.fromRGB(255, 50, 50) -- Убийца (Красный)
                elseif hasGun then
                    return Color3.fromRGB(50, 150, 255) -- Шериф (Синий)
                else
                    return Color3.fromRGB(0, 255, 100) -- Мирный (Зеленый)
                end
            end

            local function updatePlayer(player)
                if player == LocalPlayer then return end
                local char = player.Character
                if not char then return end

                local color = getRoleColor(player)
                local hl = char:FindFirstChild("RoleHighlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "RoleHighlight"
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                end
                hl.FillColor = color
                hl.OutlineColor = color
            end

            local loopConn = RunService.Heartbeat:Connect(function()
                if not getgenv().RoleESPState then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        updatePlayer(p)
                    end
                end
            end)
            
            table.insert(getgenv().RoleConnections, loopConn)
        end
    end
})

HighlightsTab:Toggle({
    Title = "Skeleton ESP",
    Callback = function(state)
        getgenv().SkeletonESPState = state

        local function removeSkeleton(player)
            if getgenv().ActiveSkeletons[player] then
                for _, line in pairs(getgenv().ActiveSkeletons[player]) do
                    pcall(function() line:Remove() end)
                end
                getgenv().ActiveSkeletons[player] = nil
            end
        end

        if not state then
            for player, _ in pairs(getgenv().ActiveSkeletons) do
                removeSkeleton(player)
            end
            table.clear(getgenv().ActiveSkeletons)
        else
            task.spawn(function()
                while getgenv().SkeletonESPState do
                    RunService.RenderStepped:Wait()

                    local activePlayers = {}
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            activePlayers[player] = true

                            local char = player.Character
                            local backpack = player:FindFirstChild("Backpack")
                            local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
                            local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))
                            
                            local color = Color3.fromRGB(0, 255, 100)
                            if hasKnife then
                                color = Color3.fromRGB(255, 50, 50)
                            elseif hasGun then
                                color = Color3.fromRGB(50, 150, 255)
                            end

                            if not getgenv().ActiveSkeletons[player] then
                                local bones = {
                                    HeadToTorso = Drawing.new("Line"),
                                    TorsoToLeftArm = Drawing.new("Line"),
                                    TorsoToRightArm = Drawing.new("Line"),
                                    TorsoToLeftLeg = Drawing.new("Line"),
                                    TorsoToRightLeg = Drawing.new("Line")
                                }
                                for _, line in pairs(bones) do
                                    line.Thickness = 1.5
                                    line.Visible = false
                                end
                                getgenv().ActiveSkeletons[player] = bones
                            end

                            local bones = getgenv().ActiveSkeletons[player]
                            local head = char:FindFirstChild("Head")
                            local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                            local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftLowerArm")
                            local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightLowerArm")
                            local leftLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftLowerLeg")
                            local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightLowerLeg")

                            local camera = Workspace.CurrentCamera

                            local function drawBone(line, p1, p2)
                                if p1 and p2 then
                                    local screen1, onScreen1 = camera:WorldToViewportPoint(p1.Position)
                                    local screen2, onScreen2 = camera:WorldToViewportPoint(p2.Position)
                                    if onScreen1 or onScreen2 then
                                        line.From = Vector2.new(screen1.X, screen1.Y)
                                        line.To = Vector2.new(screen2.X, screen2.Y)
                                        line.Color = color
                                        line.Visible = true
                                        return
                                    end
                                end
                                line.Visible = false
                            end

                            drawBone(bones.HeadToTorso, head, torso)
                            drawBone(bones.TorsoToLeftArm, torso, leftArm)
                            drawBone(bones.TorsoToRightArm, torso, rightArm)
                            drawBone(bones.TorsoToLeftLeg, torso, leftLeg)
                            drawBone(bones.TorsoToRightLeg, torso, rightLeg)
                        end
                    end

                    for player, _ in pairs(getgenv().ActiveSkeletons) do
                        if not activePlayers[player] then
                            removeSkeleton(player)
                        end
                    end
                end
            end)
        end
    end
})

-- ==========================================
-- 5. MISC, RAGE, SETTINGS
-- ==========================================

MiscTab:Toggle({
    Title = "Разные Функции (Misc)",
    Callback = function(state) end
})

RageTab:Toggle({
    Title = "Anti Aim Spin",
    Desc = "Быстрое вращение персонажа",
    Callback = function(state)
        getgenv().SpinState = state

        if getgenv().SpinConn then
            getgenv().SpinConn:Disconnect()
            getgenv().SpinConn = nil
        end

        if state then
            getgenv().SpinConn = RunService.RenderStepped:Connect(function()
                if not getgenv().SpinState then return end

                local curChar = LocalPlayer.Character
                local curRoot = curChar and curChar:FindFirstChild("HumanoidRootPart")
                local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")

                if curRoot and curHum and curHum.Health > 0 then
                    curHum.AutoRotate = false
                    curRoot.CFrame = curRoot.CFrame * CFrame.Angles(0, math.rad(30), 0)
                end
            end)
        else
            local curChar = LocalPlayer.Character
            local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
            if curHum then
                curHum.AutoRotate = true
            end
        end
    end
})

SettingsTab:Dropdown({
    Title = "Выбрать тему интерфейса",
    Values = {
        "Dark", "Light", "Sky", "Rose", "Plant", "Red", "Indigo", 
        "Violet", "Amber", "Emerald", "Midnight", "Crimson", 
        "MonokaiPro", "CottonCandy", "Mellowsi", "Rainbow"
    },
    Value = "Sky",
    Callback = function(selectedTheme)
        WindUI:SetTheme(selectedTheme)
        WindUI:Notify({
            Title = "Интерфейс",
            Content = "Установлена тема: " .. selectedTheme,
            Duration = 2
        })
    end
})

WindUI:Notify({
    Title = "Swaga Hub загружен!",
    Content = "Автор: @AnalogyScript",
    Time = 5
})
