local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Swaga Hub | Murder Mystery 2",
    Author = "Created by studs",        
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

getgenv().CoinConnections = getgenv().CoinConnections or {}
getgenv().GunDropConnections = getgenv().GunDropConnections or {}
getgenv().RoleConnections = getgenv().RoleConnections or {}
getgenv().HeroConnections = getgenv().HeroConnections or {}
getgenv().NameESPConnections = getgenv().NameESPConnections or {}
getgenv().SkeletonESPState = false
getgenv().ActiveSkeletons = {}
getgenv().PlayerRoles = getgenv().PlayerRoles or {} -- Таблица для ролей из ремоутов

-- ==========================================
-- ПЕРЕХВАТЧИК РОЛЕЙ ЧЕРЕЗ REMOTES (Ремоут ESP)
-- ==========================================
task.spawn(function()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes", true) or ReplicatedStorage
        for _, remote in ipairs(remotes:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name
                if name == "ShowTeammates" or name == "ShowRoleSelect" or name == "ShowRoleSelectNew" or name == "RoleSelect" then
                    remote.OnClientEvent:Connect(function(...)
                        local args = {...}
                        -- Анализируем аргументы события на наличие данных об игроках и ролях
                        for _, arg in ipairs(args) do
                            if typeof(arg) == "table" then
                                for k, v in pairs(arg) do
                                    if typeof(v) == "string" then
                                        local targetPlayer = Players:FindFirstChild(tostring(k)) or (typeof(v) == "Instance" and v:IsA("Player") and v)
                                        if targetPlayer then
                                            getgenv().PlayerRoles[targetPlayer] = v
                                        end
                                    elseif typeof(v) == "table" then
                                        -- Если таблица содержит роль или игрока
                                        local p = v.Player or v.player or Players:FindFirstChild(tostring(k))
                                        local role = v.Role or v.role or v[1]
                                        if p and typeof(role) == "string" then
                                            getgenv().PlayerRoles[p] = role
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end)
end)

-- Вспомогательная функция определения роли (сначала из Remotes, запасная — через Backpack/Character)
local function getPlayerRole(player)
    if getgenv().PlayerRoles[player] then
        local r = string.lower(tostring(getgenv().PlayerRoles[player]))
        if r:find("murder") or r:find("knife") or r:find("убийц") then
            return "Murderer", Color3.fromRGB(255, 50, 50)
        elseif r:find("sheriff") or r:find("gun") or r:find("шериф") or r:find("герой") then
            return "Sheriff", Color3.fromRGB(50, 150, 255)
        elseif r:find("hero") then
            return "Hero", Color3.fromRGB(200, 50, 255)
        elseif r:find("innocent") or r:find("мирн") then
            return "Innocent", Color3.fromRGB(0, 255, 100)
        end
    end

    -- Запасной вариант через Backpack / Character
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    local hasKnife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local hasGun = (char and (char:FindFirstChild("Gun") or char:FindFirstChild("Revolver"))) or (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver")))

    if hasKnife then
        return "Murderer", Color3.fromRGB(255, 50, 50)
    elseif hasGun then
        return "Sheriff", Color3.fromRGB(50, 150, 255)
    else
        return "Innocent", Color3.fromRGB(0, 255, 100)
    end
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

-- Silent Aim
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

-- Создание вкладок
local SherifTab = Window:Tab({ Title = "Sherif", Icon = "shield" })
local MurderTab = Window:Tab({ Title = "Murder", Icon = "skull" })
local CosmeticTab = Window:Tab({ Title = "Cosmetic", Icon = "sparkles" })
local HighlightsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "component" })
local RageTab = Window:Tab({ Title = "Rage", Icon = "zap" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Sherif Tab
SherifTab:Toggle({
    Title = "Silent Aim (Raycast)",
    Callback = function(state)
        getgenv().SilentAim = state
        WindUI:Notify({ Title = "Silent Aim", Content = state and "Включен" or "Выключен", Duration = 2 })
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
        local throwRemote = events and events:FindFirstChild("KnifeThrown")
        local touchRemote = events and events:FindFirstChild("HandleTouched")

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetChar = player.Character
                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
                if targetHum and targetHum.Health > 0 and targetHRP then
                    if stabRemote then pcall(function() stabRemote:FireServer(targetHum); stabRemote:FireServer(targetHRP) end) end
                    if touchRemote then pcall(function() touchRemote:FireServer(targetHRP) end) end
                    if throwRemote then pcall(function() throwRemote:FireServer(targetHRP.CFrame, targetHRP.Position) end) end
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
-- VISUALS / HIGHLIGHTS & NAME ESP
-- ==========================================

-- Name Player ESP (Никнеймы игроков над головой)
HighlightsTab:Toggle({
    Title = "Name Player ESP",
    Callback = function(state)
        getgenv().NameESPState = state

        for _, conn in ipairs(getgenv().NameESPConnections) do
            if conn and conn.Connected then conn:Disconnect() end
        end
        table.clear(getgenv().NameESPConnections)

        local function removeTag(player)
            if player.Character and player.Character:FindFirstChild("StudsNameTag") then
                player.Character.StudsNameTag:Destroy()
            end
        end

        if not state then
            for _, p in ipairs(Players:GetPlayers()) do removeTag(p) end
        else
            local function addTag(player)
                if player == LocalPlayer then return end
                local char = player.Character
                if not char or not char:FindFirstChild("Head") then return end

                if not char:FindFirstChild("StudsNameTag") then
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
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextStrokeTransparency = 0.3
                    textLabel.TextSize = 14
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.Parent = bb
                end

                local tag = char:FindFirstChild("StudsNameTag")
                if tag and tag:FindFirstChild("NameLabel") then
                    local _, color = getPlayerRole(player)
                    tag.NameLabel.Text = player.Name
                    tag.NameLabel.TextColor3 = color
                end
            end

            local conn = RunService.Heartbeat:Connect(function()
                if not getgenv().NameESPState then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        addTag(p)
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
            local loopConn = RunService.Heartbeat:Connect(function()
                if not getgenv().RoleESPState then return end
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
                        hl.FillColor = color
                        hl.OutlineColor = color
                    end
                end
            end)
            table.insert(getgenv().RoleConnections, loopConn)
        end
    end
})

HighlightsTab:Toggle({
    Title = "Highlights Hero",
    Callback = function(state)
        getgenv().HeroESPState = state
        for _, conn in ipairs(getgenv().HeroConnections) do if conn and conn.Connected then conn:Disconnect() end end
        table.clear(getgenv().HeroConnections)

        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HeroHighlight") then
                player.Character.HeroHighlight:Destroy()
            end
        end

        if state then
            local loopConn = RunService.Heartbeat:Connect(function()
                if not getgenv().HeroESPState then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local role, _ = getPlayerRole(p)
                        local hl = p.Character:FindFirstChild("HeroHighlight")
                        if role == "Sheriff" or role == "Hero" then
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "HeroHighlight"
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.FillColor = Color3.fromRGB(200, 50, 255)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.3
                                hl.Parent = p.Character
                            end
                        else
                            if hl then hl:Destroy() end
                        end
                    end
                end
            end)
            table.insert(getgenv().HeroConnections, loopConn)
        end
    end
})

HighlightsTab:Toggle({
    Title = "Skeleton ESP",
    Callback = function(state)
        getgenv().SkeletonESPState = state
        if not state then
            for player, _ in pairs(getgenv().ActiveSkeletons) do
                if getgenv().ActiveSkeletons[player] then
                    for _, line in pairs(getgenv().ActiveSkeletons[player]) do pcall(function() line:Remove() end) end
                end
            end
            table.clear(getgenv().ActiveSkeletons)
        else
            task.spawn(function()
                while getgenv().SkeletonESPState do
                    RunService.RenderStepped:Wait()
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            local char = player.Character
                            local _, color = getPlayerRole(player)

                            if not getgenv().ActiveSkeletons[player] then
                                getgenv().ActiveSkeletons[player] = {
                                    HeadToTorso = Drawing.new("Line"),
                                    TorsoToLeftArm = Drawing.new("Line"),
                                    TorsoToRightArm = Drawing.new("Line"),
                                    TorsoToLeftLeg = Drawing.new("Line"),
                                    TorsoToRightLeg = Drawing.new("Line")
                                }
                                for _, l in pairs(getgenv().ActiveSkeletons[player]) do l.Thickness = 1.5; l.Visible = false end
                            end

                            local bones = getgenv().ActiveSkeletons[player]
                            local head = char:FindFirstChild("Head")
                            local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                            local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftLowerArm")
                            local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightLowerArm")
                            local leftLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftLowerLeg")
                            local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightLowerLeg")
                            local camera = Workspace.CurrentCamera

                            local function drawBone(line, p1, p2)
                                if p1 and p2 then
                                    local s1, o1 = camera:WorldToViewportPoint(p1.Position)
                                    local s2, o2 = camera:WorldToViewportPoint(p2.Position)
                                    if o1 or o2 then
                                        line.From = Vector2.new(s1.X, s1.Y)
                                        line.To = Vector2.new(s2.X, s2.Y)
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
                end
            end)
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
