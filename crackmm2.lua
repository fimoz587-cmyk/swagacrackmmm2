task.spawn(loadstring([[
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

_G.MM2_Settings = {
    KILL_RADIUS = 16,
    SILENT_AIM_ENABLED = false,
    FAST_RELOAD_ENABLED = false,
    RELOAD_SPEED_MULTIPLIER = 5,
    GUN_PICK_TELEPORT = true,
    CoinsEspEnabled = false,
    GunDropEspEnabled = false,
    RolesEspEnabled = false,
    ShowOnlyImportantRoles = false
}

local Window = WindUI:Window({
    Title = "Swaga Crack MM2",
    Icon = "rbxassetid://1298301",
    Author = "Cracked by @AnalogyScript",
    Folder = "Swaga_Crack_Settings",
    Theme = "Dark"
})
_G.Swaga_WindowInstance = Window

local AimbotTab = Window:Tab({ 
    Title = "Aimbot", 
    Icon = "rbxassetid://10734950349" 
})

AimbotTab:Toggle({
    Title = "Enable Silent Aim",
    Default = false,
    Callback = function(v) 
        _G.MM2_Settings.SILENT_AIM_ENABLED = v 
    end
})

AimbotTab:Slider({
    Title = "Reload Speed", 
    Min = 1, 
    Max = 10, 
    Default = 5,
    Callback = function(v) 
        _G.MM2_Settings.RELOAD_SPEED_MULTIPLIER = v 
    end
})

AimbotTab:Toggle({
    Title = "Enable Kill Aura", 
    Default = false,
    Callback = function(v) 
        _G.MM2_Settings.KILL_AURA_ENABLED = v 
    end
})
]]))()
task.spawn(loadstring([[
local Window = _G.Swaga_WindowInstance
if not Window then return end

local VisualsTab = Window:Tab({ 
    Title = "Visuals", 
    Icon = "rbxassetid://10723346939" 
})

VisualsTab:Toggle({
    Title = "Coins Highlights", 
    Default = false,
    Callback = function(v) 
        _G.MM2_Settings.CoinsEspEnabled = v 
    end
})

VisualsTab:Toggle({
    Title = "Gun Drop Highlights", 
    Default = false,
    Callback = function(v) 
        _G.MM2_Settings.GunDropEspEnabled = v 
    end
})

VisualsTab:Toggle({
    Title = "Roles Highlights", 
    Default = false,
    Callback = function(v) 
        _G.MM2_Settings.RolesEspEnabled = v 
    end
})

VisualsTab:Toggle({
    Title = "Show Only Murderer & Sheriff", 
    Default = false,
    Callback = function(v) 
        _G.MM2_Settings.ShowOnlyImportantRoles = v 
    end
})
]]))()
task.spawn(loadstring([[
local Players = game:GetService("Players") 
local Workspace = game:GetService("Workspace") 
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer 

local oldGui = CoreGui:FindFirstChild("MM2_CustomTimerGui") 
if oldGui then oldGui:Destroy() end

local targetMaps = {
    ["Biolab"] = true, ["Hotel"] = true, ["Workplace"] = true, ["Workspace"] = true,
    ["Factory"] = true, ["Mansion2"] = true, ["ResearchFacility"] = true,
    ["MilBase"] = true, ["House2"] = true, ["Hospital3"] = true
}

_G.ActiveHighlights = {} 
_G.AvailableGuns = {} 
_G.playerHighlights = {} 
_G.trackedChar = {} 
_G.isRoundActive = true

local timerGui = Instance.new("ScreenGui") 
timerGui.Name = "MM2_CustomTimerGui" 
timerGui.Parent = CoreGui

local timerFrame = Instance.new("Frame") 
timerFrame.Size = UDim2.new(0, 180, 0, 40) 
timerFrame.Position = UDim2.new(0.5, -90, 0, 5) 
timerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) 
timerFrame.BackgroundTransparency = 0.25 
timerFrame.BorderSizePixel = 0 
timerFrame.Parent = timerGui

local uiCorner = Instance.new("UICorner") 
uiCorner.CornerRadius = UDim.new(0, 8) 
uiCorner.Parent = timerFrame

local textLabel = Instance.new("TextLabel") 
textLabel.Size = UDim2.new(1, 0, 1, 0) 
textLabel.BackgroundTransparency = 1 
textLabel.Font = Enum.Font.GothamBold 
textLabel.TextSize = 16 
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
textLabel.Text = "Waiting..." 
textLabel.Parent = timerFrame

local function checkTimer()
    local timerPart = Workspace:FindFirstChild("RoundTimerPart")
    if timerPart then
        local surfaceGui = timerPart:FindFirstChildOfClass("SurfaceGui")
        local timerLabel = surfaceGui and surfaceGui:FindFirstChild("Timer")
        if timerLabel and timerLabel:IsA("TextLabel") then
            local txt = timerLabel.Text
            if txt == "0:00" or txt == "00:00" or txt == "" or string.find(txt, "окончен") then 
                textLabel.Text = "ROUND ENDED" 
                textLabel.TextColor3 = Color3.fromRGB(150, 150, 150) 
                return false
            else 
                textLabel.Text = "TIME: " .. txt 
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
                return true 
            end
        end
    end
    textLabel.Text = "IN LOBBY" 
    textLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    for m, _ in pairs(targetMaps) do 
        if Workspace:FindFirstChild(m) then return true end 
    end 
    return false
end

task.spawn(function()
    while task.wait(0.2) do
        _G.isRoundActive = checkTimer()
        if not _G.isRoundActive or not _G.MM2_Settings.CoinsEspEnabled then
            for o, h in pairs(_G.ActiveHighlights) do 
                if h and h.Name == "CoinPartESP" then pcall(function() h:Destroy() end) _G.ActiveHighlights[o] = nil end 
            end
        end
        if not _G.isRoundActive or not _G.MM2_Settings.GunDropEspEnabled then
            for o, h in pairs(_G.ActiveHighlights) do 
                if h and h.Name == "GunESP" then pcall(function() h:Destroy() end) _G.ActiveHighlights[o] = nil end 
            end
        end
        if not _G.isRoundActive or not _G.MM2_Settings.RolesEspEnabled then
            for p, h in pairs(_G.playerHighlights) do pcall(function() h:Destroy() end) end 
            _G.playerHighlights, _G.trackedChar = {}, {}
        end
    end
end)

local function createESP(o, c, t) 
    if not _G.isRoundActive or _G.ActiveHighlights[o] then return end 
    local h = Instance.new("Highlight") 
    h.Name = t 
    h.FillColor = c 
    h.FillTransparency = 0.4 
    h.OutlineColor = c 
    h.OutlineTransparency = 0 
    h.Adornee = o 
    h.Parent = o 
    _G.ActiveHighlights[o] = h 
end

local function hlCoin(v) 
    local pts = {"MainCoin", "2Part", "DecalPart"} 
    for _, n in ipairs(pts) do 
        local p = v:FindFirstChild(n) 
        if p and p:IsA("BasePart") and _G.MM2_Settings.CoinsEspEnabled then 
            createESP(p, Color3.fromRGB(255, 255, 0), "CoinPartESP") 
        end 
    end 
end

local function setupCoinContainer(c) 
    for _, i in ipairs(c:GetChildren()) do 
        if i.Name == "Coin_Server" then hlCoin(i:FindFirstChild("CoinVisual") or i) end 
    end 
    c.ChildAdded:Connect(function(i) 
        task.wait(0.05) 
        if i.Name == "Coin_Server" then hlCoin(i:FindFirstChild("CoinVisual") or i) end 
    end) 
end

_G.setupMapESP = function(m)
    for _, c in ipairs(m:GetChildren()) do
        if c.Name == "GunDrop" and c:IsA("BasePart") then 
            if _G.MM2_Settings.GunDropEspEnabled then createESP(c, Color3.fromRGB(255, 130, 0), "GunESP") end 
            _G.AvailableGuns[c] = true
        elseif c.Name == "CoinContainer" then 
            setupCoinContainer(c) 
        end
    end
end

task.spawn(function() 
    while task.wait(0.1) do 
        for o, h in pairs(_G.ActiveHighlights) do 
            if not o or not o:IsDescendantOf(Workspace) then pcall(function() h:Destroy() end) _G.ActiveHighlights[o] = nil end 
        end 
        for g in pairs(_G.AvailableGuns) do 
            if not g or not g:IsDescendantOf(Workspace) then _G.AvailableGuns[g] = nil end 
        end 
    end 
end)
]]))()
task.spawn(loadstring([[
local Players = game:GetService("Players") 
local Workspace = game:GetService("Workspace") 
local LocalPlayer = Players.LocalPlayer
local targetMaps = {["Biolab"]=true,["Hotel"]=true,["Workplace"]=true,["Workspace"]=true,["Factory"]=true,["Mansion2"]=true,["ResearchFacility"]=true,["MilBase"]=true,["House2"]=true,["Hospital3"]=true}

local function getRole(p)
    local c = p.Character if not c or not c:FindFirstChildOfClass("Humanoid") or c.Humanoid.Health <= 0 then return "dead" end
    local bp = p:FindFirstChild("Backpack") 
    if c:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then return "murderer" end
    if c:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then return "sheriff" end 
    return "innocent"
end

local function getCls()
    if not _G.isRoundActive then return nil end 
    local cPl, sD = nil, math.huge 
    local mC = LocalPlayer.Character 
    local mR = mC and mC:FindFirstChild("HumanoidRootPart") 
    if not mR then return nil end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tR = p.Character:FindFirstChild("HumanoidRootPart") 
            local tH = p.Character:FindFirstChildOfClass("Humanoid")
            if tR and tH and tH.Health > 0 then
                local r = getRole(p) 
                if r == "murderer" then return p end 
                local d = (mR.Position - tR.Position).Magnitude 
                if d < sD then sD = d cPl = p end
            end
        end
    end 
    return cPl
end

task.spawn(function()
    while task.wait(0.03) do
        if _G.isRoundActive and _G.MM2_Settings.KILL_AURA_ENABLED then
            local c = LocalPlayer.Character 
            local root = c and c:FindFirstChild("HumanoidRootPart") 
            local k = c and c:FindFirstChild("Knife")
            if root and k then
                local h = k:FindFirstChild("Handle") or k:FindFirstChildOfClass("BasePart") 
                local evs = k:FindFirstChild("Events") 
                local t = getCls()
                if t and t.Character and h and t.Character:FindFirstChild("HumanoidRootPart") and (root.Position - t.Character.HumanoidRootPart.Position).Magnitude <= _G.MM2_Settings.KILL_RADIUS then
                    pcall(function() k:Activate() end) 
                    if evs then 
                        for _, e in ipairs(evs:GetChildren()) do 
                            if e:IsA("RemoteEvent") then pcall(function() e:FireServer() end) end 
                        end 
                    end
                    if firetouchinterest then 
                        firetouchinterest(t.Character.HumanoidRootPart, h, 0) 
                        firetouchinterest(t.Character.HumanoidRootPart, h, 1) 
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if _G.isRoundActive and _G.MM2_Settings.RolesEspEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if _G.trackedChar[p] ~= p.Character then
                        if _G.playerHighlights[p] then pcall(function() _G.playerHighlights[p]:Destroy() end) end
                        local hl = Instance.new("Highlight") 
                        hl.FillTransparency = 0.5 
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
                        hl.Adornee = p.Character 
                        hl.Parent = p.Character 
                        _G.playerHighlights[p], _G.trackedChar[p] = hl, p.Character
                    end
                    if _G.playerHighlights[p] then
                        local r = getRole(p) 
                        local col = r == "murderer" and Color3.fromRGB(255,40,40) or r == "sheriff" and Color3.fromRGB(40,120,255) or Color3.fromRGB(0,220,80)
                        _G.playerHighlights[p].FillColor = col 
                        _G.playerHighlights[p].OutlineColor = col
                        if _G.MM2_Settings.ShowOnlyImportantRoles and (r == "innocent" or r == "dead") then 
                            _G.playerHighlights[p].Enabled = false 
                        else 
                            _G.playerHighlights[p].Enabled = true 
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if _G.isRoundActive and _G.MM2_Settings.GUN_PICK_TELEPORT then
            local c = LocalPlayer.Character 
            local r = c and c:FindFirstChild("HumanoidRootPart") 
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 and not c:FindFirstChild("ForceField") then
                for g in pairs(_G.AvailableGuns) do
                    if g and g:IsDescendantOf(Workspace) and g.Parent then
                        local oCF = r.CFrame 
                        r.CFrame = g.CFrame 
                        task.wait(0.05)
                        local prompt = g:FindFirstChildOfClass("ProximityPrompt") 
                        if prompt then fireproximityprompt(prompt) end 
                        task.wait(0.05)
                        if LocalPlayer.Character == c and h.Health > 0 then r.CFrame = oCF end
                    end
                end
            end
        end
    end
end)

local gmt = getrawmetatable(game) 
local oldN = gmt.__namecall 
setreadonly(gmt, false)
gmt.__namecall = newcclosure(function(self, ...)
    local m = getnamecallmethod() 
    local a = {...}
    if _G.MM2_Settings.SILENT_AIM_ENABLED and _G.isRoundActive and m == "FireServer" and tostring(self) == "Shoot" then
        local t = getCls() 
        if t and t.Character and t.Character:FindFirstChild("Head") then 
            a = t.Character.Head.Position 
            return oldN(self, unpack(a)) 
        end
    end 
    return oldN(self, ...)
end) 
setreadonly(gmt, true)

task.spawn(function()
    while task.wait(0.05) do
        if _G.isRoundActive and _G.MM2_Settings.SILENT_AIM_ENABLED then
            local c = LocalPlayer.Character 
            local g = c and c:FindFirstChild("Gun")
            if g and g:FindFirstChild("GunClient") then
                if g.GunClient:FindFirstChild("CantShoot") then pcall(function() g.GunClient.CantShoot:Destroy() end) end
                local se = g.GunClient:FindFirstChild("Shoot") 
                if se and se:IsA("RemoteEvent") then
                    g.Activated:Connect(function() 
                        local t = getCls() 
                        if t and t.Character and t.Character:FindFirstChild("Head") then 
                            pcall(function() se:FireServer(t.Character.Head.Position) end) 
                        end 
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if _G.MM2_Settings.FAST_RELOAD_ENABLED and _G.isRoundActive then
            local c = LocalPlayer.Character 
            local anim = c and c:FindFirstChild("Humanoid") and c.Humanoid:FindFirstChildOfClass("Animator")
            if anim then 
                for _, t in ipairs(anim:GetPlayingAnimationTracks()) do 
                    if t.Animation and (string.find(string.lower(t.Animation.Name), "reload") or string.find(string.lower(t.Name), "reload")) then 
                        t:AdjustSpeed(_G.MM2_Settings.RELOAD_SPEED_MULTIPLIER) 
                    end 
                end 
            end
        end
    end
end)

for _, child in ipairs(Workspace:GetChildren()) do if targetMaps[child.Name] and _G.setupMapESP then _G.setupMapESP(child) end end
Workspace.ChildAdded:Connect(function(child) if targetMaps[child.Name] and _G.setupMapESP then task.wait(0.5) _G.setupMapESP(child) end end)
 darkness = true
]]))()
