local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Crack Murder Mystery 2",
    Author = "Cracked by @AnalogyScript",        
    Theme = "Sky", 
    BackgroundImageTransparency = 0.5,
    Icon = "rbxassetid://10734950349",
    Size = UDim2.fromOffset(580, 460),
    ToggleKey = Enum.KeyCode.RightShift -- Открыть/закрыть меню на правый Shift
})

-- ==========================================
-- СОЗДАНИЕ ВКЛАДОК (TABS)
-- ==========================================

local SherifTab = Window:Tab({ Title = "Sherif", Icon = "shield" })
local MurderTab = Window:Tab({ Title = "Murder", Icon = "skull" })
local CosmeticTab = Window:Tab({ Title = "Cosmetic", Icon = "sparkles" })
local HighlightsTab = Window:Tab({ Title = "Highlights", Icon = "eye" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "scan" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "component" })
local TrollTab = Window:Tab({ Title = "Troll", Icon = "laugh" })
local ExploitsTab = Window:Tab({ Title = "Exploits", Icon = "zap" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- ==========================================
-- НАПОЛНЕНИЕ ВКЛАДОК ПЕРЕКЛЮЧАТЕЛЯМИ (TOGGLES)
-- ==========================================

-- 1. Вкладка Sherif
SherifTab:Toggle({
    Title = "Функция для Шерифа",
    Callback = function(state)
        if state then
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при включении)
        else
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при выключении)
        end
    end
})

-- 2. Вкладка Murder
MurderTab:Toggle({
    Title = "Функция для Убийцы",
    Callback = function(state)
        if state then
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при включении)
        else
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при выключении)
        end
    end
})

-- 3. Вкладка Cosmetic
CosmeticTab:Toggle({
    Title = "Angel Wing",
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
    Title = "Angel Crown",
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

-- 4. Вкладка Highlights
HighlightsTab:Toggle({
    Title = "Подсветка Объектов",
    Callback = function(state)
        if state then
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при включении)
        else
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при выключении)
        end
    end
})

-- 5. Вкладка ESP
ESPTab:Toggle({
    Title = "Включить ESP (ВХ)",
    Callback = function(state)
        if state then
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при включении)
        else
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при выключении)
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
TrollTab:Toggle({
    Title = "Троллинг Игроков",
    Callback = function(state)
        if state then
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при включении)
        else
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при выключении)
        end
    end
})

-- 8. Вкладка Exploits
ExploitsTab:Toggle({
    Title = "Основные Читы (Exploits)",
    Callback = function(state)
        if state then
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при включении)
        else
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при выключении)
        end
    end
})

-- 9. Вкладка Settings
SettingsTab:Toggle({
    Title = "Сохранение Настроек",
    Callback = function(state)
        if state then
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при включении)
        else
            -- [ВСТАВЛЯЙ СВОЙ КОД СЮДА] (сработает при выключении)
        end
    end
})

WindUI:Notify({
    Title = "Пожалуйста, не проигнорируйте это сообщение.",
    Content = "Вы юзаете кряк версию! В этой версии урезан функционал, чтобы функционало было много купите свагу хаб!",
    Time = 5
})
