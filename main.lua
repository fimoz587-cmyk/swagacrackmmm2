local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Swaga Hub | Murder Mystery 2",
    Author = "Created by studs",        
    Theme = "Sky", 
    Icon = "rbxassetid://13936134740",
    Size = UDim2.fromOffset(580, 460),
    ToggleKey = Enum.KeyCode.RightShift
})

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

getgenv().RoleConnections = getgenv().RoleConnections or {}
getgenv().CoinConnections = getgenv().CoinConnections or {}
getgenv().GunDropConnections = getgenv().GunDropConnections or {}

-- Быстрая проверка ролей через Backpack и Character
local function getPlayerRole(player)
    if not player or not player.Character then return "Innocent", Color3.fromRGB(0, 255, 100) end
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))
    
    if hasKnife then 
        return "Murderer", Color3.fromRGB(255, 50, 50)
    elseif hasGun then 
        return "Sheriff", Color3.fromRGB(50, 150, 255)
    end
    return "Innocent", Color3.fromRGB(0, 255, 100)
end

-- Функция поиска живого Убийцы (из твоего нового кода)
local function getMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if player.Character:FindFirstChild("Knife") or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    return player
                end
            end
        end
    end
    return nil
end

-- ==========================================
-- УЛЬТРА-БЫСТРЫЙ SILENT AUTO-SHOOT (Без поворота камеры)
-- ==========================================
getgenv().SilentAutoShootState = false
local isShooting = false
local shotCooldown = 0.5 

RunService.RenderStepped:Connect(function()
    if not getgenv().SilentAutoShootState then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local currentGun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver")
    if not currentGun or isShooting then return end 
    
    local murderer = getMurderer()
    if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
        isShooting = true
        task.spawn(function()
            pcall(function() currentGun:Activate() end)
            task.wait(shotCooldown)
            isShooting = false
        end)
    end
end)

-- Метаметод Silent Aim (Перенаправляет пулю в Убийцу)
pcall(function()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)

    mt.__index = newcclosure(function(t, k)
        if t == LocalPlayer:GetMouse() and (k == "Hit" or k == "Target") and getgenv().SilentAutoShootState then
            local murderer = getMurderer()
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
                if k == "Hit" then
                    return murderer.Character.HumanoidRootPart.CFrame
                elseif k == "Target" then
                    return murderer.Character.HumanoidRootPart
                end
            end
        end
        return oldIndex(t, k)
    end)
    setreadonly(mt, true)
end)

-- Создание вкладок
local SherifTab = Window:Tab({ Title = "Sherif", Icon = "shield" })
local MurderTab = Window:Tab({ Title = "Murder", Icon = "skull" })
local HighlightsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local RageTab = Window:Tab({ Title = "Rage", Icon = "zap" })
local CosmeticTab = Window:Tab({ Title = "Cosmetic", Icon = "sparkles" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Sherif Tab
SherifTab:Toggle({
    Title = "Silent Auto-Shoot (Без тряски камеры)",
    Callback = function(state)
        getgenv().SilentAutoShootState = state
        WindUI:Notify({ Title = "Silent Shoot", Content = state and "Включен" or "Выключен", Duration = 2 })
    end
})

SherifTab:Toggle({
    Title = "Auto Pick Gun",
    Callback = function(state)
        getgenv().AutoPickGun = state
        task.spawn(function()
            while getgenv().AutoPickGun do
                task.wait(0.2)
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

-- Murder Tab
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
        local touchRemote = events and events:FindFirstChild("HandleTouched")

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetChar = player.Character
                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
                if targetHum and targetHum.Health > 0 and targetHRP then
                    if stabRemote then pcall(function() stabRemote:FireServer(targetHum); stabRemote:FireServer(targetHRP) end) end
                    if touchRemote then pcall(function() touchRemote:FireServer(targetHRP) end) end
                end
            end
        end
        WindUI:Notify({ Title = "Успешно", Content = "Все игроки уничтожены", Duration = 3 })
    end
})

-- Visuals Tab (Оптимизированные Highlights)
HighlightsTab:Toggle({
    Title = "Highlights Roles",
    Callback = function(state)
        getgenv().RoleESPState = state
        for _, conn in ipairs(getgenv().RoleConnections) do if conn and conn.Connected then conn:Disconnect() end end
        table.clear(getgenv().RoleConnections)

        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("RoleHighlight") then
                player.Character.RoleHighlight:Destroy()
            end
        end

        if state then
            local counter = 0
            local loopConn = RunService.Heartbeat:Connect(function()
                if not getgenv().RoleESPState then return end
                counter = counter + 1
                if counter % 10 ~= 0 then return end

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local _, color = getPlayerRole(p)
                        local hl = p.Character:FindFirstChild("RoleHighlight")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "RoleHighlight"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.FillTransparency = 0.4
                            hl.OutlineTransparency = 0
                            hl.Parent = p.Character
                        end
                        if hl.FillColor ~= color then
                            hl.FillColor = color
                            hl.OutlineColor = color
                        end
                    end
                end
            end)
            table.insert(getgenv().RoleConnections, loopConn)
        end
    end
})

HighlightsTab:Toggle({
    Title = "Highlights Coins",
    Callback = function(state)
        getgenv().AdvancedCoinESP = state
        for _, conn in ipairs(getgenv().CoinConnections) do if conn and conn.Connected then conn:Disconnect() end end
        table.clear(getgenv().CoinConnections)

        if state then
            local function addHighlight(obj)
                if not obj:FindFirstChild("CoinHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "CoinHighlight"
                    hl.FillColor = Color3.fromRGB(255, 215, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.35
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = obj
                end
            end
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if string.lower(desc.Name):find("coin") then addHighlight(desc) end
            end
            local conn = Workspace.DescendantAdded:Connect(function(obj)
                if getgenv().AdvancedCoinESP and string.lower(obj.Name):find("coin") then addHighlight(obj) end
            end)
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
        for _, conn in ipairs(getgenv().GunDropConnections) do if conn and conn.Connected then conn:Disconnect() end end
        table.clear(getgenv().GunDropConnections)

        if state then
            local function applyHighlight(target)
                if target and not target:FindFirstChild("GunDropHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "GunDropHighlight"
                    hl.FillColor = Color3.fromRGB(255, 140, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.3
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = target
                end
            end
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name == "GunDrop" then applyHighlight(desc) end
            end
            local conn = Workspace.DescendantAdded:Connect(function(obj)
                if getgenv().GunDropESP and obj.Name == "GunDrop" then applyHighlight(obj) end
            end)
            table.insert(getgenv().GunDropConnections, conn)
        else
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name == "GunDropHighlight" then desc:Destroy() end
            end
        end
    end
})

-- Rage Tab (Anti Aim Spin)
RageTab:Toggle({
    Title = "Anti Aim Spin (Крутилка)",
    Callback = function(state)
        getgenv().SpinState = state
        if getgenv().SpinConn then getgenv().SpinConn:Disconnect(); getgenv().SpinConn = nil end
        if state then
            getgenv().SpinConn = RunService.RenderStepped:Connect(function()
                if not getgenv().SpinState then return end
                local curChar = LocalPlayer.Character
                local curRoot = curChar and curChar:FindFirstChild("HumanoidRootPart")
                local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
                if curRoot and curHum and curHum.Health > 0 then
                    curHum.AutoRotate = false
                    curRoot.CFrame = curRoot.CFrame * CFrame.Angles(0, math.rad(35), 0)
                end
            end)
        else
            local curChar = LocalPlayer.Character
            local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
            if curHum then curHum.AutoRotate = true end
        end
    end
})

-- Cosmetic Tab (Настоящие шейдеры: Bloom, ColorCorrection, SunRays)
CosmeticTab:Toggle({
    Title = "Real Shaders (Цветокоррекция и Блум)",
    Value = false,
    Callback = function(state)
        for _, v in ipairs(Lighting:GetChildren()) do 
            if v.Name == "SwagaCC" or v.Name == "SwagaBloom" or v.Name == "SwagaSunRays" then v:Destroy() end 
        end
        if state then
            pcall(function()
                local cc = Instance.new("ColorCorrectionEffect")
                cc.Name = "SwagaCC"
                cc.Brightness = 0.05
                cc.Contrast = 0.2
                cc.Saturation = 0.15
                cc.TintColor = Color3.fromRGB(245, 240, 255)
                cc.Parent = Lighting

                local bloom = Instance.new("BloomEffect")
                bloom.Name = "SwagaBloom"
                bloom.Intensity = 0.35
                bloom.Size = 24
                bloom.Threshold = 0.75
                bloom.Parent = Lighting

                local sunRays = Instance.new("SunRaysEffect")
                sunRays.Name = "SwagaSunRays"
                sunRays.Intensity = 0.15
                sunRays.Spread = 0.5
                sunRays.Parent = Lighting
            end)
            WindUI:Notify({ Title = "Шейдеры", Content = "Включены", Duration = 2 })
        end
    end
})

SettingsTab:Dropdown({
    Title = "Выбрать тему интерфейса",
    Values = {"Dark", "Light", "Sky", "Rose", "Plant", "Red", "Indigo", "Violet", "Amber", "Emerald", "Midnight", "Crimson"},
    Value = "Sky",
    Callback = function(selectedTheme)
        WindUI:SetTheme(selectedTheme)
        WindUI:Notify({ Title = "Интерфейс", Content = "Тема: " .. selectedTheme, Duration = 2 })
    end
})

WindUI:Notify({
    Title = "Swaga Hub загружен!",
    Content = "Автор: studs",
    Time = 5
})
