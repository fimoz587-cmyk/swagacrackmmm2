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
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local genv = (getgenv and getgenv()) or _G
for _, k in ipairs({"NyxAll", "NyxESP", "NyxKA"}) do
    if genv[k] then pcall(genv[k]) end
end

local CFG = {
    box = true, skeleton = true, highlight = true, name = true, dist = true,
    tracer = true, health = true, gun = true,
    maxDist = 800, skelDist = 150,
    silent = true, lead = 0.1,
    autoGun = true,
    spam = true, allRemotes = true, skipFilter = true,
    tp = false, hitDelay = 0.25, maxTries = 3,
    aa = false, aaMode = 1, aaPart = 1, aaSpeed = 18,
}
local SHOW = {Murderer = true, Sheriff = true, Hero = true, Innocent = true}
local COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 130, 255),
    Hero     = Color3.fromRGB(255, 220, 60),
    Innocent = Color3.fromRGB(80, 255, 120),
}
local BLACK = Color3.new(0, 0, 0)
local KEEP = {"kill", "stab", "knife", "hit", "damage", "touch", "throw", "gun", "attack"}
local SKIP = {"shop", "buy", "trade", "sell", "purchase", "gift", "report", "ban", "kick", "crate", "equip", "data"}
local MODES = {"Spin", "Yaw", "Pitch", "Random", "Up", "Down"}
local AAPARTS = {"Neck", "Head", "Torso", "UpperTorso"}

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

local function has(name, list)
    name = name:lower()
    for _, w in ipairs(list) do
        if name:find(w, 1, true) then return true end
    end
    return false
end

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

local ST = genv.NyxST or {}
genv.NyxST = ST
ST.rec = ST.rec or {}
ST.aimOn, ST.lead, ST.target = CFG.silent, CFG.lead, nil

if not genv.NyxHook3 and hookmetamethod and getnamecallmethod then
    genv.NyxHook3 = true
    local wrap = newcclosure or function(f) return f end
    local old
    old = hookmetamethod(game, "__namecall", wrap(function(self, ...)
        local m = getnamecallmethod()
        if (m == "FireServer" or m == "InvokeServer") and not checkcaller()
           and typeof(self) == "Instance" then
            local par = self.Parent
            if par then
                local pn = par.Name
                local t = ST.target
                if ST.aimOn and t and m == "FireServer" and self.Name == "Shoot" and pn == "Gun" then
                    local args = table.pack(...)
                    local n = 0
                    for i = 1, args.n do
                        if typeof(args[i]) == "CFrame" then
                            n += 1
                            if n == 2 then
                                args[i] = CFrame.new(t.Position + t.AssemblyLinearVelocity * ST.lead)
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

local rsRemotes = {}
local function addRemote(r)
    if not (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return end
    if CFG.skipFilter and has(r.Name, SKIP) then return end
    if has(r.Name, KEEP) then rsRemotes[#rsRemotes + 1] = r end
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
        addRemote(r)
    end)
end
connect(RS.DescendantAdded, addRemote)

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

local foundTarget

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
    if role == "Murderer" then foundTarget = hrp end

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

    local mh = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    ST.myPos = mh and mh.Position

    foundTarget = nil
    for p, e in pairs(E) do
        pcall(step, p, e, cam, camPos, vp, now)
    end
    ST.target = foundTarget
    ST.aimOn, ST.lead = CFG.silent, CFG.lead

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
    local part = AAPARTS[CFG.aaPart]
    if aaS.j and (aaS.c ~= c or aaS.part ~= part or not aaS.j.Parent) then aaRestore() end
    if not aaS.j then
        local j = aaJoint(c, part)
        if not j then return end
        aaS = {j = j, c = c, part = part, c0 = j.C0, c1 = j.C1}
    end
    local mode, lim = MODES[CFG.aaMode], math.rad(85)
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

local busy = false

local function getKnife()
    local c = lp.Character
    return (c and c:FindFirstChild("Knife")) or (lp.Backpack and lp.Backpack:FindFirstChild("Knife"))
end

local function pickGun()
    local hrp = myHrp()
    if busy or not hrp or not (drop and drop.Parent) then return end
    if roles[lp] == "Murderer" or getKnife() then return end
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

local running = true
task.spawn(function()
    while running do
        if CFG.autoGun and drop then pcall(pickGun) end
        task.wait(0.4)
    end
end)

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
    if not knife then return end
    busy = true
    local back = hrp.CFrame
    if knife.Parent ~= lp.Character then
        hum:EquipTool(knife)
        task.wait(0.15)
    end
    knife = lp.Character and lp.Character:FindFirstChild("Knife")
    if not knife then
        busy = false
        return
    end
    local handle = knife:FindFirstChild("Handle")
    local remotes = collect(knife)
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

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local c, r, h = aliveChar(p)
            local tries = 0
            while c and tries < CFG.maxTries and knife.Parent == lp.Character do
                local cp = hrp.Position
                if handle then
                    knife:Activate()
                    touch(handle, r)
                end
                if #recorded > 0 then
                    for _, it in ipairs(recorded) do
                        task.spawn(function()
                            pcall(replay, it[1], it[2], p, c, h, r, cp)
                        end)
                    end
                elseif CFG.spam then
                    spamRemotes(remotes, p, c, r, h)
                end
                task.wait(CFG.hitDelay)
                tries += 1
                c, r, h = aliveChar(p)
                if c and CFG.tp and tries >= 2 then
                    hrp.CFrame = r.CFrame * CFrame.new(0, 0, 2)
                end
            end
        end
    end
    if CFG.tp and hrp.Parent then hrp.CFrame = back end
    busy = false
end

local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "NyxAll", false
local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not ok or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local function mkBtn(text, y, color, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 110, 0, 34)
    b.Position = UDim2.new(1, -130, 0.5, y)
    b.Text, b.Font, b.TextSize = text, Enum.Font.GothamBold, 13
    b.TextColor3, b.BackgroundColor3 = Color3.new(1, 1, 1), color
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.Parent = gui
    connect(b.Activated, function() cb(b) end)
    return b
end

mkBtn("KILL ALL", -90, Color3.fromRGB(200, 40, 50), function()
    task.spawn(function() pcall(killAll) end)
end)
mkBtn("AA: OFF", -50, Color3.fromRGB(40, 55, 95), function(b)
    CFG.aa = not CFG.aa
    b.Text = "AA: " .. (CFG.aa and "ON" or "OFF")
end)
mkBtn("Mode: " .. MODES[CFG.aaMode], -10, Color3.fromRGB(40, 55, 95), function(b)
    CFG.aaMode = CFG.aaMode % #MODES + 1
    b.Text = "Mode: " .. MODES[CFG.aaMode]
end)
mkBtn("Part: " .. AAPARTS[CFG.aaPart], 30, Color3.fromRGB(40, 55, 95), function(b)
    CFG.aaPart = CFG.aaPart % #AAPARTS + 1
    b.Text = "Part: " .. AAPARTS[CFG.aaPart]
end)

genv.NyxAll = function()
    running = false
    CFG.aa = false
    pcall(aaRestore)
    ST.aimOn, ST.target = false, nil
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    for _, e in pairs(E) do
        if e.cc then pcall(function() e.cc:Disconnect() end) end
        if e.hl then pcall(function() e.hl:Destroy() end) end
    end
    for _, d in ipairs(draws) do pcall(function() d:Remove() end) end
    local g = drop and drop:FindFirstChild("GunESP")
    if g then g:Destroy() end
    gui:Destroy()
    genv.NyxAll = nil
end
