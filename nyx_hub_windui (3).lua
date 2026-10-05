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
    silent = true, wallbang = true, wbMethod = "Хакер",
    farm = false, coinEsp = true, coinHighlight = true, coinTracer = true, coinTracerDist = 200, farmUnder = true,
    autoGun = true, autoKill = false,
    farmSpeed = 26, vSpeed = 45, depth = 22, gunSpeed = 150, pickDist = 400,
    killSpeed = 70, killRange = 250, hitDelay = 0.2, maxTries = 4,
    maxCoins = 40, coinRange = 1500, dangerDist = 30,
    bhop = false, bhopSpeed = 30, spinOn = false, spinSpeed = 200,
    killSnd = false, replaceSnd = true, gunSnd = "SFX Hit", gunVol = 2.5, knifeSnd = "Among Us Kill", knifeVol = 1.5,
    autoShoot = false, shootBtn = false, shootDelay = 1.2, ghostTransp = 0.5, pickTime = 0.45, shootMax = 600,
    aa = false, aaMode = "Spin", aaPart = "Neck", aaSpeed = 18,
    shaders = false, blackSky = true, fogOn = true, fog = 350, density = 0.45,
    bloom = 1.6, contrast = 0.3, sat = 0.4, dof = 0.12, bright = 1.6,
    trail = false, trailLife = 0.8, trailTransp = 0.72, trailSmoke = true,
    shotTrail = false, shotLife = 1.2,
    aura = false, auraSpeed = 1.2, wingPreset = "Angel", wingParticles = true, wingOrbs = true,
    helper = false, helperStyle = "Fairy", helperSize = 1,
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
ST.on, ST.aimPos, ST.target = CFG.silent, nil, nil

local WB_METHODS = {"Хакер", "Про", "Тихий"}

local stRP = RaycastParams.new()
stRP.FilterType = Enum.RaycastFilterType.Exclude

-- returns originPos (nil = keep the game's origin), aimPos
function ST.calc(me, t, wb)
    local tp = t.Position
    local v = t.AssemblyLinearVelocity
    local flat = Vector3.new(v.X, 0, v.Z)
    local speed = flat.Magnitude
    local lead = math.clamp(ST.ping or 0.08, 0, 0.6) + 0.1
    local pred = tp + flat * lead
    local toT = pred - me
    local dirMe = toT.Magnitude > 0.01 and toT.Unit or Vector3.new(0, 0, -1)

    local blocked = false
    if wb then
        local ignore = {t.Parent}
        if lp.Character then ignore[2] = lp.Character end
        stRP.FilterDescendantsInstances = ignore
        blocked = workspace:Raycast(me, toT, stRP) ~= nil
    end

    local method = CFG.wbMethod
    if not wb then
        return nil, pred + dirMe * 3
    elseif method == "Хакер" then
        -- always fires from right next to the target, along its own path
        if speed > 4 then
            local d = flat.Unit
            return pred - d * 5, pred + d * 10
        end
        return pred - dirMe * 3, pred + dirMe * 6
    elseif method == "Про" then
        if blocked then
            return pred - dirMe * 4, pred + dirMe * 4
        end
        return nil, pred + dirMe * 4
    else -- "Тихий"
        if blocked then
            local back = workspace:Raycast(pred, me - pred, stRP)
            local o
            if back then
                o = pred + (back.Position - pred) * 0.5
            else
                o = pred - dirMe * 3
            end
            local d = pred - o
            d = d.Magnitude > 0.01 and d.Unit or dirMe
            return o, pred + d * 3
        end
        return nil, pred
    end
end

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
                if ST.on and ST.target and ST.target.Parent and m == "FireServer"
                   and self.Name == "Shoot" and pn == "Gun" then
                    local args = table.pack(...)
                    local ok = pcall(function()
                        local first
                        for i = 1, args.n do
                            if typeof(args[i]) == "CFrame" then first = i break end
                        end
                        if not first then return end
                        local me = args[first].Position
                        local o, aim = ST.calc(me, ST.target, CFG.wallbang)
                        ST.aimPos = aim
                        args[first] = CFrame.lookAt(o or me, aim)
                        for i = first + 1, args.n do
                            if typeof(args[i]) == "CFrame" then
                                args[i] = CFrame.new(aim)
                                break
                            end
                        end
                    end)
                    if setnamecallmethod then setnamecallmethod(m) end
                    if ok then return old(self, table.unpack(args, 1, args.n)) end
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

    ST.on = CFG.silent
    ST.target = foundTarget
    ST.aimPos = foundTarget and foundTarget.Position or nil

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
    local gun, remote = findGun()
    if not gun then return end
    local t = murdererHrp()
    if not t then return end
    local mine = seen()
    local mhrp = mine and mine:FindFirstChild("HumanoidRootPart")
    local me = (mhrp and mhrp.Position or (ST.myPos or t.Position)) + Vector3.new(0, 1.5, 0)
    if not CFG.wallbang and (t.Position - me).Magnitude > CFG.shootMax then return end
    local o, aim = ST.calc(me, t, CFG.wallbang)
    if not CFG.wallbang then
        rp.FilterDescendantsInstances = {mine, t.Parent}
        if workspace:Raycast(me, aim - me, rp) ~= nil then return end
    end
    local origin = o or me
    lastShot = tick()
    lastGunFire = tick()
    ST.aimPos = aim
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
    orig = {},
}

do
    local SoundService = game:GetService("SoundService")
    local lastPlay = 0
    local made = {}

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

    local function setSound(s, id, vol)
        if SND.orig[s] == nil then SND.orig[s] = {s.SoundId, s.Volume} end
        local want = "rbxassetid://" .. tostring(id)
        if s.SoundId ~= want then s.SoundId = want end
        if s.Volume ~= vol then s.Volume = vol end
    end

    local function restoreSound(s)
        local o = SND.orig[s]
        if not o then return end
        SND.orig[s] = nil
        if made[s] then
            made[s] = nil
            pcall(function() s:Destroy() end)
        else
            pcall(function()
                s.SoundId = o[1]
                s.Volume = o[2]
            end)
        end
    end

    function SND.restore()
        for s in pairs(SND.orig) do restoreSound(s) end
    end

    local function hitName(n)
        n = n:lower()
        return n:find("stab", 1, true) or n:find("slash", 1, true) or n:find("swing", 1, true)
            or n:find("hit", 1, true) or n:find("kill", 1, true) or n:find("knife", 1, true)
    end

    local function toolSounds(t, isGun)
        local out = {}
        local sf = t:FindFirstChild("Sounds")
        local h = t:FindFirstChild("Handle")
        if isGun then
            local shoot = sf and sf:FindFirstChild("Shoot")
            if shoot and shoot:IsA("Sound") then out[#out + 1] = shoot end
            local gs = h and h:FindFirstChild("Gunshot")
            if gs and gs:IsA("Sound") then out[#out + 1] = gs end
        else
            if sf then
                for _, s in ipairs(sf:GetChildren()) do
                    if s:IsA("Sound") then out[#out + 1] = s end
                end
            end
            if h then
                for _, s in ipairs(h:GetChildren()) do
                    if s:IsA("Sound") and hitName(s.Name) then out[#out + 1] = s end
                end
            end
        end
        return out
    end

    local function holders()
        return {lp.Character or false, lp:FindFirstChild("Backpack") or false, inv.real or false}
    end

    local function scan()
        local gid, kid
        if CFG.replaceSnd then
            gid, kid = SND.gun[CFG.gunSnd], SND.knife[CFG.knifeSnd]
        end
        for _, holder in ipairs(holders()) do
            if holder then
                for _, t in ipairs(holder:GetChildren()) do
                    if t:IsA("Tool") and (t.Name == "Gun" or t.Name == "Knife") then
                        local isGun = t.Name == "Gun"
                        local id, vol
                        if isGun then
                            id, vol = gid, CFG.gunVol
                            local sf = t:FindFirstChild("Sounds")
                            if id and sf and not sf:FindFirstChild("Shoot") then
                                local ns = Instance.new("Sound")
                                ns.Name = "Shoot"
                                ns.Parent = sf
                                SND.orig[ns] = {"", 0.5}
                                made[ns] = true
                            end
                        else
                            id, vol = kid, CFG.knifeVol
                        end
                        for _, s in ipairs(toolSounds(t, isGun)) do
                            if id then setSound(s, id, vol) else restoreSound(s) end
                        end
                    end
                end
            end
        end
    end

    function SND.dump()
        local out = {}
        for _, holder in ipairs(holders()) do
            if holder then
                for _, t in ipairs(holder:GetChildren()) do
                    if t:IsA("Tool") and (t.Name == "Gun" or t.Name == "Knife") then
                        local names = {}
                        for _, d in ipairs(t:GetDescendants()) do
                            if d:IsA("Sound") then names[#names + 1] = d.Parent.Name .. "." .. d.Name end
                        end
                        out[#out + 1] = t.Name .. ": " .. (#names > 0 and table.concat(names, ", ") or "no sounds")
                    end
                end
            end
        end
        if #out == 0 then return "no Gun / Knife in backpack" end
        return table.concat(out, "\n")
    end

    task.spawn(function()
        while running do
            pcall(scan)
            task.wait(0.5)
        end
    end)

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

local WING_PRESETS = {}
do
    local SPARK = "rbxasset://textures/particles/sparkles_main.dds"
    local FIRE = "rbxasset://textures/particles/fire_main.dds"
    local function C(r, g, b) return Color3.fromRGB(r, g, b) end
    WING_PRESETS.Angel = {style = "feather", a = C(255, 255, 255), b = C(255, 218, 120), glow = C(255, 242, 200), halo = true, tex = SPARK}
    WING_PRESETS.Frost = {style = "feather", a = C(240, 250, 255), b = C(100, 185, 255), glow = C(160, 215, 255), halo = true, tex = SPARK}
    WING_PRESETS.Inferno = {style = "feather", a = C(255, 238, 175), b = C(255, 80, 25), glow = C(255, 150, 60), halo = true, tex = FIRE,
                            acc = Vector3.new(0, 2.2, 0), psize = 1.6}
    WING_PRESETS.Phoenix = {style = "feather", tail = true, a = C(255, 246, 170), b = C(235, 40, 20), glow = C(255, 170, 50), halo = true,
                            tex = FIRE, acc = Vector3.new(0, 2, 0), psize = 1.7, idle = 0.1}
    WING_PRESETS.Galaxy = {style = "feather", a = C(140, 170, 255), b = C(190, 60, 255), glow = C(150, 120, 255), halo = true,
                           tex = SPARK, pulse = true, prate = 1.8}
    WING_PRESETS.Sakura = {style = "feather", a = C(255, 235, 242), b = C(255, 120, 170), glow = C(255, 170, 200), halo = false,
                           tex = SPARK, acc = Vector3.new(0, -1.6, 0), psize = 1.3}
    WING_PRESETS.Void = {style = "feather", a = C(200, 150, 255), b = C(45, 10, 100), glow = C(175, 95, 255), halo = true, tex = SPARK}
    WING_PRESETS.Demon = {style = "demon", a = C(38, 10, 14), b = C(120, 6, 24), glow = C(255, 45, 30), halo = false,
                          tex = FIRE, acc = Vector3.new(0, 2.4, 0), psize = 1.4, idle = 0.18, flap = 0.8}
    WING_PRESETS.Butterfly = {style = "butterfly", a = C(255, 190, 70), b = C(80, 130, 255), glow = C(255, 210, 130), halo = false,
                              tex = SPARK, idle = 0.75, flap = 1.8}
    WING_PRESETS.Crystal = {style = "crystal", a = C(200, 248, 255), b = C(130, 90, 255), glow = C(170, 225, 255), halo = false,
                            tex = SPARK, idle = 0.2, flap = 0.5}
    WING_PRESETS.Cyber = {style = "cyber", a = C(0, 255, 225), b = C(255, 0, 200), glow = C(0, 255, 225), halo = false,
                          tex = SPARK, pulse = true, idle = 0.1, flap = 0.25}
end
local WING_NAMES = {"Angel", "Frost", "Inferno", "Phoenix", "Galaxy", "Sakura", "Void", "Demon", "Butterfly", "Crystal", "Cyber"}

local aura = {char = nil, folder = nil, core = nil, haloWeld = nil, feathers = {}, emitters = {}, orbs = {}, open = 0}

local function removeAura()
    if aura.folder then pcall(function() aura.folder:Destroy() end) end
    aura = {char = nil, folder = nil, core = nil, haloWeld = nil, feathers = {}, emitters = {}, orbs = {}, open = 0}
end

do
    local PI = math.pi
    local DEF = {y0 = 0.3, y1 = 0.3, ox = 0.3, oy = 0.6, oz = 0.52, tr = 0.1, t = 0, r = 1, th = 0.04}

    local function el(e)
        for k, v in pairs(DEF) do
            if e[k] == nil then e[k] = v end
        end
        if not e.mat then e.mat = Enum.Material.Neon end
        return e
    end

    local function mix(a, b, t) return a:Lerp(b, math.clamp(t, 0, 1)) end

    local GEN = {}

    function GEN.feather(P)
        local E = {}
        local rows = {
            {n = 7, len = 3.8, w = 0.7},
            {n = 6, len = 2.8, w = 0.62},
            {n = 5, len = 1.8, w = 0.55},
        }
        if P.tail then rows[#rows + 1] = {n = 4, len = 1.1, w = 0.5} end
        for r, row in ipairs(rows) do
            for i = 1, row.n do
                local t = (i - 1) / (row.n - 1)
                E[#E + 1] = el({
                    len = row.len * (1 - 0.35 * t), wid = row.w,
                    r0 = 1.28 - t * 0.55 - (r - 1) * 0.06, r1 = 1.15 - t * 1.95 - (r - 1) * 0.1,
                    y0 = 0.75, y1 = 0.22 + (r - 1) * 0.05,
                    oy = 0.62 - (r - 1) * 0.07,
                    color = mix(P.a, P.b, t * 0.65 + (r - 1) * 0.18), tr = 0.06 + (r - 1) * 0.06,
                    t = t, r = r, tip = (r == 1),
                })
            end
        end
        if P.tail then
            local lens = {5.2, 4.4, 3.6}
            for k = 1, 3 do
                E[#E + 1] = el({
                    len = lens[k], wid = 0.55, r0 = -1.1 - k * 0.12, r1 = -0.75 - k * 0.14,
                    y0 = 0.9, y1 = 0.6, oy = 0.1, color = mix(P.a, P.b, 0.4 + k * 0.2), tr = 0.1,
                    t = k / 3, r = 5,
                })
            end
        end
        return E
    end

    function GEN.demon(P)
        local E = {}
        local bone = P.a
        local ARM = 2.9
        E[1] = el({len = ARM, wid = 0.2, th = 0.2, r0 = 1.45, r1 = 1.0, y0 = 0.55, y1 = 0.4, oy = 0.7, oz = 0.55,
                   color = bone, tr = 0, mat = Enum.Material.Slate})
        local lens = {3.6, 4.0, 3.5, 2.7}
        local rel0 = {-0.18, -0.45, -0.72, -1.0}
        local rel1 = {-0.3, -0.85, -1.4, -1.95}
        local n = #lens
        for k = 1, n do
            E[#E + 1] = el({
                len = lens[k], wid = 0.11, th = 0.11, par = 1, plen = ARM, r0 = rel0[k], r1 = rel1[k], y0 = 0, y1 = 0,
                color = bone, tr = 0, mat = Enum.Material.Slate, t = k / n, r = 2, tip = true,
            })
            E[#E + 1] = el({
                len = lens[k] * 0.92, wid = 0.04, th = 0.14, par = 1, plen = ARM, r0 = rel0[k], r1 = rel1[k], y0 = 0, y1 = 0,
                color = P.glow, tr = 0.05, t = k / n, r = 2, pulse = P.pulse,
            })
        end
        for k = 1, n - 1 do
            local m0 = (rel0[k] + rel0[k + 1]) / 2
            local m1 = (rel1[k] + rel1[k + 1]) / 2
            local L = math.min(lens[k], lens[k + 1]) * 0.94
            local gap = math.abs(rel1[k + 1] - rel1[k])
            for s = 1, 4 do
                local rOut = L * s / 4
                E[#E + 1] = el({
                    len = L / 4 + 0.03, wid = 2 * rOut * math.sin(gap / 2), th = 0.025, start = L * (s - 1) / 4,
                    par = 1, plen = ARM, r0 = m0, r1 = m1, y0 = 0, y1 = 0, wvar = true,
                    color = mix(P.b, bone, (s - 1) / 6), tr = 0.16, t = k / n, r = 3,
                })
            end
        end
        E[#E + 1] = el({len = 0.9, wid = 0.1, th = 0.1, par = 1, plen = ARM, r0 = 0.55, r1 = 0.7, y0 = 0, y1 = 0,
                        color = bone, tr = 0, mat = Enum.Material.Slate, t = 0, r = 2})
        return E
    end

    function GEN.butterfly(P)
        local E = {}
        local up, lo = 9, 6
        for i = 1, up do
            local t = (i - 1) / (up - 1)
            E[#E + 1] = el({
                len = 1.8 + 2.0 * math.sin(t * PI * 0.9 + 0.15), wid = 0.95, th = 0.03,
                r0 = 1.55 - t * 0.25, r1 = 1.35 - t * 1.5, y0 = 0.12, y1 = 0.15, oy = 0.7,
                color = mix(P.a, P.b, t), tr = 0.1, t = t, r = 1, tip = true,
            })
        end
        for i = 1, lo do
            local t = (i - 1) / (lo - 1)
            E[#E + 1] = el({
                len = 1.3 + 1.3 * math.sin(t * PI * 0.9 + 0.2), wid = 0.85, th = 0.03,
                r0 = 1.3 - t * 0.2, r1 = -0.1 - t * 0.95, y0 = 0.2, y1 = 0.25, oy = 0.45,
                color = mix(P.b, P.a, t), tr = 0.14, t = t, r = 2,
            })
        end
        return E
    end

    function GEN.crystal(P)
        local E = {}
        local lens = {4.0, 3.2, 3.7, 2.7, 3.0, 2.0, 2.2}
        for i, len in ipairs(lens) do
            local t = (i - 1) / (#lens - 1)
            local r0, r1 = 1.3 - t * 0.45, 1.2 - t * 1.7
            E[#E + 1] = el({
                len = len, wid = 0.34, th = 0.16, r0 = r0, r1 = r1, y0 = 0.55, y1 = 0.25,
                color = mix(P.a, P.b, t), tr = 0.4, t = t, r = 1, tip = true,
            })
            E[#E + 1] = el({
                len = len * 0.92, wid = 0.08, th = 0.2, r0 = r0, r1 = r1, y0 = 0.55, y1 = 0.25,
                color = P.glow, tr = 0.05, t = t, r = 1,
            })
        end
        return E
    end

    function GEN.cyber(P)
        local E = {}
        local lens = {4.4, 3.8, 3.2, 2.6, 2.0}
        for i, len in ipairs(lens) do
            local t = (i - 1) / (#lens - 1)
            local r0, r1 = 1.3 - t * 0.4, 1.0 - t * 1.5
            local col = (i % 2 == 1) and P.a or P.b
            local idx = #E + 1
            E[idx] = el({
                len = len, wid = 0.3, th = 0.12, r0 = r0, r1 = r1, y0 = 0.5, y1 = 0.2,
                color = col, tr = 0.05, t = t, r = 1, tip = true, pulse = true,
            })
            E[#E + 1] = el({
                len = 1.3, wid = 0.22, th = 0.1, par = idx, plen = len, r0 = -0.75, r1 = -0.55, y0 = 0, y1 = 0,
                color = (i % 2 == 1) and P.b or P.a, tr = 0.05, t = t, r = 2, pulse = true,
            })
        end
        return E
    end

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
        local list = (GEN[P.style] or GEN.feather)(P)
        local folder = Instance.new("Folder")
        folder.Name = "NyxAura"
        folder.Parent = char
        local emitters = {}
        local psize, prate = P.psize or 1, P.prate or 1

        local function emitter(parent, rate, size, life, speed, accel, spread, useP)
            local em = Instance.new("ParticleEmitter")
            em.Texture = P.tex or "rbxasset://textures/particles/sparkles_main.dds"
            em.Color = ColorSequence.new(P.glow, P.b)
            size = size * psize
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
            rate = rate * prate
            em.Rate = rate
            em.Speed = NumberRange.new(speed * 0.4, speed)
            em.Acceleration = (useP and P.acc) or accel
            em.SpreadAngle = Vector2.new(spread, spread)
            em.Rotation = NumberRange.new(0, 360)
            em.RotSpeed = NumberRange.new(-80, 80)
            em.LightEmission = 1
            em.LightInfluence = 0
            em.Enabled = CFG.wingParticles
            em.Parent = parent
            emitters[#emitters + 1] = {em = em, rate = rate}
            return em
        end

        -- head anchor (halo + light)
        local core = auraPart(Vector3.new(0.2, 0.2, 0.2), P.a, 1, folder)
        local haloWeld = weld(head, core, CFrame.new(0, 1.15, 0))
        if P.halo then
            local n = 22
            for i = 1, n do
                local a = (i / n) * PI * 2
                local pos = Vector3.new(math.cos(a) * 0.8, 0, math.sin(a) * 0.8)
                local seg = auraPart(Vector3.new(0.14, 0.08, 0.34), P.glow, 0, folder)
                weld(core, seg, CFrame.lookAt(pos, pos + Vector3.new(-math.sin(a), 0, math.cos(a))))
            end
        end
        local light = Instance.new("PointLight")
        light.Color = P.glow
        light.Brightness = 1.8
        light.Range = 12
        light.Parent = core
        emitter(core, 10, 0.28, 1.4, 1.0, Vector3.new(0, 1.2, 0), 180, false)

        -- glitter falling from the back
        local back = auraPart(Vector3.new(0.2, 0.2, 0.2), P.a, 1, folder)
        weld(torso, back, CFrame.new(0, 0.4, 0.7))
        emitter(back, 14, 0.26, 1.8, 1.4, Vector3.new(0, -1.2, 0), 120, true)

        -- wings
        local feathers = {}
        for _, side in ipairs({1, -1}) do
            local made, tips = {}, {}
            for idx, e in ipairs(list) do
                local part = auraPart(Vector3.new(e.len, e.wid, e.th), e.color, e.tr, folder)
                part.Material = e.mat
                local c1 = CFrame.new(-side * ((e.start or 0) + e.len / 2), 0, 0)
                local rt = {
                    w = weld(torso, part, CFrame.new(), c1),
                    e = e, side = side, part = part,
                    par = e.par and made[e.par] or nil,
                    C0 = CFrame.new(), zj = idx * 0.0025,
                }
                made[idx] = rt
                feathers[#feathers + 1] = rt
                if e.tip then
                    local att = Instance.new("Attachment")
                    att.Position = Vector3.new(side * e.len / 2, 0, 0)
                    att.Parent = part
                    tips[#tips + 1] = att
                end
            end
            local nt = #tips
            if nt >= 2 then
                for _, k in ipairs({1, math.ceil(nt / 2), nt}) do
                    emitter(tips[k], 7, 0.34, 1.1, 0.8, Vector3.new(0, -1.4, 0), 180, true)
                end
                local tr = Instance.new("Trail")
                tr.Attachment0, tr.Attachment1 = tips[1], tips[nt]
                tr.Lifetime = 0.45
                tr.MinLength = 0.05
                tr.LightEmission = 1
                tr.LightInfluence = 0
                tr.FaceCamera = true
                tr.Color = ColorSequence.new(P.glow, P.b)
                tr.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.5),
                    NumberSequenceKeypoint.new(1, 1),
                })
                tr.Enabled = CFG.wingParticles
                tr.Parent = tips[1].Parent
                emitters[#emitters + 1] = {trail = tr}
            end
        end

        -- orbiting orbs with trails
        local orbs = {}
        for i = 1, 5 do
            local o = auraPart(Vector3.new(0.3, 0.3, 0.3), P.glow, 0.1, folder)
            o.Shape = Enum.PartType.Ball
            local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
            a0.Position, a1.Position = Vector3.new(0, 0.15, 0), Vector3.new(0, -0.15, 0)
            a0.Parent, a1.Parent = o, o
            local tr = Instance.new("Trail")
            tr.Attachment0, tr.Attachment1 = a0, a1
            tr.Lifetime = 0.6
            tr.LightEmission = 1
            tr.LightInfluence = 0
            tr.FaceCamera = true
            tr.Color = ColorSequence.new(P.glow, P.b)
            tr.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(1, 1),
            })
            tr.Parent = o
            orbs[i] = {w = weld(torso, o, CFrame.new()), o = o, tr = tr, ph = i * PI * 2 / 5}
        end

        aura = {char = char, folder = folder, core = core, haloWeld = haloWeld,
                feathers = feathers, emitters = emitters, orbs = orbs, open = 0, P = P}
        for _, e in ipairs(emitters) do
            if e.em then pcall(function() e.em:Emit(10) end) end
        end
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
        local P = aura.P
        local hrp = c:FindFirstChild("HumanoidRootPart")
        local speed = hrp and hrp.AssemblyLinearVelocity.Magnitude or 0
        local target = CFG.fly and 1 or math.clamp(speed / 18, 0, 1)
        target = math.max(target, P.idle or 0)
        aura.open += (target - aura.open) * math.min(dt * 6, 1)
        local open = aura.open
        local now = tick()
        local t = now * CFG.auraSpeed
        local tt = t * (3 + open * 4)
        local amp = (0.06 + open * 0.22) * (P.flap or 1)

        aura.haloWeld.C0 = CFrame.new(0, 1.15 + math.sin(t * 2) * 0.06, 0) * CFrame.Angles(0, t * 2, 0)

        for _, rt in ipairs(aura.feathers) do
            local e, side = rt.e, rt.side
            local wave = math.sin(tt - e.t * 0.9 - e.r * 0.4) * amp
            if e.par then wave *= 0.5 end
            local roll = e.r0 + (e.r1 - e.r0) * open + wave
            local yaw = e.y0 + (e.y1 - e.y0) * open + math.sin(tt - e.t) * amp * 0.3
            local c0
            if rt.par then
                c0 = rt.par.C0 * CFrame.new(side * e.plen, 0, rt.zj) * CFrame.Angles(0, -side * yaw, side * roll)
            else
                c0 = CFrame.new(side * e.ox, e.oy, e.oz + rt.zj) * CFrame.Angles(0, -side * yaw, side * roll)
            end
            rt.C0 = c0
            rt.w.C0 = c0
            if e.wvar then
                local k = 0.4 + 0.6 * open
                if not rt.k or math.abs(k - rt.k) > 0.02 then
                    rt.k = k
                    rt.part.Size = Vector3.new(e.len, e.wid * k, e.th)
                end
            end
            if e.pulse then
                rt.part.Transparency = e.tr + (1 - e.tr) * 0.5 * (0.5 + 0.5 * math.sin(now * 3 - e.t * 5))
            end
        end

        local ot = now * 1.4
        for _, ob in ipairs(aura.orbs) do
            local a = ot + ob.ph
            ob.w.C0 = CFrame.new(math.cos(a) * 2.4, math.sin(ot * 1.3 + ob.ph * 2) * 1.3, math.sin(a) * 2.4)
            ob.o.Transparency = CFG.wingOrbs and 0.1 or 1
            ob.tr.Enabled = CFG.wingOrbs
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

local HELPER_NAMES = {"Fairy", "Bat", "Orb"}
local helper = {}

local function removeHelper()
    if helper.folder then pcall(function() helper.folder:Destroy() end) end
    helper = {}
end

do
    local function hpart(size, color, tr, ball, mat)
        local p = Instance.new("Part")
        p.Size = size
        p.Color = color
        p.Transparency = tr
        p.Material = mat or Enum.Material.Neon
        if ball then p.Shape = Enum.PartType.Ball end
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.CastShadow = false
        return p
    end

    local function buildHelper()
        removeHelper()
        local P = WING_PRESETS[CFG.wingPreset] or WING_PRESETS.Angel
        local S = CFG.helperSize
        local style = CFG.helperStyle
        local folder = Instance.new("Folder")
        folder.Name = "NyxHelper"
        folder.Parent = workspace
        local rel = {}
        local function add(part, cf, kind, side, len, ph)
            part.Parent = folder
            rel[#rel + 1] = {p = part, cf = cf, kind = kind or "fix", side = side or 1, len = len or 1, ph = ph or 0}
            return part
        end
        local black = Color3.fromRGB(8, 8, 12)
        local body

        if style == "Bat" then
            body = add(hpart(Vector3.new(0.9, 0.8, 0.9) * S, Color3.fromRGB(30, 8, 18), 0, true, Enum.Material.SmoothPlastic), CFrame.new())
            for _, sd in ipairs({1, -1}) do
                add(hpart(Vector3.new(0.16, 0.2, 0.16) * S, Color3.fromRGB(255, 40, 40), 0, true),
                    CFrame.new(sd * 0.2 * S, 0.1 * S, -0.4 * S))
                add(hpart(Vector3.new(0.16, 0.5, 0.16) * S, Color3.fromRGB(20, 5, 10), 0, false, Enum.Material.SmoothPlastic),
                    CFrame.new(sd * 0.28 * S, 0.5 * S, -0.05 * S) * CFrame.Angles(0, 0, -sd * 0.35))
                for k = 1, 2 do
                    local len = (k == 1 and 1.7 or 1.2) * S
                    add(hpart(Vector3.new(len, 0.8 * S, 0.03), P.b, 0.15, false),
                        CFrame.new(sd * 0.4 * S, (k == 1 and 0.2 or -0.1) * S, 0.2 * S) * CFrame.Angles(0, -sd * 0.5, 0),
                        "wing", sd, len, k)
                end
            end
        elseif style == "Orb" then
            body = add(hpart(Vector3.new(1.1, 1.1, 1.1) * S, P.glow, 0.05, true), CFrame.new())
            add(hpart(Vector3.new(0.5, 0.5, 0.5) * S, Color3.new(1, 1, 1), 0, true, Enum.Material.SmoothPlastic),
                CFrame.new(0, 0, -0.45 * S))
            add(hpart(Vector3.new(0.24, 0.24, 0.24) * S, black, 0, true, Enum.Material.SmoothPlastic),
                CFrame.new(0, 0, -0.66 * S))
            for k = 1, 3 do
                add(hpart(Vector3.new(0.22, 0.22, 0.22) * S, P.a, 0.1, true), CFrame.new(), "orbit", 1, 1.0 * S, k * 2.1)
            end
        else
            body = add(hpart(Vector3.new(0.8, 0.8, 0.8) * S, P.glow, 0, true), CFrame.new())
            for _, sd in ipairs({1, -1}) do
                add(hpart(Vector3.new(0.14, 0.18, 0.14) * S, black, 0, true, Enum.Material.SmoothPlastic),
                    CFrame.new(sd * 0.17 * S, 0.08 * S, -0.34 * S))
                for k = 1, 2 do
                    local len = (k == 1 and 1.5 or 1.0) * S
                    add(hpart(Vector3.new(len, 0.7 * S, 0.03), k == 1 and P.a or P.b, 0.3, false),
                        CFrame.new(sd * 0.3 * S, (k == 1 and 0.2 or -0.05) * S, 0.15 * S) * CFrame.Angles(0, -sd * 0.5, 0),
                        "wing", sd, len, k)
                end
            end
            add(hpart(Vector3.new(0.18, 0.18, 0.18) * S, P.a, 0, true), CFrame.new(0, 0.55 * S, 0))
        end

        local em = Instance.new("ParticleEmitter")
        em.Texture = P.tex or "rbxasset://textures/particles/sparkles_main.dds"
        em.Color = ColorSequence.new(P.glow, P.b)
        em.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.35 * S),
            NumberSequenceKeypoint.new(1, 0),
        })
        em.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(1, 1),
        })
        em.Lifetime = NumberRange.new(0.6, 1.1)
        em.Rate = 22
        em.Speed = NumberRange.new(0.2, 1)
        em.SpreadAngle = Vector2.new(180, 180)
        em.LightEmission = 1
        em.LightInfluence = 0
        em.Parent = body

        local light = Instance.new("PointLight")
        light.Color = P.glow
        light.Brightness = 1.5
        light.Range = 9
        light.Parent = body

        local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
        a0.Position, a1.Position = Vector3.new(0, 0.3 * S, 0.2 * S), Vector3.new(0, -0.3 * S, 0.2 * S)
        a0.Parent, a1.Parent = body, body
        local tr = Instance.new("Trail")
        tr.Attachment0, tr.Attachment1 = a0, a1
        tr.Lifetime = 0.7
        tr.LightEmission = 1
        tr.LightInfluence = 0
        tr.FaceCamera = true
        tr.Color = ColorSequence.new(P.glow, P.b)
        tr.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 1),
        })
        tr.Parent = body

        helper = {folder = folder, rel = rel, pos = nil, cf = nil}
    end

    connect(RunService.Heartbeat, function(dt)
        if not CFG.helper then
            if helper.folder then removeHelper() end
            return
        end
        local c = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not helper.folder or not helper.folder.Parent then
            pcall(buildHelper)
            return
        end
        local t = os.clock()
        local hp = hrp.Position
        local a = t * 0.7
        local target = hp + Vector3.new(math.cos(a) * 3.6, 2.9 + math.sin(t * 2.1) * 0.45, math.sin(a) * 3.6)
        local old = helper.pos or target
        if (old - hp).Magnitude > 60 then old = target end
        local pos = old:Lerp(target, 1 - math.exp(-dt * 4.5))
        local vel = (pos - old) / math.max(dt, 1e-3)
        helper.pos = pos
        local lookAt = (vel.Magnitude > 4) and (pos + vel) or (hp + Vector3.new(0, 1.5, 0))
        local cf = CFrame.lookAt(pos, lookAt)
        helper.cf = helper.cf and helper.cf:Lerp(cf, 1 - math.exp(-dt * 8)) or cf
        local base = helper.cf
        for _, r in ipairs(helper.rel) do
            if r.kind == "wing" then
                local fl = math.sin(t * 14 + r.ph) * 0.55
                r.p.CFrame = base * r.cf * CFrame.Angles(0, 0, r.side * fl) * CFrame.new(r.side * r.len / 2, 0, 0)
            elseif r.kind == "orbit" then
                local o = t * 3 + r.ph
                r.p.CFrame = base * CFrame.new(math.cos(o) * r.len, math.sin(t * 2 + r.ph) * 0.3, math.sin(o) * r.len)
            else
                r.p.CFrame = base * r.cf
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

-- spin (CFrame based, works with any speed)
local spinAR
local spinLast = os.clock()

local function spinStop()
    local _, hum = myHrp()
    if hum and spinAR ~= nil then hum.AutoRotate = spinAR end
    spinAR = nil
end

connect(PRE_SIM, function()
    local now = os.clock()
    local dt = math.min(now - spinLast, 0.1)
    spinLast = now
    local hrp, hum = myHrp()
    if not hrp or not hum then return end
    if not CFG.spinOn or hum.Health <= 0 or holding then
        if spinAR ~= nil then spinStop() end
        return
    end
    if spinAR == nil then spinAR = hum.AutoRotate end
    hum.AutoRotate = false
    local ang = (CFG.spinSpeed * dt) % (math.pi * 2)
    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, ang, 0)
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
dd(tabAim, "WallBang method", WB_METHODS, CFG.wbMethod, function(v)
    CFG.wbMethod = (type(v) == "table" and v[1]) or v
end)
sec(tabAim, "Auto shoot")
if tabAim then
    pcall(function()
        tabAim:Toggle({Title = "Auto Shoot (shows button)", Value = false, Callback = function(v)
            setShootBtn(v)
        end})
    end)
end
sld(tabAim, "Shoot delay", "shootDelay", 0.3, 4, 0.1)
sld(tabAim, "Shoot range (no WallBang)", "shootMax", 100, 1500, 50)

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
    removeHelper()
end)
tog(tabCos, "Wing particles", "wingParticles")
tog(tabCos, "Orbiting orbs", "wingOrbs")
sld(tabCos, "Wing speed", "auraSpeed", 0.5, 3, 0.1)
sec(tabCos, "Flying helper")
tog(tabCos, "Helper", "helper")
dd(tabCos, "Helper style", HELPER_NAMES, CFG.helperStyle, function(v)
    CFG.helperStyle = (type(v) == "table" and v[1]) or v
    removeHelper()
end)
sld(tabCos, "Helper size", "helperSize", 0.5, 3, 0.1, function() removeHelper() end)

local tabSnd = newTab("Sound", "volume-2")
sec(tabSnd, "Mode")
tog(tabSnd, "Replace Gun / Knife sounds", "replaceSnd", function(v)
    if not v then pcall(SND.restore) end
end)
tog(tabSnd, "Also play on kill", "killSnd")
sec(tabSnd, "Gun")
dd(tabSnd, "Gun sound", SND.gunNames, CFG.gunSnd, function(v)
    CFG.gunSnd = (type(v) == "table" and v[1]) or v
end)
sld(tabSnd, "Gun volume", "gunVol", 0, 5, 0.1)
btn(tabSnd, "Test gun sound", function() SND.play(SND.gun[CFG.gunSnd], CFG.gunVol) end)
sec(tabSnd, "Knife")
dd(tabSnd, "Knife sound", SND.knifeNames, CFG.knifeSnd, function(v)
    CFG.knifeSnd = (type(v) == "table" and v[1]) or v
end)
sld(tabSnd, "Knife volume", "knifeVol", 0, 5, 0.1)
btn(tabSnd, "Test knife sound", function() SND.play(SND.knife[CFG.knifeSnd], CFG.knifeVol) end)
sec(tabSnd, "Debug")
btn(tabSnd, "Print Gun / Knife sounds", function() notify("Tool sounds", SND.dump()) end)

local tabMisc = newTab("Misc", "settings")
btn(tabMisc, "Unload", function()
    if genv.NyxWind then genv.NyxWind() end
end)

setShootBtn(false)

genv.NyxWind = function()
    running = false
    for _, k in ipairs({"autoShoot", "autoGun", "autoKill", "farm", "fly", "noclip", "aa",
                        "wsOn", "jpOn", "bhop", "spinOn", "xray", "aura", "helper", "trail", "shotTrail", "silent"}) do
        CFG[k] = false
    end
    ST.on, ST.aimPos, ST.target = false, nil, nil
    pcall(goVisible)
    pcall(flyStop)
    pcall(spinStop)
    pcall(aaRestore)
    pcall(xrRestore)
    pcall(shadersOff)
    pcall(removeAura)
    pcall(removeHelper)
    pcall(SND.restore)
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
