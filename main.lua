local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Swaga Hub | Murder Mystery 2",
    Author = "Create by @AnalogyScript",        
    Theme = "Sky", 
    Icon = "rbxassetid://13936134740",
    Size = UDim2.fromOffset(580, 460),
    ToggleKey = Enum.KeyCode.RightShift -- Открыть/закрыть меню на правый Shift
})

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
-- НАПОЛНЕНИЕ ВКЛАДОК ПЕРЕКЛЮЧАТЕЛЯМИ (TOGGLES)
-- ==========================================

-- 1. Вкладка Sherif
SherifTab:Toggle({
    Title = "Slient Aim (Button)",
    Callback = function(state)
        if state then
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при включении)
        else
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при выключении)
        end
    end
})

-- WindUI Button
MurderTab:Button({
    Title = "Kill All",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        
        -- Ищем нож в руках или в рюкзаке
        local knife = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))

        if not knife then
            WindUI:Notify({
                Title = "Error",
                Content = "There is no knife",
                Duration = 3
            })
            return
        end

        -- Если нож в рюкзаке, автоматически берем его в руки
        if knife.Parent == backpack and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):EquipTool(knife)
            task.wait(0.05) -- Даем долю секунды на экипировку ножа
        end

        local events = knife:FindFirstChild("Events")
        local stabRemote = events and events:FindFirstChild("KnifeStabbed")
        local throwRemote = events and events:FindFirstChild("KnifeThrown")
        local touchRemote = events and events:FindFirstChild("HandleTouched")

        -- Один быстрый круг по всем игрокам (без бесконечного цикла while)
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

CosmeticTab:Toggle({
    Title = "Shaders (Black Sky)",
    Value = false,

    Callback = function(state)
        if state then
            graphicsEnabled = true

            if connection then
                connection:Disconnect()
                connection = nil
            end

            for _, v in ipairs(Lighting:GetChildren()) do
                if v.Name == "SwagaSky"
                    or v.Name == "SwagaAtmosphere"
                    or v.Name == "SwagaColor"
                    or v.Name == "SwagaBloom"
                    or v.Name == "SwagaSunRays"
                    or v.Name == "SwagaDOF"
                    or v.Name == "SwagaBlur" then
                    v:Destroy()
                end
            end

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

            Lighting.Technology = Enum.Technology.Future
            Lighting.Brightness = 3.8
            Lighting.ExposureCompensation = 0.2
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 0.22
            Lighting.EnvironmentSpecularScale = 1
            Lighting.Ambient = Color3.fromRGB(95, 98, 110)
            Lighting.OutdoorAmbient = Color3.fromRGB(145, 150, 165)
            Lighting.ClockTime = 15.4
            Lighting.GeographicLatitude = 35

            local atmosphere = Instance.new("Atmosphere")
            atmosphere.Name = "SwagaAtmosphere"
            atmosphere.Density = 0.055
            atmosphere.Offset = 0
            atmosphere.Color = Color3.fromRGB(210, 220, 240)
            atmosphere.Decay = Color3.fromRGB(65, 70, 90)
            atmosphere.Glare = 0.12
            atmosphere.Haze = 0.22
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

            local dof = Instance.new("DepthOfFieldEffect")
            dof.Name = "SwagaDOF"
            dof.FocusDistance = 80
            dof.InFocusRadius = 45
            dof.NearIntensity = 0.015
            dof.FarIntensity = 0.12
            dof.Parent = Lighting

            local blur = Instance.new("BlurEffect")
            blur.Name = "SwagaBlur"
            blur.Size = 2
            blur.Parent = Lighting

            local function enhanceEffects(object)
                if not graphicsEnabled then
                    return
                end

                if not (
                    object:IsA("ParticleEmitter")
                    or object:IsA("Trail")
                    or object:IsA("Beam")
                    or object:IsA("Sparkles")
                ) then
                    return
                end

                if not originalProperties[object] then
                    if object:IsA("Sparkles") then
                        originalProperties[object] = {
                            SparkleColor = object.SparkleColor
                        }
                    else
                        originalProperties[object] = {
                            LightEmission = object.LightEmission,
                            LightInfluence = object.LightInfluence,
                            Brightness = object.Brightness,
                            ZOffset = object:IsA("ParticleEmitter")
                                and object.ZOffset
                                or nil
                        }
                    end
                end

                if object:IsA("ParticleEmitter") then
                    object.LightEmission = 1
                    object.LightInfluence = 0
                    object.Brightness = math.max(object.Brightness, 4)
                    object.ZOffset = math.clamp(
                        object.ZOffset + 0.8,
                        -1,
                        1
                    )

                elseif object:IsA("Trail") then
                    object.LightEmission = 1
                    object.LightInfluence = 0
                    object.Brightness = math.max(object.Brightness, 4)

                elseif object:IsA("Beam") then
                    object.LightEmission = 1
                    object.LightInfluence = 0
                    object.Brightness = math.max(object.Brightness, 4)

                elseif object:IsA("Sparkles") then
                    object.SparkleColor = object.SparkleColor:Lerp(
                        Color3.new(1, 1, 1),
                        0.6
                    )
                end
            end

            for _, object in ipairs(Workspace:GetDescendants()) do
                enhanceEffects(object)
            end

            connection = Workspace.DescendantAdded:Connect(function(object)
                task.defer(function()
                    enhanceEffects(object)
                end)
            end)

        else
            graphicsEnabled = false

            if connection then
                connection:Disconnect()
                connection = nil
            end

            for _, v in ipairs(Lighting:GetChildren()) do
                if v.Name == "SwagaSky"
                    or v.Name == "SwagaAtmosphere"
                    or v.Name == "SwagaColor"
                    or v.Name == "SwagaBloom"
                    or v.Name == "SwagaSunRays"
                    or v.Name == "SwagaDOF"
                    or v.Name == "SwagaBlur" then
                    v:Destroy()
                end
            end

            for object, props in pairs(originalProperties) do
                if object and object.Parent then
                    for propName, value in pairs(props) do
                        if value ~= nil then
                            pcall(function()
                                object[propName] = value
                            end)
                        end
                    end
                end
            end

            table.clear(originalProperties)
        end
    end
})

-- 3. Вкладка Cosmetic
CosmeticTab:Toggle({
    Title = "Angel Wing (bad)",
    Callback = function(state)
        if state then
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local function setupBlackSky()
    pcall(function()
        for _, object in ipairs(Lighting:GetChildren()) do
            if object:IsA("Sky") then
                object:Destroy()
            end
        end

        local sky = Instance.new("Sky")
        sky.Name = "PureBlackSky"

        local id = "rbxassetid://0"

        sky.SkyboxBk = id
        sky.SkyboxDn = id
        sky.SkyboxFt = id
        sky.SkyboxLf = id
        sky.SkyboxRt = id
        sky.SkyboxUp = id
        sky.StarCount = 0

        sky.Parent = Lighting
    end)
end

local function createNeonWings(character)
    if not character then
        return
    end

    local torso = character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")

    if not torso then
        return
    end

    local old = character:FindFirstChild("NeonWings")

    if old then
        old:Destroy()
    end

    local folder = Instance.new("Folder")
    folder.Name = "NeonWings"
    folder.Parent = character

    local feathers = {}

    local function createFeather(side, index)
        local progress = (index - 1) / 6

        local feather = Instance.new("Part")
        feather.Name = "WingFeather"
        feather.Size = Vector3.new(
            0.16,
            0.3,
            1.5 + progress * 2.3
        )
        feather.Material = Enum.Material.Neon
        feather.Color = Color3.fromRGB(255, 255, 255)
        feather.CanCollide = false
        feather.CanTouch = false
        feather.CanQuery = false
        feather.Massless = true
        feather.Parent = folder

        local weld = Instance.new("Weld")
        weld.Part0 = torso
        weld.Part1 = feather

        local x = side * (0.45 + progress * 1.8)
        local y = 0.45 - progress * 0.65
        local z = 0.75

        weld.C0 =
            CFrame.new(x, y, z)
            * CFrame.Angles(
                math.rad(-15 + progress * 28),
                math.rad(side * (15 + progress * 35)),
                math.rad(side * (8 + progress * 12))
            )

        weld.Parent = feather

        local glow = Instance.new("PointLight")
        glow.Color = Color3.fromRGB(255, 255, 255)
        glow.Brightness = 0.4
        glow.Range = 3
        glow.Parent = feather

        table.insert(feathers, {
            weld = weld,
            base = weld.C0,
            index = index + (side == 1 and 0 or 10)
        })
    end

    for side = -1, 1, 2 do
        for i = 1, 7 do
            createFeather(side, i)
        end
    end

    local core = Instance.new("Part")
    core.Name = "WingCore"
    core.Size = Vector3.new(1.2, 1.8, 0.18)
    core.Material = Enum.Material.Neon
    core.Color = Color3.fromRGB(255, 255, 255)
    core.Transparency = 0.15
    core.CanCollide = false
    core.CanTouch = false
    core.CanQuery = false
    core.Massless = true
    core.Parent = folder

    local coreWeld = Instance.new("Weld")
    coreWeld.Part0 = torso
    coreWeld.Part1 = core
    coreWeld.C0 = CFrame.new(0, 0.1, 0.78)
    coreWeld.Parent = core

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 255, 255)
    light.Brightness = 1.5
    light.Range = 8
    light.Parent = core

    local connection

    connection = RunService.RenderStepped:Connect(function()
        if not character.Parent or not folder.Parent then
            connection:Disconnect()
            return
        end

        local time = os.clock()

        for _, data in ipairs(feathers) do
            local movement =
                math.sin(time * 2.5 + data.index * 0.35) * 0.025

            data.weld.C0 =
                data.base * CFrame.Angles(0, movement, 0)
        end
    end)
end

local function createWhiteAura(character)
    if not character then
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return
    end

    local old = hrp:FindFirstChild("WhiteAura")

    if old then
        old:Destroy()
    end

    local oldLight = hrp:FindFirstChild("AuraLight")

    if oldLight then
        oldLight:Destroy()
    end

    local attachment = Instance.new("Attachment")
    attachment.Name = "WhiteAura"
    attachment.Parent = hrp

    local particles = Instance.new("ParticleEmitter")
    particles.Name = "AngelParticles"
    particles.LightEmission = 1
    particles.LightInfluence = 0
    particles.Rate = 40
    particles.Lifetime = NumberRange.new(0.7, 1.5)
    particles.Speed = NumberRange.new(0.5, 2.5)
    particles.SpreadAngle = Vector2.new(360, 360)
    particles.Rotation = NumberRange.new(0, 360)
    particles.RotSpeed = NumberRange.new(-100, 100)
    particles.Color = ColorSequence.new(
        Color3.fromRGB(255, 255, 255)
    )

    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.08),
        NumberSequenceKeypoint.new(0.45, 0.3),
        NumberSequenceKeypoint.new(1, 0)
    })

    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(0.75, 0.35),
        NumberSequenceKeypoint.new(1, 1)
    })

    particles.Parent = attachment

    local light = Instance.new("PointLight")
    light.Name = "AuraLight"
    light.Color = Color3.fromRGB(255, 255, 255)
    light.Brightness = 1
    light.Range = 7
    light.Parent = hrp
end

local function applyAll(character)
    task.wait(0.5)

    setupBlackSky()
    createNeonWings(character)
    createWhiteAura(character)
end

setupBlackSky()

if LocalPlayer.Character then
    task.spawn(function()
        applyAll(LocalPlayer.Character)
    end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    applyAll(character)
end)
        else
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character

if character then
    local wings = character:FindFirstChild("NeonWings")

    if wings then
        wings:Destroy()
    end
end
        end
    end
})

CosmeticTab:Toggle({
    Title = "Angel Crown (Not Work)",
    Callback = function(state)
        if state then
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character

if character then
    local wings = character:FindFirstChild("NeonWings")
    if wings then
        wings:Destroy()
    end

    local crown = character:FindFirstChild("NeonCrown")
    if crown then
        crown:Destroy()
    end
end
        else
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character

if character then
    local crown = character:FindFirstChild("NeonCrown")

    if crown then
        crown:Destroy()
    end
end
        end
    end
})
HighlightsTab:Toggle({
    Title = "Highlights Coins",
    Callback = function(state)
        getgenv().AdvancedCoinESP = state

        if state then
            local Workspace = game:GetService("Workspace")
            
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
                local old = obj:FindFirstChild("CoinHighlight")
                if old then return end

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

                local connection = container.DescendantAdded:Connect(function(obj)
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

                table.insert(getgenv().CoinConnections, connection)
            end

            scanContainer(Workspace)

            local workspaceChildConn = Workspace.ChildAdded:Connect(function(child)
                if not getgenv().AdvancedCoinESP then return end
                checkObject(child)
                task.defer(function()
                    if child and child.Parent then
                        scanContainer(child)
                    end
                end)
            end)
            table.insert(getgenv().CoinConnections, workspaceChildConn)

            local workspaceRemovingConn = Workspace.DescendantRemoving:Connect(function(obj)
                if getgenv().CoinHighlighted then
                    getgenv().CoinHighlighted[obj] = nil
                end
            end)
            table.insert(getgenv().CoinConnections, workspaceRemovingConn)
        else
            local Workspace = game:GetService("Workspace")
            
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

-- 4. Вкладка Highlights
HighlightsTab:Toggle({
    Title = "Highlights Gun Dropped",
    Callback = function(state)
        if state then
local Workspace = game:GetService("Workspace")
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
    for _, desc in ipairs(map:GetDescendants()) do
        scanObject(desc)
    end
    map.DescendantAdded:Connect(scanObject)
end

for _, name in ipairs(mapNames) do
    local map = Workspace:FindFirstChild(name)
    if map then
        hookMap(map)
    end
end

for _, desc in ipairs(Workspace:GetDescendants()) do
    scanObject(desc)
end
Workspace.DescendantAdded:Connect(scanObject)

Workspace.ChildAdded:Connect(function(child)
    if table.find(mapNames, child.Name) or child.Name == "Normal" or child.Name == "Map" then
        hookMap(child)
    else
        scanObject(child)
    end
end)
        else
local Workspace = game:GetService("Workspace")
for _, desc in ipairs(Workspace:GetDescendants()) do
    if desc.Name == "GunDropHighlight" then
        desc:Destroy()
                end
            end
        end
    end
})

-- 5. Вкладка ESP
HighlightsTab:Toggle({
    Title = "Highlights Roles",
    Callback = function(state)
        if state then
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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
            if not char or not char:IsDescendantOf(workspace) or not hrp or not head then
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

    if player.Character then
        task.spawn(apply)
    end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        apply()
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    createESP(p)
end

Players.PlayerAdded:Connect(createESP)
        else
local Players = game:GetService("Players")

getgenv().RoleESPEnabled = false

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        local char = player.Character
        local esp = char:FindFirstChild("RoleESP")
        local hl = char:FindFirstChild("RoleHighlight")
        if esp then esp:Destroy() end
        if hl then hl:Destroy() end
    end
end
        end
    end
})

-- 6. Вкладка Misc
MiscTab:Toggle({
    Title = "Разные Функции (Misc)",
    Callback = function(state)
        if state then
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при включении)
        else
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при выключении)
        end
    end
})

-- 7. Вкладка Troll
TrollTab:Button({
    Title = "Tung Tung Sahur Character",
    Desc = "Click and you'll turn into Tung Tung Tung Sahur.",
    Callback = function()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local ASSET_ID = 138151705692565
local assetUrl = "rbxassetid://" .. ASSET_ID

local SCALE_MULTIPLIER = 1
local ROTATE_X = 0
local ROTATE_Y = 0
local ROTATE_Z = 0
local HEIGHT_OFFSET = 0

local renderConnection = nil

local function applySkin(character)
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end

	local oldRoot = character:WaitForChild("HumanoidRootPart", 10)
	if not oldRoot then return end

	local success, result = pcall(function()
		return game:GetObjects(assetUrl)
	end)

	if success and result then
		local loadedObjects = type(result) == "table" and result or {result}
		local adiMesh = nil

		for _, obj in ipairs(loadedObjects) do
			if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") or obj:IsA("BasePart") then
				adiMesh = obj
				break
			end
		end

		if not adiMesh then
			for _, obj in ipairs(loadedObjects) do
				adiMesh = obj:FindFirstChildWhichIsA("MeshPart") or obj:FindFirstChildWhichIsA("BasePart")
				if adiMesh then break end
			end
		end

		if adiMesh then
			adiMesh.Name = "Adi_LocalMesh"
			adiMesh.CanCollide = false
			adiMesh.Anchored = true

			if adiMesh:IsA("MeshPart") then
				adiMesh.Size = adiMesh.Size * SCALE_MULTIPLIER
			end

			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				elseif part:IsA("Decal") then
					part.Transparency = 1
				end
			end

			adiMesh.Parent = Workspace
			Workspace.CurrentCamera.CameraSubject = adiMesh

			renderConnection = RunService.RenderStepped:Connect(function()
				if character and oldRoot and adiMesh and adiMesh.Parent then
					local targetCFrame = oldRoot.CFrame 
						* CFrame.new(0, HEIGHT_OFFSET, 0) 
						* CFrame.Angles(math.rad(ROTATE_X), math.rad(ROTATE_Y), math.rad(ROTATE_Z))
					adiMesh.CFrame = targetCFrame
				else
					if adiMesh then adiMesh:Destroy() end
					if renderConnection then
						renderConnection:Disconnect()
						renderConnection = nil
					end
				end
			end)
		end
	end
end

player.CharacterAdded:Connect(applySkin)

if player.Character then
	task.spawn(applySkin, player.Character)
        end
	  end
})

-- 8. Вкладка Exploits
RageTab:Toggle({
    Title = "Anti Aim Spin",
    Desc = "Anti Aim Spin :)",
    Callback = function(state)
        if state then
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local spinSpeed = 30
local spinConnection = nil

local function startSpin(character)
	if spinConnection then
		spinConnection:Disconnect()
		spinConnection = nil
	end

	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root then return end

	spinConnection = RunService.RenderStepped:Connect(function()
		if character and root and root.Parent then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
		else
			if spinConnection then
				spinConnection:Disconnect()
				spinConnection = nil
			end
		end
	end)
end

player.CharacterAdded:Connect(startSpin)

if player.Character then
	task.spawn(startSpin, player.Character)
end
        else
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer

            if player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(root.CFrame.Position)
                end
            end

            if spinConnection then
                spinConnection:Disconnect()
                spinConnection = nil
            end
        end
    end
})

-- 9. Вкладка Settings
SettingsTab:Dropdown({
    Title = "Выбрать theme interface",
    Values = {
        "Dark", "Light", "Sky", "Rose", "Plant", "Red", "Indigo", 
        "Violet", "Amber", "Emerald", "Midnight", "Crimson", 
        "MonokaiPro", "CottonCandy", "Mellowsi", "Rainbow"
    },
    Value = "Sky", -- Тема по умолчанию при запуске
    Callback = function(selectedTheme)
        -- Меняем тему всего GUI на выбранную из списка
        WindUI:SetTheme(selectedTheme)
        
        -- Выводим красивое уведомление о смене стиля
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
