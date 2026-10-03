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
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ==========================================

-- Поиск Убийцы (Murderer) для Silent Aim
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

-- Хук Raycast для Silent Aim
getgenv().SilentAim = false
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if getgenv().SilentAim and not checkcaller() then
        if method == "Raycast" and self == Workspace then
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart") 
                    or murderer.Character:FindFirstChild("UpperTorso") 
                    or murderer.Character:FindFirstChild("Head")
                
                if targetPart then
                    local origin = args[1]
                    args[2] = (targetPart.Position - origin).Unit * 1000
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)

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
                sky.SkyboxBk = SKY_ID
                sky.SkyboxDn = SKY_ID
                sky.SkyboxFt = SKY_ID
                sky.SkyboxLf = SKY_ID
                sky.SkyboxRt = SKY_ID
                sky.SkyboxUp = SKY_ID
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
        else
            for object, props in pairs(originalProperties) do
                if object and object.Parent then
                    for propName, value in pairs(props) do
                        pcall(function() object[propName] = value end)
                    end
                end
            end
            table.clear(originalProperties)
        end
    end
})

CosmeticTab:Toggle({
    Title = "Angel Wing (bad)",
    Callback = function(state)
        if state then
            local function setupBlackSky()
                pcall(function()
                    for _, object in ipairs(Lighting:GetChildren()) do
                        if object:IsA("Sky") then object:Destroy() end
                    end
                    local sky = Instance.new("Sky")
                    sky.Name = "PureBlackSky"
                    local id = "rbxassetid://0"
                    sky.SkyboxBk = id; sky.SkyboxDn = id; sky.SkyboxFt = id
                    sky.SkyboxLf = id; sky.SkyboxRt = id; sky.SkyboxUp = id
                    sky.StarCount = 0
                    sky.Parent = Lighting
                end)
            end

            local function createNeonWings(character)
                if not character then return end
                local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
                if not torso then return end

                local old = character:FindFirstChild("NeonWings")
                if old then old:Destroy() end

                local folder = Instance.new("Folder")
                folder.Name = "NeonWings"
                folder.Parent = character

                local feathers = {}
                local function createFeather(side, index)
                    local progress = (index - 1) / 6
                    local feather = Instance.new("Part")
                    feather.Name = "WingFeather"
                    feather.Size = Vector3.new(0.16, 0.3, 1.5 + progress * 2.3)
                    feather.Material = Enum.Material.Neon
                    feather.Color = Color3.fromRGB(255, 255, 255)
                    feather.CanCollide = false
                    feather.Massless = true
                    feather.Parent = folder

                    local weld = Instance.new("Weld")
                    weld.Part0 = torso
                    weld.Part1 = feather
                    weld.C0 = CFrame.new(side * (0.45 + progress * 1.8), 0.45 - progress * 0.65, 0.75) 
                        * CFrame.Angles(math.rad(-15 + progress * 28), math.rad(side * (15 + progress * 35)), math.rad(side * (8 + progress * 12)))
                    weld.Parent = feather

                    table.insert(feathers, {weld = weld, base = weld.C0, index = index + (side == 1 and 0 or 10)})
                end

                for side = -1, 1, 2 do
                    for i = 1, 7 do createFeather(side, i) end
                end

                RunService.RenderStepped:Connect(function()
                    if not character.Parent or not folder.Parent then return end
                    local time = os.clock()
                    for _, data in ipairs(feathers) do
                        data.weld.C0 = data.base * CFrame.Angles(0, math.sin(time * 2.5 + data.index * 0.35) * 0.025, 0)
                    end
                end)
            end

            local function applyAll(character)
                task.wait(0.5)
                setupBlackSky()
                createNeonWings(character)
            end

            if LocalPlayer.Character then task.spawn(applyAll, LocalPlayer.Character) end
            LocalPlayer.CharacterAdded:Connect(applyAll)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("NeonWings") then
                LocalPlayer.Character.NeonWings:Destroy()
            end
        end
    end
})

CosmeticTab:Toggle({
    Title = "Angel Crown (Not Work)",
    Callback = function(state)
        if LocalPlayer.Character then
            if LocalPlayer.Character:FindFirstChild("NeonWings") then LocalPlayer.Character.NeonWings:Destroy() end
            if LocalPlayer.Character:FindFirstChild("NeonCrown") then LocalPlayer.Character.NeonCrown:Destroy() end
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
            getgenv().CoinHighlighted = {}
            getgenv().CoinConnections = {}

            local coinNames = {
                MainCoin = true, Coin = true, CoinPart = true, 
                CoinVisual = true, CoinMesh = true, DecalPart = true, ["2Part"] = true
            }

            local containerNames = {
                Coin = true, Coins = true, CoinContainer = true, Coin_Container = true, 
                CoinVisual = true, CoinPickup = true, CoinPickups = true, Collectible = true, Collectibles = true
            }

            local function isCoinName(name)
                if coinNames[name] then return true end
                local lower = string.lower(name)
                return lower == "coin" or lower == "coins" or lower:find("coin") ~= nil
            end

            local function isCoinContainer(obj)
                return containerNames[obj.Name] == true or string.lower(obj.Name):find("coin") ~= nil
            end

            local function addHighlight(obj)
                if not getgenv().AdvancedCoinESP or not obj or getgenv().CoinHighlighted[obj] then return end
                if not obj:IsA("BasePart") and not obj:IsA("Model") then return end

                getgenv().CoinHighlighted[obj] = true
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

                if isCoinName(obj.Name) then
                    addHighlight(obj)
                    return
                end

                local parent = obj.Parent
                if parent and isCoinContainer(parent) then
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        addHighlight(obj)
                    end
                    return
                end

                if isCoinContainer(obj) then
                    for _, child in ipairs(obj:GetChildren()) do
                        if isCoinName(child.Name) then
                            addHighlight(child)
                        end
                    end
                end
            end

            local function scanContainer(container)
                if not container then return end

                for _, obj in ipairs(container:GetDescendants()) do
                    checkObject(obj)
                end

                local conn = container.DescendantAdded:Connect(function(obj)
                    if not getgenv().AdvancedCoinESP then return end
                    checkObject(obj)
                    task.defer(function()
                        if obj and obj.Parent then
                            checkObject(obj)
                            for _, child in ipairs(obj:GetDescendants()) do
                                checkObject(child)
                            end
                        end
                    end)
                end)
                table.insert(getgenv().CoinConnections, conn)
            end

            scanContainer(Workspace)

            local workspaceChildConn = Workspace.ChildAdded:Connect(function(child)
                if not getgenv().AdvancedCoinESP then return end
                checkObject(child)
                task.defer(function()
                    if child and child.Parent then scanContainer(child) end
                end)
            end)
            table.insert(getgenv().CoinConnections, workspaceChildConn)
        else
            if getgenv().CoinConnections then
                for _, conn in ipairs(getgenv().CoinConnections) do
                    if conn then conn:Disconnect() end
                end
                getgenv().CoinConnections = nil
            end

            getgenv().CoinHighlighted = nil

            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name == "CoinHighlight" then
                    desc:Destroy()
                end
            end
        end
    end
})

HighlightsTab:Toggle({
    Title = "Highlights Gun Dropped",
    Callback = function(state)
        if state then
            local mapNames = {
                "Office3", "School", "Hospital3", "Mansion2", "House2", 
                "Hotel2", "MilBase", "Factory", "ResearchFactory", 
                "Office2", "Biolab", "Workplace", "PoliceStation", "Normal", "Map"
            }

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
                if not obj then return end
                if obj.Name == "GunDrop" then
                    applyHighlight(obj)
                elseif obj:FindFirstChild("GunDrop") then
                    applyHighlight(obj.GunDrop)
                end
            end

            local function hookMap(map)
                if not map then return end
                for _, desc in ipairs(map:GetDescendants()) do scanObject(desc) end
                map.DescendantAdded:Connect(scanObject)
            end

            for _, name in ipairs(mapNames) do
                local map = Workspace:FindFirstChild(name)
                if map then hookMap(map) end
            end

            for _, desc in ipairs(Workspace:GetDescendants()) do scanObject(desc) end
            Workspace.DescendantAdded:Connect(scanObject)

            Workspace.ChildAdded:Connect(function(child)
                if table.find(mapNames, child.Name) or child.Name == "Normal" or child.Name == "Map" then
                    hookMap(child)
                else
                    scanObject(child)
                end
            end)
        else
            for _, desc in ipairs(Workspace:GetDescendants()) do
                if desc.Name == "GunDropHighlight" then
                    desc:Destroy()
                end
            end
        end
    end
})

HighlightsTab:Toggle({
    Title = "Highlights Roles",
    Callback = function(state)
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
                    local hrp = char:WaitForChild("HumanoidRootPart", 5)
                    local head = char:WaitForChild("Head", 5)
                    if not hrp or not head then return end

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
                        if not char or not char:IsDescendantOf(Workspace) or not hrp or not head then
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
            Players.PlayerAdded:Connect(createESP)
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local char = player.Character
                    if char:FindFirstChild("RoleESP") then char.RoleESP:Destroy() end
                    if char:FindFirstChild("RoleHighlight") then char.RoleHighlight:Destroy() end
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
    Callback = function(state)
        -- Дополнительный функционал
    end
})

TrollTab:Button({
    Title = "Tung Tung Sahur Character",
    Desc = "Click and you'll turn into Tung Tung Tung Sahur.",
    Callback = function()
        local ASSET_ID = 138151705692565
        local assetUrl = "rbxassetid://" .. ASSET_ID

        -- Очистка старых обработчиков и мешей
        if getgenv().SahurCharConn then
            getgenv().SahurCharConn:Disconnect()
            getgenv().SahurCharConn = nil
        end
        if getgenv().SahurRenderConn then
            getgenv().SahurRenderConn:Disconnect()
            getgenv().SahurRenderConn = nil
        end
        if getgenv().SahurMesh then
            getgenv().SahurMesh:Destroy()
            getgenv().SahurMesh = nil
        end

        for _, oldObj in ipairs(Workspace:GetChildren()) do
            if oldObj.Name == "Adi_LocalMesh" then
                oldObj:Destroy()
            end
        end

        local function cleanup()
            if getgenv().SahurRenderConn then
                getgenv().SahurRenderConn:Disconnect()
                getgenv().SahurRenderConn = nil
            end
            if getgenv().SahurMesh then
                getgenv().SahurMesh:Destroy()
                getgenv().SahurMesh = nil
            end
        end

        local function applySkin(character)
            cleanup()

            local oldRoot = character:WaitForChild("HumanoidRootPart", 10)
            local humanoid = character:WaitForChild("Humanoid", 10)
            if not oldRoot or not humanoid then return end

            -- Удаление меша сразу при смерти
            humanoid.Died:Connect(cleanup)

            local success, result = pcall(function() return game:GetObjects(assetUrl) end)
            if success and result then
                local loadedObjects = type(result) == "table" and result or {result}
                local adiMesh = nil

                for _, obj in ipairs(loadedObjects) do
                    if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") or obj:IsA("BasePart") then
                        adiMesh = obj
                        break
                    end
                end

                if adiMesh then
                    adiMesh.Name = "Adi_LocalMesh"
                    adiMesh.CanCollide = false
                    adiMesh.Anchored = true

                    -- Скрытие оригинальных деталей персонажа
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") then
                            part.Transparency = 1
                        end
                    end

                    adiMesh.Parent = Workspace
                    getgenv().SahurMesh = adiMesh
                    Workspace.CurrentCamera.CameraSubject = adiMesh

                    getgenv().SahurRenderConn = RunService.RenderStepped:Connect(function()
                        if character and character.Parent and oldRoot and oldRoot.Parent and humanoid.Health > 0 and adiMesh and adiMesh.Parent then
                            adiMesh.CFrame = oldRoot.CFrame
                        else
                            cleanup()
                        end
                    end)
                end
            end
        end

        getgenv().SahurCharConn = LocalPlayer.CharacterAdded:Connect(applySkin)
        if LocalPlayer.Character then
            task.spawn(applySkin, LocalPlayer.Character)
        end

        WindUI:Notify({
            Title = "Tung Tung Sahur",
            Content = "Скин усешно применен!",
            Duration = 2
        })
    end
})

RageTab:Toggle({
    Title = "Anti Aim Spin",
    Desc = "Anti Aim Spin :)",
    Callback = function(state)
        local spinSpeed = 30

        if state then
            if getgenv().spinConnection then
                getgenv().spinConnection:Disconnect()
                getgenv().spinConnection = nil
            end

            local function startSpin(character)
                local root = character:WaitForChild("HumanoidRootPart", 10)
                if not root then return end

                getgenv().spinConnection = RunService.RenderStepped:Connect(function()
                    if character and root and root.Parent then
                        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                    else
                        if getgenv().spinConnection then
                            getgenv().spinConnection:Disconnect()
                            getgenv().spinConnection = nil
                        end
                    end
                end)
            end

            LocalPlayer.CharacterAdded:Connect(startSpin)
            if LocalPlayer.Character then task.spawn(startSpin, LocalPlayer.Character) end
        else
            if LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(root.CFrame.Position)
                end
            end

            if getgenv().spinConnection then
                getgenv().spinConnection:Disconnect()
                getgenv().spinConnection = nil
            end
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
