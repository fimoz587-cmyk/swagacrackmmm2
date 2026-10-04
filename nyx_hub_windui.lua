local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local genv = (getgenv and getgenv()) or _G
for _, k in ipairs({"NyxWind", "NyxSE", "NyxFull", "NyxFarm", "NyxAll", "NyxESP", "NyxSA", "NyxKA", "NyxFling"}) do
    if genv[k] then pcall(genv[k]) end
end

local CFG = {
    esp = true, box = true, skeleton = true, highlight = true, name = true, dist = true,
    tracer = true, health = true, gun = true, showInnocent = true, maxDist = 800, skelDist = 150,
    silent = true, wallbang = true, lead = 0.05, pingLead = true, wbDist = 3,
    farm = false, coinEsp = true, coinHighlight = true, coinTracer = true, coinTracerDist = 200,
    autoGun = true, autoKill = false,
    farmSpeed = 26, vSpeed = 45, depth = 22, gunSpeed = 150, pickDist = 400,
    killSpeed = 70, killRange = 250, hitDelay = 0.2, maxTries = 4,
    maxCoins = 40, coinRange = 1500, dangerDist = 30,
    flingMurd = true, flingSheriff = true, flingHero = true, flingAuto = false,
    spin = 80000, flingTime = 2.2, killVel = 180, flingCooldown = 6,
}
local COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff = Color3.fromRGB(60, 130, 255),
    Hero = Color3.fromRGB(255, 220, 60),
    Innocent = Color3.fromRGB(80, 255, 120),
}
local BLACK = Color3.new(0, 0, 0)
local GOLD = Color3.fromRGB(255, 215, 60)

local HAS_DRAW = typeof(Drawing) == "table" or typeof(Drawing) == "userdata"

local R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local R6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}
local UP, DOWN = Vector3.new(0, 3, 0), Vector3.new(0, 3.5, 0)
local PARTS = {"box", "hpBack", "hp", "tracer", "name", "dist"}

local conns, draws = {}, {}
local running = true
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

local ST = genv.NyxWindST or {}
genv.NyxWindST = ST
ST.rec = ST.rec or {}
ST.on, ST.wb, ST.aimPos, ST.wbDist = CFG.silent, false, nil, CFG.wbDist

if not genv.NyxWindHook and hookmetamethod and getnamecallmethod then
    genv.NyxWindHook = true
    local wrap = newcclosure or function(f) return f end
    local old
    old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
        local m = getnamecallmethod()
        if (m == "FireServer" or m == "InvokeServer") and not checkcaller()
           and typeof(self) == "Instance" then
            local par = self.Parent
            if par then
                local pn = par.Name
                if ST.on and ST.aimPos and m == "FireServer"
                   and self.Name == "Shoot" and pn == "Gun" then
                    local args = table.pack(...)
                    local n = 0
                    for i = 1, args.n do
                        if typeof(args[i]) == "CFrame" then
                            n += 1
                            if n == 1 and ST.wb then
                                local o = args[i].Position
                                local d = o - ST.aimPos
                                if d.Magnitude > ST.wbDist then
                                    o = ST.aimPos + d.Unit * ST.wbDist
                                end
                                args[i] = CFrame.lookAt(o, ST.aimPos)
                            elseif n == 2 then
                                args[i] = CFrame.new(ST.aimPos)
                                break
                            end
                        end
                    end
                    if setnamecallmethod then setnamecallmethod(m) end
                    return old(self, table.unpack(args, 1, args.n))
                elseif pn == "Events" then
                    local nm = self.Name
                    local l = ST.rec[nm]
                    if not l then
                        l = {}
                        ST.rec[nm] = l
                    end
                    l[#l + 1] = {a = table.pack(...), p = ST.myPos}
                    if #l > 6 then table.remove(l, 1) end
                end
            end
        end
        return old(self, ...)
    end))
end

local roles, E = {}, {}
local coins, visited, danger, circles, lines, hls = {}, {}, {}, {}, {}, {}
local cooldown, orig = {}, {}
local sheriffGone, got = false, 0
local drop, dropPos
local busy, holding, flinging, under, home = false, false, false, false, nil
local lastPick = 0

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

local function aliveChar(p)
    local c = p.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if c and h and h.Health > 0 and r then return c, r, h end
end

local function readData(tbl)
    if typeof(tbl) ~= "table" then return end
    for k, d in pairs(tbl) do
        local p = typeof(k) == "Instance" and k or Players:FindFirstChild(tostring(k))
        local role = typeof(d) == "table" and (d.Role or d.role)
        if p and role then roles[p] = role end
    end
end

local function resetRound()
    table.clear(roles)
    table.clear(visited)
    table.clear(danger)
    table.clear(cooldown)
    sheriffGone, got, drop, dropPos = false, 0, nil, nil
    for _, e in pairs(E) do e.lastRole = nil end
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

local function partOf(i)
    if i:IsA("BasePart") then return i end
    return i:FindFirstChildWhichIsA("BasePart", true)
end

local function vecOf(i)
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
    drop, dropPos, sheriffGone = i, vecOf(i), true
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

local function isCoin(i)
    return i:IsA("BasePart") and (i.Name == "Coin_Server" or (i.Parent and i.Parent.Name == "CoinContainer"))
end

local function addCoin(i)
    if coins[i] or not isCoin(i) then return end
    coins[i] = true
    if HAS_DRAW then
        local c = Drawing.new("Circle")
        c.Radius, c.Filled, c.NumSides, c.Transparency, c.Visible = 5, true, 12, 0.9, false
        c.Color = GOLD
        circles[i] = c
        local l = Drawing.new("Line")
        l.Thickness, l.Transparency, l.Visible = 1, 0.8, false
        l.Color = GOLD
        lines[i] = l
    end
    local hl = Instance.new("Highlight")
    hl.Name = "CoinESP"
    hl.FillColor = GOLD
    hl.OutlineColor = Color3.fromRGB(255, 240, 150)
    hl.FillTransparency = 0.4
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = CFG.coinHighlight
    hl.Parent = i
    hls[i] = hl
end

local function removeCoin(i)
    if not coins[i] then return end
    coins[i], visited[i], danger[i] = nil, nil, nil
    if circles[i] then
        pcall(function() circles[i]:Remove() end)
        circles[i] = nil
    end
    if lines[i] then
        pcall(function() lines[i]:Remove() end)
        lines[i] = nil
    end
    if hls[i] then
        pcall(function() hls[i]:Destroy() end)
        hls[i] = nil
    end
end

connect(workspace.DescendantAdded, function(i)
    addCoin(i)
    trackDrop(i)
end)
connect(workspace.DescendantRemoving, removeCoin)
task.spawn(function()
    local n = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        addCoin(d)
        trackDrop(d)
        n += 1
        if n % 2000 == 0 then task.wait() end
    end
end)

task.spawn(function()
    while running do
        pcall(function()
            ST.ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        end)
        task.wait(0.5)
    end
end)
