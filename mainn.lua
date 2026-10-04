-- Roblox / MM2: Kill All через ВСЕ ремоуты + Auto Pick Gun (Lua, Delta)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local genv = (getgenv and getgenv()) or _G
if genv.NyxKA then pcall(genv.NyxKA) end -- защита от двойного запуска

local CFG = {
    autoGun = true,     -- авто-подбор выпавшего пистолета
    spam = true,        -- перебор аргументов по ремоутам
    allRemotes = true,  -- не только Knife.Events, но и боевые из ReplicatedStorage
    skipFilter = true,  -- не трогать shop/trade/buy и т.п.
    log = true,         -- печатать в консоль реальные вызовы ремоутов ножа
    hitDelay = 0.2,     -- пауза между попытками по одной цели
    maxTries = 3,       -- сколько попыток на одну цель
}
genv.NyxKACfg = CFG

local KEEP = {"kill", "stab", "knife", "hit", "damage", "touch", "throw", "gun", "attack"}
local SKIP = {"shop", "buy", "trade", "sell", "purchase", "gift", "report", "ban", "kick", "crate", "equip", "data"}

local function has(name, list)
    name = name:lower()
    for _, w in ipairs(list) do
        if name:find(w, 1, true) then return true end
    end
    return false
end

local conns = {}
local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

-- ===== лог ремоутов ножа (хук ставится один раз) =====
if hookmetamethod and getnamecallmethod and not genv.NyxKAHook then
    genv.NyxKAHook = true
    local wrap = newcclosure or function(f) return f end
    local old
    old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
        local m = getnamecallmethod()
        local cfg = genv.NyxKACfg
        if cfg and cfg.log and (m == "FireServer" or m == "InvokeServer")
           and not checkcaller() and typeof(self) == "Instance" then
            local par = self.Parent
            if par and par.Name == "Events" then
                local a = table.pack(...)
                local s = {}
                for i = 1, a.n do s[i] = typeof(a[i]) .. ":" .. tostring(a[i]) end
                print("[KA-LOG]", self.Name, m, table.concat(s, " | "))
                if setnamecallmethod then setnamecallmethod(m) end
            end
        end
        return old(self, ...)
    end))
end

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

-- ===== GunDrop: поиск по всему workspace =====
local drop
local function track(i)
    if i.Name ~= "GunDrop" then return end
    drop = i
    connect(i.AncestryChanged, function(_, parent)
        if not parent and drop == i then drop = nil end
    end)
end
connect(workspace.DescendantAdded, track)
task.spawn(function()
    local n = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        track(d)
        n += 1
        if n % 2000 == 0 then task.wait() end
    end
end)

local busy = false

local function getKnife()
    local c = lp.Character
    return (c and c:FindFirstChild("Knife")) or (lp.Backpack and lp.Backpack:FindFirstChild("Knife"))
end

local function pickGun()
    local hrp = myHrp()
    if busy or not hrp or not (drop and drop.Parent) or getKnife() then return end
    local part = drop:IsA("BasePart") and drop or drop:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end
    busy = true
    local back = hrp.CFrame
    touch(hrp, part)
    task.wait(0.15)
    if drop and drop.Parent then
        hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
        touch(hrp, part)
        task.wait(0.3)
    end
    if hrp.Parent then hrp.CFrame = back end
    busy = false
end

task.spawn(function()
    while genv.NyxKA do
        if CFG.autoGun and drop then pcall(pickGun) end
        task.wait(0.4)
    end
end)

-- ===== список ремоутов (кэш из ReplicatedStorage) =====
local rsRemotes = {}
local function addRemote(r)
    if not (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return end
    if CFG.skipFilter and has(r.Name, SKIP) then return end
    if has(r.Name, KEEP) then rsRemotes[#rsRemotes + 1] = r end
end
for _, r in ipairs(RS:GetDescendants()) do addRemote(r) end
connect(RS.DescendantAdded, addRemote)

local function collect(knife)
    local list, seen = {}, {}
    local function push(r)
        if not seen[r] and r.Parent and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            if not (CFG.skipFilter and has(r.Name, SKIP)) then
                seen[r] = true
                list[#list + 1] = r
            end
        end
    end
    local ev = knife:FindFirstChild("Events")
    if ev then for _, r in ipairs(ev:GetChildren()) do push(r) end end
    if CFG.allRemotes then for _, r in ipairs(rsRemotes) do push(r) end end
    return list
end

-- ===== Kill All =====
local function alive(p)
    local c = p.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if c and h and h.Health > 0 and r then return c, r, h end
end

local function spamRemotes(remotes, p, c, hrp, hum)
    local shapes = {
        {hrp}, {c}, {hum}, {p}, {hrp.CFrame}, {hrp.Position},
        {c, hrp}, {p, hrp}, {hrp, hrp.Position}, {},
    }
    for _, r in ipairs(remotes) do
        local isEvent = r:IsA("RemoteEvent")
        for _, a in ipairs(shapes) do
            task.spawn(function()
                pcall(function()
                    if isEvent then r:FireServer(table.unpack(a))
                    else r:InvokeServer(table.unpack(a)) end
                end)
            end)
        end
    end
end

local function killAll()
    if busy then return end
    local hrp, hum = myHrp()
    if not hrp or not hum then return end
    local knife = getKnife()
    if not knife then
        warn("[KA] у тебя нет ножа, ты не убийца в этом раунде")
        return
    end
    busy = true
    local back = hrp.CFrame
    if knife.Parent ~= lp.Character then hum:EquipTool(knife); task.wait(0.15) end
    knife = lp.Character:FindFirstChild("Knife")
    local handle = knife and knife:FindFirstChild("Handle")
    local remotes = knife and collect(knife) or {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local c, r, h = alive(p)
            local tries = 0
            while c and tries < CFG.maxTries and knife and knife.Parent == lp.Character do
                hrp.CFrame = r.CFrame * CFrame.new(0, 0, 2) -- вплотную за спиной
                knife:Activate()
                if handle then touch(handle, r) end
                if CFG.spam then spamRemotes(remotes, p, c, r, h) end
                task.wait(CFG.hitDelay)
                tries += 1
                c, r, h = alive(p)
            end
        end
    end
    if hrp.Parent then hrp.CFrame = back end
    busy = false
end

-- ===== кнопка =====
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "NyxKA", false
local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not ok or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local b = Instance.new("TextButton")
b.Size, b.Position = UDim2.new(0, 110, 0, 44), UDim2.new(1, -130, 0.5, -22)
b.Text, b.Font, b.TextSize = "KILL ALL", Enum.Font.GothamBold, 15
b.TextColor3, b.BackgroundColor3 = Color3.new(1, 1, 1), Color3.fromRGB(200, 40, 50)
Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
b.Parent = gui
connect(b.Activated, function() task.spawn(function() pcall(killAll) end) end)

-- выгрузка: getgenv().NyxKA()
genv.NyxKA = function()
    genv.NyxKA = nil
    CFG.log = false
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    gui:Destroy()
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local lp = Players.LocalPlayer

local genv = (getgenv and getgenv()) or _G
if genv.NyxSA then pcall(genv.NyxSA) end

local CFG = {
    silent = true,
    wallbang = true,
    lead = 0.05,
    pingLead = true,
    wbDist = 3,
}

local ST = genv.NyxSAST or {}
genv.NyxSAST = ST
ST.on, ST.wb, ST.aimPos, ST.wbDist = CFG.silent, false, nil, CFG.wbDist

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

local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude

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
    ST.on, ST.wbDist = CFG.silent, CFG.wbDist
    local hrp, char = findMurderer()
    if not hrp then
        ST.aimPos, ST.wb = nil, false
        return
    end
    local v = hrp.AssemblyLinearVelocity
    local t = (CFG.pingLead and (ST.ping or 0.08) or 0) + CFG.lead
    local pos = hrp.Position
    ST.aimPos = pos + Vector3.new(v.X, 0, v.Z) * t

    local mine = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local blocked = false
    if CFG.wallbang and mine then
        rp.FilterDescendantsInstances = {lp.Character, char}
        blocked = workspace:Raycast(mine.Position, pos - mine.Position, rp) ~= nil
    end
    ST.wb = blocked
end)

local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "NyxSA", false
local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not ok or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local function mkBtn(label, key, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 110, 0, 34)
    b.Position = UDim2.new(1, -130, 0.5, y)
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

mkBtn("Silent", "silent", -40)
mkBtn("WallBang", "wallbang", 0)

genv.NyxSA = function()
    running = false
    ST.on, ST.aimPos, ST.wb = false, nil, false
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    gui:Destroy()
    genv.NyxSA = nil
end
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
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local genv = (getgenv and getgenv()) or _G
if genv.NyxFarm then pcall(genv.NyxFarm) end

local CFG = {
    farm = false,
    coinEsp = true,
    autoGun = true,
    farmSpeed = 24,
    gunSpeed = 32,
    maxCoins = 40,
    coinRange = 1500,
    pickDist = 90,
}

local HAS_DRAW = typeof(Drawing) == "table" or typeof(Drawing) == "userdata"
local conns, running = {}, true
local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end

local myRole
local coins, visited, circles = {}, {}, {}
local got = 0
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

local function resetRound()
    myRole, got = nil, 0
    table.clear(visited)
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
    end
end

local function removeCoin(i)
    if not coins[i] then return end
    coins[i], visited[i] = nil, nil
    if circles[i] then
        pcall(function() circles[i]:Remove() end)
        circles[i] = nil
    end
end

connect(workspace.DescendantAdded, function(i) addCoin(i) end)
connect(workspace.DescendantRemoving, removeCoin)
task.spawn(function()
    local n = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        addCoin(d)
        n += 1
        if n % 2000 == 0 then task.wait() end
    end
end)

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
task.spawn(function()
    local n = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        trackDrop(d)
        n += 1
        if n % 2000 == 0 then task.wait() end
    end
end)

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

local function nearestCoin(hrp)
    local best, bd = nil, CFG.coinRange
    for c in pairs(coins) do
        if c.Parent and not visited[c] then
            local d = (c.Position - hrp.Position).Magnitude
            if d < bd then best, bd = c, d end
        end
    end
    return best
end

local function farmStep()
    local hrp, hum = myHrp()
    if busy or not hrp or not hum or hum.Health <= 0 then return end
    if got >= CFG.maxCoins then return end
    local coin = nearestCoin(hrp)
    if not coin then return end
    busy = true
    local ok = goTo(CFrame.new(coin.Position + Vector3.new(0, 1.5, 0)), CFG.farmSpeed, function()
        return CFG.farm and coin.Parent ~= nil
    end)
    if ok and coin.Parent then
        touch(hrp, coin)
        task.wait(0.2)
        if not coin.Parent then got += 1 end
    end
    visited[coin] = true
    busy = false
end

task.spawn(function()
    while running do
        if CFG.autoGun and drop then pcall(pickGun) end
        if CFG.farm then pcall(farmStep) end
        task.wait(0.15)
    end
end)

connect(RunService.RenderStepped, function()
    cam = workspace.CurrentCamera
    if not cam or not HAS_DRAW then return end
    local show = CFG.coinEsp
    for c, circle in pairs(circles) do
        if show and c.Parent and not visited[c] then
            local pt, on = cam:WorldToViewportPoint(c.Position)
            circle.Visible = on
            if on then circle.Position = Vector2.new(pt.X, pt.Y) end
        else
            circle.Visible = false
        end
    end
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

mkBtn("Farm", "farm", -60)
mkBtn("Coin ESP", "coinEsp", -20)
mkBtn("Auto Gun", "autoGun", 20)

genv.NyxFarm = function()
    running = false
    CFG.farm, CFG.autoGun = false, false
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for _, c in pairs(circles) do pcall(function() c:Remove() end) end
    gui:Destroy()
    genv.NyxFarm = nil
end
