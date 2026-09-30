local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

local Colors = {
    Murderer = Color3.fromRGB(255, 0, 0),
    Sheriff = Color3.fromRGB(0, 100, 255),
    Innocent = Color3.fromRGB(0, 255, 100),
    Dead = Color3.fromRGB(15, 15, 15),
    GunDrop = Color3.fromRGB(255, 0, 255)
}

local MAPS = {
    BioLab = true,
    Office3 = true,
    House2 = true,
    MilBase = true,
    School = true,
    Hospital3 = true,
    Mansion2 = true,
    ResearchFacility = true,
    PoliceStation = true,
    Factory = true,
    Workplace = true,
    Hotel2 = true
}

local ROLE_HIGHLIGHT_NAME = "RoleHighlight"
local COIN_HIGHLIGHT_NAME = "CoinESP"
local GUN_DROP_HIGHLIGHT_NAME = "GunDropESP"

local AUTO_TELEPORT_TO_GUN = true
local AUTO_FARM_COINS = false
local FARM_SPEED = 25
local RETURN_DELAY = 0.05

local HeroPlayers = {}

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://140207837688369"
clickSound.Volume = 15
clickSound.Parent = SoundService

local function hasTool(player, character, toolNames)
    for _, name in ipairs(toolNames) do
        local backpack = player:FindFirstChildOfClass("Backpack")

        if backpack then
            for _, toolName in ipairs(toolNames) do
                if backpack:FindFirstChild(toolName) then
                    return true
                end
            end
        end

        if character then
            for _, toolName in ipairs(toolNames) do
                if character:FindFirstChild(toolName) then
                    return true
                end
            end
        end
    end

    return false
end

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if hasTool(player, player.Character, {"Knife", "Knife_Server"}) then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    return player
                end
            end
        end
    end
    return nil
end

local function shootMurderer()
    local murderer = getMurderer()
    if not murderer or not murderer.Character then return end

    local mHrp = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not mHrp then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local gun = char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
    if not gun then return end

    if gun.Parent ~= char then
        humanoid:EquipTool(gun)
        task.wait(0.05)
    end

    local originalCFrame = hrp.CFrame

    hrp.CFrame = mHrp.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, math.pi, 0)
    task.wait(0.02)

    gun:Activate()

    for _, obj in ipairs(gun:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj:FireServer(mHrp.Position)
                obj:FireServer(mHrp.CFrame)
            end)
        end
    end

    task.wait(0.08)

    if char and hrp and humanoid.Health > 0 then
        hrp.CFrame = originalCFrame
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SheriffAimGui"
screenGui.ResetOnSpawn = false

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
if success and coreGui then
    screenGui.Parent = coreGui
else
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local shootButton = Instance.new("TextButton")
shootButton.Name = "ShootButton"
shootButton.Size = UDim2.new(0, 160, 0, 45)
shootButton.Position = UDim2.new(0.82, 0, 0.75, 0)
shootButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shootButton.Text = "KILL MURDERER"
shootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shootButton.TextSize = 14
shootButton.Font = Enum.Font.GothamBold
shootButton.AutoButtonColor = false
shootButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = shootButton

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 20, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 20))
})
uiGradient.Rotation = 45
uiGradient.Parent = shootButton

shootButton.MouseButton1Click:Connect(function()
    clickSound:Play()

    local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenDown = TweenService:Create(shootButton, tweenInfo, {Size = UDim2.new(0, 145, 0, 40)})
    local tweenUp = TweenService:Create(shootButton, tweenInfo, {Size = UDim2.new(0, 160, 0, 45)})

    tweenDown:Play()
    tweenDown.Completed:Wait()
    tweenUp:Play()

    shootMurderer()
end)

local function getRoleHighlight(character)
    local highlight = character:FindFirstChild(ROLE_HIGHLIGHT_NAME)

    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = ROLE_HIGHLIGHT_NAME
        highlight.FillTransparency = 0.55
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
    end

    return highlight
end

local function applyRoleHighlight(player, character)
    if player == LocalPlayer or not character then
        return
    end

    local highlight = getRoleHighlight(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not character:IsDescendantOf(Workspace)
        or (humanoid and humanoid.Health <= 0)
        or character:FindFirstChild("Corpse") then

        highlight.FillColor = Colors.Dead
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        return
    end

    if hasTool(player, character, {"Knife", "Knife_Server"}) then
        highlight.FillColor = Colors.Murderer
        highlight.OutlineColor = Colors.Murderer
        return
    end

    if hasTool(player, character, {"Gun", "Gun_Server"}) or HeroPlayers[player] then
        highlight.FillColor = Colors.Sheriff
        highlight.OutlineColor = Colors.Sheriff
        return
    end

    highlight.FillColor = Colors.Innocent
    highlight.OutlineColor = Colors.Innocent
end

local function setupPlayer(player)
    if player == LocalPlayer then
        return
    end

    local function onCharacter(character)
        applyRoleHighlight(player, character)

        character.ChildAdded:Connect(function()
            task.defer(function()
                applyRoleHighlight(player, character)
            end)
        end)

        local backpack = player:WaitForChild("Backpack", 5)
        if backpack then
            backpack.ChildAdded:Connect(function()
                task.defer(function()
                    applyRoleHighlight(player, character)
                end)
            end)
        end
    end

    player.CharacterAdded:Connect(onCharacter)

    if player.Character then
        task.spawn(function()
            onCharacter(player.Character)
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)
    HeroPlayers[player] = nil
end)

task.spawn(function()
    while task.wait(0.1) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                applyRoleHighlight(player, player.Character)
            end
        end
    end
end)

local function addCoinHighlight(object)
    if not object or not object.Parent then
        return
    end

    if object:FindFirstChild(COIN_HIGHLIGHT_NAME) then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = COIN_HIGHLIGHT_NAME
    highlight.Adornee = object
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
    highlight.FillTransparency = 0.35
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = object
end

local function processCoinServer(coinServer)
    if not coinServer or coinServer.Name ~= "Coin_Server" then
        return
    end

    addCoinHighlight(coinServer)

    task.spawn(function()
        local coinVisual

        for _ = 1, 30 do
            coinVisual = coinServer:FindFirstChild("CoinVisual", true)

            if coinVisual then
                break
            end

            task.wait(0.1)
        end

        if not coinVisual or not coinVisual.Parent then
            return
        end

        addCoinHighlight(coinVisual)

        for _, object in ipairs(coinVisual:GetDescendants()) do
            if object.Name == "2Part"
                or object.Name == "MainCoin"
                or object.Name == "DecalPart" then

                addCoinHighlight(object)
            end
        end

        coinVisual.DescendantAdded:Connect(function(object)
            if object.Name == "2Part"
                or object.Name == "MainCoin"
                or object.Name == "DecalPart" then

                task.defer(function()
                    addCoinHighlight(object)
                end)
            end
        end)
    end)
end

local function addGunDropHighlight(object)
    if not object or not object.Parent then
        return
    end

    if object:FindFirstChild(GUN_DROP_HIGHLIGHT_NAME) then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = GUN_DROP_HIGHLIGHT_NAME
    highlight.Adornee = object
    highlight.FillColor = Colors.GunDrop
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = object
end

local function grabGunAndReturn(gunDrop)
    if not AUTO_TELEPORT_TO_GUN then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    local targetPart = gunDrop:IsA("BasePart") and gunDrop or gunDrop:FindFirstChildWhichIsA("BasePart", true)
    if not targetPart then return end

    local originalCFrame = hrp.CFrame

    hrp.CFrame = targetPart.CFrame + Vector3.new(0, 1, 0)

    local gunCollected = false
    local connection

    connection = gunDrop.AncestryChanged:Connect(function(_, parent)
        if not parent then
            gunCollected = true
        end
    end)

    local start = tick()
    while not gunCollected and gunDrop and gunDrop.Parent and (tick() - start < 1) do
        task.wait()
    end

    if connection then connection:Disconnect() end

    task.wait(RETURN_DELAY)

    if char and hrp and humanoid.Health > 0 then
        hrp.CFrame = originalCFrame
    end
end

local function checkGunDrop(object)
    if object and object.Name == "GunDrop" then
        addGunDropHighlight(object)

        task.spawn(function()
            grabGunAndReturn(object)
        end)

        object.AncestryChanged:Connect(function(_, parent)
            if not parent then
                local gunPos = object:IsA("BasePart") and object.Position or (object:FindFirstChildWhichIsA("BasePart") and object:FindFirstChildWhichIsA("BasePart").Position)
                
                if gunPos then
                    for _, player in ipairs(Players:GetPlayers()) do
                        local char = player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position - gunPos).Magnitude <= 12 then
                            HeroPlayers[player] = true
                            applyRoleHighlight(player, char)
                            break
                        end
                    end
                end
            end
        end)
    end
end

local function processMap(map)
    if not map or not MAPS[map.Name] then
        return
    end

    for _, object in ipairs(map:GetDescendants()) do
        if object.Name == "Coin_Server" then
            task.defer(function()
                processCoinServer(object)
            end)
        end
    end

    map.DescendantAdded:Connect(function(object)
        if object.Name == "Coin_Server" then
            task.defer(function()
                processCoinServer(object)
            end)
        end
    end)
end

for _, object in ipairs(Workspace:GetChildren()) do
    if MAPS[object.Name] then
        processMap(object)
    end
end

for _, object in ipairs(Workspace:GetDescendants()) do
    checkGunDrop(object)
end

Workspace.ChildAdded:Connect(function(object)
    if MAPS[object.Name] then
        task.defer(function()
            processMap(object)
        end)
    end
end)

Workspace.DescendantAdded:Connect(function(object)
    task.defer(function()
        checkGunDrop(object)

        if object.Name == "Coin_Server" then
            processCoinServer(object)
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.5)

        if AUTO_FARM_COINS then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if hrp and humanoid and humanoid.Health > 0 then
                local currentMap
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if MAPS[obj.Name] then
                        currentMap = obj
                        break
                    end
                end

                if currentMap then
                    for _, coin in ipairs(currentMap:GetDescendants()) do
                        if coin.Name == "Coin_Server" and coin:IsA("BasePart") and coin.Parent then
                            local distance = (hrp.Position - coin.Position).Magnitude
                            local tweenTime = distance / FARM_SPEED

                            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = coin.CFrame})

                            local diedConnection
                            diedConnection = humanoid.Died:Connect(function()
                                tween:Cancel()
                                if diedConnection then diedConnection:Disconnect() end
                            end)

                            tween:Play()

                            local start = tick()
                            while coin and coin.Parent and (tick() - start < tweenTime + 0.5) do
                                if not AUTO_FARM_COINS or not humanoid or humanoid.Health <= 0 or not char.Parent then
                                    tween:Cancel()
                                    break
                                end
                                task.wait()
                            end

                            if diedConnection then diedConnection:Disconnect() end

                            if not AUTO_FARM_COINS or not humanoid or humanoid.Health <= 0 then break end
                        end
                    end
                end
            end
        end
    end
end)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local function killPlayer(targetPlayer)
    if targetPlayer == LocalPlayer or not targetPlayer.Character then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local knife = char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
    if not knife then return end

    if knife.Parent ~= char then
        humanoid:EquipTool(knife)
        task.wait(0.05)
    end

    local targetChar = targetPlayer.Character
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")

    if targetHrp and targetHumanoid and targetHumanoid.Health > 0 then
        local events = knife:FindFirstChild("Events")
        
        if events then
            local handleTouched = events:FindFirstChild("HandleTouched")
            local knifeStabbed = events:FindFirstChild("KnifeStabbed")

            if handleTouched then
                pcall(function()
                    handleTouched:FireServer(targetHrp)
                    handleTouched:FireServer(targetChar:FindFirstChild("Head") or targetHrp)
                end)
            end
            if knifeStabbed then
                pcall(function()
                    knifeStabbed:FireServer(targetHrp)
                end)
            end
        end

        local originalCFrame = hrp.CFrame
        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1)
        knife:Activate()
        
        task.wait(0.05)
        hrp.CFrame = originalCFrame
    end
end

local function killAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                killPlayer(player)
                task.wait(0.1)
            end
        end
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KnifeKillGui"
screenGui.ResetOnSpawn = false

local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
if success and coreGui then
    screenGui.Parent = coreGui
else
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local killAllButton = Instance.new("TextButton")
killAllButton.Name = "KillAllButton"
killAllButton.Size = UDim2.new(0, 160, 0, 45)
killAllButton.Position = UDim2.new(0.82, 0, 0.68, 0)
killAllButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
killAllButton.Text = "EZZ CRACK"
killAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killAllButton.TextSize = 14
killAllButton.Font = Enum.Font.GothamBold
killAllButton.AutoButtonColor = false
killAllButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = killAllButton

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
})
uiGradient.Rotation = 45
uiGradient.Parent = killAllButton

killAllButton.MouseButton1Click:Connect(function()
    local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenDown = TweenService:Create(killAllButton, tweenInfo, {Size = UDim2.new(0, 145, 0, 40)})
    local tweenUp = TweenService:Create(killAllButton, tweenInfo, {Size = UDim2.new(0, 160, 0, 45)})

    tweenDown:Play()
    tweenDown.Completed:Wait()
    tweenUp:Play()

    task.spawn(killAll)
end)
