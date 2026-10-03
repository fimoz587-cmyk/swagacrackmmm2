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

getgenv().CoinConnections = getgenv().CoinConnections or {}
getgenv().GunDropConnections = getgenv().GunDropConnections or {}
getgenv().RoleConnections = getgenv().RoleConnections or {}
getgenv().HeroConnections = getgenv().HeroConnections or {}
getgenv().NameESPConnections = getgenv().NameESPConnections or {}
getgenv().ActiveSkeletons = {}

-- Быстрая и стабильная проверка ролей через Backpack и Character
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

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role, _ = getPlayerRole(player)
            if role == "Murderer" then return player end
        end
    end
    return nil
end

-- ==========================================
-- SILENT AUTO-SHOOT (Твой код)
-- ==========================================
getgenv().SilentAutoShootState = false
local lastShotTime = 0
local shotCooldown = 0.5 

RunService.RenderStepped:Connect(function()
    if not getgenv().SilentAutoShootState then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    local currentGun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver")
    if not currentGun then return end 
    
    local murderer = getMurderer()
    if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
        if tick() - lastShotTime >= shotCooldown then
            lastShotTime = tick()
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, murderer.Character.HumanoidRootPart.Position)
            pcall(function() currentGun:Activate() end)
        end
    end
end)

-- Метаметод Silent Aim
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
local CosmeticTab = Window:Tab({ Title = "Cosmetic", Icon = "sparkles" })
local HighlightsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local RageTab = Window:Tab({ Title = "Rage", Icon = "zap" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Sherif Tab
SherifTab:Toggle({
    Title = "Silent Auto-Shoot (Авто-шот)",
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

-- Cosmetic Tab
CosmeticTab:Toggle({
    Title = "Black Sky (Темное небо)",
    Value = false,
    Callback = function(state)
        for _, v in ipairs(Lighting:GetChildren()) do if v.Name == "SwagaSky" then v:Destroy() end end
        if state then
            pcall(function()
                local sky = Instance.new("Sky")
                sky.Name = "SwagaSky"
                local SKY_ID = "rbxassetid://7158024342"
                sky.SkyboxBk = SKY_ID; sky.SkyboxDn = SKY_ID; sky.SkyboxFt = SKY_ID
                sky.SkyboxLf = SKY_ID; sky.SkyboxRt = SKY_ID; sky.SkyboxUp = SKY_ID
                sky.Parent = Lighting
            end)
        end
    end
})
-- ==========================================
-- VISUALS / HIGHLIGHTS & NAME ESP (Оптимизировано)
-- ==========================================

HighlightsTab:Toggle({
    Title = "Name Player ESP",
    Callback = function(state)
        getgenv().NameESPState = state
        for _, conn in ipairs(getgenv().NameESPConnections) do if conn and conn.Connected then conn:Disconnect() end end
        table.clear(getgenv().NameESPConnections)

        if not state then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("StudsNameTag") then p.Character.StudsNameTag:Destroy() end
            end
        else
            local counter = 0
            local conn = RunService.Heartbeat:Connect(function()
                if not getgenv().NameESPState then return end
                counter = counter + 1
                if counter % 5 ~= 0 then return end

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local char = p.Character
                        local tag = char:FindFirstChild("StudsNameTag")
                        if not tag then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "StudsNameTag"
                            bb.Size = UDim2.new(0, 200, 0, 50)
                            bb.StudsOffset = Vector3.new(0, 2.5, 0)
                            bb.AlwaysOnTop = true
                            bb.Parent = char

                            local textLabel = Instance.new("TextLabel")
                            textLabel.Name = "NameLabel"
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.TextStrokeTransparency = 0.3
                            textLabel.TextSize = 14
                            textLabel.Font = Enum.Font.GothamBold
                            textLabel.Parent = bb
                            tag = bb
                        end
                        
                        if tag and tag:FindFirstChild("NameLabel") then
                            local _, color = getPlayerRole(p)
                            tag.NameLabel.Text = p.Name
                            tag.NameLabel.TextColor3 = color
                        end
                    end
                end
            end)
            table.insert(getgenv().NameESPConnections, conn)
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
                if counter % 5 ~= 0 then return end

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

RageTab:Toggle({
    Title = "Anti Aim Spin",
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
                    curRoot.CFrame = curRoot.CFrame * CFrame.Angles(0, math.rad(30), 0)
                end
            end)
        else
            local curChar = LocalPlayer.Character
            local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
            if curHum then curHum.AutoRotate = true end
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
