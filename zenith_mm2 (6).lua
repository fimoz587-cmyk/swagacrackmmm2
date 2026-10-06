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
for _, k in ipairs({"ZenithWind", "SwagaWind", "NyxWind", "NyxSE", "NyxFull", "NyxFarm", "NyxAll", "NyxESP", "NyxSA", "NyxKA", "NyxFling"}) do
    if genv[k] then pcall(genv[k]) end
end

local CFG = {
    esp = true, box = true, skeleton = true, highlight = true, name = true, dist = true,
    tracer = true, health = true, gun = true, showInnocent = true, maxDist = 800, skelDist = 150,
    silent = true, wallbang = true, silentMethod = "Pro", burst = false, predMul = 1, aimHeight = 0.5, silentHud = true,
    knifeSilent = true, knifeWB = false, knifeLead = 0.03, knifeSpeed = 100, knifeFov = 70, knifeMode = "Crosshair",
    farm = false, coinEsp = true, coinHighlight = true, coinTracer = true, coinTracerDist = 200, farmUnder = true,
    autoGun = true, autoKill = false, auraRange = 30, auraTp = false, stabReach = 6,
    farmSpeed = 26, vSpeed = 45, depth = 7, gunSpeed = 150, pickDist = 400,
    killSpeed = 70, killRange = 250, hitDelay = 0.15, maxTries = 2,
    maxCoins = 40, coinRange = 1500, dangerDist = 30,
    bhop = false, bhopSpeed = 30, spinOn = false, spinSpeed = 200,
    killSnd = true, replaceSnd = true, gunSnd = "SFX Hit", gunVol = 2.5, knifeSnd = "Among Us Kill", knifeVol = 1.5,
    autoShoot = false, shootBtn = false, shootDelay = 1.2, ghostTransp = 0.5, pickTime = 0.25, shootMax = 600,
    shaders = false, blackSky = true, fogOn = true, fog = 350, density = 0.45,
    bloom = 1.6, contrast = 0.3, sat = 0.4, dof = 0.12, bright = 1.6,
    trail = false, trailLife = 0.8, trailTransp = 0.72, trailSmoke = true,
    shotTrail = false, shotLife = 1.2,
    aura = false, wings3d = false, auraSpeed = 1.2, wingX = 0, wingY = 0, wingZ = 0, wingIdle = 0.3, wingYaw = 0.25, wingPreset = "Angel", wingParticles = true, wingOrbs = true,
    helper = false, helperStyle = "Fairy", helperSize = 1,
    noclip = false, fly = false, flySpeed = 60, wsOn = false, walkSpeed = 24, jpOn = false, jumpPower = 70,
    xray = false, xrayTransp = 0.5,
    hackerRetry = false,
    flingAuto = false, antiFling = false, spin = 80000, flingTime = 2.2, killVel = 180, flingCooldown = 6,
    bodyGlow = false, glowColor = "Rainbow", crown = false, groundRing = false, ringColor = "Cyan",
    elemAura = false, elemType = "Fire", nameTag = false, nameTagText = "Zenith", trailColor = "Purple",
    gunCustom = "", knifeCustom = "", killCustom = "", killSndName = "Among Us Kill", killVol = 2,
    orbitStars = false, auraSphere = false, footSparkle = false,
    trailMode = "Chams", powerAura = false, auraStyle = "Super Saiyan",
    hitboxOn = false, hitboxSize = 8, reachOn = false, reachSize = 8,
    roleNotify = true, murderAlert = false, alertDist = 35, fullbright = false, fovOn = false, fov = 90,
    antiAfk = true, infJump = false,
    chamsStyle = "Highlight", chamsColor = "Role", weaponEsp = true, weaponStyle = "Chams", knifeColor = "Red", gunColor = "Blue",
    trailDelay = 0.35,
    droneType = "FPV", droneTarget = "Any (auto)", droneTpKill = true, droneCam = "First person", droneInfBat = false, droneCamDist = 9,
    knifeSkinName = "None", gunSkinName = "None", droneNoclip = false, knifeLib = "None", gunLib = "None", skinCapture = true, knifeDB = "None", gunDB = "None",
    aaOn = false, aaType = "Body", aaMode = "Up", aaAngle = 75, aaRandRate = 0.12,
    speedGlitch = false, sgSpeed = 45, sgAutoJump = false,
    ribbon = false, ribbonColor = "Rainbow", ribbonLife = 0.6, potato = false,
    emote = "Salute", emoteLoop = false, emoteSpeed = 1,
    animPack = "Default", animIdle = "Default", animWalk = "Default", animRun = "Default", animJump = "Default", animFall = "Default", animClimb = "Default",
    gunSkin = false, gunSkinId = "11006944635", gunSkinScale = 1, gunSkinRot = 0,
    knifeSkin = false, knifeSkinId = "", knifeSkinScale = 1, knifeSkinRot = 0,
    customChar = false, charModelId = "84115454229681", charScale = 1, charYaw = 0, charY = 0,
    chinaHat = false, hatColor = "Rainbow",
    watermark = true, wmTimer = true,
    specMurd = false, specSher = false, gunNotify = true,
    lang = "EN", theme = "Dark",
}
local COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff = Color3.fromRGB(60, 130, 255),
    Hero = Color3.fromRGB(255, 220, 60),
    Innocent = Color3.fromRGB(80, 255, 120),
}
local BLACK = Color3.new(0, 0, 0)
local GOLD = Color3.fromRGB(255, 215, 60)
local COLOR_MAP = {
    Dark = Color3.fromRGB(40, 40, 46), Red = Color3.fromRGB(255, 50, 60), Blue = Color3.fromRGB(60, 130, 255),
    Green = Color3.fromRGB(70, 255, 120), Purple = Color3.fromRGB(170, 90, 255), Cyan = Color3.fromRGB(60, 240, 255),
    White = Color3.fromRGB(255, 255, 255), Gold = Color3.fromRGB(255, 205, 60), Pink = Color3.fromRGB(255, 110, 190),
}
local COLOR_NAMES = {"Rainbow", "Red", "Blue", "Green", "Purple", "Cyan", "White", "Gold", "Pink"}
local TRAIL_NAMES = {"Dark", "Rainbow", "Red", "Blue", "Green", "Purple", "Cyan", "White", "Gold", "Pink"}
local function colorOf(name)
    local c = COLOR_MAP[name]
    if c then return c end
    return Color3.fromHSV((tick() * 0.25) % 1, 0.85, 1)
end

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

local ST = genv.ZenithWindST or {}
genv.ZenithWindST = ST
ST.rec = ST.rec or {}
ST.on, ST.aimPos, ST.target = CFG.silent, nil, nil

local WB_METHODS = {"Hacker", "Pro", "Quiet"}

local stRP = RaycastParams.new()
stRP.FilterType = Enum.RaycastFilterType.Exclude
ST.hist = ST.hist or setmetatable({}, {__mode = "k"})
ST.knifeSpeed = 100

function ST.passDown(old, ...)
    local prev = ST.on
    ST.on = false
    local ok, err = pcall(old, ...)
    ST.on = prev
    if not ok then error(err, 0) end
end

-- horizontal velocity: replicated one, or measured from displayed positions
function ST.velOf(t)
    local r = ST.hist[t]
    local v = t.AssemblyLinearVelocity
    local av = Vector3.new(v.X, 0, v.Z)
    local hv = r and Vector3.new(r.v.X, 0, r.v.Z) or Vector3.zero
    if av.Magnitude < 1 and hv.Magnitude > 4 then av = hv end
    return av, v.Y
end

local function predict(t, k, extra)
    local fv, vy = ST.velOf(t)
    local lead = (math.clamp(ST.ping or 0.08, 0, 0.6) + 0.1) * k + (extra or 0)
    local p = t.Position + fv * lead
    if math.abs(vy) > 3 then
        local dy = vy * lead - 0.5 * 196.2 * lead * lead
        p += Vector3.new(0, math.clamp(dy, -6, 6), 0)
    end
    return p, fv
end

-- returns a list of {originPos or nil, aimPos}; [1] is the main shot
function ST.calcAll(me, t, wb)
    local pred = predict(t, CFG.predMul or 1)
    pred = pred + Vector3.new(0, CFG.aimHeight or 0.5, 0)
    local toT = pred - me
    local dirMe = toT.Magnitude > 0.01 and toT.Unit or Vector3.new(0, 0, -1)

    local blocked = false
    if wb then
        local ignore = {t.Parent}
        if lp.Character then ignore[2] = lp.Character end
        stRP.FilterDescendantsInstances = ignore
        blocked = workspace:Raycast(me, toT, stRP) ~= nil
    end

    local method = CFG.silentMethod
    local out = {}
    if blocked and method ~= "Quiet" then
        out[1] = {pred - dirMe * 2.5, pred + dirMe * 3}
    else
        out[1] = {nil, pred + dirMe * 2}
    end
    if method == "Hacker" and CFG.burst then
        local side = Vector3.new(-dirMe.Z, 0, dirMe.X)
        for _, off in ipairs({side * 0.9, -side * 0.9, Vector3.new(0, 1.2, 0)}) do
            local p = pred + off
            out[#out + 1] = {out[1][1] and (p - dirMe * 2.5) or nil, p + dirMe * 2}
        end
    end
    return out
end

function ST.knifeTarget(origin, dir)
    local best, bestScore = nil, math.huge
    local du = dir.Unit
    local maxAng = math.rad(CFG.knifeFov or 70)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and (not ST.inRound or ST.inRound(p)) then
            local c = p.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if h and h.Health > 0 and r then
                local d = r.Position - origin
                local dist = d.Magnitude
                if dist > 0.5 and dist < 500 then
                    local score
                    if CFG.knifeMode == "Nearest" then
                        score = dist
                    else
                        local ang = math.acos(math.clamp(du:Dot(d.Unit), -1, 1))
                        if ang <= maxAng then score = ang + dist / 600 end
                    end
                    if score and score < bestScore then best, bestScore = r, score end
                end
            end
        end
    end
    return best
end

function ST.knifeRewrite(args)
    local first, second
    for i = 1, args.n do
        local ty = typeof(args[i])
        if ty == "CFrame" or ty == "Vector3" then
            if not first then
                first = i
            else
                second = i
                break
            end
        end
    end
    if not first then error("no position") end
    local a1 = args[first]
    local origin = typeof(a1) == "CFrame" and a1.Position or a1
    local dir
    if second then
        local a2 = args[second]
        dir = (typeof(a2) == "CFrame" and a2.Position or a2) - origin
    elseif typeof(a1) == "CFrame" then
        dir = a1.LookVector
    end
    if not dir or dir.Magnitude < 0.01 then
        local c0 = workspace.CurrentCamera
        dir = c0 and c0.CFrame.LookVector or Vector3.new(0, 0, -1)
    end
    local t = ST.knifeTarget(origin, dir)
    if not t then return end

    local spd = math.max(CFG.knifeSpeed, 10)
    local pred, fv = t.Position, Vector3.zero
    local travel = (pred - origin).Magnitude / spd
    for _ = 1, 4 do
        pred, fv = predict(t, CFG.predMul or 1, travel + CFG.knifeLead)
        travel = (pred - origin).Magnitude / spd
    end
    pred = pred + Vector3.new(0, CFG.aimHeight or 0.5, 0)
    local d = pred - origin
    d = d.Magnitude > 0.01 and d.Unit or dir.Unit

    local newO, aim = origin, pred + d * 2
    if CFG.knifeWB then
        stRP.FilterDescendantsInstances = {t.Parent, lp.Character}
        if workspace:Raycast(origin, pred - origin, stRP) then
            newO, aim = pred - d * 3, pred + d * 3
        end
    end
    if typeof(a1) == "CFrame" then
        args[first] = CFrame.lookAt(newO, aim)
    else
        args[first] = newO
    end
    if second then
        if typeof(args[second]) == "CFrame" then args[second] = CFrame.new(aim) else args[second] = aim end
    end
end

function ST.isKnifeThrow(r, pn, ...)
    if pn == "Knife" then
        -- direct child of the tool
    elseif pn == "Events" then
        local tool = r.Parent and r.Parent.Parent
        if not (tool and tool.Name == "Knife") then return false end
    else
        return false
    end
    local cnt = 0
    for i = 1, select("#", ...) do
        local ty = typeof((select(i, ...)))
        if ty == "CFrame" or ty == "Vector3" then cnt += 1 end
    end
    if cnt == 0 then return false end
    return r.Name:lower():find("throw", 1, true) ~= nil or cnt >= 2
end

ST.CFG = CFG
if ST.hookVer ~= 5 and hookmetamethod and getnamecallmethod then
    ST.hookVer = 5
    genv.ZenithWindHook = true
    local wrap = newcclosure or function(f) return f end
    local old
    old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
        local m = getnamecallmethod()
        if (m == "FireServer" or m == "InvokeServer") and not checkcaller()
           and typeof(self) == "Instance" then
            local par = self.Parent
            if par then
                local pn = par.Name
                if m == "FireServer" and ST.CFG.knifeSilent and ST.isKnifeThrow(self, pn, ...) then
                    local args = table.pack(...)
                    local ok = pcall(ST.knifeRewrite, args)
                    if setnamecallmethod then setnamecallmethod(m) end
                    if ok then return ST.passDown(old, self, table.unpack(args, 1, args.n)) end
                elseif ST.on and ST.target and ST.target.Parent and m == "FireServer"
                   and self.Name == "Shoot" and pn == "Gun" then
                    local args = table.pack(...)
                    local pend
                    local ok = pcall(function()
                        local first, second
                        for i = 1, args.n do
                            if typeof(args[i]) == "CFrame" then
                                if not first then
                                    first = i
                                else
                                    second = i
                                    break
                                end
                            end
                        end
                        if not first then error("no cframe") end
                        local me = args[first].Position
                        local list = ST.calcAll(me, ST.target, ST.CFG.wallbang or ST.CFG.silentMethod == "Hacker")
                        ST.aimPos = list[1][2]
                        local function make(v)
                            local a = table.pack(table.unpack(args, 1, args.n))
                            a[first] = CFrame.lookAt(v[1] or me, v[2])
                            if second then a[second] = CFrame.new(v[2]) end
                            return a
                        end
                        pend = {}
                        for i = 2, #list do pend[#pend + 1] = make(list[i]) end
                        args = make(list[1])
                    end)
                    if setnamecallmethod then setnamecallmethod(m) end
                    if ok then
                        local r = ST.passDown(old, self, table.unpack(args, 1, args.n))
                        ST.lastShot = {r = self, t = tick(), n = 0}
                        if ST.gunSound then task.spawn(ST.gunSound) end
                        for _, x in ipairs(pend or {}) do
                            if setnamecallmethod then setnamecallmethod(m) end
                            ST.passDown(old, self, table.unpack(x, 1, x.n))
                        end
                        return r
                    end
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
        if setnamecallmethod then setnamecallmethod(m) end
        return old(self, ...)
    end))
end

local roles, E = {}, {}
local deadF = {}
local function inRound(p)
    if deadF[p] then return false end
    if next(roles) ~= nil and roles[p] == nil then return false end
    return true
end
ST.inRound = inRound
local coins, visited, danger, circles, lines, hls = {}, {}, {}, {}, {}, {}
local seenVis, born = {}, {}
local cooldown, orig = {}, {}
local sheriffGone, got = false, 0
local drop, dropPos
local busy, holding, flinging, under, home = false, false, false, false, nil
local lastPick, lastShot, lastGunFire = 0, 0, 0
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
        if p and typeof(d) == "table" then
            deadF[p] = (d.Dead == true or d.Killed == true) or nil
        end
    end
end

local function resetRound()
    table.clear(roles)
    table.clear(deadF)
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
    if FX.fastPick then task.spawn(FX.fastPick) end
    if CFG.gunNotify and FX.notify then task.spawn(FX.notify, "Zenith", "Gun dropped!") end
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
    born[i] = tick()
    connect(i.ChildRemoved, function(ch)
        if ch:IsA("TouchTransmitter") then visited[i] = true end
    end)
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
    coins[i], visited[i], danger[i], seenVis[i], born[i] = nil, nil, nil, nil, nil
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

local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude

do
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

    local hstyle = CFG.chamsStyle
    local ccol = (CFG.chamsColor == "Role") and color or colorOf(CFG.chamsColor)
    e.matColor = ccol
    if CFG.highlight and (hstyle == "Highlight" or hstyle == "Chams" or hstyle == "Outline") then
        if not e.hl or e.hl.Parent ~= c then
            local hl = Instance.new("Highlight")
            hl.Name = "ESP"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = c
            e.hl = hl
        end
        e.hl.FillColor, e.hl.OutlineColor = ccol, ccol
        e.hl.FillTransparency = (hstyle == "Chams" and 0.2) or (hstyle == "Outline" and 1) or 0.55
        e.hl.OutlineTransparency = 0
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

    for _, e in pairs(E) do
        local h = e.hrp
        if h and h.Parent then
            local pos = h.Position
            local rec = ST.hist[h]
            if rec then
                local dt = now - rec.t
                if dt > 0.0005 then
                    local nv = (pos - rec.p) / dt
                    if nv.Magnitude > 150 then nv = Vector3.zero end
                    rec.v = rec.v:Lerp(nv, math.min(1, dt * 14))
                    rec.p, rec.t = pos, now
                end
            else
                ST.hist[h] = {p = pos, t = now, v = Vector3.zero}
            end
        end
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
end

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
        if hrp and not hrp:FindFirstChild("ZenithHold") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "ZenithHold"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
        end
        if hum then hum.PlatformStand = true end
    else
        holding = false
        if hrp then
            local bv = hrp:FindFirstChild("ZenithHold")
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
    return lp.Character
end

connect(lp.CharacterAdded, function(c)
    holding, under, home = false, false, nil
    table.clear(orig)
end)

local function pickReady()
    if not CFG.autoGun then return false end
    if not (drop and drop.Parent) then return false end
    if roles[lp] == nil or roles[lp] == "Murderer" or hasKnife() then return false end
    return tick() - lastPick >= 0.6
end

local function pickGun()
    if busy or picking or not pickReady() then return end
    local d = drop
    local part = d and partOf(d)
    if not part then return end
    local hrp, hum = myHrp()
    if not hrp or not hum or hum.Health <= 0 then return end
    if (part.Position - hrp.Position).Magnitude > CFG.pickDist then return end
    picking, busy = true, true
    lastPick = tick()
    local back = hrp.CFrame
    pcall(function()
        hrp.CFrame = part.CFrame * CFrame.new(0, 1.2, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero
        local s0 = tick()
        repeat
            touch(hrp, part)
            RunService.Heartbeat:Wait()
        until not d.Parent or not part.Parent or hum.Health <= 0 or tick() - s0 > CFG.pickTime
    end)
    if hrp.Parent and hum.Health > 0 then
        hrp.CFrame = back
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    picking, busy = false, false
end

FX.fastPick = function()
    pcall(pickGun)
end

local function rawAlive(c)
    if not c.Parent then return false end
    if seenVis[c] then
        local vis = c:FindFirstChild("CoinVisual")
        if not vis then return false end
        if vis:IsA("BasePart") and vis.Transparency < 0.99 then return true end
        for _, d in ipairs(vis:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 0.99 then return true end
        end
        return false
    end
    return c:FindFirstChildOfClass("TouchTransmitter") ~= nil
end

task.spawn(function()
    while running do
        local now = tick()
        for c in pairs(coins) do
            if not visited[c] then
                if seenVis[c] == nil and c:FindFirstChild("CoinVisual") then seenVis[c] = true end
                if now - (born[c] or now) > 1.5 and not rawAlive(c) then visited[c] = true end
            end
        end
        task.wait(0.25)
    end
end)

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

local farmCont
local function farmStep()
    local hrp, hum = myHrp()
    if busy or picking or not hrp or not hum or hum.Health <= 0 then return false end
    local coin = nearestCoin(hrp)
    if not coin then return true end
    if coin.Parent ~= farmCont then
        farmCont = coin.Parent
        got = 0
    end
    if got >= CFG.maxCoins then return true end
    busy = true
    local okRun = pcall(function()
        if not under then home = hrp.CFrame end
        local pos = coin.Position
        local function keep()
            return CFG.farm and coin.Parent ~= nil and not visited[coin] and not pickReady()
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
            local t0 = tick()
            repeat
                hrp.CFrame = CFrame.new(coin.Position)
                hrp.AssemblyLinearVelocity = Vector3.zero
                touch(hrp, coin)
                RunService.Heartbeat:Wait()
            until visited[coin] or not coin.Parent or hum.Health <= 0 or tick() - t0 > 0.7
            if visited[coin] or not rawAlive(coin) then got += 1 end
            visited[coin] = true
            home = hrp.CFrame
            if CFG.farmUnder then
                goTo(CFrame.new(hrp.Position.X, ug, hrp.Position.Z), CFG.vSpeed + 20, nil)
                under = true
            end
        elseif not danger[coin] and not visited[coin] then
            cooldown[coin] = (cooldown[coin] or 0) + 1
            if cooldown[coin] >= 3 then visited[coin] = true end
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

local function killAuraStep(onlyP)
    local hrp, hum = myHrp()
    if busy or picking or not hrp or not hum or hum.Health <= 0 then return end
    local knife = hasKnife()
    if not knife then return end
    local reach = CFG.auraRange
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local c, r, h = aliveChar(p)
            if c then
                local d = (r.Position - hrp.Position).Magnitude
                if d <= reach and inRound(p) then list[#list + 1] = {p = p, d = d} end
            end
        end
    end
    if onlyP then
        list = {}
        local oc, orr = aliveChar(onlyP)
        if oc then list[1] = {p = onlyP, d = (orr.Position - hrp.Position).Magnitude} end
    end
    if #list == 0 then return end
    table.sort(list, function(a, b) return a.d < b.d end)
    busy = true
    local okRun = pcall(function()
        if knife.Parent ~= lp.Character then
            hum:EquipTool(knife)
            task.wait(0.12)
        end
        knife = lp.Character and lp.Character:FindFirstChild("Knife")
        if not knife then return end
        local handle = knife:FindFirstChild("Handle")
        local ev = knife:FindFirstChild("Events")
        local recorded = {}
        if ev then
            for _, r in ipairs(ev:GetChildren()) do
                if (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) and not r.Name:lower():find("throw", 1, true) then
                    local rec = pickRec(ST.rec[r.Name])
                    if rec then recorded[#recorded + 1] = {r, rec} end
                end
            end
        end
        local back = hrp.CFrame
        local moved = false
        for _, t in ipairs(list) do
            if hum.Health <= 0 or not CFG.autoKill then break end
            local tries = 0
            while tries < CFG.maxTries and CFG.autoKill do
                local c, r, h = aliveChar(t.p)
                if not c then break end
                if CFG.auraTp and (r.Position - hrp.Position).Magnitude > CFG.stabReach then
                    hrp.CFrame = r.CFrame * CFrame.new(0, 0, 2.4)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    moved = true
                end
                knife:Activate()
                if handle then
                    touch(handle, r)
                    local head = c:FindFirstChild("Head")
                    if head then touch(handle, head) end
                end
                local cp = hrp.Position
                if #recorded > 0 then
                    for _, it in ipairs(recorded) do
                        task.spawn(pcall, replay, it[1], it[2], t.p, c, h, r, cp)
                    end
                elseif ev then
                    for _, rem in ipairs(ev:GetChildren()) do
                        if rem:IsA("RemoteEvent") and not rem.Name:lower():find("throw", 1, true) then
                            for _, a in ipairs({{r}, {c:FindFirstChild("Head") or r}, {c}, {h}, {t.p}, {r, r.Position}}) do
                                task.spawn(pcall, function() rem:FireServer(table.unpack(a)) end)
                            end
                        end
                    end
                end
                task.wait(CFG.hitDelay)
                tries += 1
            end
        end
        if moved and hrp.Parent and hum.Health > 0 then
            hrp.CFrame = back
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end)
    busy = false
    if not okRun then task.wait(0.2) end
end

do
    local SHERIFF_SET = {Sheriff = true, Hero = true}

    local function targets(kind)
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local r = roles[p]
                local ok
                if kind == "Murderer" then
                    ok = r == "Murderer"
                elseif kind == "Sheriff" then
                    ok = SHERIFF_SET[r] == true
                elseif kind == "Both" then
                    ok = r == "Murderer" or SHERIFF_SET[r] == true
                else
                    ok = true
                end
                if ok and aliveChar(p) and inRound(p) then list[#list + 1] = p end
            end
        end
        return list
    end

    local OFFS = {
        Vector3.new(0, 1.5, 0), Vector3.new(0, -1.5, 0),
        Vector3.new(2.25, 1.5, -2.25), Vector3.new(-2.25, -1.5, 2.25),
        Vector3.new(0, 1.5, 0), Vector3.new(0, -1.5, 0),
    }

    local function flingOne(p)
        if busy or picking then return false end
        if holding then surface() end
        local char = lp.Character
        local hrp, hum = myHrp()
        if not char or not hrp or not hum or hum.Health <= 0 then return false end
        if char.Parent ~= workspace then return false end
        if not aliveChar(p) then return false end
        busy, flinging = true, true
        local old = hrp.CFrame
        local fpdh = workspace.FallenPartsDestroyHeight
        pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)
        local t0 = tick()
        local i = 0
        pcall(function()
            while running and tick() - t0 < CFG.flingTime and hum.Health > 0 do
                local c2, r2 = aliveChar(p)
                if not c2 then break end
                if r2.AssemblyLinearVelocity.Magnitude > 500 then break end
                i += 1
                local off = OFFS[(i % #OFFS) + 1]
                local tv = r2.AssemblyLinearVelocity
                PRE_SIM:Wait()
                local c3, r3 = aliveChar(p)
                if not c3 then break end
                hrp.CFrame = CFrame.new(r3.Position + off * 0.6 + tv * 0.08) * CFrame.Angles(math.rad((i * 37) % 360), 0, 0)
                RunService.Heartbeat:Wait()
                local vel = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, CFG.spin, 0)
                PRE_RENDER:Wait()
                hrp.AssemblyLinearVelocity = vel
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
        local c2, r2 = aliveChar(p)
        local flung = (not c2) or r2.AssemblyLinearVelocity.Magnitude > 500
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
        local t1 = tick()
        repeat
            if not hrp.Parent then break end
            hrp.CFrame = old * CFrame.new(0, 0.5, 0)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            for _, x in ipairs(char:GetChildren()) do
                if x:IsA("BasePart") then
                    x.AssemblyLinearVelocity = Vector3.zero
                    x.AssemblyAngularVelocity = Vector3.zero
                end
            end
            RunService.Heartbeat:Wait()
        until ((hrp.Position - old.Position).Magnitude < 25 and tick() - t1 > 0.3) or tick() - t1 > 2.5
        pcall(function() workspace.FallenPartsDestroyHeight = fpdh end)
        flinging = false
        cooldown[p] = tick()
        busy = false
        return flung
    end

    FX.flingKind = function(kind)
        for _, p in ipairs(targets(kind)) do
            if not running then break end
            flingOne(p)
            task.wait(0.35)
        end
    end

    FX.flingPlayer = function(name)
        local p = name and Players:FindFirstChild(name)
        if p and p ~= lp and aliveChar(p) then flingOne(p) end
    end

    FX.autoFling = function()
        if busy then return end
        for _, p in ipairs(targets("Both")) do
            if (cooldown[p] or 0) + CFG.flingCooldown < tick() then
                flingOne(p)
                break
            end
        end
    end

    FX.playerNames = function()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then t[#t + 1] = p.Name end
        end
        table.sort(t)
        if #t == 0 then t[1] = "-" end
        return t
    end

    connect(PRE_SIM, function()
        if not CFG.antiFling or flinging then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                for _, d in ipairs(p.Character:GetChildren()) do
                    if d:IsA("BasePart") and d.CanCollide then d.CanCollide = false end
                end
            end
        end
        if busy or holding or CFG.fly then return end
        local hrp = myHrp()
        if not hrp then return end
        local v = hrp.AssemblyLinearVelocity
        local flat = Vector3.new(v.X, math.max(v.Y, 0), v.Z)
        if flat.Magnitude > 120 or hrp.AssemblyAngularVelocity.Magnitude > 50 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

do
    local hbSaved, reachSaved = {}, {}

    FX.killAll = function()
        local r0, t0, k0 = CFG.auraRange, CFG.auraTp, CFG.autoKill
        CFG.auraRange, CFG.auraTp, CFG.autoKill = 5000, true, true
        for _ = 1, 3 do
            pcall(killAuraStep)
            task.wait(0.1)
        end
        CFG.auraRange, CFG.auraTp, CFG.autoKill = r0, t0, k0
    end

    FX.killTarget = function(p)
        local r0, t0, k0 = CFG.auraRange, CFG.auraTp, CFG.autoKill
        CFG.auraRange, CFG.autoKill = 5000, true
        if CFG.droneTpKill then CFG.auraTp = true end
        for _ = 1, 2 do
            pcall(killAuraStep, p)
            task.wait(0.1)
        end
        CFG.auraRange, CFG.auraTp, CFG.autoKill = r0, t0, k0
    end

    local function restoreHB()
        for part, o in pairs(hbSaved) do
            if part.Parent then
                pcall(function()
                    part.Size = o.size
                    part.Transparency = o.tr
                    part.CanCollide = o.cc
                end)
            end
        end
        table.clear(hbSaved)
    end
    FX.restoreHB = restoreHB

    local function restoreReach()
        for part, o in pairs(reachSaved) do
            if part.Parent then
                pcall(function()
                    part.Size = o.size
                    part.Massless = o.ml
                    part.LocalTransparencyModifier = 0
                end)
            end
        end
        table.clear(reachSaved)
    end
    FX.restoreReach = restoreReach

    connect(RunService.Heartbeat, function()
        if CFG.hitboxOn then
            local sz = CFG.hitboxSize
            local want = Vector3.new(sz, sz, sz)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp then
                    local c, r = aliveChar(p)
                    if c then
                        if not hbSaved[r] then hbSaved[r] = {size = r.Size, tr = r.Transparency, cc = r.CanCollide} end
                        if r.Size ~= want then r.Size = want end
                        r.Transparency = 0.8
                        r.CanCollide = false
                    end
                end
            end
        elseif next(hbSaved) then
            restoreHB()
        end
        local c = lp.Character
        local knife = c and c:FindFirstChild("Knife")
        local h = knife and knife:FindFirstChild("Handle")
        if CFG.reachOn and h and h:IsA("BasePart") then
            if not reachSaved[h] then reachSaved[h] = {size = h.Size, ml = h.Massless} end
            local rs = CFG.reachSize
            local want = Vector3.new(rs, rs, rs)
            if h.Size ~= want then h.Size = want end
            h.Massless = true
            h.LocalTransparencyModifier = 0.85
        elseif next(reachSaved) and not CFG.reachOn then
            restoreReach()
        end
    end)
end

local function findGun()
    local places = {}
    if lp.Character then places[#places + 1] = lp.Character end
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
    local list = ST.calcAll(me, t, CFG.wallbang or CFG.silentMethod == "Hacker")
    local aim = list[1][2]
    if not CFG.wallbang then
        rp.FilterDescendantsInstances = {mine, t.Parent}
        if workspace:Raycast(me, aim - me, rp) ~= nil then return end
    end
    lastShot = tick()
    lastGunFire = tick()
    if ST.gunSound then ST.gunSound() end
    ST.aimPos = aim
    for i, v in ipairs(list) do
        local origin = v[1] or me
        remote:FireServer(CFrame.lookAt(origin, v[2]), CFrame.new(v[2]))
        if i == 1 and FX.shot and CFG.shotTrail then FX.shot(origin, v[2]) end
        if i < #list then task.wait() end
    end
end

FX.shootNow = function()
    lastShot = tick()
    pcall(autoShootStep)
end

connect(RunService.Heartbeat, function()
    if CFG.autoShoot and tick() - lastShot >= CFG.shootDelay then
        lastShot = tick()
        task.spawn(function() pcall(autoShootStep) end)
    end
    local ls = ST.lastShot
    if ls and CFG.hackerRetry and CFG.silentMethod == "Hacker" then
        local el = tick() - ls.t
        if el >= 0.6 and el <= 2.5 and ls.n < 2 then
            local t = ST.target
            local th = t and t.Parent and t.Parent:FindFirstChildOfClass("Humanoid")
            if not t or not th or th.Health <= 0 or not ls.r or not ls.r.Parent then
                ST.lastShot = nil
            else
                ls.n += 1
                ls.t = tick()
                local mh = myHrp()
                local me = (mh and mh.Position or t.Position) + Vector3.new(0, 1.5, 0)
                local list = ST.calcAll(me, t, true)
                local v = list[1]
                if v then
                    pcall(function()
                        ls.r:FireServer(CFrame.lookAt(v[1] or me, v[2]), CFrame.new(v[2]))
                    end)
                end
            end
        end
    end
end)


task.spawn(function()
    while running do
        pcall(function()
            if CFG.autoGun then pickGun() end
            if CFG.flingAuto and FX.autoFling then FX.autoFling() end
            if CFG.autoKill and (roles[lp] == "Murderer" or hasKnife()) then killAuraStep() end
            local idle = true
            if CFG.farm then idle = farmStep() end
            if holding and not busy and (not CFG.farm or idle) then surface() end
        end)
        task.wait(0.1)
    end
end)

local Debris = game:GetService("Debris")

do
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
FX.setShaders = setShaders
FX.applyPreset = applyPreset
FX.shadersApply = shadersApply
FX.shadersOff = shadersOff
FX.PRESET_NAMES = PRESET_NAMES
end
local setShaders, applyPreset, shadersApply, PRESET_NAMES = FX.setShaders, FX.applyPreset, FX.shadersApply, FX.PRESET_NAMES

do
local trailFolder = Instance.new("Folder")
trailFolder.Name = "ZenithTrail"
trailFolder.Parent = workspace
local trailCount, trailAcc = 0, 0
local TRAIL_COLOR = Color3.fromRGB(40, 40, 46)

local trailModel = Instance.new("Model")
trailModel.Name = "ZenithGhost"
trailModel.Parent = workspace
local trailHL = Instance.new("Highlight")
trailHL.Adornee = trailModel
trailHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
trailHL.FillTransparency = 0.45
trailHL.OutlineTransparency = 0
trailHL.Enabled = false
trailHL.Parent = trailModel

local gh = {char = nil, parts = {}, hist = {}, mode = nil}

local function clearGhost()
    for _, g in pairs(gh.parts) do pcall(function() g:Destroy() end) end
    gh.parts, gh.hist, gh.char, gh.mode = {}, {}, nil, nil
end

local function buildGhost(c)
    clearGhost()
    gh.char, gh.mode = c, CFG.trailMode
    for _, p in ipairs(c:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and p.Transparency < 1 then
            local ok, g = pcall(function() return p:Clone() end)
            if ok and g then
                for _, ch in ipairs(g:GetChildren()) do ch:Destroy() end
                if g:IsA("MeshPart") then pcall(function() g.TextureID = "" end) end
            else
                g = Instance.new("Part")
                g.Size = p.Size
            end
            g.Anchored = true
            g.CanCollide = false
            g.CanQuery = false
            g.CanTouch = false
            g.CastShadow = false
            g.Massless = true
            g.CFrame = p.CFrame
            local mode = CFG.trailMode
            if mode == "Chams" or mode == "Neon" then
                g.Material = Enum.Material.Neon
            elseif mode == "ForceField" then
                g.Material = Enum.Material.ForceField
            else
                g.Material = Enum.Material.SmoothPlastic
            end
            g.Transparency = 1
            g.Parent = trailModel
            gh.parts[p] = g
        end
    end
end

local function smokeEmitter(hrp)
    local e = hrp:FindFirstChild("ZenithSmoke")
    if e then return e end
    e = Instance.new("ParticleEmitter")
    e.Name = "ZenithSmoke"
    e.Texture = "rbxasset://textures/particles/smoke_main.dds"
    e.Color = ColorSequence.new(colorOf(CFG.trailColor))
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

connect(RunService.Heartbeat, function()
    local c = lp.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local sm = hrp and hrp:FindFirstChild("ZenithSmoke")
    if not CFG.trail or not hrp or not hum or hum.Health <= 0 then
        if gh.char then clearGhost() end
        trailHL.Enabled = false
        if sm then sm.Enabled = false end
        return
    end
    if gh.char ~= c or gh.mode ~= CFG.trailMode then buildGhost(c) end
    local v = hrp.AssemblyLinearVelocity
    local moving = Vector3.new(v.X, 0, v.Z).Magnitude >= 3
    if CFG.trailSmoke then
        smokeEmitter(hrp).Enabled = moving
    elseif sm then
        sm.Enabled = false
    end
    local now = tick()
    local snap = {}
    for p in pairs(gh.parts) do
        if p.Parent then snap[p] = p.CFrame end
    end
    local hist = gh.hist
    hist[#hist + 1] = {t = now, cf = snap}
    local target = now - CFG.trailDelay
    local idx
    for k = #hist, 1, -1 do
        if hist[k].t <= target then
            idx = k
            break
        end
    end
    if idx and idx > 1 then
        for _ = 1, idx - 1 do table.remove(hist, 1) end
        idx = 1
    end
    while #hist > 600 do table.remove(hist, 1) end
    local use = idx and hist[idx]
    local col = colorOf(CFG.trailColor)
    local mode = CFG.trailMode
    local base = (mode == "Chams" and 0.35) or (mode == "ForceField" and 0.1) or (mode == "Neon" and 0.4) or CFG.trailTransp
    for p, g in pairs(gh.parts) do
        if p.Parent then
            local cf = (use and use.cf[p]) or p.CFrame
            g.CFrame = cf
            g.Color = col
            local vis = math.clamp((cf.Position - p.Position).Magnitude / 2, 0, 1)
            g.Transparency = 1 - (1 - base) * vis
        else
            g.Transparency = 1
        end
    end
    trailHL.Enabled = mode == "Chams"
    if mode == "Chams" then
        trailHL.FillColor = col
        trailHL.OutlineColor = col:Lerp(Color3.new(1, 1, 1), 0.55)
    end
end)

local shotFolder = Instance.new("Folder")
shotFolder.Name = "ZenithShotTrail"
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
    p.Color = colorOf(CFG.trailColor)
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
    if p == lp then
        lastGunFire = tick()
    end
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
FX.trailFolder = trailFolder
FX.trailModel = trailModel
FX.shotFolder = shotFolder
end

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
    kill = {
        ["Among Us Kill"] = 130456049552264,
        ["Knife Kill"] = 137951817204948,
        ["SFX Hit"] = 96359585058783,
        ["Bubble Pop Hit"] = 119697580657161,
        ["Neverlose Hit"] = 82938206376993,
        ["AWP"] = 138705939667182,
    },
    killNames = {"Among Us Kill", "Knife Kill", "SFX Hit", "Bubble Pop Hit", "Neverlose Hit", "AWP", "Off"},
    orig = {},
}

do
    local SoundService = game:GetService("SoundService")
    local lastPlay = 0

    local function customId(txt)
        local n = tonumber((tostring(txt or ""):gsub("%D", "")))
        if n and n > 0 then return n end
    end

    function SND.id(kind)
        if kind == "gun" then
            return customId(CFG.gunCustom) or SND.gun[CFG.gunSnd]
        elseif kind == "knife" then
            return customId(CFG.knifeCustom) or SND.knife[CFG.knifeSnd]
        end
        return customId(CFG.killCustom) or SND.kill[CFG.killSndName]
    end

    function SND.play(id, vol)
        if not id then return end
        local s = Instance.new("Sound")
        s.Name = "ZenithSnd"
        s.SoundId = "rbxassetid://" .. tostring(id)
        s.Volume = vol or 1
        s.Parent = SoundService
        s.Ended:Connect(function() s:Destroy() end)
        s:Play()
        Debris:AddItem(s, 10)
    end

    local lastGun = 0
    function ST.gunSound()
        if not CFG.replaceSnd then return end
        if ST.gunSwapAt and tick() - ST.gunSwapAt < 2 then return end
        local now = tick()
        if now - lastGun < 0.15 then return end
        lastGun = now
        local id = SND.id("gun")
        if not id then return end
        task.delay(0.12, function()
            if tick() - (ST.lastGamePlay or 0) > 0.3 then SND.play(id, CFG.gunVol) end
        end)
    end

    local swaps = {}
    local function swapSound(snd, id, vol)
        local want = "rbxassetid://" .. tostring(id)
        if snd:GetAttribute("ZenithSnd") then
            if snd.SoundId ~= want then snd.SoundId = want end
            if snd.Volume ~= vol then snd.Volume = vol end
            return
        end
        local parent = snd.Parent
        if not parent then return end
        local new = snd:Clone()
        new.SoundId = want
        new.Volume = vol
        new:SetAttribute("ZenithSnd", true)
        swaps[new] = {orig = snd, parent = parent}
        snd.Parent = nil
        new.Parent = parent
        new.Played:Connect(function() ST.lastGamePlay = tick() end)
    end

    local function unswap(new)
        local rec = swaps[new]
        swaps[new] = nil
        pcall(function()
            if rec and rec.parent and rec.parent.Parent then rec.orig.Parent = rec.parent end
            new:Destroy()
        end)
    end

    local function setSound(s, id, vol)
        if SND.orig[s] == nil then SND.orig[s] = {s.SoundId, s.Volume} end
        local want = "rbxassetid://" .. tostring(id)
        if s.SoundId ~= want then s.SoundId = want end
        if s.Volume ~= vol then s.Volume = vol end
    end

    local function muteSound(s)
        if SND.orig[s] == nil then SND.orig[s] = {s.SoundId, s.Volume} end
        if s.Volume ~= 0 then s.Volume = 0 end
    end

    local function restoreSound(s)
        local o = SND.orig[s]
        if not o then return end
        SND.orig[s] = nil
        pcall(function()
            s.SoundId = o[1]
            s.Volume = o[2]
        end)
    end

    function SND.restore()
        for s in pairs(SND.orig) do restoreSound(s) end
        for new in pairs(swaps) do unswap(new) end
    end

    local function release(snd)
        if snd:GetAttribute("ZenithSnd") then unswap(snd) else restoreSound(snd) end
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
        return {lp.Character or false, lp:FindFirstChild("Backpack") or false}
    end

    local function scan()
        local rep = CFG.replaceSnd
        local gid = rep and SND.id("gun")
        local kid = rep and SND.id("knife")
        local killid = CFG.killSnd and SND.id("kill")
        for _, holder in ipairs(holders()) do
            if holder then
                for _, t in ipairs(holder:GetChildren()) do
                    if t:IsA("Tool") and (t.Name == "Gun" or t.Name == "Knife") then
                        local isGun = t.Name == "Gun"
                        for _, s in ipairs(toolSounds(t, isGun)) do
                            if isGun then
                                if gid then
                                    swapSound(s, gid, CFG.gunVol)
                                    ST.gunSwapAt = tick()
                                else
                                    release(s)
                                end
                            else
                                local isKill = s.Name:lower():find("kill", 1, true) ~= nil
                                local id = (isKill and killid) or kid
                                if id then
                                    swapSound(s, id, isKill and CFG.killVol or CFG.knifeVol)
                                else
                                    release(s)
                                end
                            end
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
            task.wait(0.4)
        end
    end)

    local function onDeath()
        if not CFG.killSnd then return end
        local now = tick()
        if now - lastPlay < 1 then return end
        if roles[lp] == "Murderer" or hasKnife() or now - lastGunFire < 2 then
            local id = SND.id("kill")
            if id then
                lastPlay = now
                SND.play(id, CFG.killVol)
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

    for _, r in ipairs(RS:GetDescendants()) do
        if r:IsA("RemoteEvent") and (r.Name == "KillEvent" or r.Name == "GunKill" or r.Name == "KnifeKill") then
            connect(r.OnClientEvent, function() onDeath() end)
        end
    end

    task.spawn(function()
        local list = {}
        local function add(id)
            local snd = Instance.new("Sound")
            snd.SoundId = "rbxassetid://" .. tostring(id)
            list[#list + 1] = snd
        end
        for _, tbl in ipairs({SND.gun, SND.knife, SND.kill}) do
            for _, id in pairs(tbl) do add(id) end
        end
        for _, id in ipairs({124994246147928, 114037851906101, 1548304764}) do add(id) end
        pcall(function() game:GetService("ContentProvider"):PreloadAsync(list) end)
    end)
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
    WING_PRESETS.Seraph = {style = "seraph", a = C(255, 255, 255), b = C(255, 225, 150), glow = C(255, 245, 210), halo = true, tex = SPARK}
    WING_PRESETS.Dragon = {style = "demon", a = C(25, 45, 25), b = C(30, 150, 60), glow = C(130, 255, 90), halo = false,
                           tex = FIRE, acc = Vector3.new(0, 2.4, 0), psize = 1.4, idle = 0.2, flap = 0.8}
    WING_PRESETS["Ice Dragon"] = {style = "demon", a = C(200, 230, 255), b = C(70, 140, 255), glow = C(150, 210, 255), halo = false,
                                  tex = SPARK, psize = 1.2, idle = 0.2, flap = 0.8}
    WING_PRESETS.Rainbow = {style = "feather", rainbow = true, a = C(255, 255, 255), b = C(255, 255, 255), glow = C(255, 255, 255),
                            halo = true, tex = SPARK, prate = 1.5}
    WING_PRESETS.Shadow = {style = "feather", a = C(45, 45, 55), b = C(12, 12, 18), glow = C(140, 70, 255), halo = false,
                           tex = "rbxasset://textures/particles/smoke_main.dds", acc = Vector3.new(0, 1.5, 0), psize = 1.6}
    WING_PRESETS.Mecha = {style = "cyber", a = C(255, 150, 20), b = C(70, 70, 80), glow = C(255, 180, 60), halo = false,
                          tex = SPARK, pulse = true, idle = 0.1, flap = 0.25}
end
local WING_NAMES = {"Angel", "Seraph", "Rainbow", "Frost", "Inferno", "Phoenix", "Galaxy", "Sakura", "Void", "Shadow", "Demon", "Dragon", "Ice Dragon", "Butterfly", "Crystal", "Cyber", "Mecha"}

local function newAuraState()
    return {char = nil, folder = nil, core = nil, haloWeld = nil, feathers = {}, emitters = {}, orbs = {},
            flaps = {}, tws = {}, cat = -1, gen = 0}
end
local aura = newAuraState()

local function removeAura()
    aura.gen += 1
    for _, tw in pairs(aura.tws or {}) do pcall(function() tw:Cancel() end) end
    if aura.folder then pcall(function() aura.folder:Destroy() end) end
    aura = newAuraState()
end

do
    local PI = math.pi
    local DEF = {y0 = 0.3, y1 = 0.3, ox = 0.28, oy = 0.6, oz = 0.56, tr = 0.1, t = 0, r = 1, th = 0.04}

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
                    y0 = 1.25, y1 = 0.6 + (r - 1) * 0.05,
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
                    y0 = 1.0, y1 = 0.7, oy = 0.1, color = mix(P.a, P.b, 0.4 + k * 0.2), tr = 0.1,
                    t = k / 3, r = 5,
                })
            end
        end
        return E
    end

    function GEN.seraph(P)
        local E = GEN.feather(P)
        local n = #E
        for i = 1, n do
            local e = E[i]
            local c = {}
            for k, v in pairs(e) do c[k] = v end
            c.len = e.len * 0.72
            c.oy = (e.oy or 0.6) - 0.8
            c.oz = (e.oz or 0.56) + 0.06
            c.r0 = -0.25 - math.abs(e.r0) * 0.45
            c.r1 = -0.35 - math.abs(e.r1) * 0.55
            c.tip = false
            E[#E + 1] = c
        end
        return E
    end

    function GEN.feather3d(P)
        local E = {}
        local rows = {
            {n = 7, len = 3.8, w = 0.74},
            {n = 6, len = 2.8, w = 0.66},
            {n = 5, len = 1.8, w = 0.58},
        }
        if P.tail then rows[#rows + 1] = {n = 4, len = 1.1, w = 0.52} end
        for r, row in ipairs(rows) do
            for i = 1, row.n do
                local t = (i - 1) / (row.n - 1)
                local len = row.len * (1 - 0.35 * t)
                local common = {
                    r0 = 1.28 - t * 0.55 - (r - 1) * 0.06, r1 = 1.15 - t * 1.95 - (r - 1) * 0.1,
                    y0 = 1.25, y1 = 0.6 + (r - 1) * 0.05,
                    oy = 0.62 - (r - 1) * 0.07, oz = 0.56 + (r - 1) * 0.1,
                    t = t, r = r,
                }
                local function add(over)
                    local e = {}
                    for k, v in pairs(common) do e[k] = v end
                    for k, v in pairs(over) do e[k] = v end
                    E[#E + 1] = el(e)
                end
                add({len = len, wid = row.w, th = 0.2, color = mix(P.a, P.b, t * 0.65 + (r - 1) * 0.18), tr = 0.03,
                     mat = Enum.Material.SmoothPlastic, tip = (r == 1)})
                add({len = len * 0.97, wid = 0.1, th = 0.3, color = P.glow, tr = 0.05, pulse = P.pulse})
                add({len = 0.5, wid = row.w * 0.9, th = 0.26, start = len - 0.5, color = mix(P.b, P.a, 0.3), tr = 0.03})
            end
        end
        return E
    end

    function GEN.demon(P)
        local E = {}
        local bone = P.a
        local ARM = 2.9
        E[1] = el({len = ARM, wid = 0.2, th = 0.2, r0 = 1.45, r1 = 1.0, y0 = 0.9, y1 = 0.5, oy = 0.7, oz = 0.58,
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
                r0 = 1.55 - t * 0.25, r1 = 1.35 - t * 1.5, y0 = 0.55, y1 = 0.2, oy = 0.7,
                color = mix(P.a, P.b, t), tr = 0.1, t = t, r = 1, tip = true,
            })
        end
        for i = 1, lo do
            local t = (i - 1) / (lo - 1)
            E[#E + 1] = el({
                len = 1.3 + 1.3 * math.sin(t * PI * 0.9 + 0.2), wid = 0.85, th = 0.03,
                r0 = 1.3 - t * 0.2, r1 = -0.1 - t * 0.95, y0 = 0.65, y1 = 0.3, oy = 0.45,
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
                len = len, wid = 0.34, th = 0.16, r0 = r0, r1 = r1, y0 = 0.85, y1 = 0.3,
                color = mix(P.a, P.b, t), tr = 0.4, t = t, r = 1, tip = true,
            })
            E[#E + 1] = el({
                len = len * 0.92, wid = 0.08, th = 0.2, r0 = r0, r1 = r1, y0 = 0.85, y1 = 0.3,
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
                len = len, wid = 0.3, th = 0.12, r0 = r0, r1 = r1, y0 = 0.85, y1 = 0.3,
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

    local function startFlap(a, dur)
        a.gen += 1
        local gen = a.gen
        for _, tw in pairs(a.tws) do pcall(function() tw:Cancel() end) end
        a.tws = {}
        for r, v in ipairs(a.flaps) do
            v.Value = 0
            local tw = TweenService:Create(v, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Value = 1})
            a.tws[r] = tw
            task.delay((r - 1) * dur * 0.14, function()
                if a.gen == gen and a.folder and a.folder.Parent then tw:Play() end
            end)
        end
    end

    local function buildAura(char)
        removeAura()
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if not head or not torso then return end
        local old = char:FindFirstChild("ZenithAura")
        if old then old:Destroy() end
        local P = WING_PRESETS[CFG.wingPreset] or WING_PRESETS.Angel
        local gen = (P.style == "feather" and CFG.wings3d) and GEN.feather3d or (GEN[P.style] or GEN.feather)
        local list = gen(P)
        local folder = Instance.new("Folder")
        folder.Name = "ZenithAura"
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

        local openV = Instance.new("NumberValue")
        openV.Name = "Open"
        openV.Value = math.max(P.idle or 0, CFG.wingIdle)
        openV.Parent = folder
        local flaps = {}
        for r = 1, 5 do
            local v = Instance.new("NumberValue")
            v.Name = "Flap" .. r
            v.Parent = folder
            flaps[r] = v
        end
        aura = {char = char, folder = folder, core = core, haloWeld = haloWeld,
                feathers = feathers, emitters = emitters, orbs = orbs, P = P,
                openV = openV, flaps = flaps, tws = {}, cat = -1, gen = 0}
        for _, e in ipairs(emitters) do
            if e.em then pcall(function() e.em:Emit(10) end) end
        end
    end

    connect(RunService.Heartbeat, function()
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
        local cat = aura.cat
        if CFG.fly then
            cat = 2
        elseif speed > 7 or (cat == 1 and speed > 3) then
            cat = 1
        else
            cat = 0
        end
        if cat ~= aura.cat then
            aura.cat = cat
            local tgt = math.max(cat == 2 and 1 or (cat == 1 and 0.5 or 0), P.idle or 0, CFG.wingIdle)
            TweenService:Create(aura.openV, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Value = tgt}):Play()
            startFlap(aura, ({0.9, 0.5, 0.3})[cat + 1] / CFG.auraSpeed)
        end
        local open = math.clamp(aura.openV.Value, 0, 1.1)
        local now = tick()
        local t = now * CFG.auraSpeed
        local amp = (0.05 + open * 0.26) * (P.flap or 1)

        aura.haloWeld.C0 = CFrame.new(0, 1.15 + math.sin(t * 2) * 0.06, 0) * CFrame.Angles(0, t * 2, 0)

        for _, rt in ipairs(aura.feathers) do
            local e, side = rt.e, rt.side
            local f = aura.flaps[math.min(e.r, 5)].Value * 2 - 1
            local wave = f * amp * (0.5 + e.t * 0.9)
            if e.par then wave *= 0.5 end
            local roll = e.r0 + (e.r1 - e.r0) * open + wave
            local yaw = e.y0 + (e.y1 - e.y0) * open + f * amp * 0.25
            local c0
            if rt.par then
                c0 = rt.par.C0 * CFrame.new(side * e.plen, 0, rt.zj) * CFrame.Angles(0, -side * yaw, side * roll)
            else
                c0 = CFrame.new(side * (e.ox + CFG.wingX), e.oy + CFG.wingY, e.oz + CFG.wingZ + rt.zj) * CFrame.Angles(0, -side * (yaw + CFG.wingYaw), side * roll)
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
            if P.rainbow then
                rt.part.Color = Color3.fromHSV((now * 0.2 + e.t * 0.35 + (e.r or 1) * 0.1) % 1, 0.75, 1)
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
        folder.Name = "ZenithHelper"
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

        local flapV = Instance.new("NumberValue")
        flapV.Name = "Flap"
        flapV.Parent = folder
        TweenService:Create(flapV, TweenInfo.new(0.11, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Value = 1}):Play()

        helper = {folder = folder, rel = rel, pos = nil, cf = nil, flapV = flapV}
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
                local fv = helper.flapV.Value
                if r.ph == 2 then fv = 1 - fv end
                local fl = (fv * 2 - 1) * 0.55
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

do
    local folder
    local cosChar, lastSig
    local fx = {}

    local function clear()
        if folder then pcall(function() folder:Destroy() end) end
        folder = nil
        fx = {}
        cosChar = nil
    end
    FX.clearCos = clear

    local function C(r, g, b) return Color3.fromRGB(r, g, b) end
    local SPARK = "rbxasset://textures/particles/sparkles_main.dds"
    local FIRE = "rbxasset://textures/particles/fire_main.dds"
    local SMOKE = "rbxasset://textures/particles/smoke_main.dds"

    local ELEM = {
        Fire = {tex = FIRE, c1 = C(255, 200, 60), c2 = C(255, 60, 20), size = 1.8, rate = 45, life = 1, speed = 2, acc = Vector3.new(0, 4, 0), emis = 1, flicker = true},
        Ice = {tex = SPARK, c1 = C(210, 245, 255), c2 = C(80, 160, 255), size = 0.7, rate = 35, life = 1.4, speed = 1, acc = Vector3.new(0, -1, 0), emis = 1},
        Electric = {tex = SPARK, c1 = C(255, 255, 150), c2 = C(110, 190, 255), size = 0.5, rate = 70, life = 0.5, speed = 4, acc = Vector3.zero, emis = 1, flicker = true},
        Toxic = {tex = SMOKE, c1 = C(120, 255, 90), c2 = C(30, 140, 40), size = 2.2, rate = 30, life = 1.2, speed = 1, acc = Vector3.new(0, 2, 0), emis = 0.3},
        Shadow = {tex = SMOKE, c1 = C(90, 40, 140), c2 = C(15, 5, 30), size = 2.4, rate = 35, life = 1.3, speed = 1, acc = Vector3.new(0, 2.5, 0), emis = 0},
        Stars = {tex = SPARK, c1 = C(255, 240, 150), c2 = C(255, 180, 60), size = 0.8, rate = 30, life = 1.5, speed = 1, acc = Vector3.new(0, 1, 0), emis = 1},
        Holy = {tex = SPARK, c1 = C(255, 255, 255), c2 = C(255, 225, 140), size = 0.9, rate = 40, life = 1.6, speed = 1.2, acc = Vector3.new(0, 2.5, 0), emis = 1},
    }
    FX.ELEM_NAMES = {"Fire", "Ice", "Electric", "Toxic", "Shadow", "Stars", "Holy"}
    local AURA = {
        ["Super Saiyan"] = {c1 = C(255, 235, 90), c2 = C(255, 165, 25), bolts = true},
        ["Ultra Instinct"] = {c1 = C(230, 240, 255), c2 = C(120, 160, 255), bolts = true},
        ["Dark"] = {c1 = C(160, 70, 255), c2 = C(35, 0, 70)},
        ["Blood"] = {c1 = C(255, 70, 70), c2 = C(120, 0, 0)},
        ["Toxic"] = {c1 = C(140, 255, 90), c2 = C(20, 120, 30)},
        ["Rainbow"] = {c1 = C(255, 255, 255), c2 = C(255, 255, 255), rainbow = true, bolts = true},
    }
    FX.AURA_NAMES = {"Super Saiyan", "Ultra Instinct", "Dark", "Blood", "Toxic", "Rainbow"}

    local function weldTo(p0, p1, c0)
        local w = Instance.new("Weld")
        w.Part0, w.Part1, w.C0 = p0, p1, c0
        w.Parent = p0
        return w
    end

    local function mkPart(size, color, transp, shape, mat)
        local p = Instance.new("Part")
        p.Size, p.Color, p.Transparency = size, color, transp
        p.Material = mat or Enum.Material.Neon
        p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow, p.Massless = false, false, false, false, true
        if shape then p.Shape = shape end
        p.Parent = folder
        return p
    end

    local function emitter(parent, o)
        local em = Instance.new("ParticleEmitter")
        em.Texture = o.tex or SPARK
        em.Color = ColorSequence.new(o.c1 or C(255, 255, 255), o.c2 or o.c1 or C(255, 255, 255))
        local sz = o.size or 0.5
        em.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, sz),
            NumberSequenceKeypoint.new(0.6, sz * 0.7),
            NumberSequenceKeypoint.new(1, 0),
        })
        em.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, o.t0 or 0.1),
            NumberSequenceKeypoint.new(1, 1),
        })
        em.Lifetime = NumberRange.new((o.life or 1) * 0.6, o.life or 1)
        em.Rate = o.rate or 10
        em.Speed = NumberRange.new((o.speed or 1) * 0.4, o.speed or 1)
        em.Acceleration = o.acc or Vector3.zero
        em.SpreadAngle = o.spread or Vector2.new(180, 180)
        em.Rotation = NumberRange.new(0, 360)
        em.RotSpeed = NumberRange.new(-90, 90)
        em.LightEmission = o.emis or 1
        em.LightInfluence = 0
        if o.dir then em.EmissionDirection = o.dir end
        em.Parent = parent
        return em
    end

    local function light(parent, color, bright, range)
        local l = Instance.new("PointLight")
        l.Color, l.Brightness, l.Range, l.Shadows = color, bright, range, false
        l.Parent = parent
        return l
    end

    local function ring(core, radius, count, size, color, mat, transp)
        local segs = {}
        for i = 1, count do
            local a = (i / count) * math.pi * 2
            local pos = Vector3.new(math.cos(a) * radius, 0, math.sin(a) * radius)
            local seg = mkPart(size, color, transp or 0.05, nil, mat)
            weldTo(core, seg, CFrame.lookAt(pos, pos + Vector3.new(-math.sin(a), 0, math.cos(a))))
            segs[#segs + 1] = seg
        end
        return segs
    end

    local function build(char)
        clear()
        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not head or not hrp then return end
        folder = Instance.new("Folder")
        folder.Name = "ZenithCos"
        folder.Parent = char
        cosChar = char
        local col = colorOf(CFG.glowColor)

        if CFG.bodyGlow then
            local hl = Instance.new("Highlight")
            hl.Adornee = char
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0
            hl.Parent = folder
            fx.hl = hl
            local core = mkPart(Vector3.new(0.2, 0.2, 0.2), col, 1)
            weldTo(hrp, core, CFrame.new())
            fx.glowLight = light(core, col, 1.4, 12)
        end

        if CFG.crown then
            local core = mkPart(Vector3.new(0.2, 0.2, 0.2), GOLD, 1)
            fx.crownW = weldTo(head, core, CFrame.new(0, 0.62, 0))
            local gold = C(255, 205, 60)
            ring(core, 0.62, 18, Vector3.new(0.22, 0.3, 0.32), gold, Enum.Material.Metal, 0)
            local trim = mkPart(Vector3.new(0.2, 0.2, 0.2), gold, 1)
            weldTo(core, trim, CFrame.new(0, 0.17, 0))
            ring(trim, 0.64, 18, Vector3.new(0.08, 0.06, 0.3), C(255, 240, 170), nil, 0)
            for i = 1, 6 do
                local a = (i / 6) * math.pi * 2
                local pos = Vector3.new(math.cos(a) * 0.62, 0.42, math.sin(a) * 0.62)
                local spike = mkPart(Vector3.new(0.16, 0.55, 0.16), gold, 0, nil, Enum.Material.Metal)
                weldTo(core, spike, CFrame.new(pos))
                local tip = mkPart(Vector3.new(0.16, 0.16, 0.16), C(255, 240, 170), 0, Enum.PartType.Ball)
                weldTo(core, tip, CFrame.new(pos + Vector3.new(0, 0.33, 0)))
                local gem = mkPart(Vector3.new(0.17, 0.17, 0.17), ({C(255, 60, 120), C(70, 160, 255), C(80, 255, 140)})[i % 3 + 1], 0.05, Enum.PartType.Ball)
                weldTo(core, gem, CFrame.new(pos * Vector3.new(1.06, 0, 1.06) + Vector3.new(0, -0.3, 0)))
            end
            light(core, C(255, 215, 130), 1.2, 8)
            emitter(core, {tex = SPARK, c1 = C(255, 245, 190), c2 = C(255, 190, 80), size = 0.22, rate = 7, life = 1.2, speed = 0.6, acc = Vector3.new(0, 0.6, 0)})
        end

        if CFG.groundRing then
            local rc = colorOf(CFG.ringColor)
            local coreA = mkPart(Vector3.new(0.2, 0.2, 0.2), rc, 1)
            fx.ringAW = weldTo(hrp, coreA, CFrame.new(0, -2.95, 0))
            fx.ringA = ring(coreA, 3.2, 32, Vector3.new(0.12, 0.06, 0.65), rc)
            local coreB = mkPart(Vector3.new(0.2, 0.2, 0.2), rc, 1)
            fx.ringBW = weldTo(hrp, coreB, CFrame.new(0, -2.92, 0))
            fx.ringB = ring(coreB, 2.3, 24, Vector3.new(0.1, 0.05, 0.6), rc)
            local disc = mkPart(Vector3.new(0.05, 6.6, 6.6), rc, 0.85, Enum.PartType.Cylinder)
            weldTo(hrp, disc, CFrame.new(0, -3.0, 0) * CFrame.Angles(0, 0, math.rad(90)))
            fx.disc = disc
            local src = mkPart(Vector3.new(6, 0.1, 6), rc, 1)
            weldTo(hrp, src, CFrame.new(0, -2.9, 0))
            fx.ringEm = emitter(src, {tex = SPARK, c1 = rc, size = 0.3, rate = 18, life = 1.4, speed = 1.5,
                acc = Vector3.new(0, 2, 0), spread = Vector2.new(10, 10), dir = Enum.NormalId.Top})
            fx.ringLight = light(coreA, rc, 1.6, 10)
        end

        if CFG.elemAura then
            local p = ELEM[CFG.elemType] or ELEM.Fire
            local body = mkPart(Vector3.new(2.2, 4.6, 1.4), C(255, 255, 255), 1)
            weldTo(hrp, body, CFrame.new(0, -0.3, 0))
            emitter(body, {tex = p.tex, c1 = p.c1, c2 = p.c2, size = p.size, rate = p.rate, life = p.life,
                speed = p.speed, acc = p.acc, emis = p.emis})
            emitter(body, {tex = SPARK, c1 = p.c1, c2 = p.c2, size = 0.25, rate = p.rate * 0.4, life = 0.8, speed = 2.5})
            fx.elemLight = light(body, p.c1, 1.3, 11)
            fx.elemFlicker = p.flicker
        end

        if CFG.powerAura then
            local st = AURA[CFG.auraStyle] or AURA["Super Saiyan"]
            local body = mkPart(Vector3.new(2.6, 5.2, 1.8), C(255, 255, 255), 1)
            weldTo(hrp, body, CFrame.new(0, -0.2, 0))
            fx.pa = {}
            fx.pa[1] = emitter(body, {tex = FIRE, c1 = st.c1, c2 = st.c2, size = 2.4, rate = 60, life = 0.9, speed = 6,
                acc = Vector3.new(0, 10, 0), spread = Vector2.new(8, 8), dir = Enum.NormalId.Top, t0 = 0.35})
            fx.pa[2] = emitter(body, {tex = SPARK, c1 = st.c2, c2 = st.c1, size = 0.4, rate = 40, life = 0.6, speed = 10,
                acc = Vector3.new(0, 14, 0), spread = Vector2.new(5, 5), dir = Enum.NormalId.Top})
            local base = mkPart(Vector3.new(5, 0.1, 5), st.c1, 1)
            weldTo(hrp, base, CFrame.new(0, -2.9, 0))
            fx.pa[3] = emitter(base, {tex = SMOKE, c1 = st.c1, c2 = st.c2, size = 2, rate = 12, life = 1.2, speed = 3,
                acc = Vector3.new(0, 2, 0), spread = Vector2.new(80, 80), dir = Enum.NormalId.Top, emis = 0.5, t0 = 0.5})
            if st.bolts then
                fx.pa[4] = emitter(body, {tex = SPARK, c1 = C(255, 255, 255), c2 = st.c1, size = 0.6, rate = 25, life = 0.25, speed = 8})
            end
            fx.paLight = light(body, st.c1, 2, 14)
            fx.paStyle = st
        end

        if CFG.nameTag then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 240, 0, 40)
            bb.StudsOffset = Vector3.new(0, 3.4, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = head
            bb.Parent = folder
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Font = Enum.Font.GothamBlack
            tl.TextSize = 26
            tl.Text = (CFG.nameTagText ~= "" and CFG.nameTagText) or "Zenith"
            tl.TextColor3 = C(255, 255, 255)
            tl.Parent = bb
            local st = Instance.new("UIStroke")
            st.Thickness = 1.6
            st.Color = C(0, 0, 0)
            st.Transparency = 0.15
            st.Parent = tl
            local g = Instance.new("UIGradient")
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, C(255, 80, 120)),
                ColorSequenceKeypoint.new(0.25, C(255, 200, 80)),
                ColorSequenceKeypoint.new(0.5, C(90, 255, 160)),
                ColorSequenceKeypoint.new(0.75, C(80, 160, 255)),
                ColorSequenceKeypoint.new(1, C(200, 90, 255)),
            })
            g.Parent = tl
            fx.tagGrad = g
        end

        if CFG.orbitStars then
            fx.stars = {}
            for i = 1, 6 do
                local o = mkPart(Vector3.new(0.35, 0.35, 0.35), col, 0.05, Enum.PartType.Ball)
                local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
                a0.Position, a1.Position = Vector3.new(0, 0.17, 0), Vector3.new(0, -0.17, 0)
                a0.Parent, a1.Parent = o, o
                local tr = Instance.new("Trail")
                tr.Attachment0, tr.Attachment1 = a0, a1
                tr.Lifetime = 0.5
                tr.LightEmission = 1
                tr.LightInfluence = 0
                tr.FaceCamera = true
                tr.Transparency = NumberSequence.new(0.2, 1)
                tr.Parent = o
                fx.stars[i] = {o = o, tr = tr, w = weldTo(hrp, o, CFrame.new()), ph = i * math.pi * 2 / 6,
                    r = 2.2 + (i % 2) * 0.8, h = (i % 3 - 1) * 1.1}
            end
        end

        if CFG.auraSphere then
            local sp = mkPart(Vector3.new(7.5, 7.5, 7.5), col, 0.35, Enum.PartType.Ball, Enum.Material.ForceField)
            fx.sphereW = weldTo(hrp, sp, CFrame.new(0, -0.2, 0))
            fx.sphere = sp
        end

        if CFG.footSparkle then
            local f = mkPart(Vector3.new(1.6, 0.2, 1.2), col, 1)
            weldTo(hrp, f, CFrame.new(0, -2.85, 0))
            fx.foot = emitter(f, {tex = SPARK, c1 = col, c2 = C(255, 255, 255), size = 0.35, rate = 35, life = 0.8,
                speed = 1.2, acc = Vector3.new(0, 1.5, 0)})
            fx.footHrp = hrp
        end
    end

    connect(RunService.Heartbeat, function()
        local c = lp.Character
        local want = CFG.bodyGlow or CFG.crown or CFG.groundRing or CFG.elemAura or CFG.nameTag
            or CFG.orbitStars or CFG.auraSphere or CFG.footSparkle or CFG.powerAura
        if not want then
            if folder then clear() end
            lastSig = nil
            return
        end
        if not c or not c:FindFirstChild("Head") or not c:FindFirstChild("HumanoidRootPart") then return end
        local sg = table.concat({tostring(CFG.bodyGlow), tostring(CFG.crown), tostring(CFG.groundRing),
            tostring(CFG.elemAura), CFG.elemType, tostring(CFG.nameTag), CFG.nameTagText,
            tostring(CFG.orbitStars), tostring(CFG.auraSphere), tostring(CFG.footSparkle),
            tostring(CFG.powerAura), CFG.auraStyle}, "|")
        if cosChar ~= c or not folder or not folder.Parent or sg ~= lastSig then
            lastSig = sg
            pcall(build, c)
            return
        end
        local now = tick()
        local col = colorOf(CFG.glowColor)
        if fx.hl then
            fx.hl.FillColor, fx.hl.OutlineColor = col, col
            fx.hl.FillTransparency = 0.62 + 0.18 * math.sin(now * 3)
        end
        if fx.glowLight then fx.glowLight.Color = col end
        if fx.crownW then
            fx.crownW.C0 = CFrame.new(0, 0.62 + math.sin(now * 2) * 0.03, 0) * CFrame.Angles(0, now * 0.6, 0)
        end
        if fx.ringAW then
            local rc = colorOf(CFG.ringColor)
            fx.ringAW.C0 = CFrame.new(0, -2.95, 0) * CFrame.Angles(0, now * 1.4, 0)
            fx.ringBW.C0 = CFrame.new(0, -2.92, 0) * CFrame.Angles(0, -now * 2.1, 0)
            local pulse = 0.5 + 0.5 * math.sin(now * 3)
            for _, sg2 in ipairs(fx.ringA) do
                sg2.Color = rc
                sg2.Transparency = 0.05 + 0.3 * pulse
            end
            for _, sg2 in ipairs(fx.ringB) do
                sg2.Color = rc
                sg2.Transparency = 0.35 - 0.3 * pulse
            end
            fx.disc.Color = rc
            fx.disc.Transparency = 0.82 + 0.08 * math.sin(now * 2)
            fx.ringEm.Color = ColorSequence.new(rc)
            fx.ringLight.Color = rc
        end
        if fx.elemLight and fx.elemFlicker then
            fx.elemLight.Brightness = 1 + math.random() * 0.8
        end
        if fx.tagGrad then
            fx.tagGrad.Offset = Vector2.new(math.sin(now * 1.2) * 0.5, 0)
        end
        if fx.stars then
            for i, st in ipairs(fx.stars) do
                local a = now * 1.6 + st.ph
                st.w.C0 = CFrame.new(math.cos(a) * st.r, st.h + math.sin(now * 2 + st.ph) * 0.4, math.sin(a) * st.r)
                local sc = col
                if CFG.glowColor == "Rainbow" then sc = Color3.fromHSV((now * 0.25 + i / 6) % 1, 0.8, 1) end
                st.o.Color = sc
                st.tr.Color = ColorSequence.new(sc)
            end
        end
        if fx.sphere then
            fx.sphere.Color = col
            local k = 7.5 + math.sin(now * 2) * 0.3
            fx.sphere.Size = Vector3.new(k, k, k)
            fx.sphereW.C0 = CFrame.new(0, -0.2, 0) * CFrame.Angles(now * 0.3, now * 0.5, 0)
        end
        if fx.paLight then
            fx.paLight.Brightness = 1.6 + math.random() * 0.9
            if fx.paStyle and fx.paStyle.rainbow then
                local a = Color3.fromHSV((now * 0.3) % 1, 0.8, 1)
                local b = Color3.fromHSV((now * 0.3 + 0.15) % 1, 0.9, 1)
                for _, em in pairs(fx.pa) do em.Color = ColorSequence.new(a, b) end
                fx.paLight.Color = a
            end
        end
        if fx.foot and fx.footHrp then
            local v = fx.footHrp.AssemblyLinearVelocity
            fx.foot.Enabled = Vector3.new(v.X, 0, v.Z).Magnitude > 2
            fx.foot.Color = ColorSequence.new(col, Color3.new(1, 1, 1))
        end
    end)
end

local UIS = game:GetService("UserInputService")

do
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
        bv.Name = "ZenithFly"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.P = 1e4
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        local bg = Instance.new("BodyGyro")
        bg.Name = "ZenithFlyGyro"
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
    if FX.droneFlying then return end
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
FX.mov = function() return movDef end
FX.tpLobby = tpLobby
FX.tpMap = tpMap
FX.flyStop = flyStop
FX.spinStop = spinStop
FX.ncSaved = ncSaved
FX.xrRefresh = xrRefresh
FX.xrRestore = xrRestore
end
local tpLobby, tpMap, flyStop, xrRefresh = FX.tpLobby, FX.tpMap, FX.flyStop, FX.xrRefresh

do
    local saved
    local fovSet = false
    local alertGui, alertLbl
    local lastRoles = ""

    local function restoreLight()
        if saved then
            for k, v in pairs(saved) do pcall(function() Lighting[k] = v end) end
            saved = nil
        end
    end

    FX.restoreUtil = function()
        restoreLight()
        if fovSet then
            pcall(function() workspace.CurrentCamera.FieldOfView = 70 end)
            fovSet = false
        end
        if alertGui then pcall(function() alertGui:Destroy() end) end
        alertGui = nil
    end

    local function alert(text)
        if not alertGui then
            alertGui = Instance.new("ScreenGui")
            alertGui.Name = "ZenithAlert"
            alertGui.ResetOnSpawn = false
            local ok = pcall(function() alertGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
            if not ok or not alertGui.Parent then alertGui.Parent = lp:WaitForChild("PlayerGui") end
            alertLbl = Instance.new("TextLabel")
            alertLbl.Size = UDim2.new(0, 320, 0, 40)
            alertLbl.Position = UDim2.new(0.5, -160, 0, 70)
            alertLbl.BackgroundColor3 = Color3.fromRGB(170, 25, 35)
            alertLbl.BackgroundTransparency = 0.15
            alertLbl.TextColor3 = Color3.new(1, 1, 1)
            alertLbl.Font = Enum.Font.GothamBlack
            alertLbl.TextSize = 20
            alertLbl.Parent = alertGui
            Instance.new("UICorner", alertLbl).CornerRadius = UDim.new(0, 10)
        end
        alertLbl.Text = text
        alertGui.Enabled = true
    end

    task.spawn(function()
        while running do
            pcall(function()
                if CFG.roleNotify then
                    local m, sh = {}, {}
                    for p, r in pairs(roles) do
                        if p.Parent then
                            if r == "Murderer" then
                                m[#m + 1] = p.Name
                            elseif r == "Sheriff" or r == "Hero" then
                                sh[#sh + 1] = p.Name
                            end
                        end
                    end
                    local key = table.concat(m, ",") .. "|" .. table.concat(sh, ",")
                    if key ~= lastRoles and (#m > 0 or #sh > 0) then
                        lastRoles = key
                        if FX.notify then
                            FX.notify("Zenith", "Murderer: " .. (#m > 0 and table.concat(m, ", ") or "?")
                                .. "\nSheriff: " .. (#sh > 0 and table.concat(sh, ", ") or "?"))
                        end
                    end
                end
                if CFG.fullbright and not CFG.shaders then
                    if not saved then
                        saved = {
                            Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd,
                            GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
                        }
                    end
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                    Lighting.Ambient = Color3.fromRGB(180, 180, 180)
                    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
                elseif saved and not CFG.fullbright then
                    restoreLight()
                end
            end)
            task.wait(0.5)
        end
    end)

    connect(RunService.Heartbeat, function()
        local cam0 = workspace.CurrentCamera
        if cam0 then
            if CFG.fovOn then
                cam0.FieldOfView = CFG.fov
                fovSet = true
            elseif fovSet then
                cam0.FieldOfView = 70
                fovSet = false
            end
        end
        if CFG.murderAlert and roles[lp] ~= "Murderer" then
            local m = murdererHrp()
            local me = myHrp()
            if m and me then
                local d = (m.Position - me.Position).Magnitude
                if d <= CFG.alertDist then
                    alert("!! MURDERER " .. math.floor(d) .. "m !!")
                    return
                end
            end
        end
        if alertGui and alertGui.Enabled then alertGui.Enabled = false end
    end)

    pcall(function()
        local VU = game:GetService("VirtualUser")
        connect(lp.Idled, function()
            if CFG.antiAfk then
                pcall(function()
                    VU:CaptureController()
                    VU:ClickButton2(Vector2.new())
                end)
            end
        end)
    end)

    connect(UIS.JumpRequest, function()
        if not CFG.infJump then return end
        local _, hum = myHrp()
        if hum and hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)

    FX.rejoin = function()
        local TS = game:GetService("TeleportService")
        pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp) end)
    end
end

do
    local SoundService2 = game:GetService("SoundService")

    local matSaved = {}
    local function restoreMat(part)
        local o = matSaved[part]
        if not o then return end
        matSaved[part] = nil
        if part.Parent then
            pcall(function()
                part.Material = o[1]
                part.Color = o[2]
            end)
        end
    end
    FX.restoreMatChams = function()
        for part in pairs(matSaved) do restoreMat(part) end
    end

    local function partsOf(inst)
        local list = inst:GetDescendants()
        if inst:IsA("BasePart") then list[#list + 1] = inst end
        return list
    end

    local wpn = {}
    local function restoreWeapon(tool)
        local w = wpn[tool]
        if not w then return end
        wpn[tool] = nil
        for _, o in ipairs({w.box, w.sel, w.light, w.bb}) do
            if o then pcall(function() o:Destroy() end) end
        end
        for _, d in ipairs(partsOf(tool)) do
            if d:IsA("BasePart") then restoreMat(d) end
        end
    end
    FX.restoreWeapons = function()
        for tool in pairs(wpn) do restoreWeapon(tool) end
    end

    local function styleWeapon(tool, col, seen)
        local h = (tool:IsA("BasePart") and tool) or tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true)
        if not h or not h:IsA("BasePart") then return end
        local st = CFG.weaponStyle
        local w = wpn[tool]
        if not w or w.h ~= h then
            if w then restoreWeapon(tool) end
            w = {h = h}
            wpn[tool] = w
        end
        if not w.bb or not w.bb.Parent then
            local bb = Instance.new("BillboardGui")
            bb.Name = "ZenithWpnTag"
            bb.Size = UDim2.new(0, 90, 0, 22)
            bb.StudsOffset = Vector3.new(0, 1.6, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = h
            bb.Parent = h
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.fromScale(1, 1)
            tl.BackgroundTransparency = 1
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 14
            tl.TextStrokeTransparency = 0.3
            tl.Parent = bb
            w.bb, w.tl = bb, tl
        end
        w.tl.Text = (tool.Name == "Knife" and "KNIFE") or "GUN"
        w.tl.TextColor3 = col
        if st == "Chams" or st == "Glow" then
            if not w.box or not w.box.Parent then
                local b = Instance.new("BoxHandleAdornment")
                b.Name = "ZenithWpnBox"
                b.AlwaysOnTop = true
                b.ZIndex = 5
                b.Adornee = h
                b.Parent = h
                w.box = b
            end
            w.box.Size = h.Size + Vector3.new(0.12, 0.12, 0.12)
            w.box.Color3 = col
            w.box.Transparency = (st == "Glow") and 0.55 or 0.3
        elseif w.box then
            w.box:Destroy()
            w.box = nil
        end
        if st == "Outline" or st == "Glow" then
            if not w.sel or not w.sel.Parent then
                local sb = Instance.new("SelectionBox")
                sb.Name = "ZenithWpnSel"
                sb.LineThickness = 0.05
                sb.SurfaceTransparency = 1
                sb.Adornee = h
                sb.Parent = h
                w.sel = sb
            end
            w.sel.Color3 = col
        elseif w.sel then
            w.sel:Destroy()
            w.sel = nil
        end
        if st == "Glow" then
            if not w.light or not w.light.Parent then
                local l = Instance.new("PointLight")
                l.Range = 10
                l.Brightness = 2
                l.Parent = h
                w.light = l
            end
            w.light.Color = col
        elseif w.light then
            w.light:Destroy()
            w.light = nil
        end
        if st == "ForceField" or st == "Neon" then
            local mat = (st == "ForceField") and Enum.Material.ForceField or Enum.Material.Neon
            for _, d in ipairs(partsOf(tool)) do
                if d:IsA("BasePart") and d.Transparency < 1 then
                    if not matSaved[d] then matSaved[d] = {d.Material, d.Color} end
                    if d.Material ~= mat then d.Material = mat end
                    d.Color = col
                    seen[d] = true
                end
            end
        end
    end

    task.spawn(function()
        while running do
            pcall(function()
                local seen = {}
                local st = CFG.chamsStyle
                local matMode = CFG.esp and CFG.highlight and (st == "ForceField" or st == "Neon")
                if matMode then
                    local mat = (st == "ForceField") and Enum.Material.ForceField or Enum.Material.Neon
                    for p, e in pairs(E) do
                        local c = aliveChar(p)
                        if c and e.matColor then
                            for _, d in ipairs(c:GetChildren()) do
                                if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                                    if not matSaved[d] then matSaved[d] = {d.Material, d.Color} end
                                    if d.Material ~= mat then d.Material = mat end
                                    d.Color = e.matColor
                                    seen[d] = true
                                end
                            end
                        end
                    end
                end
                local wseen = {}
                if CFG.weaponEsp then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= lp and p.Character then
                            for _, t in ipairs(p.Character:GetChildren()) do
                                if t:IsA("Tool") and (t.Name == "Knife" or t.Name == "Gun") then
                                    styleWeapon(t, colorOf(t.Name == "Knife" and CFG.knifeColor or CFG.gunColor), seen)
                                    wseen[t] = true
                                end
                            end
                        end
                    end
                    if drop and drop.Parent then
                        styleWeapon(drop, colorOf(CFG.gunColor), seen)
                        wseen[drop] = true
                    end
                end
                for tool in pairs(wpn) do
                    if not wseen[tool] then restoreWeapon(tool) end
                end
                for part in pairs(matSaved) do
                    if not seen[part] then restoreMat(part) end
                end
            end)
            task.wait(0.25)
        end
    end)

    local hud = {}
    connect(RunService.Heartbeat, function()
        if not (CFG.silent and CFG.silentHud) then
            if hud.gui then
                pcall(function() hud.gui:Destroy() end)
                hud = {}
            end
            return
        end
        if not hud.gui or not hud.gui.Parent then
            local g = Instance.new("ScreenGui")
            g.Name = "ZenithSilentHud"
            g.ResetOnSpawn = false
            local ok = pcall(function() g.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
            if not ok or not g.Parent then g.Parent = lp:WaitForChild("PlayerGui") end
            local l = Instance.new("TextLabel")
            l.AnchorPoint = Vector2.new(0.5, 0)
            l.Position = UDim2.new(0.5, 0, 0, 6)
            l.Size = UDim2.new(0, 260, 0, 22)
            l.BackgroundColor3 = Color3.fromRGB(10, 14, 28)
            l.BackgroundTransparency = 0.3
            l.Font = Enum.Font.GothamBold
            l.TextSize = 13
            l.Parent = g
            Instance.new("UICorner", l).CornerRadius = UDim.new(0, 6)
            hud = {gui = g, label = l}
        end
        local t = ST.target
        local me = myHrp()
        if t and t.Parent and me then
            local pl = Players:GetPlayerFromCharacter(t.Parent)
            hud.label.Text = string.format("SILENT [%s]  %s  %dm", CFG.silentMethod, pl and pl.Name or "?", math.floor((t.Position - me.Position).Magnitude))
            hud.label.TextColor3 = Color3.fromRGB(255, 90, 90)
        else
            hud.label.Text = "SILENT  no target (murderer unknown)"
            hud.label.TextColor3 = Color3.fromRGB(170, 170, 180)
        end
    end)

    local modelCache = {}
    local function loadModel(idText)
        local id = tonumber((tostring(idText or ""):gsub("%D", "")))
        if not id then return nil end
        if modelCache[id] then return modelCache[id] end
        local m
        pcall(function()
            local objs = game:GetObjects("rbxassetid://" .. id)
            m = objs and objs[1]
        end)
        if not m then
            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 1, 1)
            local sm = Instance.new("SpecialMesh")
            sm.MeshType = Enum.MeshType.FileMesh
            sm.MeshId = "rbxassetid://" .. id
            sm.Parent = p
            m = p
        end
        modelCache[id] = m
        return m
    end

    local function prepModel(src, scale)
        local ok, m = pcall(function() return src:Clone() end)
        if not ok or not m then return nil end
        if m:IsA("Model") and scale and scale ~= 1 then pcall(function() m:ScaleTo(scale) end) end
        local parts = {}
        if m:IsA("BasePart") then parts[1] = m end
        for _, d in ipairs(m:GetDescendants()) do
            if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("TouchTransmitter") then
                d:Destroy()
            elseif d:IsA("BasePart") then
                parts[#parts + 1] = d
            end
        end
        if #parts == 0 then
            m:Destroy()
            return nil
        end
        local main = (m:IsA("Model") and m.PrimaryPart) or nil
        if not main then
            local best = -1
            for _, p in ipairs(parts) do
                local v = p.Size.X * p.Size.Y * p.Size.Z
                if v > best then best, main = v, p end
            end
        end
        if m:IsA("BasePart") and scale and scale ~= 1 then
            m.Size = m.Size * scale
            local sm = m:FindFirstChildOfClass("SpecialMesh")
            if sm then sm.Scale = sm.Scale * scale end
        end
        for _, p in ipairs(parts) do
            p.Anchored = false
            p.CanCollide = false
            p.CanQuery = false
            p.CanTouch = false
            p.Massless = true
            p.CastShadow = false
            if p ~= main then
                local wc = Instance.new("WeldConstraint")
                wc.Part0, wc.Part1 = main, p
                wc.Parent = main
            end
        end
        m.Name = "ZenithSkin"
        return m, main
    end

    local skinLib, libKeys = {}, {}
    local knifeNames, gunNames = {"None"}, {"None"}
    FX.knifeNames = function() return knifeNames end
    FX.gunNames = function() return gunNames end

    local function snapshotTool(tool)
        local h = tool:FindFirstChild("Handle")
        if not h or not h:IsA("BasePart") then return nil end
        local m = Instance.new("Model")
        local n = 0
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 1 and not d:FindFirstAncestor("ZenithSkin") then
                local ok, c = pcall(function() return d:Clone() end)
                if ok and c then
                    for _, ch in ipairs(c:GetChildren()) do
                        if not (ch:IsA("DataModelMesh") or ch:IsA("Decal") or ch:IsA("Texture") or ch:IsA("SurfaceAppearance")) then
                            ch:Destroy()
                        end
                    end
                    c.CFrame = h.CFrame:ToObjectSpace(d.CFrame)
                    c.Parent = m
                    n += 1
                end
            end
        end
        if n == 0 then
            m:Destroy()
            return nil
        end
        return m
    end

    local function skinKey(tool)
        local h = tool:FindFirstChild("Handle")
        local mid, tid = "", ""
        if h and h:IsA("MeshPart") then mid, tid = h.MeshId, h.TextureID end
        local sm = h and h:FindFirstChildWhichIsA("SpecialMesh")
        if sm then mid, tid = sm.MeshId, sm.TextureId end
        return tool.Name .. "|" .. mid .. "|" .. tid
    end

    local function capture(p, tool)
        local key = skinKey(tool)
        if libKeys[key] then return false end
        local snap = snapshotTool(tool)
        if not snap then return false end
        local label = tool.Name .. " - " .. p.Name
        local i = 2
        while skinLib[label] do
            label = tool.Name .. " - " .. p.Name .. " " .. i
            i += 1
        end
        libKeys[key] = true
        skinLib[label] = snap
        local list = tool.Name == "Knife" and knifeNames or gunNames
        list[#list + 1] = label
        return true
    end

    FX.copySkins = function()
        local added = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                for _, t in ipairs(p.Character:GetChildren()) do
                    if t:IsA("Tool") and (t.Name == "Knife" or t.Name == "Gun") then
                        if capture(p, t) then added += 1 end
                    end
                end
            end
        end
        if added > 0 and FX.skinDD then
            if FX.skinDD.knife then pcall(function() FX.skinDD.knife:Refresh(knifeNames) end) end
            if FX.skinDD.gun then pcall(function() FX.skinDD.gun:Refresh(gunNames) end) end
        end
        return added
    end

    task.spawn(function()
        while running do
            if CFG.skinCapture then pcall(FX.copySkins) end
            task.wait(1.5)
        end
    end)

    local skinHidden = {}
    local function unhideTool(tool)
        local hid = skinHidden[tool]
        if not hid then return end
        for d in pairs(hid) do
            if d.Parent then pcall(function() d.LocalTransparencyModifier = 0 end) end
        end
        skinHidden[tool] = nil
    end

    local function applySkin(tool, enabled, idText, scale, rotY)
        local h = tool:FindFirstChild("Handle")
        local cur = tool:FindFirstChild("ZenithSkin")
        if not enabled or not h then
            if cur then cur:Destroy() end
            unhideTool(tool)
            return
        end
        local sig = tostring(idText) .. "|" .. tostring(scale) .. "|" .. tostring(rotY)
        if cur and cur:GetAttribute("sig") ~= sig then
            cur:Destroy()
            cur = nil
        end
        if not cur then
            local src = (typeof(idText) == "Instance") and idText or loadModel(idText)
            local m, main = nil, nil
            if src then m, main = prepModel(src, scale) end
            if not m then return end
            m:SetAttribute("sig", sig)
            main.CFrame = h.CFrame
            local w = Instance.new("Weld")
            w.Part0, w.Part1 = h, main
            w.C0 = CFrame.Angles(0, math.rad(rotY), 0)
            w.Parent = main
            m.Parent = tool
            cur = m
        end
        local hid = skinHidden[tool] or {}
        skinHidden[tool] = hid
        for _, d in ipairs(tool:GetDescendants()) do
            if (d:IsA("BasePart") or d:IsA("Decal")) and not d:IsDescendantOf(cur) then
                d.LocalTransparencyModifier = 1
                hid[d] = true
            end
        end
    end

    local dbItems, dbKnife, dbGun = {}, {"None"}, {"None"}
    FX.dbKnifeNames = function() return dbKnife end
    FX.dbGunNames = function() return dbGun end

    local function dbVisual(it)
        local mesh, tex, model
        for kk, v in pairs(it) do
            if type(v) == "string" or type(v) == "number" then
                local kl = tostring(kk):lower()
                local num = tostring(v):match("%d%d%d%d+")
                if num then
                    if kl:find("mesh") then
                        mesh = num
                    elseif kl:find("texture") or kl == "tex" then
                        tex = num
                    elseif kl == "itemid" or kl:find("model") or kl:find("asset") then
                        model = model or num
                    end
                end
            end
        end
        if mesh then
            local p = Instance.new("Part")
            p.Size = Vector3.new(1, 1, 1)
            local sm = Instance.new("SpecialMesh")
            sm.MeshType = Enum.MeshType.FileMesh
            sm.MeshId = "rbxassetid://" .. mesh
            if tex then sm.TextureId = "rbxassetid://" .. tex end
            sm.Parent = p
            return p
        end
        if model then return loadModel(model) end
    end

    FX.scanDB = function()
        local cands = {}
        local db = RS:FindFirstChild("Database")
        if db then
            for _, d in ipairs(db:GetDescendants()) do
                if d:IsA("ModuleScript") then cands[#cands + 1] = d end
            end
        end
        for _, d in ipairs(RS:GetDescendants()) do
            if d:IsA("ModuleScript") then
                local nl = d.Name:lower()
                if nl == "item" or nl == "items" or nl == "weapons" or nl == "itemdatabase" or nl == "sync" then
                    cands[#cands + 1] = d
                end
            end
        end
        local found = 0
        for _, ms in ipairs(cands) do
            local ok, data = pcall(require, ms)
            if ok and type(data) == "table" then
                for _, pool in ipairs({data, data.Item, data.Items, data.Weapons}) do
                    if type(pool) == "table" then
                        for name, it in pairs(pool) do
                            if type(it) == "table" then
                                local typ = tostring(it.ItemType or it.Type or it.Category or it.WeaponType or ""):lower()
                                local isK = typ:find("knife") ~= nil
                                local isG = typ:find("gun") ~= nil or typ:find("revolver") ~= nil
                                if isK or isG then
                                    local label = tostring(it.ItemName or it.DisplayName or it.Name or name)
                                    if not dbItems[label] then
                                        dbItems[label] = it
                                        local list = isK and dbKnife or dbGun
                                        list[#list + 1] = label
                                        found += 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        table.sort(dbKnife, function(a, b) return a == "None" or (b ~= "None" and a < b) end)
        table.sort(dbGun, function(a, b) return a == "None" or (b ~= "None" and a < b) end)
        if FX.dbDD then
            if FX.dbDD.knife then pcall(function() FX.dbDD.knife:Refresh(dbKnife) end) end
            if FX.dbDD.gun then pcall(function() FX.dbDD.gun:Refresh(dbGun) end) end
        end
        return found
    end
    task.delay(5, function() pcall(FX.scanDB) end)

    local dbCache = {}
    local function dbSource(label)
        if dbCache[label] ~= nil then return dbCache[label] or nil end
        local it = dbItems[label]
        local src = it and dbVisual(it)
        dbCache[label] = src or false
        return src
    end

    local function applySnap(tool, snap, key)
        local h = tool:FindFirstChild("Handle")
        if not h then return end
        local cur = tool:FindFirstChild("ZenithSkin")
        if cur and cur:GetAttribute("sig") ~= key then
            cur:Destroy()
            cur = nil
        end
        if not cur then
            local m = snap:Clone()
            m.Name = "ZenithSkin"
            m:SetAttribute("sig", key)
            for _, p in ipairs(m:GetChildren()) do
                if p:IsA("BasePart") then
                    local rel = p.CFrame
                    p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.Massless, p.CastShadow = false, false, false, false, true, false
                    local w = Instance.new("Weld")
                    w.Part0, w.Part1, w.C0 = h, p, rel
                    w.Parent = p
                end
            end
            m.Parent = tool
            cur = m
        end
        local hid = skinHidden[tool] or {}
        skinHidden[tool] = hid
        for _, d in ipairs(tool:GetDescendants()) do
            if (d:IsA("BasePart") or d:IsA("Decal")) and not d:IsDescendantOf(cur) then
                d.LocalTransparencyModifier = 1
                hid[d] = true
            end
        end
    end

    local cs = {char = nil, model = nil, weld = nil, sig = nil, hidden = {}}
    local function clearChar()
        if cs.model then pcall(function() cs.model:Destroy() end) end
        for d in pairs(cs.hidden) do
            if d.Parent then pcall(function() d.LocalTransparencyModifier = 0 end) end
        end
        cs = {char = nil, model = nil, weld = nil, sig = nil, hidden = {}}
    end

    local hat = {}
    local function clearHat()
        if hat.part then pcall(function() hat.part:Destroy() end) end
        hat = {}
    end

    FX.restoreModels = function()
        clearChar()
        clearHat()
        for tool in pairs(skinHidden) do unhideTool(tool) end
        for _, holder in ipairs({lp.Character, lp:FindFirstChild("Backpack")}) do
            if holder then
                for _, t in ipairs(holder:GetChildren()) do
                    local sk = t:IsA("Tool") and t:FindFirstChild("ZenithSkin")
                    if sk then sk:Destroy() end
                end
            end
        end
    end

    local specOn = false
    connect(RunService.Heartbeat, function()
        local c = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local head = c and c:FindFirstChild("Head")
        if c then
            for _, t in ipairs(c:GetChildren()) do
                if t:IsA("Tool") then
                    if t.Name == "Gun" then
                        local dsrc = CFG.gunDB ~= "None" and dbSource(CFG.gunDB)
                        local snap = CFG.gunLib ~= "None" and skinLib[CFG.gunLib]
                        if dsrc then
                            pcall(applySkin, t, true, dsrc, CFG.gunSkinScale, CFG.gunSkinRot)
                        elseif snap then
                            pcall(applySnap, t, snap, CFG.gunLib)
                        else
                            pcall(applySkin, t, CFG.gunSkin, CFG.gunSkinId, CFG.gunSkinScale, CFG.gunSkinRot)
                        end
                    elseif t.Name == "Knife" then
                        local dsrc = CFG.knifeDB ~= "None" and dbSource(CFG.knifeDB)
                        local snap = CFG.knifeLib ~= "None" and skinLib[CFG.knifeLib]
                        if dsrc then
                            pcall(applySkin, t, true, dsrc, CFG.knifeSkinScale, CFG.knifeSkinRot)
                        elseif snap then
                            pcall(applySnap, t, snap, CFG.knifeLib)
                        else
                            pcall(applySkin, t, CFG.knifeSkin and CFG.knifeSkinId ~= "", CFG.knifeSkinId, CFG.knifeSkinScale, CFG.knifeSkinRot)
                        end
                    end
                end
            end
        end

        if CFG.customChar and hrp then
            local sig = tostring(CFG.charModelId) .. "|" .. tostring(CFG.charScale)
            if cs.char ~= c or cs.sig ~= sig or not (cs.model and cs.model.Parent) then
                clearChar()
                local src = loadModel(CFG.charModelId)
                local m, main = nil, nil
                if src then m, main = prepModel(src, CFG.charScale) end
                if m then
                    main.CFrame = hrp.CFrame
                    local w = Instance.new("Weld")
                    w.Part0, w.Part1 = hrp, main
                    w.Parent = main
                    m.Parent = c
                    cs.model, cs.weld = m, w
                end
                cs.char, cs.sig = c, sig
            end
            if cs.weld then
                cs.weld.C0 = CFrame.new(0, CFG.charY, 0) * CFrame.Angles(0, math.rad(CFG.charYaw), 0)
            end
            for _, d in ipairs(c:GetDescendants()) do
                local par = d.Parent
                local body = (d:IsA("BasePart") and (par == c or (par and par:IsA("Accessory"))))
                    or (d:IsA("Decal") and par and par.Name == "Head" and par.Parent == c)
                if body and d.Name ~= "HumanoidRootPart" and not (cs.model and d:IsDescendantOf(cs.model)) then
                    d.LocalTransparencyModifier = 1
                    cs.hidden[d] = true
                end
            end
        elseif cs.char then
            clearChar()
        end

        if CFG.chinaHat and head then
            if hat.char ~= c or not (hat.part and hat.part.Parent) then
                clearHat()
                local p = Instance.new("Part")
                p.Name = "ZenithChinaHat"
                p.Size = Vector3.new(1, 1, 1)
                p.Material = Enum.Material.Neon
                p.Transparency = 0.3
                p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow, p.Massless = false, false, false, false, true
                local sm = Instance.new("SpecialMesh")
                sm.MeshType = Enum.MeshType.FileMesh
                sm.MeshId = "rbxassetid://1033714"
                sm.Scale = Vector3.new(1.7, 1.1, 1.7)
                sm.Parent = p
                local w = Instance.new("Weld")
                w.Part0, w.Part1 = head, p
                w.C0 = CFrame.new(0, 1.05, 0)
                w.Parent = p
                p.Parent = c
                local hl = Instance.new("Highlight")
                hl.Adornee = p
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0
                hl.Parent = p
                hat = {char = c, part = p, hl = hl}
            end
            local col = colorOf(CFG.hatColor)
            hat.part.Color = col
            hat.hl.OutlineColor = col
        elseif hat.part then
            clearHat()
        end

        if not FX.droneFlying then
            local cam0 = workspace.CurrentCamera
            local subj
            if CFG.specMurd then
                local m = murdererHrp()
                subj = m and m.Parent and m.Parent:FindFirstChildOfClass("Humanoid")
            elseif CFG.specSher then
                for p, r in pairs(roles) do
                    if p ~= lp and (r == "Sheriff" or r == "Hero") then
                        local c2, _, h2 = aliveChar(p)
                        if c2 then
                            subj = h2
                            break
                        end
                    end
                end
            end
            if subj and cam0 then
                cam0.CameraSubject = subj
                specOn = true
            elseif specOn and cam0 then
                local hum = c and c:FindFirstChildOfClass("Humanoid")
                if hum then cam0.CameraSubject = hum end
                specOn = false
            end
        end
    end)

    local function guiRoot(name)
        local g = Instance.new("ScreenGui")
        g.Name = name
        g.IgnoreGuiInset = true
        g.ResetOnSpawn = false
        g.DisplayOrder = 1000
        local ok = pcall(function() g.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
        if not ok or not g.Parent then g.Parent = lp:WaitForChild("PlayerGui") end
        return g
    end

    local function osdText(parent, text, ax, ay, px, py, size, color, xa)
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.AnchorPoint = Vector2.new(ax, ay)
        t.Position = UDim2.new(px, 0, py, 0)
        t.Size = UDim2.new(0, 420, 0, (size or 18) + 8)
        t.Font = Enum.Font.Code
        t.TextSize = size or 18
        t.TextColor3 = color or Color3.new(1, 1, 1)
        t.TextStrokeTransparency = 0.3
        t.TextXAlignment = xa or Enum.TextXAlignment.Left
        t.Text = text
        t.Parent = parent
        return t
    end

    local DRONES = {
        FPV = {speed = 80, accel = 2.8, arms = 4, frame = Color3.fromRGB(28, 28, 32), accent = Color3.fromRGB(150, 60, 255),
               led = Color3.fromRGB(150, 60, 255), boom = 6, vol = 1.3, scale = 1, blades = 3},
        ["Kamikaze FPV"] = {speed = 75, accel = 2.5, arms = 4, frame = Color3.fromRGB(40, 44, 34), accent = Color3.fromRGB(200, 60, 40),
                            led = Color3.fromRGB(255, 50, 40), boom = 11, vol = 1.35, scale = 1.05, payload = true, blades = 3},
        Shahed = {speed = 95, accel = 2, wing = true, frame = Color3.fromRGB(150, 150, 150), accent = Color3.fromRGB(60, 60, 60),
                  led = Color3.fromRGB(255, 40, 40), boom = 14, vol = 1.6, scale = 1.25, minThrottle = 0.6},
        Racer = {speed = 115, accel = 3.2, arms = 4, frame = Color3.fromRGB(28, 28, 32), accent = Color3.fromRGB(255, 140, 0),
                 led = Color3.fromRGB(255, 140, 0), boom = 6, vol = 1.4, scale = 0.85, blades = 3},
        Heavy = {speed = 50, accel = 1.6, arms = 6, frame = Color3.fromRGB(45, 52, 42), accent = Color3.fromRGB(200, 200, 60),
                 led = Color3.fromRGB(255, 60, 60), boom = 15, vol = 1.7, scale = 1.45, payload = true, blades = 2},
        Kamikaze = {speed = 95, accel = 2, wing = true, frame = Color3.fromRGB(150, 150, 150), accent = Color3.fromRGB(60, 60, 60),
                    led = Color3.fromRGB(255, 40, 40), boom = 12, vol = 1.6, scale = 1.2, minThrottle = 0.6},
        Mini = {speed = 60, accel = 4.5, arms = 4, frame = Color3.fromRGB(28, 28, 32), accent = Color3.fromRGB(60, 140, 255),
                led = Color3.fromRGB(60, 140, 255), boom = 5, vol = 0.8, scale = 0.6, blades = 3},
        Stealth = {speed = 85, accel = 2.8, arms = 4, frame = Color3.fromRGB(10, 10, 12), accent = Color3.fromRGB(25, 25, 28),
                   led = Color3.fromRGB(60, 0, 0), boom = 8, vol = 0.25, scale = 1, blades = 2, propColor = Color3.fromRGB(20, 20, 22)},
        Cinewhoop = {speed = 55, accel = 4, arms = 4, frame = Color3.fromRGB(28, 28, 32), accent = Color3.fromRGB(255, 60, 120),
                     led = Color3.fromRGB(255, 60, 120), boom = 6, vol = 1, scale = 0.9, ducts = true, gopro = true, blades = 5},
        ["Long Range"] = {speed = 90, accel = 2.2, arms = 4, frame = Color3.fromRGB(28, 28, 32), accent = Color3.fromRGB(40, 200, 120),
                          led = Color3.fromRGB(40, 255, 140), boom = 9, vol = 1.2, scale = 1.25, battery = 150, payload = true, blades = 2},
        Thermal = {speed = 70, accel = 2.6, arms = 4, frame = Color3.fromRGB(60, 62, 66), accent = Color3.fromRGB(230, 230, 230),
                   led = Color3.fromRGB(255, 255, 255), boom = 8, vol = 1.1, scale = 1.05, thermal = true, payload = true, blades = 3},
        ["Night Vision"] = {speed = 72, accel = 2.6, arms = 4, frame = Color3.fromRGB(35, 45, 35), accent = Color3.fromRGB(90, 200, 90),
                            led = Color3.fromRGB(80, 255, 80), boom = 8, vol = 1.1, scale = 1, nv = true, payload = true, blades = 3},
        Interceptor = {speed = 150, accel = 4.2, arms = 4, frame = Color3.fromRGB(20, 22, 26), accent = Color3.fromRGB(0, 220, 255),
                       led = Color3.fromRGB(0, 220, 255), boom = 6, vol = 1.5, scale = 0.8, blades = 3},
        Mavic = {speed = 45, accel = 5, arms = 4, frame = Color3.fromRGB(95, 97, 102), accent = Color3.fromRGB(70, 72, 76),
                 led = Color3.fromRGB(255, 80, 80), boom = 6, vol = 0.7, scale = 0.85, gimbal = true, blades = 2,
                 propColor = Color3.fromRGB(60, 60, 64)},
        Lancet = {speed = 105, accel = 2.2, lancet = true, frame = Color3.fromRGB(110, 115, 100), accent = Color3.fromRGB(60, 62, 55),
                  led = Color3.fromRGB(255, 40, 40), boom = 13, vol = 1.6, scale = 1.15, minThrottle = 0.55},
    }

    local function buildDrone(cf, spec)
        local k = spec.scale or 1
        local m = Instance.new("Model")
        m.Name = "ZenithDrone"
        local function part(size, color, mat, shape, tr)
            local p = Instance.new("Part")
            p.Size, p.Color = size * k, color
            p.Material = mat or Enum.Material.SmoothPlastic
            p.Transparency = tr or 0
            p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = false, false, false, false
            p.Massless = true
            if shape then p.Shape = shape end
            p.Parent = m
            return p
        end
        local body = part(Vector3.new(0.3, 0.3, 0.3), spec.frame, nil, nil, 1)
        body.Anchored = true
        body.CFrame = cf
        m.PrimaryPart = body
        local function attach(p, c0)
            local w = Instance.new("Weld")
            w.Part0, w.Part1, w.C0 = body, p, c0
            w.Parent = p
            return w
        end
        local function at(v) return v * k end
        local SIDE = CFrame.Angles(0, 0, math.pi / 2)
        local FWD = CFrame.Angles(0, math.pi / 2, 0)
        local props = {}
        local lens

        if spec.lancet then
            local fus = part(Vector3.new(2.6, 0.42, 0.42), spec.frame, Enum.Material.Metal, Enum.PartType.Cylinder)
            attach(fus, FWD)
            local nose = part(Vector3.new(0.42, 0.42, 0.42), spec.frame, Enum.Material.Metal, Enum.PartType.Ball)
            attach(nose, CFrame.new(at(Vector3.new(0, 0, -1.3))))
            local seeker = part(Vector3.new(0.24, 0.24, 0.24), Color3.fromRGB(20, 20, 24), Enum.Material.Glass, Enum.PartType.Ball)
            attach(seeker, CFrame.new(at(Vector3.new(0, 0, -1.5))))
            for _, zc in ipairs({-0.55, 0.85}) do
                for f = 0, 3 do
                    local ang = math.rad(45 + f * 90)
                    local fin = part(Vector3.new(0.05, 1.1, 0.5), spec.frame, Enum.Material.Metal)
                    attach(fin, CFrame.new(at(Vector3.new(0, 0, zc))) * CFrame.Angles(0, 0, ang) * CFrame.new(0, at(0.6), 0))
                    local tipL = part(Vector3.new(0.06, 0.1, 0.12), spec.led, Enum.Material.Neon)
                    attach(tipL, CFrame.new(at(Vector3.new(0, 0, zc))) * CFrame.Angles(0, 0, ang) * CFrame.new(0, at(1.15), 0))
                end
            end
            local band = part(Vector3.new(0.1, 0.44, 0.44), spec.accent, Enum.Material.Metal, Enum.PartType.Cylinder)
            attach(band, CFrame.new(at(Vector3.new(0, 0, -0.2))) * FWD)
            local motor = part(Vector3.new(0.3, 0.36, 0.36), spec.accent, Enum.Material.Metal, Enum.PartType.Cylinder)
            attach(motor, CFrame.new(at(Vector3.new(0, 0, 1.35))) * FWD)
            local base = at(Vector3.new(0, 0, 1.58))
            for j = 0, 1 do
                local b = part(Vector3.new(0.45, 0.1, 0.03), Color3.fromRGB(30, 30, 30), Enum.Material.SmoothPlastic)
                props[#props + 1] = {w = attach(b, CFrame.new(base)), base = base, off = j * math.pi, axis = "Z", shift = at(0.22)}
            end
            lens = part(Vector3.new(0.1, 0.1, 0.1), Color3.fromRGB(60, 140, 255), Enum.Material.Neon, Enum.PartType.Ball)
            attach(lens, CFrame.new(at(Vector3.new(0, -0.12, -1.62))))
        elseif spec.wing then
            local fus = part(Vector3.new(3, 0.55, 0.55), spec.frame, Enum.Material.Metal, Enum.PartType.Cylinder)
            attach(fus, FWD)
            local nose = part(Vector3.new(0.55, 0.55, 0.55), spec.frame, Enum.Material.Metal, Enum.PartType.Ball)
            attach(nose, CFrame.new(at(Vector3.new(0, 0, -1.5))))
            local tip = part(Vector3.new(0.3, 0.3, 0.3), Color3.fromRGB(85, 95, 60), Enum.Material.Metal, Enum.PartType.Ball)
            attach(tip, CFrame.new(at(Vector3.new(0, 0, -1.72))))
            for _, sd in ipairs({1, -1}) do
                local wing = part(Vector3.new(2.6, 0.07, 1.3), spec.frame, Enum.Material.Metal)
                attach(wing, CFrame.new(at(Vector3.new(sd * 1.25, 0, 0.55))) * CFrame.Angles(0, sd * math.rad(30), 0))
                local edge = part(Vector3.new(2.6, 0.08, 0.12), spec.accent, Enum.Material.Metal)
                attach(edge, CFrame.new(at(Vector3.new(sd * 1.25, 0, 0.55))) * CFrame.Angles(0, sd * math.rad(30), 0) * CFrame.new(0, 0, at(0.62)))
                local winglet = part(Vector3.new(0.07, 0.55, 0.55), spec.frame, Enum.Material.Metal)
                attach(winglet, CFrame.new(at(Vector3.new(sd * 2.35, 0.22, 1.25))))
                local navLed = part(Vector3.new(0.12, 0.12, 0.12), sd == 1 and Color3.fromRGB(40, 255, 90) or Color3.fromRGB(255, 40, 40), Enum.Material.Neon, Enum.PartType.Ball)
                attach(navLed, CFrame.new(at(Vector3.new(sd * 2.4, 0, 1.1))))
            end
            local fin = part(Vector3.new(0.07, 0.75, 0.7), spec.frame, Enum.Material.Metal)
            attach(fin, CFrame.new(at(Vector3.new(0, 0.48, 1.2))))
            local engine = part(Vector3.new(0.45, 0.45, 0.45), spec.accent, Enum.Material.Metal, Enum.PartType.Cylinder)
            attach(engine, CFrame.new(at(Vector3.new(0, 0, 1.6))) * FWD)
            local base = at(Vector3.new(0, 0, 1.88))
            for j = 0, 1 do
                local b = part(Vector3.new(0.5, 0.12, 0.03), Color3.fromRGB(30, 30, 30), Enum.Material.SmoothPlastic)
                props[#props + 1] = {w = attach(b, CFrame.new(base)), base = base, off = j * math.pi, axis = "Z", shift = at(0.25)}
            end
            lens = part(Vector3.new(0.12, 0.12, 0.12), Color3.fromRGB(60, 140, 255), Enum.Material.Neon, Enum.PartType.Ball)
            attach(lens, CFrame.new(at(Vector3.new(0, -0.15, -1.85))))
        else
            local bottom = part(Vector3.new(1.0, 0.06, 1.6), spec.frame, Enum.Material.Slate)
            attach(bottom, CFrame.new())
            local top = part(Vector3.new(0.85, 0.05, 1.3), spec.frame, Enum.Material.Slate)
            attach(top, CFrame.new(at(Vector3.new(0, 0.34, 0))))
            for _, o in ipairs({Vector3.new(0.34, 0.17, 0.55), Vector3.new(-0.34, 0.17, 0.55), Vector3.new(0.34, 0.17, -0.55), Vector3.new(-0.34, 0.17, -0.55)}) do
                local so = part(Vector3.new(0.3, 0.07, 0.07), spec.accent, Enum.Material.Metal, Enum.PartType.Cylinder)
                attach(so, CFrame.new(at(o)) * SIDE)
            end
            local fc = part(Vector3.new(0.62, 0.05, 0.62), Color3.fromRGB(20, 90, 45), Enum.Material.SmoothPlastic)
            attach(fc, CFrame.new(at(Vector3.new(0, 0.16, 0))))
            local bat = part(Vector3.new(0.56, 0.3, 1.0), Color3.fromRGB(235, 195, 40), Enum.Material.SmoothPlastic)
            attach(bat, CFrame.new(at(Vector3.new(0, 0.53, 0.05))))
            local wrap = part(Vector3.new(0.57, 0.31, 0.55), Color3.fromRGB(25, 25, 28), Enum.Material.SmoothPlastic)
            attach(wrap, CFrame.new(at(Vector3.new(0, 0.53, 0.1))))
            local strap = part(Vector3.new(0.62, 0.34, 0.12), Color3.fromRGB(200, 30, 40), Enum.Material.Fabric)
            attach(strap, CFrame.new(at(Vector3.new(0, 0.53, -0.2))))
            local lead = part(Vector3.new(0.5, 0.07, 0.07), Color3.fromRGB(190, 30, 30), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
            attach(lead, CFrame.new(at(Vector3.new(0.12, 0.42, 0.75))) * FWD)
            local xt = part(Vector3.new(0.14, 0.1, 0.18), Color3.fromRGB(240, 220, 40), Enum.Material.SmoothPlastic)
            attach(xt, CFrame.new(at(Vector3.new(0.12, 0.42, 1.02))))
            local ant = part(Vector3.new(0.6, 0.05, 0.05), Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
            attach(ant, CFrame.new(at(Vector3.new(0, 0.6, 0.82))) * CFrame.Angles(math.rad(-35), 0, 0) * SIDE)
            local antTip = part(Vector3.new(0.14, 0.14, 0.14), Color3.fromRGB(20, 20, 20), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
            attach(antTip, CFrame.new(at(Vector3.new(0, 0.85, 1.0))))
            for _, sx in ipairs({0.2, -0.2}) do
                local plate = part(Vector3.new(0.05, 0.32, 0.32), spec.accent, Enum.Material.SmoothPlastic)
                attach(plate, CFrame.new(at(Vector3.new(sx, 0.17, -0.68))))
            end
            local camBody = part(Vector3.new(0.34, 0.3, 0.3), Color3.fromRGB(15, 15, 15), Enum.Material.Metal)
            attach(camBody, CFrame.new(at(Vector3.new(0, 0.17, -0.7))) * CFrame.Angles(math.rad(15), 0, 0))
            local lensRing = part(Vector3.new(0.12, 0.22, 0.22), Color3.fromRGB(40, 40, 44), Enum.Material.Metal, Enum.PartType.Cylinder)
            attach(lensRing, CFrame.new(at(Vector3.new(0, 0.19, -0.88))) * FWD)
            lens = part(Vector3.new(0.12, 0.14, 0.14), Color3.fromRGB(60, 140, 255), Enum.Material.Neon, Enum.PartType.Ball)
            attach(lens, CFrame.new(at(Vector3.new(0, 0.19, -0.96))))
            if spec.gimbal then
                local arm1 = part(Vector3.new(0.08, 0.25, 0.08), spec.accent, Enum.Material.Metal)
                attach(arm1, CFrame.new(at(Vector3.new(0, -0.15, -0.72))))
                local gb = part(Vector3.new(0.3, 0.3, 0.3), Color3.fromRGB(40, 40, 44), Enum.Material.Metal, Enum.PartType.Ball)
                attach(gb, CFrame.new(at(Vector3.new(0, -0.32, -0.72))))
                lens = part(Vector3.new(0.12, 0.12, 0.12), Color3.fromRGB(60, 140, 255), Enum.Material.Neon, Enum.PartType.Ball)
                attach(lens, CFrame.new(at(Vector3.new(0, -0.32, -0.88))))
            end
            if spec.gopro then
                local gp = part(Vector3.new(0.45, 0.32, 0.25), Color3.fromRGB(20, 20, 22), Enum.Material.SmoothPlastic)
                attach(gp, CFrame.new(at(Vector3.new(0, 0.86, -0.25))))
                local gpl = part(Vector3.new(0.08, 0.16, 0.16), Color3.fromRGB(60, 60, 70), Enum.Material.Glass, Enum.PartType.Cylinder)
                attach(gpl, CFrame.new(at(Vector3.new(0.1, 0.86, -0.4))) * FWD)
            end
            if spec.payload then
                local war = part(Vector3.new(1.1, 0.32, 0.32), Color3.fromRGB(85, 95, 60), Enum.Material.Metal, Enum.PartType.Cylinder)
                attach(war, CFrame.new(at(Vector3.new(0, -0.28, -0.1))) * FWD)
                local cone = part(Vector3.new(0.32, 0.32, 0.32), Color3.fromRGB(70, 78, 50), Enum.Material.Metal, Enum.PartType.Ball)
                attach(cone, CFrame.new(at(Vector3.new(0, -0.28, -0.68))))
                local band = part(Vector3.new(0.08, 0.34, 0.34), Color3.fromRGB(230, 200, 40), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
                attach(band, CFrame.new(at(Vector3.new(0, -0.28, 0.25))) * FWD)
                for f = 0, 3 do
                    local fin = part(Vector3.new(0.03, 0.22, 0.22), Color3.fromRGB(60, 66, 44), Enum.Material.Metal)
                    attach(fin, CFrame.new(at(Vector3.new(0, -0.28, 0.42))) * CFrame.Angles(0, 0, f * math.pi / 2) * CFrame.new(0, at(0.2), 0))
                end
            end
            local n = spec.arms or 4
            local armLen = 1.25
            for i = 0, n - 1 do
                local r = math.rad((n == 4 and 45 or 0) + i * 360 / n)
                local dir = Vector3.new(math.cos(r), 0, math.sin(r))
                local arm = part(Vector3.new(0.2, 0.07, armLen), spec.frame, Enum.Material.Slate)
                attach(arm, CFrame.lookAt(at(dir * armLen / 2), at(dir * armLen * 2)))
                local stripe = part(Vector3.new(0.08, 0.03, armLen * 0.7), spec.led, Enum.Material.Neon)
                local sp = dir * armLen / 2 - Vector3.new(0, 0.05, 0)
                attach(stripe, CFrame.lookAt(at(sp), at(sp + dir)))
                local mpos = dir * armLen
                local stator = part(Vector3.new(0.18, 0.3, 0.3), Color3.fromRGB(60, 60, 68), Enum.Material.Metal, Enum.PartType.Cylinder)
                attach(stator, CFrame.new(at(mpos + Vector3.new(0, 0.1, 0))) * SIDE)
                local bell = part(Vector3.new(0.1, 0.32, 0.32), spec.accent, Enum.Material.Metal, Enum.PartType.Cylinder)
                attach(bell, CFrame.new(at(mpos + Vector3.new(0, 0.22, 0))) * SIDE)
                local base = at(mpos + Vector3.new(0, 0.3, 0))
                local bl = spec.blades or 2
                for j = 0, bl - 1 do
                    local b = part(Vector3.new(0.48, 0.025, 0.15), spec.propColor or Color3.fromRGB(235, 235, 240), Enum.Material.SmoothPlastic, nil, 0.05)
                    props[#props + 1] = {w = attach(b, CFrame.new(base)), base = base, off = j * math.pi * 2 / bl, axis = "Y", shift = at(0.24)}
                end
                local disc = part(Vector3.new(0.02, 1.0, 1.0), Color3.fromRGB(200, 200, 210), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder, 0.88)
                attach(disc, CFrame.new(base) * SIDE)
                if spec.ducts then
                    for q = 0, 15 do
                        local a = q / 16 * math.pi * 2
                        local off = at(Vector3.new(math.cos(a), 0, math.sin(a)) * 0.56)
                        local seg = part(Vector3.new(0.06, 0.28, 0.24), spec.accent, Enum.Material.SmoothPlastic)
                        attach(seg, CFrame.lookAt(base + off, base + off + Vector3.new(-math.sin(a), 0, math.cos(a))))
                    end
                end
            end
            local ledR = part(Vector3.new(0.1, 0.1, 0.1), Color3.fromRGB(255, 40, 40), Enum.Material.Neon, Enum.PartType.Ball)
            attach(ledR, CFrame.new(at(Vector3.new(-0.3, -0.06, 0.78))))
            local ledG = part(Vector3.new(0.1, 0.1, 0.1), Color3.fromRGB(40, 255, 90), Enum.Material.Neon, Enum.PartType.Ball)
            attach(ledG, CFrame.new(at(Vector3.new(0.3, -0.06, 0.78))))
        end
        m.Parent = workspace
        return m, body, props, lens
    end

    local function bigBoom(pos, radius)
        local ex = Instance.new("Explosion")
        ex.Position = pos
        ex.BlastPressure = 0
        ex.BlastRadius = radius
        ex.DestroyJointRadiusPercent = 0
        ex.ExplosionType = Enum.ExplosionType.NoCraters
        ex.Parent = workspace
        local folder = Instance.new("Folder")
        folder.Name = "ZenithBoom"
        folder.Parent = workspace
        local function fxp(size, color, shape, tr)
            local p = Instance.new("Part")
            p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
            p.Size, p.Color = size, color
            p.Material = Enum.Material.Neon
            p.Shape = shape or Enum.PartType.Ball
            p.Transparency = tr or 0
            p.CFrame = CFrame.new(pos)
            p.Parent = folder
            return p
        end
        local fire = fxp(Vector3.new(1, 1, 1), Color3.fromRGB(255, 170, 50))
        TweenService:Create(fire, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = Vector3.new(1, 1, 1) * radius * 1.6, Transparency = 1, Color = Color3.fromRGB(255, 70, 20)}):Play()
        local core = fxp(Vector3.new(1, 1, 1), Color3.fromRGB(255, 255, 220))
        TweenService:Create(core, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = Vector3.new(1, 1, 1) * radius * 0.8, Transparency = 1}):Play()
        local ringP = fxp(Vector3.new(0.2, 1, 1), Color3.fromRGB(255, 210, 140), Enum.PartType.Cylinder, 0.2)
        ringP.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2)
        TweenService:Create(ringP, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = Vector3.new(0.2, radius * 3.2, radius * 3.2), Transparency = 1}):Play()
        local src = fxp(Vector3.new(1, 1, 1), Color3.new(1, 1, 1), nil, 1)
        local function burst(tex, c1, c2, s0, s1, life, sp, count, acc, emis)
            local em = Instance.new("ParticleEmitter")
            em.Texture = tex
            em.Color = ColorSequence.new(c1, c2)
            em.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, s0), NumberSequenceKeypoint.new(1, s1)})
            em.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 1)})
            em.Lifetime = NumberRange.new(life * 0.6, life)
            em.Speed = NumberRange.new(sp * 0.4, sp)
            em.SpreadAngle = Vector2.new(180, 180)
            em.Acceleration = acc or Vector3.zero
            em.Rotation = NumberRange.new(0, 360)
            em.RotSpeed = NumberRange.new(-120, 120)
            em.LightEmission = emis or 1
            em.LightInfluence = 0
            em.Rate = 0
            em.Drag = 2
            em.Parent = src
            em:Emit(count)
        end
        burst("rbxasset://textures/particles/fire_main.dds", Color3.fromRGB(255, 220, 90), Color3.fromRGB(255, 70, 20), radius * 0.5, 0, 0.8, radius * 2.2, 45)
        burst("rbxasset://textures/particles/smoke_main.dds", Color3.fromRGB(70, 70, 70), Color3.fromRGB(25, 25, 25), radius * 0.4, radius * 1.1, 2.6, radius * 1.4, 35, Vector3.new(0, 3, 0), 0)
        burst("rbxasset://textures/particles/sparkles_main.dds", Color3.fromRGB(255, 240, 160), Color3.fromRGB(255, 140, 40), 0.5, 0, 0.9, radius * 5, 70, Vector3.new(0, -30, 0))
        local l = Instance.new("PointLight")
        l.Color = Color3.fromRGB(255, 150, 60)
        l.Range = math.min(radius * 4, 60)
        l.Brightness = 10
        l.Parent = src
        TweenService:Create(l, TweenInfo.new(0.7), {Brightness = 0}):Play()
        local bs = Instance.new("Sound")
        bs.SoundId = "rbxassetid://124994246147928"
        bs.Volume = 3
        bs.Parent = SoundService2
        bs:Play()
        Debris:AddItem(bs, 10)
        Debris:AddItem(folder, 4)
    end

    local function signalLost(duration)
        local g = guiRoot("ZenithSignalLost")
        local bg = Instance.new("Frame")
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
        bg.BorderSizePixel = 0
        bg.Parent = g
        local noise = {}
        for k = 1, 90 do
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0
            f.Parent = bg
            noise[k] = f
        end
        local bars = {}
        for k = 1, 6 do
            local f = Instance.new("Frame")
            f.BorderSizePixel = 0
            f.BackgroundColor3 = Color3.fromRGB(210, 210, 210)
            f.Parent = bg
            bars[k] = f
        end
        local big = osdText(bg, "SIGNAL LOST", 0.5, 0.5, 0.5, 0.45, 46, Color3.fromRGB(255, 60, 60), Enum.TextXAlignment.Center)
        big.Size = UDim2.new(0, 640, 0, 60)
        local sub = osdText(bg, "NO VIDEO  |  CH 5.8G  |  LINK DOWN", 0.5, 0.5, 0.5, 0.55, 18, Color3.fromRGB(220, 220, 220), Enum.TextXAlignment.Center)
        sub.Size = UDim2.new(0, 640, 0, 26)
        local rec = osdText(bg, "REC", 0, 0, 0.03, 0.05, 18, Color3.fromRGB(255, 60, 60))
        local t0 = tick()
        while tick() - t0 < duration do
            for _, f in ipairs(noise) do
                local w = math.random(10, 160)
                f.Size = UDim2.new(0, w, 0, math.random(2, 6))
                f.Position = UDim2.new(math.random(), -w / 2, math.random(), 0)
                local v = math.random(40, 210)
                f.BackgroundColor3 = Color3.fromRGB(v, v, v)
                f.BackgroundTransparency = math.random() * 0.6
            end
            for _, f in ipairs(bars) do
                f.Size = UDim2.new(1, 0, 0, math.random(2, 10))
                f.Position = UDim2.new(0, 0, math.random(), 0)
                f.BackgroundTransparency = 0.6 + math.random() * 0.35
            end
            big.Visible = math.floor((tick() - t0) * 4) % 2 == 0
            rec.Text = string.format("REC 00:%02d   NO SIGNAL", math.floor(tick() - t0))
            PRE_RENDER:Wait()
        end
        g:Destroy()
    end

    local function nearestOf(filter)
        local hrp = myHrp()
        if not hrp then return nil end
        local best, bd = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local c, r = aliveChar(p)
                if c and filter(p) then
                    local d = (r.Position - hrp.Position).Magnitude
                    if d < bd then best, bd = p, d end
                end
            end
        end
        return best
    end

    FX.DRONE_TARGETS = {"Any (auto)", "Hero (Fling)", "Innocent (Fling)", "Sheriff (Fling)", "Murder (Kill)"}
    FX.DRONE_TYPES = {"FPV", "Kamikaze FPV", "Shahed"}

    local mapC = {t = 0}
    local function onMap(pos)
        local now = tick()
        if now - mapC.t > 1 then
            mapC.t = now
            mapC.box = nil
            for _, ch in ipairs(workspace:GetChildren()) do
                if ch:IsA("Model") and ch:FindFirstChild("CoinContainer") then
                    local ok, cf, size = pcall(function() return ch:GetBoundingBox() end)
                    if ok then mapC.box = {cf, size / 2 + Vector3.new(40, 60, 40)} end
                    break
                end
            end
        end
        local b = mapC.box
        if not b then return true end
        local l = b[1]:PointToObjectSpace(pos)
        return math.abs(l.X) <= b[2].X and math.abs(l.Y) <= b[2].Y and math.abs(l.Z) <= b[2].Z
    end

    local function eligible(p)
        if p == lp then return false end
        local c, r = aliveChar(p)
        if not c or not inRound(p) or not onMap(r.Position) then return false end
        if roles[lp] == "Murderer" or hasKnife() then return true end
        local pick = CFG.droneTarget
        local role = roles[p] or "Innocent"
        if pick == "Any (auto)" then return true end
        if pick == "Murder (Kill)" then return role == "Murderer" end
        if pick == "Hero (Fling)" then return role == "Hero" end
        if pick == "Sheriff (Fling)" then return role == "Sheriff" end
        return role == "Innocent"
    end

    local function act(p)
        local how
        if roles[lp] == "Murderer" or hasKnife() then
            how = "KILL"
            FX.killTarget(p)
        elseif roles[p] == "Murderer" and FX.shootNow then
            how = "SHOOT"
            FX.shootNow()
        else
            how = "FLING"
            FX.flingPlayer(p.Name)
        end
        task.wait(1.2)
        local c = aliveChar(p)
        if c and inRound(p) and how ~= "FLING" then
            how = how .. " + FLING"
            FX.flingPlayer(p.Name)
        end
        if FX.notify then FX.notify("Zenith FPV", "HIT " .. p.Name .. "  ->  " .. how) end
    end

    FX.droneCmd = nil
    local launchInner
    FX.launchDrone = function()
        if FX.droneFlying then
            FX.droneCmd = "boom"
            return
        end
        FX.droneRestore = nil
        local okL, err = pcall(launchInner)
        if not okL then
            if FX.droneRestore then
                pcall(FX.droneRestore)
            else
                FX.droneFlying = false
                FX.droneCmd = nil
                local c0 = workspace.CurrentCamera
                c0.CameraType = Enum.CameraType.Custom
                local _, hm = myHrp()
                if hm then c0.CameraSubject = hm end
            end
            if FX.notify then FX.notify("Zenith FPV", "Error: " .. tostring(err)) end
        end
    end

    launchInner = function()
        if FX.droneFlying then
            FX.droneCmd = "boom"
            return
        end
        local hrp, hum = myHrp()
        if not hrp or not hum or hum.Health <= 0 then return end
        FX.droneFlying = true
        FX.droneCmd = nil
        local spec = DRONES[CFG.droneType] or DRONES.FPV
        local maxSpeed = spec.speed
        local cam0 = workspace.CurrentCamera
        local oldFov, oldMode = cam0.FieldOfView, lp.CameraMode
        local oldWS, oldJP = hum.WalkSpeed, hum.JumpPower
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        local start = hrp.CFrame * CFrame.new(0, 4, -3)
        do
            local up = RaycastParams.new()
            up.FilterType = Enum.RaycastFilterType.Exclude
            up.FilterDescendantsInstances = {lp.Character}
            up.RespectCanCollide = true
            local hitUp = workspace:Raycast(hrp.Position, start.Position - hrp.Position, up)
            if hitUp then start = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 0)) * hrp.CFrame.Rotation end
        end
        local m, body, props, lens = buildDrone(start, spec)
        local oldMin, oldMax = lp.CameraMinZoomDistance, lp.CameraMaxZoomDistance
        cam0.CameraType = Enum.CameraType.Custom
        if CFG.droneCam == "Third person" then
            cam0.CameraSubject = body
            pcall(function()
                lp.CameraMode = Enum.CameraMode.Classic
                lp.CameraMaxZoomDistance = CFG.droneCamDist
                lp.CameraMinZoomDistance = CFG.droneCamDist
            end)
            cam0.FieldOfView = 80
        else
            cam0.CameraSubject = lens
            pcall(function() lp.CameraMode = Enum.CameraMode.LockFirstPerson end)
            cam0.FieldOfView = 100
        end
        local fly = Instance.new("Sound")
        fly.SoundId = "rbxassetid://114037851906101"
        fly.Looped = true
        fly.Volume = spec.vol
        fly.Parent = body
        fly:Play()

        local osd = guiRoot("ZenithFPVOSD")
        local red = Color3.fromRGB(255, 70, 70)
        osdText(osd, string.upper(CFG.droneType) .. (spec.thermal and "  THERMAL" or "") .. (spec.nv and "  NV" or "") .. "  CH 5.8G  1W", 0, 0, 0.03, 0.05, 18)
        local recT = osdText(osd, "REC", 1, 0, 0.97, 0.05, 18, red, Enum.TextXAlignment.Right)
        local cross = osdText(osd, "[  +  ]", 0.5, 0.5, 0.5, 0.5, 26, Color3.new(1, 1, 1), Enum.TextXAlignment.Center)
        cross.Size = UDim2.new(0, 200, 0, 34)
        local tgtT = osdText(osd, "", 0.5, 0, 0.5, 0.12, 18, red, Enum.TextXAlignment.Center)
        local armT = osdText(osd, "ARMED", 0.5, 0, 0.5, 0.17, 20, red, Enum.TextXAlignment.Center)
        local spdT = osdText(osd, "", 0, 1, 0.03, 0.93, 18)
        local batT = osdText(osd, "", 0, 1, 0.03, 0.87, 18)
        local upHeld, downHeld = false, false
        local function mkBtn(text, px, py, color, w)
            local b = Instance.new("TextButton")
            b.AnchorPoint = Vector2.new(1, 1)
            b.Position = UDim2.new(px, 0, py, 0)
            b.Size = UDim2.new(0, w or 90, 0, 46)
            b.BackgroundColor3 = color
            b.BackgroundTransparency = 0.2
            b.Font = Enum.Font.Code
            b.TextSize = 20
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Text = text
            b.AutoButtonColor = true
            b.Parent = osd
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end
        local boomB = mkBtn("BOOM", 0.97, 0.62, Color3.fromRGB(200, 30, 40), 110)
        local exitB = mkBtn("EXIT", 0.97, 0.74, Color3.fromRGB(60, 60, 70))
        local upB = mkBtn("UP", 0.85, 0.62, Color3.fromRGB(40, 90, 160))
        local downB = mkBtn("DOWN", 0.85, 0.74, Color3.fromRGB(40, 90, 160))
        boomB.Activated:Connect(function() FX.droneCmd = "boom" end)
        exitB.Activated:Connect(function() FX.droneCmd = "exit" end)
        upB.MouseButton1Down:Connect(function() upHeld = true end)
        upB.MouseButton1Up:Connect(function() upHeld = false end)
        upB.MouseLeave:Connect(function() upHeld = false end)
        downB.MouseButton1Down:Connect(function() downHeld = true end)
        downB.MouseButton1Up:Connect(function() downHeld = false end)
        downB.MouseLeave:Connect(function() downHeld = false end)
        local climb = 0
        local jconn = UIS.JumpRequest:Connect(function() climb = 0.3 end)

        local rpP = RaycastParams.new()
        rpP.FilterType = Enum.RaycastFilterType.Include
        local thermal = {}
        if spec.thermal or spec.nv then
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "ZenithThermal"
            if spec.nv then
                cc.Saturation = -0.7
                cc.Contrast = 0.25
                cc.Brightness = 0.18
                cc.TintColor = Color3.fromRGB(120, 255, 120)
            else
                cc.Saturation = -1
                cc.Contrast = 0.35
                cc.Brightness = 0.05
                cc.TintColor = Color3.fromRGB(225, 235, 255)
                thermal.hls = {}
            end
            cc.Parent = Lighting
            thermal.cc = cc
        end
        local rp2 = RaycastParams.new()
        rp2.FilterType = Enum.RaycastFilterType.Exclude
        rp2.FilterDescendantsInstances = {lp.Character, m}
        pcall(function() rp2.RespectCanCollide = true end)

        local restored = false
        FX.droneRestore = function()
            if restored then return end
            restored = true
            pcall(function() jconn:Disconnect() end)
            pcall(function() fly:Stop() end)
            if thermal.cc then pcall(function() thermal.cc:Destroy() end) end
            for _, h in pairs(thermal.hls or {}) do pcall(function() h:Destroy() end) end
            pcall(function() osd:Destroy() end)
            pcall(function() m:Destroy() end)
            pcall(function() lp.CameraMode = oldMode end)
            pcall(function()
                lp.CameraMaxZoomDistance = oldMax
                lp.CameraMinZoomDistance = oldMin
            end)
            pcall(function()
                cam0.FieldOfView = oldFov
                cam0.CameraType = Enum.CameraType.Custom
                local _, hum2 = myHrp()
                if hum2 then cam0.CameraSubject = hum2 end
                if hum.Parent then
                    hum.WalkSpeed = oldWS
                    hum.JumpPower = oldJP
                end
            end)
            FX.droneCmd = nil
            FX.droneFlying = false
        end

        local pos, vel = start.Position, Vector3.zero
        local t0 = tick()
        local hitP, reason = nil, nil
        local spin = 0
        local ok = pcall(function()
            while running do
                local dt = PRE_RENDER:Wait()
                if hum.Health <= 0 then
                    reason = "dead"
                    break
                end
                if FX.droneCmd == "exit" or FX.droneCmd == "boom" then
                    reason = FX.droneCmd
                    break
                end
                local el = tick() - t0
                if not CFG.droneInfBat and el > (spec.battery or 60) then
                    reason = "battery"
                    break
                end
                local cf0 = cam0.CFrame
                local look, right = cf0.LookVector, cf0.RightVector
                local fl = Vector3.new(look.X, 0, look.Z)
                fl = fl.Magnitude > 0.01 and fl.Unit or Vector3.new(0, 0, -1)
                local fr = Vector3.new(right.X, 0, right.Z)
                fr = fr.Magnitude > 0.01 and fr.Unit or Vector3.new(1, 0, 0)
                local md = hum.MoveDirection
                local fwd, side = md:Dot(fl), md:Dot(fr)
                if spec.minThrottle and fwd < spec.minThrottle then fwd = spec.minThrottle end
                climb = math.max(0, climb - dt)
                local up = ((climb > 0 or upHeld) and 1) or (downHeld and -1) or 0
                local wish = look * fwd + right * side + Vector3.new(0, up, 0)
                if wish.Magnitude > 1 then wish = wish.Unit end
                vel = vel:Lerp(wish * maxSpeed, math.clamp(dt * spec.accel, 0, 1))
                local stepV = vel * dt
                if stepV.Magnitude > 0.001 then
                    local params = rp2
                    if CFG.droneNoclip then
                        local chars = {}
                        for _, pl in ipairs(Players:GetPlayers()) do
                            if pl ~= lp and pl.Character then chars[#chars + 1] = pl.Character end
                        end
                        rpP.FilterDescendantsInstances = chars
                        params = rpP
                    end
                    local hit = workspace:Raycast(pos, stepV + stepV.Unit * 0.8, params)
                    if hit then
                        local mdl = hit.Instance:FindFirstAncestorOfClass("Model")
                        local hp = mdl and Players:GetPlayerFromCharacter(mdl)
                        if hp and eligible(hp) then
                            hitP, reason = hp, "hit"
                            pos = hit.Position
                            break
                        elseif not CFG.droneNoclip then
                            reason = "crash"
                            pos = hit.Position
                            break
                        end
                    end
                end
                pos = pos + stepV
                local nearP, nearD = nil, math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if eligible(p) then
                        local _, r = aliveChar(p)
                        local d = (r.Position - pos).Magnitude
                        if d < nearD then nearP, nearD = p, d end
                    end
                end
                if thermal.hls then
                    for _, pl in ipairs(Players:GetPlayers()) do
                        local ch = pl ~= lp and pl.Character
                        if ch and not thermal.hls[ch] then
                            local h = Instance.new("Highlight")
                            h.FillColor, h.OutlineColor = Color3.new(1, 1, 1), Color3.new(1, 1, 1)
                            h.FillTransparency, h.OutlineTransparency = 0.05, 0
                            h.DepthMode = Enum.HighlightDepthMode.Occluded
                            h.Adornee = ch
                            h.Parent = ch
                            thermal.hls[ch] = h
                        end
                    end
                end
                if nearP and nearD < 3.5 * (spec.scale or 1) then
                    hitP, reason = nearP, "hit"
                    break
                end
                body.CFrame = CFrame.lookAt(pos, pos + fl) * CFrame.Angles(-fwd * 0.35, 0, -side * 0.35)
                spin += dt * 70
                for _, pr in ipairs(props) do
                    if pr.axis == "Z" then
                        pr.w.C0 = CFrame.new(pr.base) * CFrame.Angles(0, 0, spin + pr.off) * CFrame.new(pr.shift or 0, 0, 0)
                    else
                        pr.w.C0 = CFrame.new(pr.base) * CFrame.Angles(0, spin + pr.off, 0) * CFrame.new(pr.shift or 0, 0, 0)
                    end
                end
                fly.PlaybackSpeed = 0.85 + math.clamp(vel.Magnitude / maxSpeed, 0, 1) * 0.6
                spdT.Text = string.format("SPD %d km/h  ALT %dm", math.floor(vel.Magnitude * 1.8), math.floor(pos.Y - start.Position.Y + 4))
                batT.Text = CFG.droneInfBat and "BAT INF" or string.format("BAT %d%%", math.max(0, math.floor(100 - el * 100 / (spec.battery or 60))))
                recT.Text = (math.floor(el * 2) % 2 == 0 and "REC  " or "     ") .. string.format("00:%02d", math.floor(el) % 60)
                armT.Visible = math.floor(el * 3) % 2 == 0
                tgtT.Text = nearP and string.format("TGT %s  %dm", nearP.Name, math.floor(nearD)) or "NO TARGET"
            end
        end)
        jconn:Disconnect()
        if thermal.cc then pcall(function() thermal.cc:Destroy() end) end
        for _, h in pairs(thermal.hls or {}) do pcall(function() h:Destroy() end) end
        pcall(function() fly:Stop() end)

        if reason == "boom" and not hitP then
            local best, bd = nil, spec.boom
            for _, p in ipairs(Players:GetPlayers()) do
                if eligible(p) then
                    local _, r = aliveChar(p)
                    local d = (r.Position - pos).Magnitude
                    if d < bd then best, bd = p, d end
                end
            end
            hitP = best
        end

        pcall(function() osd:Destroy() end)
        if reason ~= "exit" and reason ~= "dead" then
            pcall(function() m:Destroy() end)
            pcall(bigBoom, pos, spec.boom)
            if hitP and ok then
                local target = hitP
                task.spawn(function() pcall(act, target) end)
            elseif FX.notify then
                task.spawn(FX.notify, "Zenith FPV", reason == "crash" and "CRASH - no target" or "NO TARGET")
            end
            pcall(signalLost, 1.8)
        else
            pcall(function() m:Destroy() end)
        end
        FX.droneRestore()
    end

    local wm = {}
    local function roundTimer()
        local part = workspace:FindFirstChild("RoundTimerPart")
        local sg = part and part:FindFirstChildWhichIsA("SurfaceGui")
        local t = sg and sg:FindFirstChild("Timer")
        if t and t:IsA("TextLabel") then return t.Text end
    end

    local function buildWatermark()
        local PANEL_COLOR = Color3.fromRGB(5, 13, 28)
        local ICON_COLOR = Color3.fromRGB(25, 70, 135)
        local TEXT_COLOR = Color3.fromRGB(150, 175, 205)
        local TITLE_COLOR = Color3.fromRGB(35, 90, 155)
        local g = guiRoot("ZenithWatermark")
        g.DisplayOrder = 50
        local main = Instance.new("Frame")
        main.Size = UDim2.new(0, 232, 0, 32)
        main.Position = UDim2.new(0, 15, 0, 15)
        main.BackgroundColor3 = PANEL_COLOR
        main.BackgroundTransparency = 0.2
        main.BorderSizePixel = 0
        main.Active = true
        main.Parent = g
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke")
        st.Color = ICON_COLOR
        st.Transparency = 0.25
        st.Thickness = 1
        st.Parent = main
        local icon = Instance.new("ImageLabel")
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, 7, 0.5, -9)
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Image = "rbxassetid://132137903274702"
        icon.ImageColor3 = ICON_COLOR
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = main
        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 29, 0, 0)
        title.Size = UDim2.new(0, 43, 1, 0)
        title.Font = Enum.Font.GothamBold
        title.Text = "zenith"
        title.TextColor3 = TITLE_COLOR
        title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = main
        local function info(iconId, text, x, width)
            if iconId then
                local ic = Instance.new("ImageLabel")
                ic.BackgroundTransparency = 1
                ic.Position = UDim2.new(0, x, 0.5, -6)
                ic.Size = UDim2.new(0, 12, 0, 12)
                ic.Image = iconId
                ic.ImageColor3 = ICON_COLOR
                ic.Parent = main
            end
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Position = UDim2.new(0, x + 15, 0, 0)
            l.Size = UDim2.new(0, width, 1, 0)
            l.Font = Enum.Font.GothamMedium
            l.Text = text
            l.TextColor3 = TEXT_COLOR
            l.TextSize = 9
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = main
            return l
        end
        wm.fps = info("rbxassetid://11395830213", "0 FPS", 76, 48)
        wm.ping = info("rbxassetid://105127187178989", "0ms", 127, 42)
        wm.timer = info(nil, "--:--", 172, 50)
        wm.gui, wm.main = g, main
        local dragging, dragStart, startPos = false, nil, nil
        main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging, dragStart, startPos = true, input.Position, main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        connect(UIS.InputChanged, function(input)
            if not dragging or not dragStart then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    FX.wmDestroy = function()
        if wm.gui then pcall(function() wm.gui:Destroy() end) end
        wm = {}
    end

    pcall(function()
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxassetid://1548304764"
        snd.Volume = 1
        snd.Parent = SoundService2
        task.delay(0.1, function()
            snd:Play()
            Debris:AddItem(snd, 8)
        end)
    end)

    local frames, lastT = 0, tick()
    connect(PRE_RENDER, function()
        frames += 1
        local now = tick()
        if now - lastT >= 1 then
            if wm.fps then wm.fps.Text = tostring(frames) .. " FPS" end
            frames, lastT = 0, now
        end
    end)

    task.spawn(function()
        while running do
            pcall(function()
                if CFG.watermark then
                    if not wm.gui or not wm.gui.Parent then buildWatermark() end
                    local okp, ping = pcall(function() return math.floor(lp:GetNetworkPing() * 1000) end)
                    wm.ping.Text = (okp and tostring(ping) or "0") .. "ms"
                    local tt = CFG.wmTimer and roundTimer()
                    wm.timer.Visible = CFG.wmTimer
                    wm.timer.Text = tt and ("T " .. tt) or "T --:--"
                    wm.main.Size = UDim2.new(0, CFG.wmTimer and 232 or 175, 0, 32)
                elseif wm.gui then
                    FX.wmDestroy()
                end
            end)
            task.wait(1)
        end
    end)
end

do
    local PACKS = {
        Zombie = {idle1 = 616158929, idle2 = 616160636, walk = 616168032, run = 616163682, jump = 616161997, climb = 616156119, fall = 616157476, swim = 616165109, swimidle = 616166655},
        Ninja = {idle1 = 656117400, idle2 = 656118341, walk = 656121766, run = 656118852, jump = 656117878, climb = 656114359, fall = 656115606, swim = 656119721, swimidle = 656121397},
        Robot = {idle1 = 616088211, idle2 = 616089559, walk = 616095330, run = 616091570, jump = 616090535, climb = 616086039, fall = 616087089, swim = 616092998, swimidle = 616094091},
        Stylish = {idle1 = 616136790, idle2 = 616138447, walk = 616146177, run = 616140816, jump = 616139451, climb = 616133594, fall = 616134815, swim = 616143378, swimidle = 616144772},
        Cartoony = {idle1 = 742637544, idle2 = 742638445, walk = 742640026, run = 742638842, jump = 742637942, climb = 742636889, fall = 742637151, swim = 742639220, swimidle = 742639812},
        Superhero = {idle1 = 616111295, idle2 = 616113536, walk = 616122287, run = 616117076, jump = 616115533, climb = 616104706, fall = 616108001, swim = 616119360, swimidle = 616120861},
        Knight = {idle1 = 657595757, idle2 = 657568135, walk = 657552124, run = 657564596, jump = 658409194, climb = 658360781, fall = 657600338, swim = 657560551, swimidle = 657557095},
        Levitation = {idle1 = 616006778, idle2 = 616008087, walk = 616013216, run = 616010382, jump = 616008936, climb = 616003713, fall = 616005863, swim = 616011509, swimidle = 616012453},
        Astronaut = {idle1 = 891621366, idle2 = 891633237, walk = 891667138, run = 891636393, jump = 891627522, climb = 891609353, fall = 891617961, swim = 891639666, swimidle = 891663592},
        Vampire = {idle1 = 1083445855, idle2 = 1083450166, walk = 1083473930, run = 1083462077, jump = 1083455352, climb = 1083439238, fall = 1083443587, swim = 1083222527, swimidle = 1083225406},
        Werewolf = {idle1 = 1083195517, idle2 = 1083214717, walk = 1083178339, run = 1083216690, jump = 1083218792, climb = 1083182000, fall = 1083189019, swim = 1083222527, swimidle = 1083225406},
        Toy = {idle1 = 782841498, idle2 = 782845736, walk = 782843345, run = 782842708, jump = 782847020, climb = 782843869, fall = 782846423, swim = 782844582, swimidle = 782845186},
        Pirate = {idle1 = 750781874, idle2 = 750782770, walk = 750785693, run = 750783738, jump = 750782230, climb = 750779899, fall = 750780242, swim = 750784579, swimidle = 750785176},
        Elder = {idle1 = 845397899, idle2 = 845400520, walk = 845403856, run = 845386501, jump = 845398858, climb = 845392038, fall = 845396048, swim = 845401742, swimidle = 845403127},
        Mage = {idle1 = 707742142, idle2 = 707855907, walk = 707897309, run = 707861613, jump = 707853694, climb = 707826056, fall = 707829716, swim = 707876443, swimidle = 707894699},
        Bubbly = {idle1 = 910004836, idle2 = 910009958, walk = 910034870, run = 910025107, jump = 910016857, fall = 910001910, swim = 910028158, swimidle = 910030921},
        Rthro = {idle1 = 2510196951, idle2 = 2510197257, walk = 2510202577, run = 2510198475, jump = 2510197830, climb = 2510192778, fall = 2510195892, swim = 2510199791, swimidle = 2510201162},
        Oldschool = {idle1 = 5319828216, idle2 = 5319831086, walk = 5319847204, run = 5319844329, jump = 5319841935, climb = 5319816685, fall = 5319839762, swim = 5319850266, swimidle = 5319852613},
    }
    local names = {"Default"}
    for n in pairs(PACKS) do names[#names + 1] = n end
    table.sort(names, function(a, b) return a == "Default" or (b ~= "Default" and a < b) end)
    FX.ANIM_NAMES = names

    local SLOTS = {
        {key = "animIdle", folder = "idle", anims = {{"Animation1", "idle1"}, {"Animation2", "idle2"}}},
        {key = "animWalk", folder = "walk", anims = {{"WalkAnim", "walk"}}},
        {key = "animRun", folder = "run", anims = {{"RunAnim", "run"}}},
        {key = "animJump", folder = "jump", anims = {{"JumpAnim", "jump"}}},
        {key = "animFall", folder = "fall", anims = {{"FallAnim", "fall"}}},
        {key = "animClimb", folder = "climb", anims = {{"ClimbAnim", "climb"}}},
    }

    local saved = setmetatable({}, {__mode = "k"})
    local function idOf(n) return "http://www.roblox.com/asset/?id=" .. tostring(n) end

    FX.applyAnims = function()
        local c = lp.Character
        local an = c and c:FindFirstChild("Animate")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not an or not hum then return false end
        local orig = saved[an]
        if not orig then
            orig = {}
            for _, sl in ipairs(SLOTS) do
                local f = an:FindFirstChild(sl.folder)
                for _, a in ipairs(sl.anims) do
                    local obj = f and f:FindFirstChild(a[1])
                    if obj then orig[obj] = obj.AnimationId end
                end
            end
            for _, extra in ipairs({{"swim", "Swim"}, {"swimidle", "SwimIdle"}}) do
                local f = an:FindFirstChild(extra[1])
                local obj = f and f:FindFirstChild(extra[2])
                if obj then orig[obj] = obj.AnimationId end
            end
            saved[an] = orig
        end
        for _, sl in ipairs(SLOTS) do
            local choice = CFG[sl.key]
            if choice == "Default" then choice = CFG.animPack end
            local pack = PACKS[choice]
            local f = an:FindFirstChild(sl.folder)
            for _, a in ipairs(sl.anims) do
                local obj = f and f:FindFirstChild(a[1])
                if obj then
                    if pack and pack[a[2]] then
                        obj.AnimationId = idOf(pack[a[2]])
                    elseif orig[obj] then
                        obj.AnimationId = orig[obj]
                    end
                end
            end
        end
        local pk = PACKS[CFG.animPack]
        for _, extra in ipairs({{"swim", "Swim", "swim"}, {"swimidle", "SwimIdle", "swimidle"}}) do
            local f = an:FindFirstChild(extra[1])
            local obj = f and f:FindFirstChild(extra[2])
            if obj then
                if pk and pk[extra[3]] then
                    obj.AnimationId = idOf(pk[extra[3]])
                elseif orig[obj] then
                    obj.AnimationId = orig[obj]
                end
            end
        end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, tr in ipairs(animator:GetPlayingAnimationTracks()) do tr:Stop(0) end
        end
        an.Disabled = true
        task.wait()
        an.Disabled = false
        return true
    end

    local function wanted()
        if CFG.animPack ~= "Default" then return true end
        for _, sl in ipairs(SLOTS) do
            if CFG[sl.key] ~= "Default" then return true end
        end
        return false
    end

    connect(lp.CharacterAdded, function(c)
        if not wanted() then return end
        c:WaitForChild("Animate", 10)
        task.wait(0.3)
        pcall(FX.applyAnims)
    end)
end

do
    local aa = {char = nil, joints = {}}
    local function aaCollect(c)
        local list = {}
        local function add(partName, jointName, k)
            local p = c:FindFirstChild(partName)
            local j = p and p:FindFirstChild(jointName)
            if j and j:IsA("Motor6D") then list[#list + 1] = {j = j, c0 = j.C0, k = k} end
        end
        add("Head", "Neck", 1)
        add("UpperTorso", "Waist", 0.7)
        add("LowerTorso", "Root", 0.45)
        add("Torso", "Neck", 1)
        add("HumanoidRootPart", "RootJoint", 0.55)
        return list
    end
    local function aaRestore()
        for _, e in ipairs(aa.joints) do
            if e.j.Parent then pcall(function() e.j.C0 = e.c0 end) end
        end
        aa = {char = nil, joints = {}}
    end
    FX.aaRestore = aaRestore

    local aaSign, aaFlip = 1, 0
    local function aaSgn()
        if CFG.aaMode == "Up" then return 1 end
        if CFG.aaMode == "Down" then return -1 end
        local now = tick()
        if now - aaFlip > CFG.aaRandRate then
            aaFlip = now
            aaSign = math.random(2) == 1 and 1 or -1
        end
        return aaSign
    end

    local body = {}
    connect(PRE_SIM, function()
        local hrp = body.hrp
        if body.rot and hrp and hrp.Parent then
            hrp.CFrame = CFrame.new(hrp.Position) * body.rot
        end
        body.rot = nil
    end)

    connect(RunService.Heartbeat, function()
        local c = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local active = CFG.aaOn and hrp and hum and hum.Health > 0 and not FX.droneFlying and not busy and not flinging
        if not active then
            if aa.char then aaRestore() end
            return
        end
        local sgn = aaSgn()
        local ang = math.rad(CFG.aaAngle) * sgn
        if CFG.aaType == "Joints" then
            if aa.char ~= c then
                aaRestore()
                aa.joints = aaCollect(c)
                aa.char = c
            end
            for _, e in ipairs(aa.joints) do
                if e.j.Parent then
                    e.j.C0 = CFrame.new(e.c0.Position) * CFrame.Angles(ang * e.k, 0, 0) * e.c0.Rotation
                end
            end
        else
            if aa.char then aaRestore() end
            local _, yaw = hrp.CFrame:ToEulerAnglesYXZ()
            local rot = CFrame.Angles(0, yaw, 0)
            body.hrp, body.rot = hrp, rot
            hrp.CFrame = CFrame.new(hrp.Position) * rot * CFrame.Angles(ang, 0, 0)
        end
    end)

    connect(RunService.Heartbeat, function()
        if not CFG.speedGlitch or FX.droneFlying then return end
        local hrp, hum = myHrp()
        if not hrp or not hum or hum.Health <= 0 then return end
        local md = hum.MoveDirection
        local st = hum:GetState()
        local air = st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping
        if md.Magnitude > 0.1 then
            if air then
                local v = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(md.X * CFG.sgSpeed, v.Y, md.Z * CFG.sgSpeed)
            elseif CFG.sgAutoJump then
                hum.Jump = true
            end
        end
    end)

    local rb = {}
    local function ribbonClear()
        for _, o in pairs(rb) do
            if typeof(o) == "Instance" then pcall(function() o:Destroy() end) end
        end
        rb = {}
    end
    FX.ribbonClear = ribbonClear
    connect(RunService.Heartbeat, function()
        local c = lp.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not CFG.ribbon or not hrp then
            if rb.trail then ribbonClear() end
            return
        end
        if rb.hrp ~= hrp or not (rb.trail and rb.trail.Parent) then
            ribbonClear()
            local a0 = Instance.new("Attachment")
            a0.Name = "ZenithRibbonA"
            a0.Position = Vector3.new(0, 1.2, 0)
            a0.Parent = hrp
            local a1 = Instance.new("Attachment")
            a1.Name = "ZenithRibbonB"
            a1.Position = Vector3.new(0, -1.6, 0)
            a1.Parent = hrp
            local t = Instance.new("Trail")
            t.Name = "ZenithRibbon"
            t.Attachment0, t.Attachment1 = a0, a1
            t.LightEmission = 0.8
            t.LightInfluence = 0
            t.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1)})
            t.WidthScale = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.2)})
            t.Parent = hrp
            rb = {hrp = hrp, trail = t, a0 = a0, a1 = a1}
        end
        rb.trail.Lifetime = CFG.ribbonLife
        if CFG.ribbonColor == "Rainbow" then
            local h = (tick() * 0.25) % 1
            rb.trail.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 0.8, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.fromHSV((h + 0.33) % 1, 0.8, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV((h + 0.66) % 1, 0.8, 1)),
            })
        else
            rb.trail.Color = ColorSequence.new(colorOf(CFG.ribbonColor))
        end
    end)

    local potSaved, potLight, potActive = {}, nil, false
    local function potatoRestore()
        for d, v in pairs(potSaved) do
            if d.Parent then
                pcall(function()
                    if d:IsA("BasePart") then
                        d.Material, d.Reflectance = v[1], v[2]
                    elseif d:IsA("Decal") or d:IsA("Texture") then
                        d.Transparency = v[1]
                    else
                        d.Enabled = v[1]
                    end
                end)
            end
        end
        table.clear(potSaved)
        if potLight then
            for k, v in pairs(potLight) do pcall(function() Lighting[k] = v end) end
            potLight = nil
        end
        pcall(function() workspace.Terrain.Decoration = true end)
        potActive = false
    end
    FX.potatoRestore = potatoRestore
    local function isOurs(d)
        local a = d
        while a and a ~= workspace do
            if a.Name:sub(1, 6) == "Zenith" then return true end
            if a:IsA("Model") and a:FindFirstChildOfClass("Humanoid") then return true end
            a = a.Parent
        end
        return false
    end
    local function potatoApply()
        potActive = true
        if not potLight then
            potLight = {GlobalShadows = Lighting.GlobalShadows, EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
                        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale}
        end
        Lighting.GlobalShadows = false
        pcall(function() Lighting.EnvironmentDiffuseScale = 0 end)
        pcall(function() Lighting.EnvironmentSpecularScale = 0 end)
        pcall(function() workspace.Terrain.Decoration = false end)
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            n += 1
            if n % 1500 == 0 then task.wait() end
            if potSaved[d] == nil then
                if d:IsA("BasePart") then
                    if not isOurs(d) then
                        potSaved[d] = {d.Material, d.Reflectance}
                        d.Material = Enum.Material.SmoothPlastic
                        d.Reflectance = 0
                    end
                elseif d:IsA("Decal") or d:IsA("Texture") then
                    if not isOurs(d) then
                        potSaved[d] = {d.Transparency}
                        d.Transparency = 1
                    end
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                    if not isOurs(d) then
                        potSaved[d] = {d.Enabled}
                        d.Enabled = false
                    end
                end
            end
        end
    end
    task.spawn(function()
        while running do
            if CFG.potato then
                pcall(potatoApply)
            elseif potActive then
                pcall(potatoRestore)
            end
            task.wait(4)
        end
    end)

    local EMOTES = {
        Salute = {3333387824, 3360689775}, Tilt = {3334538554, 3360692915}, Stadium = {3338055167, 3360686498},
        Shrug = {3334392772, 3576968026}, Point = {3344585679, 3576823880}, Hello = {3344650532, 3576686446},
        ["Around Town"] = {3303391864, 3576747102}, Fashionable = {3333331310, 3576745472}, ["Top Rock"] = {3361276673, 3570535774},
        Robot = {3338025566, 3576721660}, Jacks = {3338066331, 3570649048}, T = {3338010159, 3576719440},
        Shy = {3337978742, 3576717965}, Sneaky = {3334424322, 3576754235}, Louder = {3338083565, 3576751796},
        Swish = {3361426436, 3361481910}, Monkey = {3333499508, 3716636630}, Godlike = {3337994105, 3823158750},
        Tree = {4049551434, 4049634387}, ["Line Dance"] = {4049037604, 4049646104}, ["Dorky Dance"] = {4212455378, 4212499637},
        ["Floss Dance"] = {5917459365, 5917570207}, ["Hero Landing"] = {5104344710, 5104377791}, Applaud = {5915693819, 5915779043},
        ["Old Town Road"] = {5937560570, 5938365243},
    }
    local emoteNames = {}
    for n in pairs(EMOTES) do emoteNames[#emoteNames + 1] = n end
    table.sort(emoteNames)
    FX.EMOTE_NAMES = emoteNames
    local curTrack
    FX.stopEmote = function()
        if curTrack then pcall(function() curTrack:Stop(0.2) end) end
        curTrack = nil
    end
    FX.playEmote = function(name)
        local ids = EMOTES[name]
        local c = lp.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not ids or not hum then return false end
        FX.stopEmote()
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = hum
        end
        local tr
        for _, id in ipairs(ids) do
            local a = Instance.new("Animation")
            a.AnimationId = "rbxassetid://" .. tostring(id)
            local ok, t = pcall(function() return animator:LoadAnimation(a) end)
            if ok and t then
                t.Priority = Enum.AnimationPriority.Action4
                t.Looped = CFG.emoteLoop
                t:Play(0.15)
                local loaded = false
                for _ = 1, 12 do
                    if t.Length > 0 then
                        loaded = true
                        break
                    end
                    task.wait(0.1)
                end
                if loaded then
                    tr = t
                    break
                end
                pcall(function() t:Stop(0) end)
            end
        end
        if not tr then
            pcall(function()
                local ok, t = hum:PlayEmoteAndGetAnimTrackById(ids[2])
                if ok then tr = t end
            end)
        end
        if tr then
            pcall(function()
                tr.Looped = CFG.emoteLoop
                tr:AdjustSpeed(CFG.emoteSpeed)
            end)
            curTrack = tr
            return true
        end
        return false
    end

    local HttpService = game:GetService("HttpService")
    local DIR = "ZenithMM2"
    local function fsOk() return writefile ~= nil and readfile ~= nil and isfile ~= nil end
    local function ensureDir()
        if makefolder and isfolder and not isfolder(DIR) then pcall(makefolder, DIR) end
    end
    FX.cfgList = function()
        local out = {}
        pcall(function()
            if listfiles and isfolder and isfolder(DIR) then
                for _, f in ipairs(listfiles(DIR)) do
                    local name = tostring(f):match("([^/\\]+)%.json$")
                    if name then out[#out + 1] = name end
                end
            end
        end)
        table.sort(out)
        if #out == 0 then out[1] = "default" end
        return out
    end
    FX.cfgSave = function(name)
        if not fsOk() then return false, "file API not supported" end
        ensureDir()
        local data = {}
        for k, v in pairs(CFG) do
            local t = type(v)
            if t == "boolean" or t == "number" or t == "string" then data[k] = v end
        end
        return pcall(function() writefile(DIR .. "/" .. name .. ".json", HttpService:JSONEncode(data)) end)
    end
    FX.cfgLoad = function(name)
        if not fsOk() then return false, "file API not supported" end
        local path = DIR .. "/" .. name .. ".json"
        if not isfile(path) then return false, "not found" end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if not ok or type(data) ~= "table" then return false, "bad file" end
        for k, v in pairs(data) do
            if CFG[k] ~= nil and type(CFG[k]) == type(v) then CFG[k] = v end
        end
        return true
    end
    FX.cfgDelete = function(name)
        if delfile then pcall(delfile, DIR .. "/" .. name .. ".json") end
    end
    FX.cfgGetAuto = function()
        local ok, v = pcall(function()
            if isfile and isfile(DIR .. "/autoload.txt") then return readfile(DIR .. "/autoload.txt") end
        end)
        return ok and v or nil
    end
    FX.cfgSetAuto = function(name)
        if not fsOk() then return end
        ensureDir()
        pcall(writefile, DIR .. "/autoload.txt", name or "")
    end
end

local function showError(text)
    local g = Instance.new("ScreenGui")
    g.Name = "ZenithError"
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    local okg = pcall(function() g.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not okg or not g.Parent then g.Parent = lp:WaitForChild("PlayerGui") end
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.9, 0, 0, 64)
    l.Position = UDim2.new(0.05, 0, 0, 8)
    l.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    l.BackgroundTransparency = 0.1
    l.TextColor3 = Color3.new(1, 1, 1)
    l.TextWrapped = true
    l.TextSize = 14
    l.Font = Enum.Font.GothamMedium
    l.Text = text
    l.Parent = g
    Instance.new("UICorner", l).CornerRadius = UDim.new(0, 8)
    task.delay(25, function() g:Destroy() end)
end

local WindUI
local loadErr = "unknown"
for _, url in ipairs({
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
}) do
    local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
    if ok and res then
        WindUI = res
        break
    end
    loadErr = tostring(res)
end
if not WindUI then showError("WindUI не загрузился: " .. loadErr) end

local function notify(title, text)
    if WindUI then
        pcall(function() WindUI:Notify({Title = title, Content = text, Duration = 8}) end)
    end
end
FX.notify = notify

do
local btnGui = Instance.new("ScreenGui")
btnGui.Name = "ZenithButton"
btnGui.ResetOnSpawn = false
btnGui.IgnoreGuiInset = true
local okp = pcall(function() btnGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okp or not btnGui.Parent then btnGui.Parent = lp:WaitForChild("PlayerGui") end

local Button = Instance.new("TextButton")
Button.Name = "ZenithButton"
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
FX.btnGui = btnGui
FX.setShootBtn = setShootBtn
end
local setShootBtn = FX.setShootBtn

local Window
local flDrop, buildUI
local selectedPlayer

local LANG_LABELS = {"English (EN)", "Русский (RU)", "Қазақша (KZ)", "Українська (UA)"}
local LANG_CODES = {["English (EN)"] = "EN", ["Русский (RU)"] = "RU", ["Қазақша (KZ)"] = "KZ", ["Українська (UA)"] = "UA"}
local LANG_NAME = {EN = "English (EN)", RU = "Русский (RU)", KZ = "Қазақша (KZ)", UA = "Українська (UA)"}

CFG.lang = genv.ZenithLang or CFG.lang
CFG.theme = genv.ZenithTheme or CFG.theme

local function L(en, ru, kk, uk)
    local l = CFG.lang
    if l == "RU" then return ru or en end
    if l == "KZ" then return kk or en end
    if l == "UA" then return uk or en end
    return en
end

local function val(v) return (type(v) == "table" and v[1]) or v end

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

local function inp(tab, title, value, placeholder, cb)
    if not tab then return end
    pcall(function()
        tab:Input({Title = title, Value = tostring(value or ""), Placeholder = placeholder or "", Callback = cb})
    end)
end

local function reshade()
    if CFG.shaders then pcall(shadersApply) end
end

local function themeNames()
    local out = {}
    if WindUI then
        pcall(function()
            for name in pairs(WindUI:GetThemes()) do out[#out + 1] = name end
        end)
    end
    if #out == 0 then
        out = {"Dark", "Light", "Rose", "Plant", "Red", "Indigo", "Sky", "Violet", "Amber", "Emerald"}
    end
    table.sort(out)
    return out
end

local function rebuildUI()
    if Window then pcall(function() Window:Destroy() end) end
    Window, flDrop = nil, nil
    buildUI()
end

buildUI = function()
    if WindUI then
        local ok, w = pcall(function()
            return WindUI:CreateWindow({
                Title = "Zenith | MM2",
                Icon = "rbxassetid://132137903274702",
                Author = "by @swagahubscripts",
                Folder = "ZenithHub",
                Size = UDim2.fromOffset(520, 340),
                Theme = CFG.theme,
            })
        end)
        if ok and w then
            Window = w
        else
            showError("WindUI окно не создалось: " .. tostring(w))
        end
    end

    local tabAim = newTab(L("Combat", "Бой", "Ұрыс", "Бій"), "swords")
    sec(tabAim, L("Silent Aim", "Silent Aim (скрытое наведение)", "Silent Aim (жасырын бағыттау)", "Silent Aim (приховане наведення)"))
    tog(tabAim, L("Silent aim", "Скрытое наведение", "Жасырын бағыттау", "Приховане наведення"), "silent")
    dd(tabAim, L("Silent Aim method", "Метод Silent Aim", "Silent Aim әдісі", "Метод Silent Aim"), WB_METHODS, CFG.silentMethod, function(v)
        CFG.silentMethod = val(v)
    end)
    tog(tabAim, L("Burst (extra rays)", "Очередь (доп. лучи)", "Қосымша сәулелер", "Черга (дод. промені)"), "burst")
    sld(tabAim, L("Prediction", "Упреждение", "Алдын-ала есептеу", "Упередження"), "predMul", 0, 2.5, 0.05)
    sld(tabAim, L("Aim height", "Высота прицела", "Нысана биіктігі", "Висота прицілу"), "aimHeight", -1, 2, 0.1)
    tog(tabAim, L("Silent target HUD", "Показывать цель Silent", "Silent нысанасын көрсету", "Показувати ціль Silent"), "silentHud")
    tog(tabAim, L("Hacker: re-shoot if missed", "Hacker: повтор выстрела при промахе", "Hacker: бос кетсе қайта ату", "Hacker: повтор пострілу при промаху"), "hackerRetry")
    sec(tabAim, L("Silent knife", "Скрытый нож", "Жасырын пышақ", "Прихований ніж"))
    tog(tabAim, L("Silent Knife Throw", "Наведение броска ножа", "Пышақ лақтыруды бағыттау", "Наведення кидка ножа"), "knifeSilent")
    tog(tabAim, L("Knife through walls", "Нож сквозь стены", "Пышақ қабырға арқылы", "Ніж крізь стіни"), "knifeWB")
    dd(tabAim, L("Knife target", "Цель ножа", "Пышақ нысанасы", "Ціль ножа"), {"Crosshair", "Nearest"}, CFG.knifeMode, function(v)
        CFG.knifeMode = val(v)
    end)
    sld(tabAim, L("Knife FOV", "Угол захвата ножа", "Пышақ көру бұрышы", "Кут захоплення ножа"), "knifeFov", 10, 180, 5)
    sld(tabAim, L("Knife lead (sec)", "Упреждение ножа (сек)", "Пышақ алдын-ала (сек)", "Упередження ножа (сек)"), "knifeLead", -0.1, 0.3, 0.01)
    sld(tabAim, L("Knife speed (studs/s)", "Скорость ножа", "Пышақ жылдамдығы", "Швидкість ножа"), "knifeSpeed", 30, 300, 5)
    sec(tabAim, L("Auto shoot", "Авто-выстрел", "Авто ату", "Авто-постріл"))
    if tabAim then
        pcall(function()
            tabAim:Toggle({Title = L("Auto Shoot (shows button)", "Авто-выстрел (показать кнопку)", "Авто ату (түймені көрсету)", "Авто-постріл (показати кнопку)"),
                Value = CFG.shootBtn, Callback = function(v) setShootBtn(v) end})
        end)
    end
    sld(tabAim, L("Shoot delay", "Задержка выстрела", "Ату кідірісі", "Затримка пострілу"), "shootDelay", 0.3, 4, 0.1)
    sec(tabAim, L("Kill Aura", "Килл Аура", "Өлтіру аурасы", "Кіл Аура"))
    tog(tabAim, L("Kill Aura (murderer)", "Килл Аура (убийца)", "Өлтіру аурасы (өлтіруші)", "Кіл Аура (вбивця)"), "autoKill")
    tog(tabAim, L("Fast TP to targets", "Быстрый ТП к целям", "Нысанаға жылдам ТП", "Швидкий ТП до цілей"), "auraTp")
    sld(tabAim, L("Kill Aura range", "Радиус Килл Ауры", "Аура радиусы", "Радіус Кіл Аури"), "auraRange", 5, 250, 5)
    sld(tabAim, L("Hit delay", "Задержка удара", "Соққы кідірісі", "Затримка удару"), "hitDelay", 0.05, 0.5, 0.01)
    sec(tabAim, L("Gun", "Пистолет", "Мылтық", "Пістолет"))
    tog(tabAim, L("Auto pick gun (Fast TP)", "Авто-подбор пистолета (быстрый ТП)", "Мылтықты авто алу (жылдам ТП)", "Авто-підбір пістолета (швидкий ТП)"), "autoGun")

    local tabRage = newTab(L("Rage", "Рейдж", "Рейдж", "Рейдж"), "flame")
    sec(tabRage, L("Murderer", "Убийца", "Өлтіруші", "Вбивця"))
    btn(tabRage, L("Kill All", "Убить всех", "Барлығын өлтіру", "Вбити всіх"), function() FX.killAll() end)
    tog(tabRage, L("Kill Aura (murderer)", "Килл Аура (убийца)", "Өлтіру аурасы (өлтіруші)", "Кіл Аура (вбивця)"), "autoKill")
    tog(tabRage, L("Knife reach", "Дальность ножа", "Пышақ қашықтығы", "Дальність ножа"), "reachOn")
    sld(tabRage, L("Reach size", "Размер досягаемости", "Жету өлшемі", "Розмір досяжності"), "reachSize", 2, 25, 1)
    sec(tabRage, L("Sheriff", "Шериф", "Шериф", "Шериф"))
    btn(tabRage, L("Shoot murderer now", "Выстрелить в убийцу сейчас", "Өлтірушіге қазір ату", "Вистрілити у вбивцю зараз"), function() FX.shootNow() end)
    sec(tabRage, L("Hitbox", "Хитбокс", "Хитбокс", "Хітбокс"))
    tog(tabRage, L("Hitbox expander", "Расширение хитбоксов", "Хитбоксты үлкейту", "Розширення хітбоксів"), "hitboxOn")
    sld(tabRage, L("Hitbox size", "Размер хитбокса", "Хитбокс өлшемі", "Розмір хітбокса"), "hitboxSize", 2, 30, 1)
    sec(tabRage, L("Chaos", "Хаос", "Хаос", "Хаос"))
    tog(tabRage, L("Spinbot", "Спинбот", "Спинбот", "Спінбот"), "spinOn")
    tog(tabRage, L("Auto Fling (sheriff + murderer)", "Авто-флинг (шериф + убийца)", "Авто ұшыру (шериф + өлтіруші)", "Авто-флінг (шериф + вбивця)"), "flingAuto")
    sec(tabRage, L("FPV Drone", "FPV дрон", "FPV дрон", "FPV дрон"))
    btn(tabRage, L("Launch FPV drone (again = BOOM)", "Запустить FPV дрон (ещё раз = взрыв)", "FPV дронды ұшыру (қайта = жарылыс)", "Запустити FPV дрон (ще раз = вибух)"), function() FX.launchDrone() end)
    dd(tabRage, L("Drone type", "Тип дрона", "Дрон түрі", "Тип дрона"), FX.DRONE_TYPES, CFG.droneType, function(v)
        CFG.droneType = val(v)
    end)
    dd(tabRage, L("Target (sheriff / innocent)", "Цель (шериф / мирный)", "Нысана (шериф / бейбіт)", "Ціль (шериф / мирний)"), FX.DRONE_TARGETS, CFG.droneTarget, function(v)
        CFG.droneTarget = val(v)
    end)
    tog(tabRage, L("Drone: TP stab (reliable kill)", "Дрон: ТП-удар (надёжное убийство)", "Дрон: ТП соққы (сенімді өлтіру)", "Дрон: ТП-удар (надійне вбивство)"), "droneTpKill")
    dd(tabRage, L("Drone camera", "Камера дрона", "Дрон камерасы", "Камера дрона"), {"First person", "Third person"}, CFG.droneCam, function(v)
        CFG.droneCam = val(v)
    end)
    sld(tabRage, L("Third person distance", "Дистанция 3-го лица", "Үшінші тұлға қашықтығы", "Дистанція 3-ї особи"), "droneCamDist", 4, 25, 1)
    tog(tabRage, L("Infinite battery", "Бесконечная батарея", "Шексіз батарея", "Нескінченна батарея"), "droneInfBat")
    tog(tabRage, L("No-clip (hit only players)", "No-clip (врезается только в людей)", "No-clip (тек адамдарға соғылады)", "No-clip (врізається лише в людей)"), "droneNoclip")

    local tabFling = newTab(L("Fling", "Флинг", "Флинг", "Флінг"), "wind")
    sec(tabFling, L("Targets", "Цели", "Нысаналар", "Цілі"))
    btn(tabFling, L("Fling Sheriff", "Флинг шерифа", "Шерифті ұшыру", "Флінг шерифа"), function() FX.flingKind("Sheriff") end)
    btn(tabFling, L("Fling Murderer", "Флинг убийцы", "Өлтірушіні ұшыру", "Флінг вбивці"), function() FX.flingKind("Murderer") end)
    btn(tabFling, L("Fling All", "Флинг всех", "Барлығын ұшыру", "Флінг усіх"), function() FX.flingKind("All") end)
    local names = FX.playerNames()
    selectedPlayer = selectedPlayer or names[1]
    flDrop = dd(tabFling, L("Fling Player", "Флинг игрока", "Ойыншыны ұшыру", "Флінг гравця"), names, selectedPlayer, function(v)
        selectedPlayer = val(v)
    end)
    btn(tabFling, L("Fling selected player", "Флинг выбранного игрока", "Таңдалған ойыншыны ұшыру", "Флінг обраного гравця"), function()
        FX.flingPlayer(selectedPlayer)
    end)
    tog(tabFling, L("Auto Fling (sheriff + murderer)", "Авто-флинг (шериф + убийца)", "Авто ұшыру (шериф + өлтіруші)", "Авто-флінг (шериф + вбивця)"), "flingAuto")
    sec(tabFling, L("Protection", "Защита", "Қорғаныс", "Захист"))
    tog(tabFling, L("Anti-Fling", "Анти-флинг", "Анти-ұшыру", "Анти-флінг"), "antiFling")
    sec(tabFling, L("Settings", "Настройки", "Баптаулар", "Налаштування"))
    sld(tabFling, L("Fling time", "Время флинга", "Ұшыру уақыты", "Час флінга"), "flingTime", 1, 5, 0.1)
    sld(tabFling, L("Spin power", "Сила вращения", "Айналу күші", "Сила обертання"), "spin", 20000, 150000, 5000)

    local tabChar = newTab(L("Character", "Персонаж", "Кейіпкер", "Персонаж"), "user")
    sec(tabChar, L("Movement", "Движение", "Қозғалыс", "Рух"))
    tog(tabChar, L("Noclip", "Прохождение сквозь стены", "Қабырғадан өту", "Проходження крізь стіни"), "noclip")
    tog(tabChar, L("Fly", "Полёт", "Ұшу", "Політ"), "fly", function(v)
        if not v then flyStop() end
    end)
    sld(tabChar, L("Fly speed", "Скорость полёта", "Ұшу жылдамдығы", "Швидкість польоту"), "flySpeed", 10, 250, 5)
    tog(tabChar, L("WalkSpeed", "Скорость ходьбы", "Жүру жылдамдығы", "Швидкість ходьби"), "wsOn")
    sld(tabChar, L("WalkSpeed value", "Значение скорости ходьбы", "Жүру жылдамдығының мәні", "Значення швидкості ходьби"), "walkSpeed", 16, 200, 1)
    tog(tabChar, L("JumpPower", "Сила прыжка", "Секіру күші", "Сила стрибка"), "jpOn")
    sld(tabChar, L("JumpPower value", "Значение силы прыжка", "Секіру күшінің мәні", "Значення сили стрибка"), "jumpPower", 50, 300, 5)
    sec(tabChar, L("Bunny Hop", "Банни-хоп", "Банни-хоп", "Банні-хоп"))
    tog(tabChar, L("Bunny Hop", "Банни-хоп", "Банни-хоп", "Банні-хоп"), "bhop")
    sld(tabChar, L("Bunny Hop speed", "Скорость банни-хопа", "Банни-хоп жылдамдығы", "Швидкість банні-хопа"), "bhopSpeed", 10, 50, 1)
    sec(tabChar, "Speed-Glitch")
    tog(tabChar, "Speed-Glitch", "speedGlitch")
    sld(tabChar, L("Speed-Glitch speed", "Скорость Speed-Glitch", "Speed-Glitch жылдамдығы", "Швидкість Speed-Glitch"), "sgSpeed", 20, 120, 1)
    tog(tabChar, L("Auto jump", "Автопрыжок", "Авто секіру", "Автострибок"), "sgAutoJump")
    sec(tabChar, "Anti-Aim")
    tog(tabChar, "Anti-Aim", "aaOn", function(v)
        if not v then FX.aaRestore() end
    end)
    dd(tabChar, L("Anti-Aim type", "Тип Anti-Aim", "Anti-Aim түрі", "Тип Anti-Aim"), {"Body", "Joints"}, CFG.aaType, function(v)
        CFG.aaType = val(v)
        FX.aaRestore()
    end)
    dd(tabChar, L("Anti-Aim mode", "Режим Anti-Aim", "Anti-Aim режимі", "Режим Anti-Aim"), {"Up", "Down", "Random"}, CFG.aaMode, function(v)
        CFG.aaMode = val(v)
    end)
    sld(tabChar, L("Anti-Aim angle", "Угол Anti-Aim", "Anti-Aim бұрышы", "Кут Anti-Aim"), "aaAngle", 10, 90, 5)
    sld(tabChar, L("Random switch speed", "Скорость переключения Random", "Random ауысу жылдамдығы", "Швидкість перемикання Random"), "aaRandRate", 0.03, 0.5, 0.01)
    sec(tabChar, L("Spin", "Вращение", "Айналу", "Обертання"))
    tog(tabChar, L("Spin", "Вращение", "Айналу", "Обертання"), "spinOn")
    inp(tabChar, L("Spin speed (20 and up)", "Скорость вращения (от 20)", "Айналу жылдамдығы (20-дан)", "Швидкість обертання (від 20)"),
        CFG.spinSpeed, "20, 200, 5000...", function(text)
            local n = tonumber(text)
            if n and n == n then CFG.spinSpeed = math.clamp(n, 20, 1e12) end
        end)

    local tabTp = newTab(L("Teleport", "Телепорт", "Телепорт", "Телепорт"), "map-pin")
    sec(tabTp, L("Teleport", "Телепорт", "Телепорт", "Телепорт"))
    btn(tabTp, L("TP Lobby", "ТП в лобби", "Лоббиге ТП", "ТП в лобі"), tpLobby)
    btn(tabTp, L("TP Map", "ТП на карту", "Картаға ТП", "ТП на мапу"), tpMap)

    local tabFarm = newTab(L("Farm", "Фарм", "Ферма", "Фарм"), "coins")
    sec(tabFarm, L("Coins", "Монеты", "Монеталар", "Монети"))
    tog(tabFarm, L("Auto farm", "Авто-фарм", "Авто ферма", "Авто-фарм"), "farm")
    tog(tabFarm, L("Underground path", "Путь под землёй", "Жер астымен жүру", "Шлях під землею"), "farmUnder")
    sld(tabFarm, L("Max coins per round", "Макс. монет за раунд", "Раундқа макс. монета", "Макс. монет за раунд"), "maxCoins", 10, 60, 1)
    tog(tabFarm, L("Coin ESP", "ESP монет", "Монета ESP", "ESP монет"), "coinEsp")
    tog(tabFarm, L("Coin highlight", "Подсветка монет", "Монета жарығы", "Підсвітка монет"), "coinHighlight")
    tog(tabFarm, L("Coin tracer", "Трейсер монет", "Монета трейсері", "Трейсер монет"), "coinTracer")
    sld(tabFarm, L("Farm speed", "Скорость фарма", "Ферма жылдамдығы", "Швидкість фарму"), "farmSpeed", 10, 60, 1)
    sld(tabFarm, L("Depth (studs under floor)", "Глубина (под полом)", "Тереңдік (еден астында)", "Глибина (під підлогою)"), "depth", 3, 40, 1)

    local tabVis = newTab(L("Visuals", "Визуалы", "Визуалдар", "Візуали"), "scan-eye")
    sec(tabVis, "ESP")
    tog(tabVis, L("ESP", "ESP (игроки)", "ESP (ойыншылар)", "ESP (гравці)"), "esp")
    tog(tabVis, L("Box", "Бокс", "Бокс", "Бокс"), "box")
    tog(tabVis, L("Skeleton", "Скелет", "Қаңқа", "Скелет"), "skeleton")
    tog(tabVis, L("Highlight", "Подсветка", "Жарықтандыру", "Підсвітка"), "highlight")
    dd(tabVis, L("Chams style", "Стиль чамсов", "Чамс стилі", "Стиль чамсів"), {"Highlight", "Chams", "Outline", "ForceField", "Neon"}, CFG.chamsStyle, function(v)
        CFG.chamsStyle = val(v)
    end)
    local chamsCols = {"Role"}
    for _, n in ipairs(COLOR_NAMES) do chamsCols[#chamsCols + 1] = n end
    dd(tabVis, L("Chams color", "Цвет чамсов", "Чамс түсі", "Колір чамсів"), chamsCols, CFG.chamsColor, function(v)
        CFG.chamsColor = val(v)
    end)
    tog(tabVis, L("Name + role", "Ник + роль", "Есім + рөл", "Нік + роль"), "name")
    tog(tabVis, L("Distance", "Дистанция", "Қашықтық", "Дистанція"), "dist")
    tog(tabVis, L("Tracer", "Трейсер", "Трейсер", "Трейсер"), "tracer")
    tog(tabVis, L("Health bar", "Полоска HP", "HP жолағы", "Смужка HP"), "health")
    tog(tabVis, L("Dropped gun", "Выпавший пистолет", "Түскен мылтық", "Випущений пістолет"), "gun")
    tog(tabVis, L("Show innocent", "Показывать мирных", "Бейбіт тұрғындарды көрсету", "Показувати мирних"), "showInnocent")
    sld(tabVis, L("Max distance", "Макс. дистанция", "Макс. қашықтық", "Макс. дистанція"), "maxDist", 100, 2000, 50)
    sld(tabVis, L("Skeleton distance", "Дистанция скелета", "Қаңқа қашықтығы", "Дистанція скелета"), "skelDist", 30, 500, 10)
    sec(tabVis, L("Weapons", "Оружие", "Қару", "Зброя"))
    tog(tabVis, L("Weapon ESP (gun / knife)", "ESP оружия (пистолет / нож)", "Қару ESP (мылтық / пышақ)", "ESP зброї (пістолет / ніж)"), "weaponEsp")
    dd(tabVis, L("Weapon style", "Стиль оружия", "Қару стилі", "Стиль зброї"), {"Chams", "Outline", "Glow", "ForceField", "Neon"}, CFG.weaponStyle, function(v)
        CFG.weaponStyle = val(v)
    end)
    dd(tabVis, L("Knife color", "Цвет ножа", "Пышақ түсі", "Колір ножа"), COLOR_NAMES, CFG.knifeColor, function(v)
        CFG.knifeColor = val(v)
    end)
    dd(tabVis, L("Gun color", "Цвет пистолета", "Мылтық түсі", "Колір пістолета"), COLOR_NAMES, CFG.gunColor, function(v)
        CFG.gunColor = val(v)
    end)
    sec(tabVis, "X-ray")
    tog(tabVis, L("X-ray (map walls)", "X-ray (стены карты)", "X-ray (карта қабырғалары)", "X-ray (стіни мапи)"), "xray")
    sld(tabVis, L("X-ray transparency", "Прозрачность X-ray", "X-ray мөлдірлігі", "Прозорість X-ray"), "xrayTransp", 0.1, 0.9, 0.05, function()
        xrRefresh()
    end)

    local tabCos = newTab(L("World", "Мир", "Әлем", "Світ"), "globe")
    sec(tabCos, L("Shaders", "Шейдеры", "Шейдерлер", "Шейдери"))
    tog(tabCos, L("Shaders", "Шейдеры", "Шейдерлер", "Шейдери"), "shaders", setShaders)
    dd(tabCos, L("Preset", "Пресет", "Пресет", "Пресет"), PRESET_NAMES, "BlueFog", applyPreset)
    tog(tabCos, L("Black sky", "Чёрное небо", "Қара аспан", "Чорне небо"), "blackSky", reshade)
    tog(tabCos, L("Blue fog", "Синий туман", "Көк тұман", "Синій туман"), "fogOn", reshade)
    sld(tabCos, L("Fog distance", "Дальность тумана", "Тұман қашықтығы", "Дальність туману"), "fog", 50, 2000, 10, reshade)
    sld(tabCos, L("Fog density", "Плотность тумана", "Тұман тығыздығы", "Щільність туману"), "density", 0, 1, 0.05, reshade)
    sld(tabCos, "Bloom", "bloom", 0, 4, 0.1, reshade)
    sld(tabCos, L("Contrast", "Контраст", "Контраст", "Контраст"), "contrast", -0.5, 1, 0.05, reshade)
    sld(tabCos, L("Saturation", "Насыщенность", "Қанықтық", "Насиченість"), "sat", -1, 1, 0.05, reshade)
    sld(tabCos, L("Blur", "Размытие", "Бұлыңғырлық", "Розмиття"), "dof", 0, 1, 0.05, reshade)
    sld(tabCos, L("Brightness", "Яркость", "Жарықтық", "Яскравість"), "bright", 0, 5, 0.1, reshade)
    tog(tabCos, L("Potato graphics (more FPS)", "Картошечная графика (больше FPS)", "Картоп графика (көбірек FPS)", "Картопляна графіка (більше FPS)"), "potato")
    sec(tabCos, L("Ghost Trail", "Призрачный след", "Елес із", "Примарний слід"))
    tog(tabCos, L("Ghost Trail", "Призрачный след", "Елес із", "Примарний слід"), "trail")
    dd(tabCos, L("Ghost style", "Стиль тени", "Көлеңке стилі", "Стиль тіні"), {"Chams", "ForceField", "Neon", "Classic"}, CFG.trailMode, function(v)
        CFG.trailMode = val(v)
    end)
    dd(tabCos, L("Ghost color", "Цвет тени", "Көлеңке түсі", "Колір тіні"), TRAIL_NAMES, CFG.trailColor, function(v)
        CFG.trailColor = val(v)
        local hrp = myHrp()
        local e = hrp and hrp:FindFirstChild("ZenithSmoke")
        if e then e:Destroy() end
    end)
    sld(tabCos, L("Ghost delay", "Задержка тени", "Көлеңке кідірісі", "Затримка тіні"), "trailDelay", 0.1, 1.5, 0.05)
    tog(tabCos, L("Ghost smoke", "Дым тени", "Көлеңке түтіні", "Дим тіні"), "trailSmoke")
    sec(tabCos, "Trail")
    tog(tabCos, L("Trail", "Шлейф", "Шлейф", "Шлейф"), "ribbon")
    dd(tabCos, L("Trail color", "Цвет шлейфа", "Шлейф түсі", "Колір шлейфу"), TRAIL_NAMES, CFG.ribbonColor, function(v)
        CFG.ribbonColor = val(v)
    end)
    sld(tabCos, L("Trail length", "Длина шлейфа", "Шлейф ұзындығы", "Довжина шлейфу"), "ribbonLife", 0.1, 2, 0.05)
    sec(tabCos, L("Shoot Trail", "След выстрела", "Ату ізі", "Слід пострілу"))
    tog(tabCos, L("Shoot Trail", "След выстрела", "Ату ізі", "Слід пострілу"), "shotTrail")

    local tabMod = newTab(L("Models & Skinchanger", "Модели и скинчейнджер", "Модельдер мен скинчейнджер", "Моделі та скінчейнджер"), "box")
    sec(tabMod, L("Gun skin", "Скин пистолета", "Мылтық скині", "Скін пістолета"))
    tog(tabMod, L("Custom gun model", "Своя модель пистолета", "Жеке мылтық моделі", "Своя модель пістолета"), "gunSkin")
    inp(tabMod, L("Gun model ID", "ID модели пистолета", "Мылтық моделінің ID", "ID моделі пістолета"), CFG.gunSkinId, "11006944635", function(t)
        CFG.gunSkinId = tostring(t or "")
    end)
    sld(tabMod, L("Gun model scale", "Масштаб пистолета", "Мылтық масштабы", "Масштаб пістолета"), "gunSkinScale", 0.2, 3, 0.05)
    sld(tabMod, L("Gun model rotation", "Поворот пистолета", "Мылтық бұрылысы", "Поворот пістолета"), "gunSkinRot", 0, 360, 5)
    sec(tabMod, L("Knife skin", "Скин ножа", "Пышақ скині", "Скін ножа"))
    tog(tabMod, L("Custom knife model", "Своя модель ножа", "Жеке пышақ моделі", "Своя модель ножа"), "knifeSkin")
    inp(tabMod, L("Knife model ID", "ID модели ножа", "Пышақ моделінің ID", "ID моделі ножа"), CFG.knifeSkinId, "123456789", function(t)
        CFG.knifeSkinId = tostring(t or "")
    end)
    sld(tabMod, L("Knife model scale", "Масштаб ножа", "Пышақ масштабы", "Масштаб ножа"), "knifeSkinScale", 0.2, 3, 0.05)
    sld(tabMod, L("Knife model rotation", "Поворот ножа", "Пышақ бұрылысы", "Поворот ножа"), "knifeSkinRot", 0, 360, 5)
    sec(tabMod, L("Skinchanger", "Скинчейнджер", "Скинчейнджер", "Скінчейнджер"))
    tog(tabMod, L("Auto-copy skins from players", "Автокопирование скинов у игроков", "Ойыншылардан скиндерді авто көшіру", "Автокопіювання скінів у гравців"), "skinCapture")
    btn(tabMod, L("Copy skins now", "Скопировать скины сейчас", "Скиндерді қазір көшіру", "Скопіювати скіни зараз"), function()
        local n = FX.copySkins()
        if FX.notify then FX.notify("Zenith", "New skins: " .. tostring(n)) end
    end)
    btn(tabMod, L("Scan game database", "Найти скины в базе игры", "Ойын базасынан скиндерді іздеу", "Знайти скіни в базі гри"), function()
        local n = FX.scanDB()
        if FX.notify then
            FX.notify("Zenith", n > 0 and ("Database skins: " .. n) or "Database not found - send a Dex screenshot of ReplicatedStorage")
        end
    end)
    FX.dbDD = {}
    FX.dbDD.knife = dd(tabMod, L("Knife skin (database)", "Скин ножа (база игры)", "Пышақ скині (ойын базасы)", "Скін ножа (база гри)"), FX.dbKnifeNames(), CFG.knifeDB, function(v)
        CFG.knifeDB = val(v) or "None"
    end)
    FX.dbDD.gun = dd(tabMod, L("Gun skin (database)", "Скин пистолета (база игры)", "Мылтық скині (ойын базасы)", "Скін пістолета (база гри)"), FX.dbGunNames(), CFG.gunDB, function(v)
        CFG.gunDB = val(v) or "None"
    end)
    FX.skinDD = {}
    FX.skinDD.knife = dd(tabMod, L("Knife skin (copied)", "Скин ножа (скопированный)", "Пышақ скині (көшірілген)", "Скін ножа (скопійований)"), FX.knifeNames(), CFG.knifeLib, function(v)
        CFG.knifeLib = val(v) or "None"
    end)
    FX.skinDD.gun = dd(tabMod, L("Gun skin (copied)", "Скин пистолета (скопированный)", "Мылтық скині (көшірілген)", "Скін пістолета (скопійований)"), FX.gunNames(), CFG.gunLib, function(v)
        CFG.gunLib = val(v) or "None"
    end)
    sec(tabMod, L("Character", "Персонаж", "Кейіпкер", "Персонаж"))
    tog(tabMod, L("Custom character (no animation)", "Свой персонаж (без анимации)", "Жеке кейіпкер (анимациясыз)", "Свій персонаж (без анімації)"), "customChar")
    inp(tabMod, L("Character model ID", "ID модели персонажа", "Кейіпкер моделінің ID", "ID моделі персонажа"), CFG.charModelId, "84115454229681", function(t)
        CFG.charModelId = tostring(t or "")
    end)
    sld(tabMod, L("Character scale", "Масштаб персонажа", "Кейіпкер масштабы", "Масштаб персонажа"), "charScale", 0.2, 3, 0.05)
    sld(tabMod, L("Character rotation", "Поворот персонажа", "Кейіпкер бұрылысы", "Поворот персонажа"), "charYaw", 0, 360, 5)
    sld(tabMod, L("Character height", "Высота персонажа", "Кейіпкер биіктігі", "Висота персонажа"), "charY", -4, 4, 0.1)
    sec(tabMod, L("Accessories", "Аксессуары", "Аксессуарлар", "Аксесуари"))
    tog(tabMod, L("China Hat", "Китайская шляпа", "Қытай қалпағы", "Китайський капелюх"), "chinaHat")
    dd(tabMod, L("Hat color", "Цвет шляпы", "Қалпақ түсі", "Колір капелюха"), COLOR_NAMES, CFG.hatColor, function(v)
        CFG.hatColor = val(v)
    end)

    local tabAnim = newTab(L("Anims", "Анимации", "Анимациялар", "Анімації"), "person-standing")
    sec(tabAnim, L("Animation pack", "Набор анимаций", "Анимация жинағы", "Набір анімацій"))
    dd(tabAnim, L("Pack (all)", "Набор (всё)", "Жинақ (бәрі)", "Набір (усе)"), FX.ANIM_NAMES, CFG.animPack, function(v)
        CFG.animPack = val(v)
        task.spawn(function()
            local ok = pcall(FX.applyAnims)
            if not ok and FX.notify then FX.notify("Zenith", "Animate script not found") end
        end)
    end)
    sec(tabAnim, L("Mix (per action)", "Микс (по действиям)", "Аралас (әрекет бойынша)", "Мікс (за діями)"))
    local function animDD(title, key)
        dd(tabAnim, title, FX.ANIM_NAMES, CFG[key], function(v)
            CFG[key] = val(v)
            task.spawn(function() pcall(FX.applyAnims) end)
        end)
    end
    animDD(L("Idle", "Стойка", "Тұру", "Стійка"), "animIdle")
    animDD(L("Walk", "Ходьба", "Жүру", "Ходьба"), "animWalk")
    animDD(L("Run", "Бег", "Жүгіру", "Біг"), "animRun")
    animDD(L("Jump", "Прыжок", "Секіру", "Стрибок"), "animJump")
    animDD(L("Fall", "Падение", "Құлау", "Падіння"), "animFall")
    animDD(L("Climb", "Лазание", "Өрмелеу", "Лазіння"), "animClimb")
    sec(tabAnim, L("Emotes", "Эмоции", "Эмоциялар", "Емоції"))
    dd(tabAnim, L("Emote", "Эмоция", "Эмоция", "Емоція"), FX.EMOTE_NAMES, CFG.emote, function(v)
        CFG.emote = val(v)
    end)
    btn(tabAnim, L("Play emote", "Включить эмоцию", "Эмоцияны ойнату", "Увімкнути емоцію"), function()
        if not FX.playEmote(CFG.emote) and FX.notify then FX.notify("Zenith", "Emote failed (R15 only)") end
    end)
    btn(tabAnim, L("Stop emote", "Остановить эмоцию", "Эмоцияны тоқтату", "Зупинити емоцію"), function() FX.stopEmote() end)
    tog(tabAnim, L("Loop emote", "Повторять эмоцию", "Эмоцияны қайталау", "Повторювати емоцію"), "emoteLoop")
    sld(tabAnim, L("Emote speed", "Скорость эмоции", "Эмоция жылдамдығы", "Швидкість емоції"), "emoteSpeed", 0.25, 3, 0.05)
    sec(tabAnim, L("Reset", "Сброс", "Қалпына келтіру", "Скидання"))
    btn(tabAnim, L("Reset animations", "Сбросить анимации", "Анимацияларды қалпына келтіру", "Скинути анімації"), function()
        CFG.animPack = "Default"
        for _, k in ipairs({"animIdle", "animWalk", "animRun", "animJump", "animFall", "animClimb"}) do CFG[k] = "Default" end
        pcall(FX.applyAnims)
    end)

    local tabSnd = newTab(L("Sound", "Звук", "Дыбыс", "Звук"), "volume-2")
    sec(tabSnd, L("Mode", "Режим", "Режим", "Режим"))
    tog(tabSnd, L("Replace Gun / Knife sounds", "Заменять звуки пистолета / ножа", "Мылтық / пышақ дыбыстарын ауыстыру", "Замінювати звуки пістолета / ножа"), "replaceSnd", function(v)
        if not v then pcall(SND.restore) end
    end)
    tog(tabSnd, L("Replace kill sound", "Заменять звук убийства", "Өлтіру дыбысын ауыстыру", "Замінювати звук вбивства"), "killSnd", function(v)
        if not v then pcall(SND.restore) end
    end)
    sec(tabSnd, L("Gun", "Пистолет", "Мылтық", "Пістолет"))
    dd(tabSnd, L("Gun sound", "Звук пистолета", "Мылтық дыбысы", "Звук пістолета"), SND.gunNames, CFG.gunSnd, function(v)
        CFG.gunSnd = val(v)
    end)
    inp(tabSnd, L("Custom gun sound ID", "Свой ID звука пистолета", "Мылтық дыбысының ID-і", "Свій ID звуку пістолета"), CFG.gunCustom, "123456789", function(t)
        CFG.gunCustom = tostring(t or "")
    end)
    sld(tabSnd, L("Gun volume", "Громкость пистолета", "Мылтық дыбыс деңгейі", "Гучність пістолета"), "gunVol", 0, 10, 0.1)
    btn(tabSnd, L("Test gun sound", "Проверить звук пистолета", "Мылтық дыбысын тексеру", "Перевірити звук пістолета"), function()
        SND.play(SND.id("gun"), CFG.gunVol)
    end)
    sec(tabSnd, L("Knife", "Нож", "Пышақ", "Ніж"))
    dd(tabSnd, L("Knife sound", "Звук ножа", "Пышақ дыбысы", "Звук ножа"), SND.knifeNames, CFG.knifeSnd, function(v)
        CFG.knifeSnd = val(v)
    end)
    inp(tabSnd, L("Custom knife sound ID", "Свой ID звука ножа", "Пышақ дыбысының ID-і", "Свій ID звуку ножа"), CFG.knifeCustom, "123456789", function(t)
        CFG.knifeCustom = tostring(t or "")
    end)
    sld(tabSnd, L("Knife volume", "Громкость ножа", "Пышақ дыбыс деңгейі", "Гучність ножа"), "knifeVol", 0, 10, 0.1)
    btn(tabSnd, L("Test knife sound", "Проверить звук ножа", "Пышақ дыбысын тексеру", "Перевірити звук ножа"), function()
        SND.play(SND.id("knife"), CFG.knifeVol)
    end)
    sec(tabSnd, L("Kill sound", "Звук убийства", "Өлтіру дыбысы", "Звук вбивства"))
    dd(tabSnd, L("Kill sound", "Звук убийства", "Өлтіру дыбысы", "Звук вбивства"), SND.killNames, CFG.killSndName, function(v)
        CFG.killSndName = val(v)
    end)
    inp(tabSnd, L("Custom kill sound ID", "Свой ID звука убийства", "Өлтіру дыбысының ID-і", "Свій ID звуку вбивства"), CFG.killCustom, "123456789", function(t)
        CFG.killCustom = tostring(t or "")
    end)
    sld(tabSnd, L("Kill volume", "Громкость убийства", "Өлтіру дыбыс деңгейі", "Гучність вбивства"), "killVol", 0, 10, 0.1)
    btn(tabSnd, L("Test kill sound", "Проверить звук убийства", "Өлтіру дыбысын тексеру", "Перевірити звук вбивства"), function()
        SND.play(SND.id("kill"), CFG.killVol)
    end)
    sec(tabSnd, L("Debug", "Отладка", "Түзету", "Налагодження"))
    btn(tabSnd, L("Show Gun / Knife sounds", "Показать звуки Gun / Knife", "Gun / Knife дыбыстарын көрсету", "Показати звуки Gun / Knife"), function()
        notify(L("Tool sounds", "Звуки предметов", "Заттар дыбыстары", "Звуки предметів"), SND.dump())
    end)

    local tabUtil = newTab(L("Utility", "Утилиты", "Утилиталар", "Утиліти"), "wrench")
    sec(tabUtil, L("Alerts", "Оповещения", "Хабарламалар", "Сповіщення"))
    tog(tabUtil, L("Role notifications", "Уведомления о ролях", "Рөлдер туралы хабарлама", "Сповіщення про ролі"), "roleNotify")
    tog(tabUtil, L("Murderer nearby alert", "Предупреждение: убийца рядом", "Ескерту: өлтіруші жақын", "Попередження: вбивця поруч"), "murderAlert")
    sld(tabUtil, L("Alert distance", "Дистанция оповещения", "Ескерту қашықтығы", "Дистанція сповіщення"), "alertDist", 10, 120, 5)
    sec(tabUtil, L("World", "Мир", "Әлем", "Світ"))
    tog(tabUtil, L("Fullbright", "Полная яркость", "Толық жарық", "Повна яскравість"), "fullbright")
    tog(tabUtil, L("Custom FOV", "Свой FOV", "Жеке FOV", "Свій FOV"), "fovOn")
    sld(tabUtil, "FOV", "fov", 40, 120, 1)
    sec(tabUtil, L("Player", "Игрок", "Ойыншы", "Гравець"))
    tog(tabUtil, L("Anti-AFK", "Анти-АФК", "Анти-АФК", "Анти-АФК"), "antiAfk")
    tog(tabUtil, L("Infinite jump", "Бесконечный прыжок", "Шексіз секіру", "Нескінченний стрибок"), "infJump")
    btn(tabUtil, L("Rejoin server", "Перезайти на сервер", "Серверге қайта кіру", "Перезайти на сервер"), function() FX.rejoin() end)
    sec(tabUtil, L("Spectate", "Наблюдение", "Бақылау", "Спостереження"))
    tog(tabUtil, L("Spectate murderer", "Следить за убийцей", "Өлтірушіні бақылау", "Стежити за вбивцею"), "specMurd")
    tog(tabUtil, L("Spectate sheriff", "Следить за шерифом", "Шерифті бақылау", "Стежити за шерифом"), "specSher")
    tog(tabUtil, L("Gun drop alert", "Оповещение о выпавшем пистолете", "Мылтық түскені туралы хабарлама", "Сповіщення про випадений пістолет"), "gunNotify")

    local tabCfg = newTab(L("Config", "Конфиг", "Конфиг", "Конфіг"), "save")
    sec(tabCfg, L("Configs", "Конфиги", "Конфигтер", "Конфіги"))
    local cfgName = FX.cfgGetAuto() or "default"
    if cfgName == "" then cfgName = "default" end
    inp(tabCfg, L("Config name", "Имя конфига", "Конфиг атауы", "Назва конфігу"), cfgName, "default", function(t)
        local n = tostring(t or ""):gsub("[^%w_%-]", "")
        if n ~= "" then cfgName = n end
    end)
    local cfgDD = dd(tabCfg, L("Saved configs", "Сохранённые конфиги", "Сақталған конфигтер", "Збережені конфіги"), FX.cfgList(), cfgName, function(v)
        cfgName = val(v) or cfgName
    end)
    local function refreshCfg()
        if cfgDD then pcall(function() cfgDD:Refresh(FX.cfgList()) end) end
    end
    btn(tabCfg, L("Save config", "Сохранить конфиг", "Конфигті сақтау", "Зберегти конфіг"), function()
        local ok, err = FX.cfgSave(cfgName)
        refreshCfg()
        if FX.notify then FX.notify("Zenith", ok and ("Saved: " .. cfgName) or ("Save failed: " .. tostring(err))) end
    end)
    btn(tabCfg, L("Load config", "Загрузить конфиг", "Конфигті жүктеу", "Завантажити конфіг"), function()
        local ok, err = FX.cfgLoad(cfgName)
        if FX.notify then FX.notify("Zenith", ok and ("Loaded: " .. cfgName) or ("Load failed: " .. tostring(err))) end
        if ok then
            genv.ZenithLang = CFG.lang
            setShaders(CFG.shaders)
            pcall(setShootBtn, CFG.shootBtn)
            task.spawn(function() pcall(FX.applyAnims) end)
            task.delay(0.3, rebuildUI)
        end
    end)
    btn(tabCfg, L("Delete config", "Удалить конфиг", "Конфигті жою", "Видалити конфіг"), function()
        FX.cfgDelete(cfgName)
        refreshCfg()
    end)
    btn(tabCfg, L("Set as autoload", "Загружать при запуске", "Іске қосқанда жүктеу", "Завантажувати при запуску"), function()
        FX.cfgSetAuto(cfgName)
        if FX.notify then FX.notify("Zenith", "Autoload: " .. cfgName) end
    end)
    btn(tabCfg, L("Disable autoload", "Выключить автозагрузку", "Авто жүктеуді өшіру", "Вимкнути автозавантаження"), function()
        FX.cfgSetAuto("")
    end)

    local tabSet = newTab(L("Settings", "Настройки", "Баптаулар", "Налаштування"), "settings")
    sec(tabSet, L("Interface", "Интерфейс", "Интерфейс", "Інтерфейс"))
    dd(tabSet, L("Select Theme", "Выбрать тему", "Тақырыпты таңдау", "Обрати тему"), themeNames(), CFG.theme, function(v)
        local name = val(v)
        CFG.theme = name
        genv.ZenithTheme = name
        if WindUI then pcall(function() WindUI:SetTheme(name) end) end
    end)
    dd(tabSet, L("Language", "Язык", "Тіл", "Мова"), LANG_LABELS, LANG_NAME[CFG.lang], function(v)
        local code = LANG_CODES[val(v)]
        if code and code ~= CFG.lang then
            CFG.lang = code
            genv.ZenithLang = code
            task.delay(0.25, rebuildUI)
        end
    end)
    sec(tabSet, L("Watermark", "Ватермарк", "Су белгісі", "Водяний знак"))
    tog(tabSet, L("Watermark", "Ватермарк", "Су белгісі", "Водяний знак"), "watermark")
    tog(tabSet, L("Round timer in watermark", "Таймер раунда в ватермарке", "Су белгісінде раунд таймері", "Таймер раунду у водяному знаку"), "wmTimer")
    sec(tabSet, L("Script", "Скрипт", "Скрипт", "Скрипт"))
    btn(tabSet, L("Unload", "Выгрузить скрипт", "Скриптті өшіру", "Вивантажити скрипт"), function()
        if genv.ZenithWind then genv.ZenithWind() end
    end)
end

do
    local auto = FX.cfgGetAuto and FX.cfgGetAuto()
    if auto and auto ~= "" then
        local ok = FX.cfgLoad(auto)
        if ok then
            genv.ZenithLang = CFG.lang
            pcall(setShaders, CFG.shaders)
            task.spawn(function() pcall(FX.applyAnims) end)
        end
    end
end

buildUI()

local function refreshPlayers()
    if flDrop then pcall(function() flDrop:Refresh(FX.playerNames()) end) end
end
connect(Players.PlayerAdded, function() task.defer(refreshPlayers) end)
connect(Players.PlayerRemoving, function() task.defer(refreshPlayers) end)

setShootBtn(CFG.shootBtn == true)

genv.ZenithWind = function()
    running = false
    for _, k in ipairs({"autoShoot", "autoGun", "autoKill", "farm", "fly", "noclip", "flingAuto", "antiFling",
                        "wsOn", "jpOn", "bhop", "spinOn", "xray", "aura", "helper", "trail", "shotTrail", "silent",
                        "bodyGlow", "crown", "groundRing", "elemAura", "nameTag", "aaOn", "speedGlitch", "ribbon", "potato", "orbitStars", "auraSphere", "footSparkle", "powerAura", "hitboxOn", "reachOn", "murderAlert",
                        "fullbright", "fovOn", "infJump", "roleNotify", "customChar", "gunSkin", "knifeSkin", "chinaHat",
                        "specMurd", "specSher", "weaponEsp", "watermark"}) do
        CFG[k] = false
    end
    ST.on, ST.aimPos, ST.target, ST.lastShot = false, nil, nil, nil
    pcall(flyStop)
    pcall(FX.spinStop)
    pcall(FX.xrRestore)
    pcall(FX.shadersOff)
    pcall(removeAura)
    pcall(removeHelper)
    pcall(FX.clearCos)
    pcall(FX.restoreHB)
    pcall(FX.restoreReach)
    pcall(FX.restoreUtil)
    pcall(FX.restoreModels)
    pcall(FX.restoreMatChams)
    pcall(FX.restoreWeapons)
    pcall(FX.wmDestroy)
    pcall(FX.aaRestore)
    pcall(FX.ribbonClear)
    pcall(FX.potatoRestore)
    pcall(FX.stopEmote)
    pcall(function() FX.trailModel:Destroy() end)
    pcall(SND.restore)
    pcall(function()
        if holding then surface() end
    end)
    pcall(function()
        local md = FX.mov()
        if md.hum then
            if md.ws then md.hum.WalkSpeed = md.ws end
            if md.jp then md.hum.JumpPower = md.jp end
        end
    end)
    for part in pairs(FX.ncSaved) do
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
    pcall(function() FX.trailFolder:Destroy() end)
    pcall(function() FX.shotFolder:Destroy() end)
    local g = drop and drop:FindFirstChild("GunESP")
    if g then pcall(function() g:Destroy() end) end
    local hrp = myHrp()
    if hrp then
        for _, n in ipairs({"ZenithSmoke", "ZenithHold", "ZenithSpin", "ZenithFly", "ZenithFlyGyro", "ZenithFlingBV"}) do
            local o = hrp:FindFirstChild(n)
            if o then pcall(function() o:Destroy() end) end
        end
    end
    pcall(function() FX.btnGui:Destroy() end)
    if Window then pcall(function() Window:Destroy() end) end
    genv.ZenithWind = nil
end
