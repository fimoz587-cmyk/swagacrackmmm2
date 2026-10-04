local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer

local function sig(name, fallback)
    local ok, v = pcall(function() return RunService[name] end)
    if ok and v then return v end
    return RunService[fallback]
end
local PRE_RENDER = sig("PreRender", "RenderStepped")
local PRE_SIM = sig("PreSimulation", "Stepped")
local cam = workspace.CurrentCamera

local genv = (getgenv and getgenv()) or _G
for _, k in ipairs({"NyxWind", "NyxSE", "NyxFull", "NyxFarm", "NyxAll", "NyxESP", "NyxSA", "NyxKA", "NyxFling"}) do
    if genv[k] then pcall(genv[k]) end
end

local CFG = {
    esp = true, box = true, skeleton = true, highlight = true, name = true, dist = true,
    tracer = true, health = true, gun = true, showInnocent = true, maxDist = 800, skelDist = 150,
    silent = true, wallbang = true, lead = 0.05, pingLead = true, wbDist = 3,
    farm = false, coinEsp = true, coinHighlight = true, coinTracer = true, coinTracerDist = 200, farmUnder = true,
    autoGun = true, autoKill = false,
    farmSpeed = 26, vSpeed = 45, depth = 22, gunSpeed = 150, pickDist = 400,
    killSpeed = 70, killRange = 250, hitDelay = 0.2, maxTries = 4,
    maxCoins = 40, coinRange = 1500, dangerDist = 30,
    bhop = false, bhopSpeed = 30, spinOn = false, spinSpeed = 200,
    killSnd = true, gunSnd = "SFX Hit", gunVol = 2.5, knifeSnd = "Among Us Kill", knifeVol = 1.5,
    autoShoot = false, shootBtn = false, shootDelay = 1.2, ghostTransp = 0.5, pickTime = 0.45, shootMax = 600,
    aa = false, aaMode = "Spin", aaPart = "Neck", aaSpeed = 18,
    shaders = false, blackSky = true, fogOn = true, fog = 350, density = 0.45,
    bloom = 1.6, contrast = 0.3, sat = 0.4, dof = 0.12, bright = 1.6,
    trail = false, trailLife = 0.8, trailTransp = 0.72, trailSmoke = true,
    shotTrail = false, shotLife = 1.2,
    aura = false, auraSpeed = 1.2, wingPreset = "Angel", wingParticles = true,
    noclip = false, fly = false, flySpeed = 60, wsOn = false, walkSpeed = 24, jpOn = false, jumpPower = 70,
    xray = false, xrayTransp = 0.5,
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
local busy, holding, under, home = false, false, false, nil
local lastPick, lastShot, lastGunFire = 0, 0, 0
local inv = {on = false, real = nil, clone = nil}
local picking = false
local ping = 0.08
local FX = {}

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
    if not CFG.esp or (role == "Innocent" and not CFG.showInnocent) or dist > CFG.maxDist then
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

connect(PRE_RENDER, function()
    cam = workspace.CurrentCamera
    if not cam then return end
    local camPos, vp, now = cam.CFrame.Position, cam.ViewportSize, tick()
    local mh = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    ST.myPos = mh and mh.Position

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
        local blocked = false
        if CFG.wallbang and mh then
            rp.FilterDescendantsInstances = {lp.Character, t.Parent}
            blocked = workspace:Raycast(mh.Position, t.Position - mh.Position, rp) ~= nil
        end
        ST.wb = blocked
    else
        ST.aimPos, ST.wb = nil, false
    end

    if drop and drop.Parent then dropPos = vecOf(drop) or dropPos end
    if gunTxt then
        if CFG.esp and CFG.gun and drop and drop.Parent and dropPos then
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

    local hlOn = CFG.coinEsp and CFG.coinHighlight
    for c, hl in pairs(hls) do
        hl.Enabled = hlOn and not visited[c]
    end
    if HAS_DRAW then
        local origin = Vector2.new(vp.X / 2, vp.Y)
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
    end
end)

local Lighting = game:GetService("Lighting")

connect(PRE_SIM, function()
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

local function seen()
    if inv.on and inv.clone then return inv.clone end
    return lp.Character
end

local function restartAnimate(char)
    local a = char and char:FindFirstChild("Animate")
    if a then
        a.Disabled = true
        task.wait(0.05)
        a.Disabled = false
    end
end

local function resetInvis()
    local clone = inv.clone
    inv.on, inv.real, inv.clone = false, nil, nil
    if clone then pcall(function() clone:Destroy() end) end
end

local function goInvisible()
    if inv.on or busy then return false end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    if holding then surface() end
    char.Archivable = true
    local clone = char:Clone()
    if not clone then return false end
    local c0 = workspace.CurrentCamera
    local camCF = c0.CFrame
    local cf = hrp.CFrame
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Transparency = (d.Name == "HumanoidRootPart") and 1 or CFG.ghostTransp
        end
    end
    hrp.CFrame = CFrame.new(0, math.pi * 1000000, 0)
    task.wait(0.2)
    inv.on, inv.real, inv.clone = true, char, clone
    char.Parent = Lighting
    clone.Parent = workspace
    local chrp = clone:FindFirstChild("HumanoidRootPart")
    if chrp then chrp.CFrame = cf end
    lp.Character = clone
    local chum = clone:FindFirstChildOfClass("Humanoid")
    if chum then c0.CameraSubject = chum end
    c0.CFrame = camCF
    restartAnimate(clone)
    return true
end

local function goVisible()
    if not inv.on then return end
    local real, clone = inv.real, inv.clone
    local chrp = clone and clone:FindFirstChild("HumanoidRootPart")
    local cf = chrp and chrp.CFrame
    inv.on, inv.real, inv.clone = false, nil, nil
    if clone then pcall(function() clone:Destroy() end) end
    if real and real.Parent then
        local rhrp = real:FindFirstChild("HumanoidRootPart")
        local rh = real:FindFirstChildOfClass("Humanoid")
        if rhrp and cf then
            rhrp.CFrame = cf
            rhrp.AssemblyLinearVelocity = Vector3.zero
        end
        real.Parent = workspace
        lp.Character = real
        if rh then
            workspace.CurrentCamera.CameraSubject = rh
            rh.PlatformStand = false
            local an = rh:FindFirstChildOfClass("Animator")
            if an then
                for _, tr in ipairs(an:GetPlayingAnimationTracks()) do tr:Stop(0) end
            end
            rh:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        restartAnimate(real)
    end
end

connect(lp.CharacterAdded, function(c)
    if inv.on and c ~= inv.clone then resetInvis() end
    holding, under, home = false, false, nil
    table.clear(orig)
end)

local function pickReady()
    if not CFG.autoGun then return false end
    if not (drop and drop.Parent) then return false end
    if roles[lp] == nil or roles[lp] == "Murderer" or hasKnife() then return false end
    return tick() - lastPick >= 2
end

local function pickGun()
    if busy or picking or not pickReady() then return end
    local part = partOf(drop)
    if not part then return end
    local char = inv.on and inv.real or lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    if not inv.on and (part.Position - hrp.Position).Magnitude > CFG.pickDist then return end
    picking, busy = true, true
    lastPick = tick()
    if inv.on then
        local back = hrp.CFrame
        local moved = char.Parent ~= workspace
        if moved then char.Parent = workspace end
        local s = tick()
        while tick() - s < CFG.pickTime and drop and drop.Parent and char.Parent do
            hrp.CFrame = part.CFrame + Vector3.new(0, 2.5, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
            touch(hrp, part)
            RunService.Heartbeat:Wait()
        end
        for _ = 1, 8 do
            if not hrp.Parent then break end
            hrp.CFrame = back
            hrp.AssemblyLinearVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
        end
        task.wait(0.25)
        if moved and inv.on and inv.real == char and char.Parent then char.Parent = Lighting end
    else
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
    end
    picking, busy = false, false
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
    if inv.on then return true end
    local hrp, hum = myHrp()
    if busy or not hrp or not hum or hum.Health <= 0 then return false end
    if got >= CFG.maxCoins then return true end
    local coin = nearestCoin(hrp)
    if not coin then return true end
    busy = true
    local okRun = pcall(function()
        if not under then home = hrp.CFrame end
        local pos = coin.Position
        local function keep()
            return CFG.farm and coin.Parent ~= nil and not pickReady()
        end
        local ug = math.min(hrp.Position.Y, pos.Y) - CFG.depth
        local ok
        if CFG.farmUnder then
            ok = goTo(CFrame.new(hrp.Position.X, ug, hrp.Position.Z), CFG.vSpeed, keep)
            if ok then
                under = true
                ok = goTo(CFrame.new(pos.X, ug, pos.Z), CFG.farmSpeed, keep)
            end
        else
            under = false
            ok = goTo(CFrame.new(pos), CFG.farmSpeed, keep)
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
        if ok and CFG.farmUnder then
            ok = goTo(CFrame.new(pos), CFG.vSpeed, keep)
        end
        if ok then
            under = false
            touch(hrp, coin)
            task.wait(0.15)
            home = hrp.CFrame
            cooldown[coin] = (cooldown[coin] or 0) + 1
            if not coin.Parent then got += 1 end
            if not coin.Parent or cooldown[coin] >= 3 then visited[coin] = true end
            if CFG.farmUnder then
                goTo(CFrame.new(hrp.Position.X, ug, hrp.Position.Z), CFG.vSpeed + 20, nil)
                under = true
            end
        end
    end)
    busy = false
    if not okRun then task.wait(0.3) end
    return false
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

local function sub(a, tp, tc, th, tr, rpos, cp)
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
        if rpos and (a - rpos).Magnitude < 8 then return cp end
        return tr.Position
    elseif t == "CFrame" then
        if rpos and (a.Position - rpos).Magnitude < 8 then return CFrame.lookAt(cp, tr.Position) end
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
    if inv.on then return end
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

local function findGun()
    local places = {}
    if inv.on and inv.real then places[#places + 1] = inv.real end
    if not inv.on and lp.Character then places[#places + 1] = lp.Character end
    local bp = lp:FindFirstChild("Backpack")
    if bp then places[#places + 1] = bp end
    for _, pl in ipairs(places) do
        for _, t in ipairs(pl:GetChildren()) do
            if t:IsA("Tool") then
                local r = t:FindFirstChild("Shoot")
                if r and r:IsA("RemoteEvent") then return t, r end
            end
        end
    end
end

local function autoShootStep()
    if roles[lp] == "Murderer" or picking then return end
    local vis = seen()
    local mhrp = vis and vis:FindFirstChild("HumanoidRootPart")
    local hum = vis and vis:FindFirstChildOfClass("Humanoid")
    if not mhrp or not hum or hum.Health <= 0 then return end
    local gun, remote = findGun()
    if not gun then return end
    local t = murdererHrp()
    if not t then return end
    local origin0 = mhrp.Position + Vector3.new(0, 1.5, 0)
    if (t.Position - origin0).Magnitude > CFG.shootMax then return end
    local v = t.AssemblyLinearVelocity
    local lead = (CFG.pingLead and (ST.ping or 0.08) or 0) + CFG.lead
    local aim = t.Position + Vector3.new(v.X, 0, v.Z) * lead
    local origin = origin0
    rp.FilterDescendantsInstances = {vis, t.Parent}
    local blocked = workspace:Raycast(origin0, aim - origin0, rp) ~= nil
    if blocked then
        if not CFG.wallbang then return end
        local d = origin0 - aim
        origin = aim + d.Unit * CFG.wbDist
    end
    lastShot = tick()
    lastGunFire = tick()
    remote:FireServer(CFrame.lookAt(origin, aim), CFrame.new(aim))
    if FX.shot and CFG.shotTrail then FX.shot(origin, aim) end
end

connect(RunService.Heartbeat, function()
    if inv.on and (not inv.real or not inv.real.Parent or not inv.clone or not inv.clone.Parent) then
        resetInvis()
    end
    if CFG.autoShoot and tick() - lastShot >= CFG.shootDelay then
        lastShot = tick()
        task.spawn(function() pcall(autoShootStep) end)
    end
end)

local aaS = {}
local rndSign, rndT = 1, 0

local function aaJoint(c, part)
    if part == "Neck" or part == "Head" then
        local h = c:FindFirstChild("Head")
        local j = h and h:FindFirstChild("Neck")
        if j then return j end
        local t = c:FindFirstChild("Torso")
        return t and t:FindFirstChild("Neck")
    elseif part == "UpperTorso" then
        local u = c:FindFirstChild("UpperTorso")
        return u and u:FindFirstChild("Waist")
    end
    local r = c:FindFirstChild("HumanoidRootPart")
    return r and r:FindFirstChild("RootJoint")
end

local function aaRestore()
    local s = aaS
    if s.j and s.j.Parent then
        s.j.C0, s.j.C1 = s.c0, s.c1
    end
    aaS = {}
end

local function aaStep(now)
    local c = lp.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not CFG.aa or not c or not hum or hum.Health <= 0 then
        if aaS.j then aaRestore() end
        return
    end
    local part = CFG.aaPart
    if aaS.j and (aaS.c ~= c or aaS.part ~= part or not aaS.j.Parent) then aaRestore() end
    if not aaS.j then
        local j = aaJoint(c, part)
        if not j then return end
        aaS = {j = j, c = c, part = part, c0 = j.C0, c1 = j.C1}
    end
    local mode, lim = CFG.aaMode, math.rad(85)
    local x, y = 0, 0
    if mode == "Spin" then
        y = (now * CFG.aaSpeed) % (math.pi * 2)
    elseif mode == "Yaw" then
        y = math.pi + math.rad(math.random(-40, 40))
    elseif mode == "Pitch" then
        x = (math.floor(now * 12) % 2 == 0) and lim or -lim
    elseif mode == "Random" then
        if now - rndT > 0.08 then
            rndT = now
            rndSign = math.random(2) == 1 and 1 or -1
        end
        x = lim * rndSign
    elseif mode == "Up" then
        x = lim
    else
        x = -lim
    end
    local r = CFrame.Angles(x, y, 0)
    local j = aaS.j
    if part == "Head" then
        j.C1 = CFrame.new(aaS.c1.Position) * r:Inverse() * aaS.c1.Rotation
    else
        j.C0 = CFrame.new(aaS.c0.Position) * r * aaS.c0.Rotation
    end
end

connect(RunService.Heartbeat, function()
    pcall(aaStep, tick())
end)

task.spawn(function()
    while running do
        pcall(function()
            if CFG.autoGun then pickGun() end
            if CFG.autoKill and (roles[lp] == "Murderer" or hasKnife()) then killStep() end
            local idle = true
            if CFG.farm then idle = farmStep() end
            if holding and not busy and (not CFG.farm or idle) then surface() end
        end)
        task.wait(0.1)
    end
end)

local Debris = game:GetService("Debris")

local look = {
    tint = Color3.fromRGB(190, 215, 255),
    amb = Color3.fromRGB(40, 80, 170),
    fogColor = Color3.fromRGB(25, 70, 200),
}
local PRESETS = {
    BlueFog = {tint = Color3.fromRGB(190, 215, 255), amb = Color3.fromRGB(40, 80, 170),
               fogColor = Color3.fromRGB(25, 70, 200), bloom = 1.6, sat = 0.4, fog = 350, density = 0.45},
    Neon = {tint = Color3.fromRGB(215, 190, 255), amb = Color3.fromRGB(70, 60, 110),
            fogColor = Color3.fromRGB(90, 40, 200), bloom = 1.8, sat = 0.5, fog = 500, density = 0.3},
    Ice = {tint = Color3.fromRGB(200, 235, 255), amb = Color3.fromRGB(90, 130, 190),
           fogColor = Color3.fromRGB(120, 180, 255), bloom = 1.0, sat = 0.2, fog = 250, density = 0.6},
    Abyss = {tint = Color3.fromRGB(150, 190, 255), amb = Color3.fromRGB(15, 35, 90),
             fogColor = Color3.fromRGB(5, 20, 80), bloom = 1.2, sat = 0.3, fog = 150, density = 0.7},
}
local PRESET_NAMES = {"BlueFog", "Neon", "Ice", "Abyss"}

local sh = {fx = nil, saved = nil, removed = {}}

local function shadersOn()
    if sh.fx then return end
    sh.saved = {
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness, ExposureCompensation = Lighting.ExposureCompensation,
        FogColor = Lighting.FogColor, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd,
        ClockTime = Lighting.ClockTime,
    }
    sh.removed = {}
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
            sh.removed[#sh.removed + 1] = v
            v.Parent = nil
        end
    end
    local fx = {}
    fx.bloom = Instance.new("BloomEffect", Lighting)
    fx.cc = Instance.new("ColorCorrectionEffect", Lighting)
    fx.rays = Instance.new("SunRaysEffect", Lighting)
    fx.dof = Instance.new("DepthOfFieldEffect", Lighting)
    fx.atm = Instance.new("Atmosphere", Lighting)
    fx.sky = Instance.new("Sky")
    fx.sky.StarCount = 0
    fx.sky.CelestialBodiesShown = false
    sh.fx = fx
end

local function shadersApply()
    local fx = sh.fx
    if not fx then return end
    fx.bloom.Intensity, fx.bloom.Size, fx.bloom.Threshold = CFG.bloom, 45, 0.75
    fx.cc.Contrast, fx.cc.Saturation, fx.cc.TintColor = CFG.contrast, CFG.sat, look.tint
    fx.rays.Intensity, fx.rays.Spread = 0.15, 0.8
    fx.dof.FarIntensity, fx.dof.NearIntensity = CFG.dof, 0
    fx.dof.FocusDistance, fx.dof.InFocusRadius = 60, 80
    fx.atm.Density = CFG.fogOn and CFG.density or 0
    fx.atm.Haze = CFG.fogOn and 2 or 0
    fx.atm.Offset = 0.2
    fx.atm.Color, fx.atm.Decay = look.fogColor, look.fogColor
    Lighting.Ambient, Lighting.OutdoorAmbient = look.amb, look.amb
    Lighting.Brightness = CFG.bright
    Lighting.ExposureCompensation = 0.3
    Lighting.FogColor, Lighting.FogStart = look.fogColor, 0
    Lighting.FogEnd = CFG.fogOn and CFG.fog or 100000
    if CFG.blackSky then Lighting.ClockTime = 0 end
    fx.sky.Parent = CFG.blackSky and Lighting or nil
end

local function shadersOff()
    local fx = sh.fx
    if not fx then return end
    sh.fx = nil
    for _, v in pairs(fx) do pcall(function() v:Destroy() end) end
    for _, v in ipairs(sh.removed) do pcall(function() v.Parent = Lighting end) end
    sh.removed = {}
    if sh.saved then
        for k, v in pairs(sh.saved) do pcall(function() Lighting[k] = v end) end
    end
end

local function setShaders(v)
    CFG.shaders = v
    if v then
        shadersOn()
        shadersApply()
    else
        shadersOff()
    end
end

local function applyPreset(name)
    local p = PRESETS[name]
    if not p then return end
    look.tint, look.amb, look.fogColor = p.tint, p.amb, p.fogColor
    CFG.bloom, CFG.sat, CFG.fog, CFG.density = p.bloom, p.sat, p.fog, p.density
    if CFG.shaders then shadersApply() end
end

task.spawn(function()
    while running do
        if CFG.shaders then
            pcall(function()
                shadersOn()
                shadersApply()
            end)
        end
        task.wait(1)
    end
end)

local trailFolder = Instance.new("Folder")
trailFolder.Name = "NyxTrail"
trailFolder.Parent = workspace
local trailCount, trailAcc = 0, 0
local TRAIL_COLOR = Color3.fromRGB(40, 40, 46)

local function ghost(c)
    local info = TweenInfo.new(CFG.trailLife, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    for _, p in ipairs(c:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Transparency < 1 and trailCount < 500 then
            local g = Instance.new("Part")
            g.Size = p.Size * 1.08
            g.CFrame = p.CFrame
            g.Anchored = true
            g.CanCollide = false
            g.CanQuery = false
            g.CanTouch = false
            g.CastShadow = false
            g.Material = Enum.Material.SmoothPlastic
            g.Color = TRAIL_COLOR
            g.Transparency = CFG.trailTransp
            g.Parent = trailFolder
            trailCount += 1
            local tw = TweenService:Create(g, info, {Transparency = 1, Size = g.Size * 1.35})
            tw.Completed:Connect(function()
                g:Destroy()
                trailCount -= 1
            end)
            tw:Play()
        end
    end
end

local function smokeEmitter(hrp)
    local e = hrp:FindFirstChild("NyxSmoke")
    if e then return e end
    e = Instance.new("ParticleEmitter")
    e.Name = "NyxSmoke"
    e.Texture = "rbxasset://textures/particles/smoke_main.dds"
    e.Color = ColorSequence.new(TRAIL_COLOR)
    e.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.15, 0.55),
        NumberSequenceKeypoint.new(1, 1),
    })
    e.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 2.7),
        NumberSequenceKeypoint.new(1, 6.3),
    })
    e.Lifetime = NumberRange.new(0.55, 0.9)
    e.Rate = 55
    e.Speed = NumberRange.new(0, 0.5)
    e.Rotation = NumberRange.new(0, 360)
    e.RotSpeed = NumberRange.new(-20, 20)
    e.LightEmission = 0
    e.LightInfluence = 0
    e.Drag = 4
    e.SpreadAngle = Vector2.new(180, 180)
    e.Enabled = false
    e.Parent = hrp
    return e
end

connect(RunService.Heartbeat, function(dt)
    local c = lp.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local sm = hrp:FindFirstChild("NyxSmoke")
    if not CFG.trail or hum.Health <= 0 then
        if sm then sm.Enabled = false end
        return
    end
    local v = hrp.AssemblyLinearVelocity
    local moving = Vector3.new(v.X, 0, v.Z).Magnitude >= 3
    if CFG.trailSmoke then
        smokeEmitter(hrp).Enabled = moving
    elseif sm then
        sm.Enabled = false
    end
    trailAcc += dt
    if trailAcc < 0.05 then return end
    trailAcc = 0
    if moving then ghost(c) end
end)

local shotFolder = Instance.new("Folder")
shotFolder.Name = "NyxShotTrail"
shotFolder.Parent = workspace
local srp = RaycastParams.new()
srp.FilterType = Enum.RaycastFilterType.Exclude

local function mkShotPart(size, cf, tr, shape)
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Material = Enum.Material.Neon
    p.Color = TRAIL_COLOR
    p.Shape = shape or Enum.PartType.Block
    p.Size = size
    p.CFrame = cf
    p.Transparency = tr
    p.Parent = shotFolder
    return p
end

local function shotSeg(a, b)
    local d = b - a
    local len = d.Magnitude
    if len < 0.5 then return end
    local info = TweenInfo.new(CFG.shotLife, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local cf = CFrame.lookAt(a + d / 2, b)
    local t = 0.12
    local core = mkShotPart(Vector3.new(t, t, len), cf, 0.5)
    local glow = mkShotPart(Vector3.new(t * 4, t * 4, len), cf, 0.85)
    local puff = mkShotPart(Vector3.new(0.6, 0.6, 0.6), CFrame.new(b), 0.5, Enum.PartType.Ball)
    TweenService:Create(core, info, {Transparency = 1, Size = Vector3.new(t * 0.2, t * 0.2, len)}):Play()
    TweenService:Create(glow, info, {Transparency = 1, Size = Vector3.new(t * 8, t * 8, len)}):Play()
    TweenService:Create(puff, info, {Transparency = 1, Size = Vector3.new(2.6, 2.6, 2.6)}):Play()
    Debris:AddItem(core, CFG.shotLife + 0.2)
    Debris:AddItem(glow, CFG.shotLife + 0.2)
    Debris:AddItem(puff, CFG.shotLife + 0.2)
end
FX.shot = shotSeg

local function shotCast(origin, dir, ignore)
    srp.FilterDescendantsInstances = {ignore, shotFolder}
    local u = dir.Unit * 500
    local r = workspace:Raycast(origin, u, srp)
    return r and r.Position or origin + u
end

local function muzzle(char)
    local gun = char:FindFirstChild("Gun")
    local h = gun and gun:FindFirstChild("Handle")
    if h then return h.Position end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position
end

local function onShootAnim(p, char)
    if p == lp then lastGunFire = tick() end
    if not CFG.shotTrail then return end
    local origin = muzzle(char)
    if not origin then return end
    if p == lp then
        local target
        if CFG.silent and ST.aimPos then
            target = ST.aimPos
        else
            local c0 = workspace.CurrentCamera
            local vp = c0.ViewportSize
            local ray = c0:ViewportPointToRay(vp.X / 2, vp.Y / 2)
            target = shotCast(ray.Origin, ray.Direction, char)
        end
        shotSeg(origin, target)
    else
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then shotSeg(origin, shotCast(origin, hrp.CFrame.LookVector, char)) end
    end
end

local function hookShotChar(p, char)
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    local an = hum:FindFirstChildOfClass("Animator") or hum
    connect(an.AnimationPlayed, function(track)
        local a = track.Animation
        if track.Name == "Shoot" or (a and a.Name == "Shoot") then
            onShootAnim(p, char)
        end
    end)
end

local function hookShotPlayer(p)
    if p.Character then task.spawn(hookShotChar, p, p.Character) end
    connect(p.CharacterAdded, function(c) hookShotChar(p, c) end)
end

for _, p in ipairs(Players:GetPlayers()) do hookShotPlayer(p) end
connect(Players.PlayerAdded, hookShotPlayer)

local SND = {
    gun = {
        ["SFX Hit"] = 96359585058783,
        ["Bubble Pop Hit"] = 119697580657161,
        ["Neverlose Hit"] = 82938206376993,
        ["AWP"] = 138705939667182,
    },
    gunNames = {"SFX Hit", "Bubble Pop Hit", "Neverlose Hit", "AWP", "Off"},
    knife = {
        ["Among Us Kill"] = 130456049552264,
        ["Knife Kill"] = 137951817204948,
    },
    knifeNames = {"Among Us Kill", "Knife Kill", "Off"},
}

do
    local SoundService = game:GetService("SoundService")
    local lastPlay = 0

    function SND.play(id, vol)
        if not id then return end
        local s = Instance.new("Sound")
        s.Name = "NyxKillSound"
        s.SoundId = "rbxassetid://" .. tostring(id)
        s.Volume = vol or 1
        s.Parent = SoundService
        s.Ended:Connect(function() s:Destroy() end)
        s:Play()
        Debris:AddItem(s, 10)
    end

    local function onDeath()
        if not CFG.killSnd then return end
        local now = tick()
        if now - lastPlay < 0.15 then return end
        if roles[lp] == "Murderer" or hasKnife() then
            local id = SND.knife[CFG.knifeSnd]
            if id then
                lastPlay = now
                SND.play(id, CFG.knifeVol)
            end
        elseif now - lastGunFire < 2 then
            local id = SND.gun[CFG.gunSnd]
            if id then
                lastPlay = now
                SND.play(id, CFG.gunVol)
            end
        end
    end

    local function hookChar(p, char)
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then connect(hum.Died, onDeath) end
    end

    local function hookPlayer(p)
        if p == lp then return end
        if p.Character then task.spawn(hookChar, p, p.Character) end
        connect(p.CharacterAdded, function(c) hookChar(p, c) end)
    end

    for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
    connect(Players.PlayerAdded, hookPlayer)
end

local WING_PRESETS = {
    Angel = {a = Color3.fromRGB(255, 255, 255), b = Color3.fromRGB(255, 218, 120),
             glow = Color3.fromRGB(255, 242, 200), halo = Color3.fromRGB(255, 226, 140)},
    Frost = {a = Color3.fromRGB(240, 250, 255), b = Color3.fromRGB(100, 185, 255),
             glow = Color3.fromRGB(160, 215, 255), halo = Color3.fromRGB(150, 210, 255)},
    Inferno = {a = Color3.fromRGB(255, 238, 175), b = Color3.fromRGB(255, 80, 25),
               glow = Color3.fromRGB(255, 150, 60), halo = Color3.fromRGB(255, 120, 40)},
    Void = {a = Color3.fromRGB(200, 150, 255), b = Color3.fromRGB(45, 10, 100),
            glow = Color3.fromRGB(175, 95, 255), halo = Color3.fromRGB(170, 90, 255)},
}
local WING_NAMES = {"Angel", "Frost", "Inferno", "Void"}

local aura = {char = nil, folder = nil, core = nil, haloWeld = nil, feathers = {}, emitters = {}, open = 0}

local function removeAura()
    if aura.folder then pcall(function() aura.folder:Destroy() end) end
    aura = {char = nil, folder = nil, core = nil, haloWeld = nil, feathers = {}, emitters = {}, open = 0}
end

do
    local ROWS = {
        {n = 7, len = 3.6, w = 0.55},
        {n = 6, len = 2.5, w = 0.5},
        {n = 5, len = 1.5, w = 0.45},
    }

    local function auraPart(size, color, transp, parent)
        local p = Instance.new("Part")
        p.Size = size
        p.Color = color
        p.Material = Enum.Material.Neon
        p.Transparency = transp
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.CastShadow = false
        p.Massless = true
        p.Parent = parent
        return p
    end

    local function weld(p0, p1, c0, c1)
        local w = Instance.new("Weld")
        w.Part0, w.Part1 = p0, p1
        w.C0 = c0
        w.C1 = c1 or CFrame.new()
        w.Parent = p0
        return w
    end

    local function buildAura(char)
        removeAura()
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if not head or not torso then return end
        local old = char:FindFirstChild("NyxAura")
        if old then old:Destroy() end
        local P = WING_PRESETS[CFG.wingPreset] or WING_PRESETS.Angel
        local folder = Instance.new("Folder")
        folder.Name = "NyxAura"
        folder.Parent = char
        local emitters = {}

        local function emitter(parent, rate, size, life, speed, accel, spread)
            local em = Instance.new("ParticleEmitter")
            em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
            em.Color = ColorSequence.new(P.a, P.glow)
            em.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, size),
                NumberSequenceKeypoint.new(0.5, size * 0.7),
                NumberSequenceKeypoint.new(1, 0),
            })
            em.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(1, 1),
            })
            em.Lifetime = NumberRange.new(life * 0.7, life)
            em.Rate = rate
            em.Speed = NumberRange.new(speed * 0.4, speed)
            em.Acceleration = accel
            em.SpreadAngle = Vector2.new(spread, spread)
            em.Rotation = NumberRange.new(0, 360)
            em.RotSpeed = NumberRange.new(-60, 60)
            em.LightEmission = 1
            em.LightInfluence = 0
            em.Enabled = CFG.wingParticles
            em.Parent = parent
            emitters[#emitters + 1] = {em = em, rate = rate}
        end

        -- halo
        local core = auraPart(Vector3.new(0.2, 0.2, 0.2), P.a, 1, folder)
        local haloWeld = weld(head, core, CFrame.new(0, 1.15, 0))
        local n = 20
        for i = 1, n do
            local a = (i / n) * math.pi * 2
            local pos = Vector3.new(math.cos(a) * 0.8, 0, math.sin(a) * 0.8)
            local seg = auraPart(Vector3.new(0.14, 0.08, 0.34), P.halo, 0, folder)
            weld(core, seg, CFrame.lookAt(pos, pos + Vector3.new(-math.sin(a), 0, math.cos(a))))
        end
        local light = Instance.new("PointLight")
        light.Color = P.glow
        light.Brightness = 1.6
        light.Range = 11
        light.Parent = core
        emitter(core, 10, 0.28, 1.4, 1.0, Vector3.new(0, 1.2, 0), 180)

        -- falling glitter from the back
        local back = auraPart(Vector3.new(0.2, 0.2, 0.2), P.a, 1, folder)
        weld(torso, back, CFrame.new(0, 0.4, 0.7))
        emitter(back, 12, 0.26, 1.8, 1.4, Vector3.new(0, -1.2, 0), 120)

        -- wings: 3 rows of feathers per side
        local feathers = {}
        for _, side in ipairs({1, -1}) do
            local tips = {}
            for r, row in ipairs(ROWS) do
                for i = 1, row.n do
                    local t = (i - 1) / (row.n - 1)
                    local len = row.len * (1 - 0.42 * t)
                    local col = P.a:Lerp(P.b, math.clamp(t * 0.6 + (r - 1) * 0.2, 0, 1))
                    local f = auraPart(Vector3.new(len, 0.05, row.w), col, 0.08 + (r - 1) * 0.07, folder)
                    local w = weld(torso, f, CFrame.new(), CFrame.new(-side * len / 2, 0, 0))
                    feathers[#feathers + 1] = {w = w, side = side, r = r, t = t}
                    if r == 1 then
                        local att = Instance.new("Attachment")
                        att.Position = Vector3.new(side * len / 2, 0, 0)
                        att.Parent = f
                        tips[#tips + 1] = att
                        if i == 1 or i == 4 or i == 7 then
                            emitter(att, 7, 0.34, 1.1, 0.8, Vector3.new(0, -1.4, 0), 180)
                        end
                    end
                end
            end
            local top, bot = tips[1], tips[#tips]
            if top and bot then
                local tr = Instance.new("Trail")
                tr.Attachment0, tr.Attachment1 = top, bot
                tr.Lifetime = 0.45
                tr.MinLength = 0.05
                tr.LightEmission = 1
                tr.LightInfluence = 0
                tr.FaceCamera = true
                tr.Color = ColorSequence.new(P.glow, P.b)
                tr.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.55),
                    NumberSequenceKeypoint.new(1, 1),
                })
                tr.Enabled = CFG.wingParticles
                tr.Parent = top.Parent
                emitters[#emitters + 1] = {trail = tr}
            end
        end

        aura = {char = char, folder = folder, core = core, haloWeld = haloWeld,
                feathers = feathers, emitters = emitters, open = 0}
    end

    connect(RunService.Heartbeat, function(dt)
        if not CFG.aura then
            if aura.folder then removeAura() end
            return
        end
        local c = lp.Character
        if not c then return end
        if aura.char ~= c or not aura.folder or not aura.folder.Parent then
            if c:FindFirstChild("Head") and (c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso")) then
                pcall(buildAura, c)
            end
            return
        end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local speed = hrp and hrp.AssemblyLinearVelocity.Magnitude or 0
        local target = CFG.fly and 1 or math.clamp(speed / 18, 0, 1)
        aura.open += (target - aura.open) * math.min(dt * 6, 1)
        local open = aura.open
        local t = tick() * CFG.auraSpeed
        local tt = t * (3 + open * 4)
        local amp = 0.06 + open * 0.22

        aura.haloWeld.C0 = CFrame.new(0, 1.15 + math.sin(t * 2) * 0.06, 0) * CFrame.Angles(0, t * 2, 0)
        for _, f in ipairs(aura.feathers) do
            local side, r, ft = f.side, f.r, f.t
            local folded = 0.15 - ft * 0.5 - (r - 1) * 0.12
            local opened = 1.0 - ft * 1.55 - (r - 1) * 0.1
            local roll = folded + (opened - folded) * open + math.sin(tt - ft * 0.9 - r * 0.4) * amp
            local yaw = 0.3 + open * 0.28 + (r - 1) * 0.04 + math.sin(tt - ft) * amp * 0.35
            f.w.C0 = CFrame.new(side * 0.32, 0.6 - (r - 1) * 0.06, 0.52 + (r - 1) * 0.04)
                * CFrame.Angles(0, -side * yaw, side * roll)
        end
        for _, e in ipairs(aura.emitters) do
            if e.em then
                e.em.Enabled = CFG.wingParticles
                e.em.Rate = e.rate * (0.5 + open * 2.2)
            elseif e.trail then
                e.trail.Enabled = CFG.wingParticles and open > 0.15
            end
        end
    end)
end

local UIS = game:GetService("UserInputService")

local function findMap()
    for _, ch in ipairs(workspace:GetChildren()) do
        if (ch:IsA("Model") or ch:IsA("Folder")) and ch:FindFirstChild("CoinContainer") then return ch end
    end
    for _, ch in ipairs(workspace:GetChildren()) do
        if (ch:IsA("Model") or ch:IsA("Folder")) and not Players:GetPlayerFromCharacter(ch) then
            if ch:FindFirstChild("CoinContainer", true) then return ch end
        end
    end
end

local function findLobby()
    local l = workspace:FindFirstChild("Lobby")
    if l then return l end
    for _, ch in ipairs(workspace:GetChildren()) do
        if (ch:IsA("Model") or ch:IsA("Folder")) and ch.Name:lower():find("lobby", 1, true) then return ch end
    end
end

local function spawnPoints(container)
    local list = {}
    if not container then return list end
    local sf = container:FindFirstChild("Spawns", true)
    local scan = sf or container
    for _, d in ipairs(scan:GetDescendants()) do
        if d:IsA("SpawnLocation") or (sf and d:IsA("BasePart")) then list[#list + 1] = d end
    end
    return list
end

local function destCF(container)
    if not container then return nil end
    local pts = spawnPoints(container)
    if #pts > 0 then
        return pts[math.random(#pts)].CFrame + Vector3.new(0, 4, 0)
    end
    local base = container:FindFirstChild("Base", true)
    if base and base:IsA("BasePart") then return base.CFrame + Vector3.new(0, 6, 0) end
    local ok, pv = pcall(function() return container:GetPivot() end)
    if ok then return pv + Vector3.new(0, 8, 0) end
end

local function tpTo(cf)
    if not cf then return false end
    local hrp = myHrp()
    if not hrp then return false end
    if holding then surface() end
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity = Vector3.zero
    return true
end

local function tpLobby()
    local cf = destCF(findLobby())
    if not cf then
        local m = findMap()
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("SpawnLocation") and not (m and d:IsDescendantOf(m)) then
                cf = d.CFrame + Vector3.new(0, 4, 0)
                break
            end
        end
    end
    return tpTo(cf)
end

local function tpMap()
    return tpTo(destCF(findMap()))
end

local function mapInfo()
    local out = {}
    local m = findMap()
    if m then
        local names = {}
        for i, ch in ipairs(m:GetChildren()) do
            if i > 8 then break end
            names[#names + 1] = ch.Name
        end
        local cc = m:FindFirstChild("CoinContainer", true)
        out[#out + 1] = "Map: " .. m.Name .. " [" .. table.concat(names, ", ") .. "] spawns "
            .. #spawnPoints(m) .. ", coins " .. (cc and #cc:GetChildren() or 0)
    else
        out[#out + 1] = "Map: not loaded"
    end
    local l = findLobby()
    if l then
        out[#out + 1] = "Lobby: " .. l.Name .. ", spawns " .. #spawnPoints(l)
    else
        out[#out + 1] = "Lobby: not found"
    end
    return table.concat(out, "\n")
end

task.spawn(function()
    local lastMap
    local busySince = 0
    while running do
        pcall(function()
            local m = findMap()
            if m ~= lastMap then
                lastMap = m
                if m then
                    table.clear(visited)
                    table.clear(danger)
                    table.clear(cooldown)
                    got = 0
                end
            end
        end)
        if busy then
            if busySince == 0 then
                busySince = tick()
            elseif tick() - busySince > 40 then
                busy, picking, busySince = false, false, 0
                pcall(hold, false)
            end
        else
            busySince = 0
        end
        task.wait(0.5)
    end
end)

local ncSaved = {}
connect(PRE_SIM, function()
    if not CFG.noclip then
        if next(ncSaved) then
            for part in pairs(ncSaved) do
                if part.Parent then part.CanCollide = true end
            end
            table.clear(ncSaved)
        end
        return
    end
    local c = lp.Character
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then
            ncSaved[p] = true
            p.CanCollide = false
        end
    end
end)

local fly = {bv = nil, bg = nil, ctrl = nil}
local function flyStop()
    if fly.bv then pcall(function() fly.bv:Destroy() end) end
    if fly.bg then pcall(function() fly.bg:Destroy() end) end
    fly.bv, fly.bg = nil, nil
    local _, hum = myHrp()
    if hum then hum.PlatformStand = false end
end

task.spawn(function()
    local ok, c = pcall(function()
        local pm = lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 5)
        return require(pm):GetControls()
    end)
    fly.ctrl = ok and c or false
end)

local function moveVec()
    if fly.ctrl then
        local ok, v = pcall(function() return fly.ctrl:GetMoveVector() end)
        if ok and typeof(v) == "Vector3" and v.Magnitude > 0 then return v end
    end
    local x = (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
    local z = (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
    return Vector3.new(x, 0, z)
end

connect(PRE_RENDER, function()
    if not CFG.fly or holding or picking then
        if fly.bv then flyStop() end
        return
    end
    local hrp, hum = myHrp()
    if not hrp or not hum or hum.Health <= 0 then return end
    if not fly.bv or fly.bv.Parent ~= hrp then
        flyStop()
        local bv = Instance.new("BodyVelocity")
        bv.Name = "NyxFly"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.P = 1e4
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        local bg = Instance.new("BodyGyro")
        bg.Name = "NyxFlyGyro"
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.P = 1e5
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        fly.bv, fly.bg = bv, bg
    end
    hum.PlatformStand = true
    local c0 = workspace.CurrentCamera
    local mv = moveVec()
    local dir = c0.CFrame.LookVector * -mv.Z + c0.CFrame.RightVector * mv.X
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
    local target = dir.Magnitude > 0.05 and dir.Unit * CFG.flySpeed or Vector3.zero
    fly.bv.Velocity = fly.bv.Velocity:Lerp(target, 0.35)
    local look = c0.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if CFG.spinOn then
        fly.bg.MaxTorque = Vector3.zero
    else
        fly.bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        if flat.Magnitude > 0.01 then
            fly.bg.CFrame = CFrame.new(hrp.Position, hrp.Position + flat)
        end
    end
end)

-- bunny hop
connect(PRE_SIM, function()
    if not CFG.bhop or CFG.fly or holding or busy then return end
    local hrp, hum = myHrp()
    if not hrp or not hum or hum.Health <= 0 then return end
    local md = hum.MoveDirection
    if md.Magnitude < 0.1 then return end
    if hum.FloorMaterial ~= Enum.Material.Air then hum.Jump = true end
    local v = hrp.AssemblyLinearVelocity
    local flat = Vector3.new(v.X, 0, v.Z):Lerp(md.Unit * CFG.bhopSpeed, 0.3)
    hrp.AssemblyLinearVelocity = Vector3.new(flat.X, v.Y, flat.Z)
end)

-- spin
local function spinStop()
    local hrp = myHrp()
    local s = hrp and hrp:FindFirstChild("NyxSpin")
    if s then s:Destroy() end
end

connect(PRE_RENDER, function()
    local hrp, hum = myHrp()
    if not hrp or not hum then return end
    local s = hrp:FindFirstChild("NyxSpin")
    if not CFG.spinOn or hum.Health <= 0 or holding then
        if s then s:Destroy() end
        return
    end
    if not s then
        s = Instance.new("BodyAngularVelocity")
        s.Name = "NyxSpin"
        s.MaxTorque = Vector3.new(0, 1e9, 0)
        s.P = 1e9
        s.Parent = hrp
    end
    s.AngularVelocity = Vector3.new(0, CFG.spinSpeed, 0)
end)

local movDef = {}
connect(PRE_SIM, function()
    local c = lp.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if movDef.hum ~= hum then
        movDef = {hum = hum}
    end
    if CFG.wsOn then
        if movDef.ws == nil then movDef.ws = hum.WalkSpeed end
        hum.WalkSpeed = CFG.walkSpeed
    elseif movDef.ws ~= nil then
        hum.WalkSpeed = movDef.ws
        movDef.ws = nil
    end
    if CFG.jpOn then
        if movDef.jp == nil then movDef.jp = hum.JumpPower end
        hum.UseJumpPower = true
        hum.JumpPower = CFG.jumpPower
    elseif movDef.jp ~= nil then
        hum.JumpPower = movDef.jp
        movDef.jp = nil
    end
end)

local xr = {map = nil, saved = {}}

local function xrSkip(part)
    local n = part.Name
    if n:find("Coin", 1, true) or n:find("Spawn", 1, true) or n == "GunDrop" or n == "HumanoidRootPart" then return true end
    local m = part:FindFirstAncestorOfClass("Model")
    if m and m:FindFirstChildOfClass("Humanoid") then return true end
    return false
end

local function xrApply(part)
    if not part:IsA("BasePart") or xr.saved[part] ~= nil then return end
    if part.Transparency >= CFG.xrayTransp or xrSkip(part) then return end
    xr.saved[part] = part.Transparency
    part.Transparency = CFG.xrayTransp
end

local function xrRestore()
    for part, t in pairs(xr.saved) do
        pcall(function() part.Transparency = t end)
    end
    table.clear(xr.saved)
    xr.map = nil
end

local function xrRefresh()
    for part in pairs(xr.saved) do
        pcall(function() part.Transparency = CFG.xrayTransp end)
    end
end

connect(workspace.DescendantAdded, function(d)
    if CFG.xray and xr.map and d:IsA("BasePart") and d:IsDescendantOf(xr.map) then
        xrApply(d)
    end
end)

task.spawn(function()
    while running do
        if CFG.xray then
            local m = findMap()
            if m ~= xr.map then
                xrRestore()
                xr.map = m
                if m then
                    local n = 0
                    for _, d in ipairs(m:GetDescendants()) do
                        xrApply(d)
                        n += 1
                        if n % 400 == 0 then task.wait() end
                    end
                end
            end
        elseif next(xr.saved) then
            xrRestore()
        end
        task.wait(1)
    end
end)

local WindUI
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok then WindUI = res end
end

local function notify(title, text)
    if WindUI then
        pcall(function() WindUI:Notify({Title = title, Content = text, Duration = 8}) end)
    end
end

local btnGui = Instance.new("ScreenGui")
btnGui.Name = "SwagaButton"
btnGui.ResetOnSpawn = false
btnGui.IgnoreGuiInset = true
local okp = pcall(function() btnGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okp or not btnGui.Parent then btnGui.Parent = lp:WaitForChild("PlayerGui") end

local Button = Instance.new("TextButton")
Button.Name = "SwagaButton"
Button.Size = UDim2.new(0, 72, 0, 72)
Button.Position = UDim2.new(0, 20, 0.5, -36)
Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Button.BackgroundTransparency = 0.05
Button.BorderSizePixel = 0
Button.Text = ""
Button.AutoButtonColor = false
Button.Active = true
Button.Parent = btnGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 18)
Corner.Parent = Button

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(70, 70, 70)
Stroke.Thickness = 2
Stroke.Transparency = 0.1
Stroke.Parent = Button

local Icon = Instance.new("ImageLabel")
Icon.Name = "Icon"
Icon.BackgroundTransparency = 1
Icon.Size = UDim2.new(0, 54, 0, 54)
Icon.Position = UDim2.new(0.5, -27, 0.5, -27)
Icon.Image = "rbxassetid://9826609769"
Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
Icon.ImageTransparency = 0
Icon.ScaleType = Enum.ScaleType.Fit
Icon.Parent = Button

task.spawn(function()
    while running and Icon.Parent do
        local tw = TweenService:Create(Icon, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = Icon.Rotation + 360})
        tw:Play()
        tw.Completed:Wait()
    end
end)

local function setAutoShoot(v)
    CFG.autoShoot = v
    Stroke.Color = v and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(70, 70, 70)
    Icon.ImageTransparency = v and 0 or 0.55
end

local function setShootBtn(v)
    CFG.shootBtn = v
    Button.Visible = v
    setAutoShoot(v)
end

connect(Button.MouseEnter, function()
    TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 38, 38)}):Play()
end)
connect(Button.MouseLeave, function()
    TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
end)

local dragging, dragStart, startPos, moved = false, nil, nil, 0
connect(Button.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos, moved = true, input.Position, Button.Position, 0
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0, 66, 0, 66)}):Play()
    end
end)
connect(UIS.InputChanged, function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - dragStart
        moved = math.max(moved, d.Magnitude)
        if moved > 10 then
            Button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end
end)
connect(UIS.InputEnded, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0, 72, 0, 72)}):Play()
        if moved <= 10 then setAutoShoot(not CFG.autoShoot) end
    end
end)

local Window
if WindUI then
    local ok, w = pcall(function()
        return WindUI:CreateWindow({
            Title = "Nyx Hub",
            Icon = "star",
            Author = "MM2",
            Size = UDim2.fromOffset(520, 340),
            Theme = "Dark",
        })
    end)
    if ok then Window = w end
end

local function newTab(title, icon)
    if not Window then return nil end
    local ok, t = pcall(function() return Window:Tab({Title = title, Icon = icon}) end)
    if ok then return t end
end

local function sec(tab, title)
    if tab then pcall(function() tab:Section({Title = title}) end) end
end

local function tog(tab, title, key, cb)
    if not tab then return nil end
    local ok, el = pcall(function()
        return tab:Toggle({Title = title, Value = CFG[key], Callback = function(v)
            CFG[key] = v
            if cb then cb(v) end
        end})
    end)
    if ok then return el end
end

local function sld(tab, title, key, mn, mx, step, cb)
    if not tab then return end
    pcall(function()
        tab:Slider({Title = title, Step = step, Value = {Min = mn, Max = mx, Default = CFG[key]}, Callback = function(v)
            CFG[key] = v
            if cb then cb(v) end
        end})
    end)
end

local function btn(tab, title, fn)
    if not tab then return end
    pcall(function()
        tab:Button({Title = title, Callback = function()
            task.spawn(function() pcall(fn) end)
        end})
    end)
end

local function dd(tab, title, values, default, cb)
    if not tab then return nil end
    local ok, el = pcall(function()
        return tab:Dropdown({Title = title, Values = values, Value = default, Callback = cb})
    end)
    if ok then return el end
end

local function reshade()
    if CFG.shaders then pcall(shadersApply) end
end

local tabAim = newTab("Aim", "crosshair")
sec(tabAim, "Silent aim")
tog(tabAim, "Silent aim", "silent")
tog(tabAim, "WallBang", "wallbang")
tog(tabAim, "Ping lead", "pingLead")
sld(tabAim, "Lead", "lead", 0, 0.2, 0.01)
sld(tabAim, "WallBang distance", "wbDist", 1, 20, 1)
sec(tabAim, "Auto shoot")
if tabAim then
    pcall(function()
        tabAim:Toggle({Title = "Auto Shoot (shows button)", Value = false, Callback = function(v)
            setShootBtn(v)
        end})
    end)
end
sld(tabAim, "Shoot delay", "shootDelay", 0.3, 4, 0.1)
sld(tabAim, "Shoot range", "shootMax", 100, 1500, 50)

local tabChar = newTab("Character", "user")
sec(tabChar, "Movement")
tog(tabChar, "Noclip", "noclip")
tog(tabChar, "Fly", "fly", function(v)
    if not v then flyStop() end
end)
sld(tabChar, "Fly speed", "flySpeed", 10, 250, 5)
tog(tabChar, "WalkSpeed", "wsOn")
sld(tabChar, "WalkSpeed value", "walkSpeed", 16, 200, 1)
tog(tabChar, "JumpPower", "jpOn")
sld(tabChar, "JumpPower value", "jumpPower", 50, 300, 5)
sec(tabChar, "Bunny Hop")
tog(tabChar, "Bunny Hop", "bhop")
sld(tabChar, "Bunny Hop speed", "bhopSpeed", 10, 50, 1)
sec(tabChar, "Spin")
tog(tabChar, "Spin", "spinOn")
if tabChar then
    pcall(function()
        tabChar:Input({
            Title = "Spin speed (20 and up)",
            Value = tostring(CFG.spinSpeed),
            Placeholder = "20, 200, 5000...",
            Callback = function(text)
                local n = tonumber(text)
                if n and n == n then CFG.spinSpeed = math.clamp(n, 20, 1e12) end
            end,
        })
    end)
end
sec(tabChar, "Stealth")
local invToggle
if tabChar then
    local ok, el = pcall(function()
        return tabChar:Toggle({Title = "Invisible", Value = false, Callback = function(v)
            task.spawn(function()
                if v then
                    if not goInvisible() and invToggle then
                        pcall(function() invToggle:Set(false) end)
                    end
                else
                    goVisible()
                end
            end)
        end})
    end)
    if ok then invToggle = el end
end
tog(tabChar, "Anti-Aim", "aa", function(v)
    if not v then aaRestore() end
end)
dd(tabChar, "Anti-Aim mode", {"Spin", "Yaw", "Pitch", "Random", "Up", "Down"}, "Spin", function(v)
    CFG.aaMode = v
end)
dd(tabChar, "Anti-Aim part", {"Neck", "Head", "Torso", "UpperTorso"}, "Neck", function(v)
    CFG.aaPart = v
end)

local tabTp = newTab("Teleport", "map-pin")
sec(tabTp, "Teleport")
btn(tabTp, "TP Lobby", tpLobby)
btn(tabTp, "TP Map", tpMap)
btn(tabTp, "Scan maps", function() notify("Maps", mapInfo()) end)

local tabFarm = newTab("Farm", "coins")
sec(tabFarm, "Coins")
tog(tabFarm, "Auto farm", "farm")
tog(tabFarm, "Underground path", "farmUnder")
sld(tabFarm, "Max coins per round", "maxCoins", 10, 60, 1)
tog(tabFarm, "Coin ESP", "coinEsp")
tog(tabFarm, "Coin highlight", "coinHighlight")
tog(tabFarm, "Coin tracer", "coinTracer")
sld(tabFarm, "Farm speed", "farmSpeed", 10, 60, 1)
sld(tabFarm, "Depth", "depth", 8, 60, 1)
sec(tabFarm, "Combat")
tog(tabFarm, "Auto pick gun", "autoGun")
tog(tabFarm, "Auto kill (murderer)", "autoKill")

local tabVis = newTab("Visuals", "scan-eye")
sec(tabVis, "ESP")
tog(tabVis, "ESP", "esp")
tog(tabVis, "Box", "box")
tog(tabVis, "Skeleton", "skeleton")
tog(tabVis, "Highlight", "highlight")
tog(tabVis, "Name + role", "name")
tog(tabVis, "Distance", "dist")
tog(tabVis, "Tracer", "tracer")
tog(tabVis, "Health bar", "health")
tog(tabVis, "Dropped gun", "gun")
tog(tabVis, "Show innocent", "showInnocent")
sld(tabVis, "Max distance", "maxDist", 100, 2000, 50)
sld(tabVis, "Skeleton distance", "skelDist", 30, 500, 10)
sec(tabVis, "X-ray")
tog(tabVis, "X-ray (map walls)", "xray")
sld(tabVis, "X-ray transparency", "xrayTransp", 0.1, 0.9, 0.05, function()
    xrRefresh()
end)

local tabCos = newTab("Cosmetic", "sparkles")
sec(tabCos, "Shaders")
tog(tabCos, "Shaders", "shaders", setShaders)
dd(tabCos, "Preset", PRESET_NAMES, "BlueFog", applyPreset)
tog(tabCos, "Black sky", "blackSky", reshade)
tog(tabCos, "Blue fog", "fogOn", reshade)
sld(tabCos, "Fog distance", "fog", 50, 2000, 10, reshade)
sld(tabCos, "Fog density", "density", 0, 1, 0.05, reshade)
sld(tabCos, "Bloom", "bloom", 0, 4, 0.1, reshade)
sld(tabCos, "Contrast", "contrast", -0.5, 1, 0.05, reshade)
sld(tabCos, "Saturation", "sat", -1, 1, 0.05, reshade)
sld(tabCos, "Blur", "dof", 0, 1, 0.05, reshade)
sld(tabCos, "Brightness", "bright", 0, 5, 0.1, reshade)
sec(tabCos, "Effects")
tog(tabCos, "Ghost trail", "trail")
tog(tabCos, "Trail smoke", "trailSmoke")
tog(tabCos, "Shot trail", "shotTrail")
sec(tabCos, "Wings")
tog(tabCos, "Wings", "aura")
dd(tabCos, "Wings style", WING_NAMES, CFG.wingPreset, function(v)
    CFG.wingPreset = (type(v) == "table" and v[1]) or v
    removeAura()
end)
tog(tabCos, "Wing particles", "wingParticles")
sld(tabCos, "Wing speed", "auraSpeed", 0.5, 3, 0.1)

local tabSnd = newTab("Sound", "volume-2")
sec(tabSnd, "Kill sounds")
tog(tabSnd, "Kill sounds", "killSnd")
sec(tabSnd, "Gun kill")
dd(tabSnd, "Gun kill sound", SND.gunNames, CFG.gunSnd, function(v)
    CFG.gunSnd = (type(v) == "table" and v[1]) or v
end)
sld(tabSnd, "Gun volume", "gunVol", 0, 5, 0.1)
btn(tabSnd, "Test gun sound", function() SND.play(SND.gun[CFG.gunSnd], CFG.gunVol) end)
sec(tabSnd, "Knife kill")
dd(tabSnd, "Knife kill sound", SND.knifeNames, CFG.knifeSnd, function(v)
    CFG.knifeSnd = (type(v) == "table" and v[1]) or v
end)
sld(tabSnd, "Knife volume", "knifeVol", 0, 5, 0.1)
btn(tabSnd, "Test knife sound", function() SND.play(SND.knife[CFG.knifeSnd], CFG.knifeVol) end)

local tabMisc = newTab("Misc", "settings")
btn(tabMisc, "Unload", function()
    if genv.NyxWind then genv.NyxWind() end
end)

setShootBtn(false)

genv.NyxWind = function()
    running = false
    for _, k in ipairs({"autoShoot", "autoGun", "autoKill", "farm", "fly", "noclip", "aa",
                        "wsOn", "jpOn", "bhop", "spinOn", "xray", "aura", "trail", "shotTrail", "silent"}) do
        CFG[k] = false
    end
    ST.on, ST.aimPos, ST.wb = false, nil, false
    pcall(goVisible)
    pcall(flyStop)
    pcall(spinStop)
    pcall(aaRestore)
    pcall(xrRestore)
    pcall(shadersOff)
    pcall(removeAura)
    pcall(function()
        if holding then surface() end
    end)
    pcall(function()
        if movDef.hum then
            if movDef.ws then movDef.hum.WalkSpeed = movDef.ws end
            if movDef.jp then movDef.hum.JumpPower = movDef.jp end
        end
    end)
    for part in pairs(ncSaved) do
        if part.Parent then part.CanCollide = true end
    end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for _, e in pairs(E) do
        if e.cc then pcall(function() e.cc:Disconnect() end) end
        if e.hl then pcall(function() e.hl:Destroy() end) end
    end
    for _, d in ipairs(draws) do pcall(function() d:Remove() end) end
    for _, c in pairs(circles) do pcall(function() c:Remove() end) end
    for _, l in pairs(lines) do pcall(function() l:Remove() end) end
    for _, h in pairs(hls) do pcall(function() h:Destroy() end) end
    pcall(function() trailFolder:Destroy() end)
    pcall(function() shotFolder:Destroy() end)
    local g = drop and drop:FindFirstChild("GunESP")
    if g then pcall(function() g:Destroy() end) end
    local hrp = myHrp()
    if hrp then
        for _, n in ipairs({"NyxSmoke", "NyxHold", "NyxSpin", "NyxFly", "NyxFlyGyro"}) do
            local o = hrp:FindFirstChild(n)
            if o then pcall(function() o:Destroy() end) end
        end
    end
    pcall(function() btnGui:Destroy() end)
    if Window then pcall(function() Window:Destroy() end) end
    genv.NyxWind = nil
end
