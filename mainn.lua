local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local genv = (getgenv and getgenv()) or _G
if genv.NyxFarm then pcall(genv.NyxFarm) end

local CFG = {
    farm = false, coinEsp = true, autoGun = true, autoKill = false,
    coinHighlight = true, coinTracer = true, coinTracerDist = 200,
    farmSpeed = 26, vSpeed = 45, depth = 22,
    gunSpeed = 150, pickDist = 400,
    killSpeed = 70, killRange = 250, hitDelay = 0.2, maxTries = 4,
    maxCoins = 40, coinRange = 1500, dangerDist = 30,
}

local HAS_DRAW = typeof(Drawing) == "table" or typeof(Drawing) == "userdata"

local ST = genv.NyxFarmST or {}
genv.NyxFarmST = ST
ST.rec = ST.rec or {}

if not genv.NyxFarmHook and hookmetamethod and getnamecallmethod then
    genv.NyxFarmHook = true
    local wrap = newcclosure or function(f) return f end
    local old
    old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
        local m = getnamecallmethod()
        if (m == "FireServer" or m == "InvokeServer") and not checkcaller()
           and typeof(self) == "Instance" then
            local par = self.Parent
            if par and par.Name == "Events" then
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
        return old(self, ...)
    end))
end

local conns, running = {}, true
local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

local roles, coins, visited, danger, circles, lines, hls = {}, {}, {}, {}, {}, {}, {}
local got, drop = 0, nil
local busy, holding, under, home = false, false, false, nil
local orig = {}
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
            connect(r.OnClientEvent, function()
                table.clear(roles)
                table.clear(visited)
                table.clear(danger)
                got = 0
            end)
        elseif r:IsA("RemoteFunction") and r.Name == "GetPlayerData" then
            task.spawn(function()
                local ok, res = pcall(function() return r:InvokeServer() end)
                if ok then readData(res) end
            end)
        end
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
        c.Color = Color3.fromRGB(255, 215, 60)
        circles[i] = c
        local l = Drawing.new("Line")
        l.Thickness, l.Transparency, l.Visible = 1, 0.8, false
        l.Color = Color3.fromRGB(255, 215, 60)
        lines[i] = l
    end
    local hl = Instance.new("Highlight")
    hl.Name = "CoinESP"
    hl.FillColor = Color3.fromRGB(255, 215, 60)
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

local function hold(on)
    local c = lp.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if on then
        holding = true
        if hrp and not hrp:FindFirstChild("NyxHold") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "NyxHold"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
        end
        if hum then hum.PlatformStand = true end
    else
        holding = false
        if hrp then
            local bv = hrp:FindFirstChild("NyxHold")
            if bv then bv:Destroy() end
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
        if hum then hum.PlatformStand = false end
        for part, v in pairs(orig) do
            if part.Parent then part.CanCollide = v end
        end
        table.clear(orig)
    end
end

connect(RunService.Stepped, function()
    if not holding then return end
    local c = lp.Character
    if not c then return end
    for _, p in ipairs(c:GetChildren()) do
        if p:IsA("BasePart") then
            if orig[p] == nil then orig[p] = p.CanCollide end
            p.CanCollide = false
        end
    end
end)

local function goTo(cf, speed, keep)
    local hrp, hum = myHrp()
    if not hrp or not hum or hum.Health <= 0 then return false end
    if not holding then hold(true) end
    local t = math.max((hrp.Position - cf.Position).Magnitude / speed, 0.03)
    local tw = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = cf})
    local done = false
    local cc = tw.Completed:Connect(function() done = true end)
    tw:Play()
    local s = tick()
    while not done and tick() - s < t + 1 and running do
        if hum.Health <= 0 or (keep and not keep()) then break end
        task.wait()
    end
    tw:Cancel()
    cc:Disconnect()
    return done
end

local function surface()
    local hrp, hum = myHrp()
    if hrp and hum and hum.Health > 0 and under and home then
        goTo(home, CFG.vSpeed + 40, nil)
    end
    hold(false)
    under = false
end

local function murdererHrp()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local c = p.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if h and h.Health > 0 and r and (roles[p] == "Murderer" or c:FindFirstChild("Knife")) then
                return r
            end
        end
    end
end

local function gunWanted()
    if not CFG.autoGun then return false end
    local hrp, hum = myHrp()
    if not hrp or not hum or hum.Health <= 0 then return false end
    if not (lp.Character and lp.Character.Parent == workspace) then return false end
    if not (drop and drop.Parent) then return false end
    if roles[lp] == nil or roles[lp] == "Murderer" or hasKnife() then return false end
    if tick() - lastPick < 1.5 then return false end
    local part = posOf(drop)
    return part ~= nil and (part.Position - hrp.Position).Magnitude <= CFG.pickDist
end

local function pickGun()
    if busy or not gunWanted() then return end
    local hrp, hum = myHrp()
    local part = posOf(drop)
    if not part then return end
    busy = true
    lastPick = tick()
    local back = (under and home) or hrp.CFrame
    local ok = goTo(CFrame.new(part.Position + Vector3.new(0, 1.5, 0)), CFG.gunSpeed, nil)
    if ok then
        touch(hrp, part)
        task.wait(0.15)
    end
    if hum.Health > 0 and hrp.Parent then
        goTo(back, CFG.gunSpeed, nil)
        hold(false)
    end
    under = false
    busy = false
end

local function nearestCoin(hrp)
    local best, bd = nil, CFG.coinRange
    local now = tick()
    for c in pairs(coins) do
        if c.Parent and not visited[c] and not (danger[c] and danger[c] > now) then
            local d = (c.Position - hrp.Position).Magnitude
            if d < bd then best, bd = c, d end
        end
    end
    return best
end

local function farmStep()
    local hrp, hum = myHrp()
    if busy or not hrp or not hum or hum.Health <= 0 then return false end
    if got >= CFG.maxCoins then return true end
    local coin = nearestCoin(hrp)
    if not coin then return true end
    busy = true
    if not under then home = hrp.CFrame end
    local pos = coin.Position
    local ug = math.min(hrp.Position.Y, pos.Y) - CFG.depth
    local function keep()
        return CFG.farm and coin.Parent ~= nil and not gunWanted()
    end
    local ok = goTo(CFrame.new(hrp.Position.X, ug, hrp.Position.Z), CFG.vSpeed, keep)
    if ok then
        under = true
        ok = goTo(CFrame.new(pos.X, ug, pos.Z), CFG.farmSpeed, keep)
    end
    if ok then
        local waited = 0
        local m = murdererHrp()
        while m and (m.Position - pos).Magnitude < CFG.dangerDist and waited < 2 and keep() do
            task.wait(0.1)
            waited += 0.1
            m = murdererHrp()
        end
        if m and (m.Position - pos).Magnitude < CFG.dangerDist then
            danger[coin] = tick() + 8
            ok = false
        end
    end
    if ok then
        ok = goTo(CFrame.new(pos.X, pos.Y + 1.5, pos.Z), CFG.vSpeed, keep)
    end
    if ok then
        under = false
        touch(hrp, coin)
        task.wait(0.12)
        home = hrp.CFrame
        visited[coin] = true
        if not coin.Parent then got += 1 end
        goTo(CFrame.new(hrp.Position.X, ug, hrp.Position.Z), CFG.vSpeed + 20, nil)
        under = true
    end
    busy = false
    return false
end

local function aliveChar(p)
    local c = p.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if c and h and h.Health > 0 and r then return c, r, h end
end

local function charOf(i)
    if i:IsA("Model") and i:FindFirstChildOfClass("Humanoid") then return i end
    local m = i:FindFirstAncestorOfClass("Model")
    if m and m:FindFirstChildOfClass("Humanoid") then return m end
end

local function pickRec(list)
    if not list or #list == 0 then return end
    for i = #list, 1, -1 do
        local e = list[i]
        for k = 1, e.a.n do
            local v = e.a[k]
            if typeof(v) == "Instance" then
                local ch = charOf(v)
                if (ch and ch ~= lp.Character) or (v:IsA("Player") and v ~= lp) then return e end
            end
        end
    end
    return list[#list]
end

local function sub(a, tp, tc, th, tr, rp, cp)
    local t = typeof(a)
    if t == "Instance" then
        if a:IsA("Player") then
            return a == lp and a or tp
        end
        local ch = charOf(a)
        if ch and ch ~= lp.Character then
            if a == ch then return tc end
            if a:IsA("Humanoid") then return th end
            return tc:FindFirstChild(a.Name) or tr
        end
        return a
    elseif t == "Vector3" then
        if rp and (a - rp).Magnitude < 8 then return cp end
        return tr.Position
    elseif t == "CFrame" then
        if rp and (a.Position - rp).Magnitude < 8 then return CFrame.lookAt(cp, tr.Position) end
        return CFrame.new(tr.Position)
    end
    return a
end

local function replay(r, rec, p, tc, th, tr, cp)
    local a, args = rec.a, {}
    for i = 1, a.n do args[i] = sub(a[i], p, tc, th, tr, rec.p, cp) end
    if r:IsA("RemoteEvent") then
        r:FireServer(table.unpack(args, 1, a.n))
    else
        r:InvokeServer(table.unpack(args, 1, a.n))
    end
end

local function killStep()
    local hrp, hum = myHrp()
    if busy or not hrp or not hum or hum.Health <= 0 then return end
    local knife = hasKnife()
    if not knife then return end
    local function nearest()
        local bp, bc, br, bh, bd = nil, nil, nil, nil, CFG.killRange
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local c, r, h = aliveChar(p)
                if c then
                    local d = (r.Position - hrp.Position).Magnitude
                    if d < bd then bp, bc, br, bh, bd = p, c, r, h, d end
                end
            end
        end
        return bp, bc, br, bh
    end
    if not nearest() then return end
    busy = true
    local back = (under and home) or hrp.CFrame
    if knife.Parent ~= lp.Character then
        hum:EquipTool(knife)
        task.wait(0.15)
    end
    knife = lp.Character and lp.Character:FindFirstChild("Knife")
    if knife then
        local handle = knife:FindFirstChild("Handle")
        local ev = knife:FindFirstChild("Events")
        local recorded = {}
        if ev then
            for _, r in ipairs(ev:GetChildren()) do
                local rec = pickRec(ST.rec[r.Name])
                if rec and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
                    recorded[#recorded + 1] = {r, rec}
                end
            end
        end
        local guard = 0
        while CFG.autoKill and guard < 8 and hum.Health > 0 and knife.Parent == lp.Character do
            guard += 1
            local p, c, r, h = nearest()
            if not p then break end
            local tries = 0
            while c and tries < CFG.maxTries and CFG.autoKill and knife.Parent == lp.Character and hum.Health > 0 do
                goTo(r.CFrame * CFrame.new(0, 0, 2.5), CFG.killSpeed, function() return CFG.autoKill end)
                knife:Activate()
                if handle then touch(handle, r) end
                local cp = hrp.Position
                for _, it in ipairs(recorded) do
                    task.spawn(pcall, replay, it[1], it[2], p, c, h, r, cp)
                end
                task.wait(CFG.hitDelay)
                tries += 1
                c, r, h = aliveChar(p)
            end
        end
    end
    if hum.Health > 0 and hrp.Parent then
        goTo(back, CFG.killSpeed + 30, nil)
        hold(false)
    end
    under = false
    busy = false
end

task.spawn(function()
    while running do
        pcall(function()
            if gunWanted() then pickGun() end
            if CFG.autoKill and (roles[lp] == "Murderer" or hasKnife()) then killStep() end
            local idle = true
            if CFG.farm then idle = farmStep() end
            if holding and not busy and (not CFG.farm or idle) then surface() end
        end)
        task.wait(0.1)
    end
end)

connect(RunService.RenderStepped, function()
    cam = workspace.CurrentCamera
    local mh = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    ST.myPos = mh and mh.Position
    if not cam then return end
    local hlOn = CFG.coinEsp and CFG.coinHighlight
    for c, hl in pairs(hls) do
        hl.Enabled = hlOn and not visited[c]
    end
    if not HAS_DRAW then return end
    local vp = cam.ViewportSize
    local origin = Vector2.new(vp.X / 2, vp.Y)
    local camPos = cam.CFrame.Position
    for c, circle in pairs(circles) do
        local line = lines[c]
        if CFG.coinEsp and c.Parent and not visited[c] then
            local pt, vis = cam:WorldToViewportPoint(c.Position)
            circle.Visible = vis
            if vis then circle.Position = Vector2.new(pt.X, pt.Y) end
            if line then
                local near = (c.Position - camPos).Magnitude <= CFG.coinTracerDist
                line.Visible = vis and CFG.coinTracer and near
                if line.Visible then
                    line.From = origin
                    line.To = Vector2.new(pt.X, pt.Y)
                end
            end
        else
            circle.Visible = false
            if line then line.Visible = false end
        end
    end
end)

connect(lp.CharacterAdded, function()
    holding, under, home = false, false, nil
    table.clear(orig)
end)

local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "NyxFarm", false
local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not ok or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local function mkBtn(label, key, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 120, 0, 34)
    b.Position = UDim2.new(1, -140, 0.5, y)
    b.Font, b.TextSize = Enum.Font.GothamBold, 13
    b.TextColor3, b.BackgroundColor3 = Color3.new(1, 1, 1), Color3.fromRGB(40, 55, 95)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local function refresh() b.Text = label .. ": " .. (CFG[key] and "ON" or "OFF") end
    refresh()
    b.Parent = gui
    connect(b.Activated, function()
        CFG[key] = not CFG[key]
        refresh()
    end)
end

mkBtn("Farm", "farm", -120)
mkBtn("Coin ESP", "coinEsp", -80)
mkBtn("Coin HL", "coinHighlight", -40)
mkBtn("Coin Line", "coinTracer", 0)
mkBtn("Auto Gun", "autoGun", 40)
mkBtn("Auto Kill", "autoKill", 80)

genv.NyxFarm = function()
    running = false
    CFG.farm, CFG.autoGun, CFG.autoKill = false, false, false
    local hrp = myHrp()
    if hrp and under and home then hrp.CFrame = home end
    hold(false)
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for _, c in pairs(circles) do pcall(function() c:Remove() end) end
    for _, l in pairs(lines) do pcall(function() l:Remove() end) end
    for _, h in pairs(hls) do pcall(function() h:Destroy() end) end
    gui:Destroy()
    genv.NyxFarm = nil
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local genv = (getgenv and getgenv()) or _G
for _, k in ipairs({"NyxSE", "NyxFull", "NyxFarm", "NyxAll", "NyxESP", "NyxSA", "NyxKA"}) do
    if genv[k] then pcall(genv[k]) end
end

local CFG = {
    esp = true, box = true, skeleton = true, highlight = true, name = true, dist = true,
    tracer = true, health = true, gun = true, maxDist = 800, skelDist = 150,
    silent = true, wallbang = true, lead = 0.05, pingLead = true, wbDist = 3,
}
local COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff = Color3.fromRGB(60, 130, 255),
    Hero = Color3.fromRGB(255, 220, 60),
    Innocent = Color3.fromRGB(80, 255, 120),
}
local BLACK = Color3.new(0, 0, 0)
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

local ST = genv.NyxSEST or {}
genv.NyxSEST = ST
ST.on, ST.wb, ST.aimPos, ST.wbDist = CFG.silent, false, nil, CFG.wbDist

if not genv.NyxSEHook and hookmetamethod and getnamecallmethod then
    genv.NyxSEHook = true
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
            end
        end
        return old(self, ...)
    end))
end

local roles, E = {}, {}
local sheriffGone = false
local drop, dropPos

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
    sheriffGone, drop, dropPos = false, nil, nil
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

connect(workspace.DescendantAdded, trackDrop)
task.spawn(function()
    local n = 0
    for _, d in ipairs(workspace:GetDescendants()) do
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
local function proj(part)
    local v = PC[part]
    if v == nil then
        local pt, on = cam:WorldToViewportPoint(part.Position)
        v = on and Vector2.new(pt.X, pt.Y) or false
        PC[part] = v
    end
    return v
end

local foundTarget

local function step(p, e, camPos, vp, now)
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
    if role == "Murderer" then foundTarget = hrp end

    local dist = (camPos - pos).Magnitude
    if not CFG.esp or dist > CFG.maxDist then
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
            local a, d = proj(b[1]), proj(b[2])
            if a and d then
                l.Color, l.From, l.To = color, a, d
                on = true
            end
        end
        if on ~= e.lv[i] then l.Visible = on; e.lv[i] = on end
    end
end

local gunTxt = HAS_DRAW and newText() or nil
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude

connect(RunService.RenderStepped, function()
    cam = workspace.CurrentCamera
    if not cam then return end
    local camPos, vp, now = cam.CFrame.Position, cam.ViewportSize, tick()

    foundTarget = nil
    for p, e in pairs(E) do
        pcall(step, p, e, camPos, vp, now)
    end

    ST.on, ST.wbDist = CFG.silent, CFG.wbDist
    local t = foundTarget
    if t then
        local v = t.AssemblyLinearVelocity
        local lead = (CFG.pingLead and (ST.ping or 0.08) or 0) + CFG.lead
        ST.aimPos = t.Position + Vector3.new(v.X, 0, v.Z) * lead
        local mine = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local blocked = false
        if CFG.wallbang and mine then
            rp.FilterDescendantsInstances = {lp.Character, t.Parent}
            blocked = workspace:Raycast(mine.Position, t.Position - mine.Position, rp) ~= nil
        end
        ST.wb = blocked
    else
        ST.aimPos, ST.wb = nil, false
    end

    if drop and drop.Parent then dropPos = vecOf(drop) or dropPos end
    if gunTxt then
        if CFG.esp and drop and drop.Parent and dropPos and CFG.gun then
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

local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "NyxSE", false
local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not ok or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local function mkBtn(label, key, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 120, 0, 34)
    b.Position = UDim2.new(1, -140, 0.5, y)
    b.Font, b.TextSize = Enum.Font.GothamBold, 13
    b.TextColor3, b.BackgroundColor3 = Color3.new(1, 1, 1), Color3.fromRGB(40, 55, 95)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local function refresh() b.Text = label .. ": " .. (CFG[key] and "ON" or "OFF") end
    refresh()
    b.Parent = gui
    connect(b.Activated, function()
        CFG[key] = not CFG[key]
        refresh()
    end)
end

mkBtn("ESP", "esp", -60)
mkBtn("Silent", "silent", -20)
mkBtn("WallBang", "wallbang", 20)

genv.NyxSE = function()
    running = false
    ST.on, ST.aimPos, ST.wb = false, nil, false
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for _, e in pairs(E) do
        if e.cc then pcall(function() e.cc:Disconnect() end) end
        if e.hl then pcall(function() e.hl:Destroy() end) end
    end
    for _, d in ipairs(draws) do pcall(function() d:Remove() end) end
    local g = drop and drop:FindFirstChild("GunESP")
    if g then g:Destroy() end
    gui:Destroy()
    genv.NyxSE = nil
end
