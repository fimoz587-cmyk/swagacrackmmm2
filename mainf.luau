--// SWAGA.CC WATERMARK

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// ICONS
local FPS_ICON = "rbxassetid://11395830213"
local PING_ICON = "rbxassetid://105127187178989"
local TIME_ICON = "rbxassetid://75946779176337"
local USER_ICON = "rbxassetid://128851059336118"
local PRODUCT_ICON = "rbxassetid://111429937040741"

--// COLORS
local DARK_BLUE = Color3.fromRGB(35, 90, 155)
local TEXT_COLOR = Color3.fromRGB(210, 225, 245)
local TITLE_COLOR = Color3.fromRGB(70, 135, 210)

--// GUI
local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "SwagaWatermark"
WatermarkGui.ResetOnSpawn = false
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
WatermarkGui.Parent = game:GetService("CoreGui")

--// MAIN
local Main = Instance.new("Frame")
Main.Name = "Main"

--// Compact size
Main.Size = UDim2.new(0, 350, 0, 32)
Main.Position = UDim2.new(0, 15, 0, 15)

Main.BackgroundColor3 = Color3.fromRGB(5, 13, 28)
Main.BackgroundTransparency = 0.5
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = WatermarkGui

--// CORNER
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Main

--// OUTLINE
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(25, 70, 135)
Stroke.Transparency = 0.4
Stroke.Thickness = 1
Stroke.Parent = Main

--// SWAGA.CC
local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 8, 0, 0)
Title.Size = UDim2.new(0, 62, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "swaga.cc"
Title.TextColor3 = TITLE_COLOR
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--// INFO CREATOR
local function createInfo(iconId, text, x, width)

    local Icon = Instance.new("ImageLabel")
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, x, 0.5, -6)
    Icon.Size = UDim2.new(0, 12, 0, 12)

    --// Dark blue icon
    Icon.Image = iconId
    Icon.ImageColor3 = DARK_BLUE
    Icon.ImageTransparency = 0

    Icon.Parent = Main

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, x + 15, 0, 0)
    Label.Size = UDim2.new(0, width, 1, 0)

    Label.Font = Enum.Font.GothamMedium
    Label.Text = text
    Label.TextColor3 = TEXT_COLOR
    Label.TextSize = 9
    Label.TextXAlignment = Enum.TextXAlignment.Left

    Label.Parent = Main

    return Label
end

--// FPS
--// Speedometer + FPS number
local FPSLabel = createInfo(
    FPS_ICON,
    "0 FPS",
    70,
    48
)

--// PING
local PingLabel = createInfo(
    PING_ICON,
    "0ms",
    121,
    42
)

--// TIME
local TimeLabel = createInfo(
    TIME_ICON,
    "00:00",
    166,
    42
)

--// USER ICON
local UserIcon = Instance.new("ImageLabel")
UserIcon.BackgroundTransparency = 1

UserIcon.Position = UDim2.new(
    0,
    211,
    0.5,
    -6
)

UserIcon.Size = UDim2.new(0, 12, 0, 12)

UserIcon.Image = USER_ICON

--// Dark blue
UserIcon.ImageColor3 = DARK_BLUE
UserIcon.ImageTransparency = 0

UserIcon.Parent = Main

--// USERNAME
local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.BackgroundTransparency = 1

UsernameLabel.Position = UDim2.new(
    0,
    227,
    0,
    0
)

UsernameLabel.Size = UDim2.new(
    0,
    58,
    1,
    0
)

UsernameLabel.Font = Enum.Font.GothamMedium
UsernameLabel.Text = LocalPlayer.Name
UsernameLabel.TextColor3 = TEXT_COLOR
UsernameLabel.TextSize = 9
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd

UsernameLabel.Parent = Main

--// PRODUCT ICON
local ProductIcon = Instance.new("ImageLabel")
ProductIcon.BackgroundTransparency = 1

--// Moved closer to username
ProductIcon.Position = UDim2.new(
    0,
    285,
    0.5,
    -6
)

ProductIcon.Size = UDim2.new(
    0,
    12,
    0,
    12
)

ProductIcon.Image = PRODUCT_ICON

--// Dark blue
ProductIcon.ImageColor3 = DARK_BLUE
ProductIcon.ImageTransparency = 0

ProductIcon.Parent = Main

--// PRODUCT
local ProductLabel = Instance.new("TextLabel")
ProductLabel.BackgroundTransparency = 1

--// Moved closer to username
ProductLabel.Position = UDim2.new(
    0,
    301,
    0,
    0
)

ProductLabel.Size = UDim2.new(
    0,
    42,
    1,
    0
)

ProductLabel.Font = Enum.Font.GothamMedium
ProductLabel.Text = "Free"
ProductLabel.TextColor3 = TEXT_COLOR
ProductLabel.TextSize = 9
ProductLabel.TextXAlignment = Enum.TextXAlignment.Left

ProductLabel.Parent = Main

--// FPS CALCULATION
local frames = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()

    frames += 1

    if tick() - lastTime >= 1 then

        FPSLabel.Text = tostring(frames) .. " FPS"

        frames = 0
        lastTime = tick()

    end

end)

--// PING
task.spawn(function()

    while task.wait(1) do

        local ping = math.floor(
            LocalPlayer:GetNetworkPing() * 1000
        )

        PingLabel.Text = tostring(ping) .. "ms"

    end

end)

--// TIME
task.spawn(function()

    while task.wait(1) do

        TimeLabel.Text = os.date("%H:%M")

    end

end)

--// DRAG SYSTEM
local dragging = false
local dragStart
local startPos

local function updateDrag(input)

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(

        startPos.X.Scale,
        startPos.X.Offset + delta.X,

        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y

    )

end

--// Mouse / Touch start
Main.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)

    end

end)

--// Mouse / Touch movement
UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        updateDrag(input)

    end

end)
-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Динамическое получение всех доступных тем библиотеки
local AvailableThemes = {}
for ThemeName, _ in pairs(WindUI:GetThemes()) do
    table.insert(AvailableThemes, ThemeName)
end
table.sort(AvailableThemes) -- Сортировка по алфавиту для удобства

-- Создание главного окна
local Window = WindUI:CreateWindow({
    Title = "Swaga Hub | updated to 1.1.1 (Murder Mystery 2)",
    Icon = "shield",
    Size = UDim2.new(0, 550, 0, 400),
    Transparent = true,
    Glass = true,
    Resizable = true
})

-- ========================================================
-- ВКЛАДКА: SHERIFF
-- ========================================================
local SheriffTab = Window:Tab({ Title = "Sheriff", Icon = "user-check" })

SheriffTab:Toggle({
    Title = "Silent Aim",
    Value = false,
    Callback = function(Value)
        if Value then
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer

local genv = (getgenv and getgenv()) or _G
if genv.NyxSA then pcall(genv.NyxSA) end

local CFG = {
    silent = true,
    lead = 0.05,
    pingLead = true,
}

local ST = genv.NyxSAST or {}
genv.NyxSAST = ST
ST.on, ST.aimPos = CFG.silent, nil

if not genv.NyxSAHook and hookmetamethod and getnamecallmethod then
    genv.NyxSAHook = true
    local wrap = newcclosure or function(f) return f end
    local old
    old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
        local m = getnamecallmethod()
        if ST.on and ST.aimPos and m == "FireServer" and not checkcaller()
           and typeof(self) == "Instance" and self.Name == "Shoot" then
            local par = self.Parent
            if par and par.Name == "Gun" then
                local args = table.pack(...)
                local n = 0
                for i = 1, args.n do
                    if typeof(args[i]) == "CFrame" then
                        n += 1
                        if n == 2 then
                            args[i] = CFrame.new(ST.aimPos)
                            break
                        end
                    end
                end
                if setnamecallmethod then setnamecallmethod(m) end
                return old(self, table.unpack(args, 1, args.n))
            end
        end
        return old(self, ...)
    end))
end

local roles = {}
local conns = {}
local running = true

local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

local function readData(tbl)
    if typeof(tbl) ~= "table" then return end
    for k, d in pairs(tbl) do
        local p = typeof(k) == "Instance" and k or Players:FindFirstChild(tostring(k))
        local role = typeof(d) == "table" and (d.Role or d.role)
        if p and role then roles[p] = role end
    end
end

for _, r in ipairs(RS:GetDescendants()) do
    pcall(function()
        if r:IsA("RemoteEvent") and r.Name == "PlayerDataChanged" then
            connect(r.OnClientEvent, function(...) readData((...)) end)
        elseif r:IsA("RemoteEvent") and r.Name == "LoadingMap" then
            connect(r.OnClientEvent, function() table.clear(roles) end)
        elseif r:IsA("RemoteFunction") and r.Name == "GetPlayerData" then
            task.spawn(function()
                local ok, res = pcall(function() return r:InvokeServer() end)
                if ok then readData(res) end
            end)
        end
    end)
end

task.spawn(function()
    while running do
        pcall(function()
            ST.ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        end)
        task.wait(0.5)
    end
end)

local function findMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local c = p.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp
               and (roles[p] == "Murderer" or c:FindFirstChild("Knife")) then
                return hrp, c
            end
        end
    end
end

connect(RunService.Heartbeat, function()
    ST.on = CFG.silent
    local hrp = findMurderer()
    if not hrp then
        ST.aimPos = nil
        return
    end
    local v = hrp.AssemblyLinearVelocity
    local t = (CFG.pingLead and (ST.ping or 0.08) or 0) + CFG.lead
    local pos = hrp.Position
    ST.aimPos = pos + Vector3.new(v.X, 0, v.Z) * t
end)                
        else
CFG.silent = false
ST.on = false
ST.aimPos = nil
running = false

for _, c in ipairs(conns) do
    pcall(function()
        c:Disconnect()
    end)
end

table.clear(conns)            
        end
    end
})

SheriffTab:Toggle({
    Title = "Auto Pick Dropped Gun",
    Value = false,
    Callback = function(Value)
        if Value then
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local CFG = {
    autoGun = true, -- Сразу включено
    gunSpeed = 32,
    pickDist = 90,
}

local conns, running = {}, true
local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

local myRole
local drop
local busy, moving = false, false

local function myHrp()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function touch(a, b)
    if firetouchinterest then
        firetouchinterest(a, b, 0)
        firetouchinterest(a, b, 1)
    end
end

local function hasKnife()
    local c = lp.Character
    return (c and c:FindFirstChild("Knife")) or (lp.Backpack and lp.Backpack:FindFirstChild("Knife"))
end

local function readData(tbl)
    if typeof(tbl) ~= "table" then return end
    for k, d in pairs(tbl) do
        local p = typeof(k) == "Instance" and k or Players:FindFirstChild(tostring(k))
        local role = typeof(d) == "table" and (d.Role or d.role)
        if p == lp and role then myRole = role end
    end
end

for _, r in ipairs(RS:GetDescendants()) do
    pcall(function()
        if r:IsA("RemoteEvent") and r.Name == "PlayerDataChanged" then
            connect(r.OnClientEvent, function(...) readData((...)) end)
        elseif r:IsA("RemoteEvent") and r.Name == "LoadingMap" then
            connect(r.OnClientEvent, function() myRole = nil end)
        elseif r:IsA("RemoteFunction") and r.Name == "GetPlayerData" then
            task.spawn(function()
                local ok, res = pcall(function() return r:InvokeServer() end)
                if ok then readData(res) end
            end)
        end
    end)
end

local function posOf(i)
    if i:IsA("BasePart") then return i end
    return i:FindFirstChildWhichIsA("BasePart", true)
end

local function trackDrop(i)
    if i.Name ~= "GunDrop" or drop == i then return end
    drop = i
    connect(i.AncestryChanged, function(_, parent)
        if not parent and drop == i then drop = nil end
    end)
end

connect(workspace.DescendantAdded, trackDrop)
for _, d in ipairs(workspace:GetDescendants()) do trackDrop(d) end

connect(RunService.Stepped, function()
    if not moving then return end
    local c = lp.Character
    if not c then return end
    for _, p in ipairs(c:GetChildren()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

local function goTo(cf, speed, keep)
    local hrp, hum = myHrp()
    if not hrp or not hum or hum.Health <= 0 then return false end
    local t = math.max((hrp.Position - cf.Position).Magnitude / speed, 0.05)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    local done = false
    local cc = tw.Completed:Connect(function() done = true end)
    moving = true
    tw:Play()
    local s = tick()
    while not done and tick() - s < t + 1 and running do
        if hum.Health <= 0 or (keep and not keep()) then break end
        task.wait()
    end
    tw:Cancel()
    cc:Disconnect()
    moving = false
    if hrp.Parent then hrp.AssemblyLinearVelocity = Vector3.zero end
    return done
end

local lastPick = 0
local function pickGun()
    local hrp, hum = myHrp()
    if busy or not hrp or not hum or hum.Health <= 0 then return end
    if not (lp.Character and lp.Character.Parent == workspace) then return end
    if not (drop and drop.Parent) then return end
    if myRole == nil or myRole == "Murderer" or hasKnife() then return end
    if tick() - lastPick < 3 then return end
    local part = posOf(drop)
    if not part or (part.Position - hrp.Position).Magnitude > CFG.pickDist then return end
    busy = true
    lastPick = tick()
    local back = hrp.CFrame
    local ok = goTo(CFrame.new(part.Position + Vector3.new(0, 1.5, 0)), CFG.gunSpeed, function() return CFG.autoGun end)
    if ok then
        touch(hrp, part)
        task.wait(0.25)
    end
    if hum.Health > 0 and hrp.Parent then
        goTo(back, CFG.gunSpeed, function() return true end)
    end
    busy = false
end

task.spawn(function()
    while running do
        if CFG.autoGun and drop then pcall(pickGun) end
        task.wait(0.15)
    end
end)               
        else
CFG.autoGun = false
running = false

for _, c in ipairs(conns) do
    pcall(function()
        c:Disconnect()
    end)
end

table.clear(conns)

moving = false
busy = false
        end
    end
})

SheriffTab:Toggle({
    Title = "WallBang",
    Value = false,
    Callback = function(Value)
        if Value then
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local CFG = {
    wallbang = true -- Сразу включено
}

local conns = {}
local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

local isWallBangActive = false
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude

-- Поиск Убийцы (Murderer) на карте
local function findMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local c = p.Character
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp and (c:FindFirstChild("Knife")) then
                return hrp, c
            end
        end
    end
end

-- Проверка преграды (стены) между вами и целью
connect(RunService.Heartbeat, function()
    local hrp, char = findMurderer()
    if not hrp or not CFG.wallbang then
        isWallBangActive = false
        return
    end

    local mine = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if mine then
        rp.FilterDescendantsInstances = {lp.Character, char}
        -- Если луч сталкивается со стеной, значит цель за стеной (WallBang активен)
        local blocked = workspace:Raycast(mine.Position, hrp.Position - mine.Position, rp) ~= nil
        isWallBangActive = blocked
    else
        isWallBangActive = false
    end
end)                
        else
CFG.wallbang = false
isWallBangActive = false

for _, c in ipairs(conns) do
    pcall(function()
        c:Disconnect()
    end)
end

table.clear(conns)
        end
    end
})

-- ========================================================
-- ВКЛАДКА: MURDER
-- ========================================================
local MurderTab = Window:Tab({ Title = "Murder", Icon = "skull" })

MurderTab:Button({
    Title = "Kill All",
    Value = false,
    Callback = function(Value)
        if Value then
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
        end
    end
})

-- ========================================================
-- ВКЛАДКА: COSMETIC
-- ========================================================
local CosmeticTab = Window:Tab({ Title = "Cosmetic", Icon = "sparkles" })

CosmeticTab:Toggle({
    Title = "Shaders (Black Sky)",
    Value = false,
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        local names = {
            "SwagaBloom",
            "SwagaColorCorrection",
            "SwagaSunRays",
            "SwagaDepthOfField",
            "SwagaAtmosphere",
            "SwagaSky"
        }

        local function removeShaders()
            for _, name in ipairs(names) do
                local obj = Lighting:FindFirstChild(name)
                if obj then obj:Destroy() end
            end
        end

        if Value then
            _G.NyxShadersEnabled = true
            removeShaders()

            local FOG_END, DENSITY = 500, 0.65
            local BLOOM, CONTRAST, SAT, DOF, BRIGHT = 2.8, 0.45, 0.4, 0.22, 2.10
            local TINT = Color3.fromRGB(190, 215, 255)
            local AMB = Color3.fromRGB(40, 80, 170)
            local FOG = Color3.fromRGB(25, 70, 200)

            local bloom = Instance.new("BloomEffect")
            bloom.Name = "SwagaBloom"
            bloom.Parent = Lighting

            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "SwagaColorCorrection"
            cc.Parent = Lighting

            local rays = Instance.new("SunRaysEffect")
            rays.Name = "SwagaSunRays"
            rays.Parent = Lighting

            local dof = Instance.new("DepthOfFieldEffect")
            dof.Name = "SwagaDepthOfField"
            dof.Parent = Lighting

            local atm = Instance.new("Atmosphere")
            atm.Name = "SwagaAtmosphere"
            atm.Parent = Lighting

            local sky = Instance.new("Sky")
            sky.Name = "SwagaSky"
            sky.StarCount = 0
            sky.CelestialBodiesShown = false
            sky.Parent = Lighting

            bloom.Intensity, bloom.Size, bloom.Threshold = BLOOM, 45, 0.75
            cc.Contrast, cc.Saturation, cc.TintColor = CONTRAST, SAT, TINT
            rays.Intensity, rays.Spread = 0.15, 0.8
            dof.FarIntensity, dof.NearIntensity = DOF, 0
            dof.FocusDistance, dof.InFocusRadius = 60, 80
            atm.Density, atm.Haze, atm.Offset = DENSITY, 2, 0.2
            atm.Color, atm.Decay = FOG, FOG
            Lighting.Ambient, Lighting.OutdoorAmbient = AMB, AMB
            Lighting.Brightness = BRIGHT
            Lighting.ExposureCompensation = 0.3
            Lighting.FogColor, Lighting.FogStart, Lighting.FogEnd = FOG, 0, FOG_END
            Lighting.ClockTime = 0
        else
            _G.NyxShadersEnabled = false
            removeShaders()
        end
    end
})

-- Создание вкладки: AUTO FARM
local AutoFarmTab = Window:Tab({ Title = "Auto Farm", Icon = "coins" })

-- Тоггл внутри вкладки
AutoFarmTab:Toggle({
    Title = "Auto Farm Coins",
    Value = false,
    Callback = function(Value)
        CFG.farm = Value -- Меняет значение в настройках для цикла
        
        if Value then
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local CFG = {
    farm = true, -- Сразу включено
    farmSpeed = 24,
    maxCoins = 40,
    coinRange = 1500,
}

local conns, running = {}, true
local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

local coins, visited = {}, {}
local got = 0
local busy, moving = false, false

local function myHrp()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function touch(a, b)
    if firetouchinterest then
        firetouchinterest(a, b, 0)
        firetouchinterest(a, b, 1)
    end
end

local function bindLoadingMap(r)
    if r:IsA("RemoteEvent") and r.Name == "LoadingMap" then
        connect(r.OnClientEvent, function()
            got = 0
            table.clear(visited)
        end)
    end
end

for _, r in ipairs(RS:GetDescendants()) do
    bindLoadingMap(r)
end

connect(RS.DescendantAdded, function(r)
    bindLoadingMap(r)
end)

local function isCoin(i)
    return i:IsA("BasePart") and (i.Name == "Coin_Server" or (i.Parent and i.Parent.Name == "CoinContainer"))
end

local function addCoin(i)
    if coins[i] or not isCoin(i) then return end
    coins[i] = true
end

connect(workspace.DescendantAdded, addCoin)
connect(workspace.DescendantRemoving, function(i)
    if not coins[i] then return end
    coins[i], visited[i] = nil, nil
end)

for _, d in ipairs(workspace:GetDescendants()) do addCoin(d) end

connect(RunService.Stepped, function()
    if not moving then return end
    local c = lp.Character
    if not c then return end
    for _, p in ipairs(c:GetChildren()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

local function goTo(cf, speed)
    local hrp, hum = myHrp()
    if not hrp or not hum or hum.Health <= 0 then return false end
    local t = math.max((hrp.Position - cf.Position).Magnitude / speed, 0.05)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    local done = false
    local cc = tw.Completed:Connect(function() done = true end)
    moving = true
    tw:Play()
    local s = tick()
    while not done and tick() - s < t + 1 and running do
        if hum.Health <= 0 or not CFG.farm then break end
        task.wait()
    end
    tw:Cancel()
    cc:Disconnect()
    moving = false
    if hrp.Parent then hrp.AssemblyLinearVelocity = Vector3.zero end
    return done
end

local function farmStep()
    local hrp, hum = myHrp()
    if busy or not hrp or not hum or hum.Health <= 0 then return end
    if got >= CFG.maxCoins then return end
    
    local best, bd = nil, CFG.coinRange
    for c in pairs(coins) do
        if c.Parent and not visited[c] then
            local d = (c.Position - hrp.Position).Magnitude
            if d < bd then best, bd = c, d end
        end
    end
    
    if not best then return end
    busy = true
    local ok = goTo(CFrame.new(best.Position + Vector3.new(0, 1.5, 0)), CFG.farmSpeed)
    if ok and best.Parent then
        touch(hrp, best)
        task.wait(0.2)
        if not best.Parent then got += 1 end
    end
    visited[best] = true
    busy = false
end

task.spawn(function()
    while running do
        if CFG.farm then pcall(farmStep) end
        task.wait(0.15)
    end
end)              
        else
CFG.farm = false
running = false

for _, c in ipairs(conns) do
    pcall(function()
        c:Disconnect()
    end)
end

table.clear(conns)
        end
    end
})


-- ========================================================
-- ВКЛАДКА: VISUALS
-- ========================================================
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

VisualsTab:Toggle({
    Title = "ESP Roles",
    Value = false,
    Callback = function(Value)
        if Value then
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local genv = (getgenv and getgenv()) or _G
for _, k in ipairs({"NyxESP", "NyxAll", "NyxKA"}) do
    if genv[k] then pcall(genv[k]) end
end

local CFG = {
    box = true, skeleton = true, highlight = true, name = true, dist = true,
    tracer = true, health = true, gun = true,
    maxDist = 800, skelDist = 150,
}
local SHOW = {Murderer = true, Sheriff = true, Hero = true, Innocent = true}
local COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 130, 255),
    Hero     = Color3.fromRGB(255, 220, 60),
    Innocent = Color3.fromRGB(80, 255, 120),
}
local BLACK = Color3.new(0, 0, 0)

local HAS_DRAW = typeof(Drawing) == "table" or typeof(Drawing) == "userdata"

local R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local R6 = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}
local UP, DOWN = Vector3.new(0, 3, 0), Vector3.new(0, 3.5, 0)
local PARTS = {"box", "hpBack", "hp", "tracer", "name", "dist"}

local conns, draws = {}, {}
local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end
local function draw(class)
    local d = Drawing.new(class)
    draws[#draws + 1] = d
    return d
end
local function newText()
    local t = draw("Text")
    t.Size, t.Center, t.Outline, t.Visible = 14, true, true, false
    return t
end

local roles, E = {}, {}
local sheriffGone = false
local drop, dropPos

local function resetRound()
    table.clear(roles)
    sheriffGone, drop, dropPos = false, nil, nil
    for _, e in pairs(E) do e.lastRole = nil end
end

local function readData(tbl)
    if typeof(tbl) ~= "table" then return end
    for k, d in pairs(tbl) do
        local p = typeof(k) == "Instance" and k or Players:FindFirstChild(tostring(k))
        local role = typeof(d) == "table" and (d.Role or d.role)
        if p and role then roles[p] = role end
    end
end

for _, r in ipairs(RS:GetDescendants()) do
    pcall(function()
        if r:IsA("RemoteEvent") and r.Name == "PlayerDataChanged" then
            connect(r.OnClientEvent, function(...) readData((...)) end)
        elseif r:IsA("RemoteEvent") and r.Name == "LoadingMap" then
            connect(r.OnClientEvent, resetRound)
        elseif r:IsA("RemoteFunction") and r.Name == "GetPlayerData" then
            task.spawn(function()
                local ok, res = pcall(function() return r:InvokeServer() end)
                if ok then readData(res) end
            end)
        end
    end)
end

local function toolCheck(p, ch)
    if ch.Name == "Knife" then
        roles[p] = "Murderer"
    elseif ch.Name == "Gun" and roles[p] ~= "Sheriff" and roles[p] ~= "Murderer" then
        roles[p] = sheriffGone and "Hero" or "Sheriff"
    end
end

local function posOf(i)
    if i:IsA("BasePart") then return i.Position end
    if i:IsA("Model") then return i:GetPivot().Position end
end

local function onDropGone()
    local pos = dropPos
    drop, dropPos = nil, nil
    if not pos then return end
    local best, bd = nil, 25
    for p, e in pairs(E) do
        if e.hrp and e.hrp.Parent and e.hum and e.hum.Health > 0 then
            local d = (e.hrp.Position - pos).Magnitude
            if d < bd then best, bd = p, d end
        end
    end
    local mine = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if mine and (mine.Position - pos).Magnitude < bd then return end
    if best and roles[best] ~= "Murderer" then roles[best] = "Hero" end
end

local function trackDrop(i)
    if i.Name ~= "GunDrop" or drop == i then return end
    drop, dropPos, sheriffGone = i, posOf(i), true
    if CFG.gun and not i:FindFirstChild("GunESP") then
        local hl = Instance.new("Highlight")
        hl.Name = "GunESP"
        hl.FillColor, hl.OutlineColor = COLORS.Hero, COLORS.Hero
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = i
    end
    connect(i.AncestryChanged, function(_, parent)
        if not parent and drop == i then onDropGone() end
    end)
end

connect(workspace.DescendantAdded, trackDrop)
task.spawn(function()
    local n = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        trackDrop(d)
        n += 1
        if n % 2000 == 0 then task.wait() end
    end
end)

local function create(p)
    if p == lp or E[p] then return end
    local e = {tries = 0, built = 0, lv = {}, bones = {}}
    if HAS_DRAW then
        e.box = draw("Square"); e.box.Thickness, e.box.Filled, e.box.Visible = 1.5, false, false
        e.hpBack = draw("Square"); e.hpBack.Filled, e.hpBack.Color, e.hpBack.Visible = true, BLACK, false
        e.hp = draw("Square"); e.hp.Filled, e.hp.Visible = true, false
        e.tracer = draw("Line"); e.tracer.Thickness, e.tracer.Visible = 1, false
        e.name, e.dist = newText(), newText()
        e.lines = {}
        for i = 1, 14 do
            local l = draw("Line")
            l.Thickness, l.Visible = 1.5, false
            e.lines[i] = l
        end
    end
    E[p] = e
end

local function destroy(p)
    local e = E[p]
    if e then
        if e.cc then pcall(function() e.cc:Disconnect() end) end
        if e.hl then pcall(function() e.hl:Destroy() end) end
        if HAS_DRAW then
            for _, k in ipairs(PARTS) do pcall(function() e[k]:Remove() end) end
            for _, l in ipairs(e.lines) do pcall(function() l:Remove() end) end
        end
    end
    E[p], roles[p] = nil, nil
end

for _, p in ipairs(Players:GetPlayers()) do create(p) end
connect(Players.PlayerAdded, create)
connect(Players.PlayerRemoving, destroy)

local function build(p, e, c, now)
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return false end
    if e.cc then e.cc:Disconnect() end
    if e.hl then e.hl:Destroy(); e.hl = nil end
    e.char, e.hrp, e.hum, e.lastRole, e.built = c, hrp, hum, nil, now
    local set = c:FindFirstChild("UpperTorso") and R15 or R6
    e.bones = {}
    for _, b in ipairs(set) do
        local a, d = c:FindFirstChild(b[1]), c:FindFirstChild(b[2])
        if a and d then e.bones[#e.bones + 1] = {a, d} end
    end
    e.retry = #e.bones < #set
    e.tries = e.retry and e.tries + 1 or 0
    for _, ch in ipairs(c:GetChildren()) do toolCheck(p, ch) end
    e.cc = c.ChildAdded:Connect(function(ch) toolCheck(p, ch) end)
    return true
end

local function hideAll(e)
    if not HAS_DRAW or not e.shown then return end
    e.shown = false
    for _, k in ipairs(PARTS) do e[k].Visible = false end
    for i, l in ipairs(e.lines) do l.Visible = false; e.lv[i] = false end
end

local PC = {}
local function proj(cam, part)
    local v = PC[part]
    if v == nil then
        local pt, on = cam:WorldToViewportPoint(part.Position)
        v = on and Vector2.new(pt.X, pt.Y) or false
        PC[part] = v
    end
    return v
end

local function step(p, e, cam, camPos, vp, now)
    local c = p.Character
    if c and e.char ~= c then
        if not build(p, e, c, now) then hideAll(e); return end
    elseif c and e.retry and e.tries < 5 and now - e.built > 1 then
        build(p, e, c, now)
    end

    local hum, hrp = e.hum, e.hrp
    local alive = c and e.char == c and hrp and hrp.Parent and hum and hum.Health > 0
    if not alive then
        hideAll(e)
        if e.hl then e.hl:Destroy(); e.hl = nil end
        return
    end

    local pos = hrp.Position
    local role = roles[p] or "Innocent"
    local dist = (camPos - pos).Magnitude
    if not SHOW[role] or dist > CFG.maxDist then
        hideAll(e)
        if e.hl then e.hl.Enabled = false end
        return
    end
    local color = COLORS[role] or COLORS.Innocent

    if CFG.highlight then
        if not e.hl or e.hl.Parent ~= c then
            local hl = Instance.new("Highlight")
            hl.Name = "ESP"
            hl.FillTransparency = 0.55
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = c
            e.hl, e.lastRole = hl, nil
        end
        if e.lastRole ~= role then
            e.hl.FillColor, e.hl.OutlineColor = color, color
            e.lastRole = role
        end
        e.hl.Enabled = true
    elseif e.hl then
        e.hl.Enabled = false
    end

    if not HAS_DRAW then return end
    local top, v1 = cam:WorldToViewportPoint(pos + UP)
    local bot, v2 = cam:WorldToViewportPoint(pos - DOWN)
    if not (v1 and v2) then hideAll(e); return end

    e.shown = true
    local h = math.abs(bot.Y - top.Y)
    local w = h / 2
    local cx = (top.X + bot.X) / 2

    e.box.Visible = CFG.box
    e.box.Color = color
    e.box.Size = Vector2.new(w, h)
    e.box.Position = Vector2.new(cx - w / 2, top.Y)

    local frac = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
    e.hpBack.Visible, e.hp.Visible = CFG.health, CFG.health
    if CFG.health then
        e.hpBack.Size = Vector2.new(4, h)
        e.hpBack.Position = Vector2.new(cx - w / 2 - 7, top.Y)
        e.hp.Size = Vector2.new(2, math.max(h * frac - 2, 0))
        e.hp.Position = Vector2.new(cx - w / 2 - 6, top.Y + h - h * frac + 1)
        e.hp.Color = BLACK:Lerp(color, 0.35 + 0.65 * frac)
    end

    e.tracer.Visible = CFG.tracer
    if CFG.tracer then
        e.tracer.Color = color
        e.tracer.From = Vector2.new(vp.X / 2, vp.Y)
        e.tracer.To = Vector2.new(cx, bot.Y)
    end

    e.name.Visible = CFG.name
    if CFG.name then
        e.name.Color = color
        e.name.Position = Vector2.new(cx, top.Y - 18)
        local s = p.DisplayName .. " [" .. role .. "]"
        if e.nt ~= s then e.nt = s; e.name.Text = s end
    end

    e.dist.Visible = CFG.dist
    if CFG.dist then
        e.dist.Position = Vector2.new(cx, bot.Y + 2)
        local m = math.floor(dist)
        if e.dm ~= m then e.dm = m; e.dist.Text = m .. "m" end
    end

    table.clear(PC)
    local showSkel = CFG.skeleton and dist < CFG.skelDist
    for i, l in ipairs(e.lines) do
        local b = showSkel and e.bones[i]
        local on = false
        if b then
            local a, d = proj(cam, b[1]), proj(cam, b[2])
            if a and d then
                l.Color, l.From, l.To = color, a, d
                on = true
            end
        end
        if on ~= e.lv[i] then l.Visible = on; e.lv[i] = on end
    end
end

local gunTxt = HAS_DRAW and newText() or nil

connect(RunService.RenderStepped, function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local camPos, vp, now = cam.CFrame.Position, cam.ViewportSize, tick()

    for p, e in pairs(E) do
        pcall(step, p, e, cam, camPos, vp, now)
    end

    if drop and drop.Parent then dropPos = posOf(drop) or dropPos end
    if gunTxt then
        if drop and drop.Parent and dropPos and CFG.gun then
            local sp, vis = cam:WorldToViewportPoint(dropPos)
            gunTxt.Visible = vis
            if vis then
                gunTxt.Color = COLORS.Hero
                gunTxt.Text = "GUN " .. math.floor((camPos - dropPos).Magnitude) .. "m"
                gunTxt.Position = Vector2.new(sp.X, sp.Y)
            end
        else
            gunTxt.Visible = false
        end
    end
end)

genv.NyxESP = function()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for _, e in pairs(E) do
        if e.cc then pcall(function() e.cc:Disconnect() end) end
        if e.hl then pcall(function() e.hl:Destroy() end) end
    end
    for _, d in ipairs(draws) do pcall(function() d:Remove() end) end
    local g = drop and drop:FindFirstChild("GunESP")
    if g then g:Destroy() end
    genv.NyxESP = nil
end
        else
local genv = (getgenv and getgenv()) or _G

if genv.NyxESP then
    pcall(genv.NyxESP)
end
        end
    end
})

-- ========================================================
-- ВКЛАДКА: SETTINGS
-- ========================================================
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

SettingsTab:Dropdown({
    Title = "Theme Selection",
    Values = AvailableThemes, -- Подставляем список автоматически найденных тем
    Value = "Sky", -- Тема по умолчанию
    Callback = function(SelectedTheme)
        -- Код изменения темы оформления интерфейса
        WindUI:SetTheme(SelectedTheme)
        
        -- Красивое уведомление о смене темы
        WindUI:Notify({
            Title = "Theme Changed",
            Content = "Switched to " .. SelectedTheme .. " theme!",
            Duration = 2,
            Icon = "palette"
        })
    end
})
