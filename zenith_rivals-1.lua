-- Zenith | Rivals
-- Silent Aim, ESP, Chams (Body / Hands / Weapon), Anti-Aim
-- Luau (Roblox). Needs: hookmetamethod, getnamecallmethod, checkcaller, Drawing (Delta works)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local genv = (getgenv and getgenv()) or _G
if genv.ZenithRivals then pcall(genv.ZenithRivals) end

local CFG = {
    silent = true, part = "Head", fov = 200, showFov = true, hitChance = 100, wallCheck = false,
    esp = true, box = true, name = true, health = true, dist = true, showTeam = false, maxDist = 1500,
    chWeapon = false, weaponMode = "Highlight", weaponColor = "Cyan",
    chHands = false, handsMode = "Highlight", handsColor = "Purple",
    chBody = true, bodyMode = "Highlight", bodyColor = "Team",
    aa = false, aaYaw = "Spin", aaSpin = 900, aaPitch = "Off",
}

local running = true
local conns = {}
local function connect(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end
local HAS_DRAW = false
pcall(function()
    local d = Drawing.new("Square")
    d:Remove()
    HAS_DRAW = true
end)

local S = genv.ZenithRivalsState or {}
genv.ZenithRivalsState = S
S.cfg, S.target, S.on = CFG, nil, true

local PALETTE = {
    Red = Color3.fromRGB(255, 60, 60), Blue = Color3.fromRGB(60, 130, 255), Purple = Color3.fromRGB(160, 90, 255),
    Pink = Color3.fromRGB(255, 90, 190), Cyan = Color3.fromRGB(0, 220, 255), Green = Color3.fromRGB(70, 230, 110),
    Yellow = Color3.fromRGB(255, 220, 60), White = Color3.fromRGB(255, 255, 255),
}
local COLOR_LIST = {"Red", "Blue", "Purple", "Pink", "Cyan", "Green", "Yellow", "White", "Rainbow"}
local function colorOf(name)
    if name == "Rainbow" then return Color3.fromHSV((tick() * 0.2) % 1, 0.85, 1) end
    return PALETTE[name] or PALETTE.White
end

------------------------------------------------------------------ players
local ENEMY = Color3.fromRGB(255, 70, 70)
local TEAM = Color3.fromRGB(70, 140, 255)

local function myModel() return lp.Character end

local function isEnemy(p)
    if p == lp then return false end
    if p.Team ~= nil and lp.Team ~= nil and #game:GetService("Teams"):GetTeams() > 1 then return p.Team ~= lp.Team end
    return true
end

local function allModels()
    local out = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then out[#out + 1] = {p.Character, isEnemy(p)} end
    end
    return out
end

local function alive(m)
    local h = m:FindFirstChildOfClass("Humanoid")
    local r = m:FindFirstChild("HumanoidRootPart")
    if h and r and h.Health > 0 then return r, h end
end

local function aimPart(m)
    local torso = m:FindFirstChild("UpperTorso") or m:FindFirstChild("Torso") or m:FindFirstChild("HumanoidRootPart")
    if CFG.part == "Torso" then return torso end
    if CFG.part == "Random" and math.random() < 0.5 then return torso end
    return m:FindFirstChild("Head") or torso
end

local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude
local function visible(part, m)
    local ig = {m, cam}
    if lp.Character then ig[#ig + 1] = lp.Character end
    rp.FilterDescendantsInstances = ig
    local o = cam.CFrame.Position
    return workspace:Raycast(o, part.Position - o, rp) == nil
end

local function pickTarget()
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local best, bestD = nil, CFG.fov
    for _, it in ipairs(allModels()) do
        local m, enemy = it[1], it[2]
        if enemy and alive(m) then
            local part = aimPart(m)
            if part then
                local sp, on = cam:WorldToViewportPoint(part.Position)
                if on and sp.Z > 0 then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bestD and (not CFG.wallCheck or visible(part, m)) then
                        best, bestD = part, d
                    end
                end
            end
        end
    end
    return best
end

-- nearest living enemy, used when nobody is inside the FOV circle
local function nearestEnemy()
    local me = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not me then return nil end
    local best, bd = nil, math.huge
    for _, it in ipairs(allModels()) do
        if it[2] then
            local r = alive(it[1])
            if r then
                local d = (r.Position - me.Position).Magnitude
                if d < bd then best, bd = aimPart(it[1]), d end
            end
        end
    end
    return best
end

------------------------------------------------------------------ silent aim hooks (once per server)
if not S.hooked and hookmetamethod and getnamecallmethod and checkcaller then
    S.hooked = true

    local function shotRay(origin, dir)
        if dir.Magnitude < 20 then return false end
        local cp, mp = S.camPos, S.myPos
        if not cp then return false end
        if (origin - cp).Magnitude > 25 and not (mp and (origin - mp).Magnitude < 25) then return false end
        return dir.Unit:Dot(S.camLook) > 0.5
    end

    local function aimDir(origin, len)
        local t = S.target
        if not t or not t.Parent then return nil end
        local cfg = S.cfg
        if cfg.hitChance < 100 and math.random(1, 100) > cfg.hitChance then return nil end
        return (t.Position - origin).Unit * len
    end

    local oldNc
    oldNc = hookmetamethod(game, "__namecall", function(self, ...)
        if S.on and S.cfg.silent and S.target and not checkcaller() then
            local m = getnamecallmethod()
            if m == "Raycast" and self == workspace then
                local o, d = ...
                if typeof(o) == "Vector3" and typeof(d) == "Vector3" and shotRay(o, d) then
                    local nd = aimDir(o, d.Magnitude)
                    if nd then
                        local args = table.pack(...)
                        args[2] = nd
                        return oldNc(self, table.unpack(args, 1, args.n))
                    end
                end
            elseif m == "Spherecast" and self == workspace then
                local o, r, d = ...
                if typeof(o) == "Vector3" and typeof(d) == "Vector3" and shotRay(o, d) then
                    local nd = aimDir(o, d.Magnitude)
                    if nd then
                        local args = table.pack(...)
                        args[3] = nd
                        return oldNc(self, table.unpack(args, 1, args.n))
                    end
                end
            elseif m == "FindPartOnRayWithIgnoreList" or m == "FindPartOnRayWithWhitelist" or m == "FindPartOnRay" then
                local ray = ...
                if typeof(ray) == "Ray" and shotRay(ray.Origin, ray.Direction) then
                    local nd = aimDir(ray.Origin, ray.Direction.Magnitude)
                    if nd then
                        local args = table.pack(...)
                        args[1] = Ray.new(ray.Origin, nd)
                        return oldNc(self, table.unpack(args, 1, args.n))
                    end
                end
            elseif (m == "ViewportPointToRay" or m == "ScreenPointToRay") and self == workspace.CurrentCamera then
                local x, y = ...
                local vp = self.ViewportSize
                if type(x) == "number" and type(y) == "number" and math.abs(x - vp.X / 2) < 60 and math.abs(y - vp.Y / 2) < 60 then
                    local ray = oldNc(self, ...)
                    local nd = aimDir(ray.Origin, 1)
                    if nd then return Ray.new(ray.Origin, nd) end
                    return ray
                end
            end
        end
        return oldNc(self, ...)
    end)

end
S.myModel = myModel

------------------------------------------------------------------ ESP
local draws = {}
local function draw(class, props)
    local ok, d = pcall(Drawing.new, class)
    if not ok or not d then return nil end
    for k, v in pairs(props or {}) do pcall(function() d[k] = v end) end
    draws[#draws + 1] = d
    return d
end

local fovCircle = HAS_DRAW and draw("Circle", {Thickness = 1.5, NumSides = 64, Filled = false, Transparency = 0.8, Color = Color3.new(1, 1, 1)})

local hlFolder = Instance.new("Folder")
hlFolder.Name = "ZenithRivals"
pcall(function() hlFolder.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not hlFolder.Parent then hlFolder.Parent = lp:WaitForChild("PlayerGui") end

local PARTS = {"box", "boxOut", "name", "dist", "hpBack", "hp"}
local E = {}

local function newESP(m)
    local e = {}
    if HAS_DRAW then
        e.boxOut = draw("Square", {Thickness = 4, Filled = false, Visible = false, Color = Color3.new(0, 0, 0), Transparency = 0.6})
        e.box = draw("Square", {Thickness = 2, Filled = false, Visible = false})
        e.name = draw("Text", {Size = 15, Center = true, Outline = true, Visible = false, Font = 2})
        e.dist = draw("Text", {Size = 13, Center = true, Outline = true, Visible = false, Font = 2})
        e.hpBack = draw("Square", {Filled = true, Visible = false, Color = Color3.new(0, 0, 0)})
        e.hp = draw("Square", {Filled = true, Visible = false})
    end
    local hl = Instance.new("Highlight")
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.Enabled = false
    hl.Parent = hlFolder
    e.hl = hl
    E[m] = e
    return e
end

local function setIf(o, k, v)
    if o[k] ~= v then o[k] = v end
end

local function bodyMat(e, m, mode, col)
    if not mode then
        if e.mats then
            for p, o in pairs(e.mats) do
                if p.Parent then pcall(function() p.Material, p.Color = o[1], o[2] end) end
            end
            e.mats = nil
        end
        return
    end
    e.mats = e.mats or {}
    if tick() - (e.matAt or 0) > 0.5 then
        e.matAt = tick()
        for _, d in ipairs(m:GetDescendants()) do
            if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" and d.Transparency < 1 and not e.mats[d] then
                e.mats[d] = {d.Material, d.Color}
            end
        end
    end
    local mat = (mode == "Neon") and Enum.Material.Neon or Enum.Material.ForceField
    for p in pairs(e.mats) do
        if p.Parent then
            setIf(p, "Material", mat)
            setIf(p, "Color", col)
        end
    end
end

local function hideESP(e)
    for _, k in ipairs(PARTS) do
        if e[k] then pcall(function() e[k].Visible = false end) end
    end
    setIf(e.hl, "Enabled", false)
    bodyMat(e, nil, nil)
end

local function removeESP(m)
    local e = E[m]
    if not e then return end
    for _, k in ipairs(PARTS) do
        if e[k] then pcall(function() e[k]:Remove() end) end
    end
    pcall(bodyMat, e, nil, nil)
    pcall(function() e.hl:Destroy() end)
    E[m] = nil
end

local UP, DOWN = Vector3.new(0, 2.8, 0), Vector3.new(0, 3.2, 0)

local function stepESP(m, enemy, e)
    local r, h = alive(m)
    if not CFG.esp or not r or (not enemy and not CFG.showTeam) then
        hideESP(e)
        return
    end
    local dist = (cam.CFrame.Position - r.Position).Magnitude
    if dist > CFG.maxDist then
        hideESP(e)
        return
    end
    local color = enemy and ENEMY or TEAM
    local bc = (CFG.bodyColor == "Team") and color or colorOf(CFG.bodyColor)
    local mode = CFG.bodyMode
    local matMode = mode == "Neon" or mode == "ForceField"
    setIf(e.hl, "Adornee", m)
    setIf(e.hl, "FillColor", bc)
    setIf(e.hl, "OutlineColor", bc)
    setIf(e.hl, "FillTransparency", (mode == "Outline" and 1) or (matMode and 0.7) or 0.45)
    setIf(e.hl, "Enabled", CFG.chBody)
    bodyMat(e, m, (CFG.chBody and matMode) and mode or nil, bc)
    if not HAS_DRAW or not e.box or not e.name then return end
    local top, v1 = cam:WorldToViewportPoint(r.Position + UP)
    local bot, v2 = cam:WorldToViewportPoint(r.Position - DOWN)
    if not (v1 or v2) or top.Z <= 0 then
        for _, k in ipairs(PARTS) do if e[k] then e[k].Visible = false end end
        return
    end
    local hgt = math.abs(bot.Y - top.Y)
    local wid = hgt * 0.55
    local x = top.X - wid / 2
    e.box.Visible, e.boxOut.Visible = CFG.box, CFG.box
    if CFG.box then
        e.box.Color = color
        e.box.Size, e.box.Position = Vector2.new(wid, hgt), Vector2.new(x, top.Y)
        e.boxOut.Size, e.boxOut.Position = e.box.Size, e.box.Position
    end
    e.name.Visible = CFG.name
    if CFG.name then
        local pl = Players:GetPlayerFromCharacter(m)
        e.name.Text = pl and pl.DisplayName or m.Name
        e.name.Color = color
        e.name.Position = Vector2.new(top.X, top.Y - 18)
    end
    e.dist.Visible = CFG.dist
    if CFG.dist then
        e.dist.Text = math.floor(dist) .. "m"
        e.dist.Color = Color3.new(1, 1, 1)
        e.dist.Position = Vector2.new(top.X, top.Y + hgt + 2)
    end
    e.hpBack.Visible, e.hp.Visible = CFG.health, CFG.health
    if CFG.health then
        local frac = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
        e.hpBack.Size, e.hpBack.Position = Vector2.new(4, hgt + 2), Vector2.new(x - 7, top.Y - 1)
        e.hp.Size, e.hp.Position = Vector2.new(2, hgt * frac), Vector2.new(x - 6, top.Y + hgt * (1 - frac))
        e.hp.Color = Color3.fromRGB(255, 60, 60):Lerp(Color3.fromRGB(80, 230, 110), frac)
    end
end

local PERF = {fps = 60, frame = 0}
connect(RunService.RenderStepped, function(dt)
    cam = workspace.CurrentCamera
    if not running then return end
    PERF.fps = PERF.fps * 0.92 + (1 / math.max(dt, 1 / 240)) * 0.08
    PERF.frame += 1
    local ccf = cam.CFrame
    S.camPos, S.camLook = ccf.Position, ccf.LookVector
    local mc = lp.Character
    local mh = mc and mc:FindFirstChild("HumanoidRootPart")
    S.myPos = mh and mh.Position or nil
    if PERF.fps < 45 and PERF.frame % 2 == 1 then return end
    S.target = CFG.silent and pickTarget() or nil
    if fovCircle then
        local vp = cam.ViewportSize
        fovCircle.Visible = CFG.silent and CFG.showFov
        fovCircle.Radius = CFG.fov
        fovCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
        fovCircle.Color = S.target and ENEMY or Color3.new(1, 1, 1)
    end
    local seen = {}
    for _, it in ipairs(allModels()) do
        local m = it[1]
        seen[m] = true
        local e = E[m] or newESP(m)
        pcall(stepESP, m, it[2], e)
    end
    for m in pairs(E) do
        if not seen[m] or not m.Parent then removeESP(m) end
    end
end)


------------------------------------------------------------------ weapon / hand chams (Workspace.ViewModels.FirstPerson)
local vmSaved, vmHl = {}, {}
local vmRootHl

local function isHand(part)
    local n = part.Name:lower()
    local pn = part.Parent and part.Parent.Name:lower() or ""
    for _, w in ipairs({"arm", "hand", "glove", "sleeve", "finger", "wrist"}) do
        if n:find(w, 1, true) or pn:find(w, 1, true) then return true end
    end
    return false
end

local function vmRestore(p)
    local o = vmSaved[p]
    if not o then return end
    vmSaved[p] = nil
    pcall(function()
        p.Material, p.Color = o.mat, o.col
        if o.tex ~= nil then p.TextureID = o.tex end
        if o.sa then o.sa.Parent = p end
    end)
end

local function vmPaint(p, mode, col)
    if not vmSaved[p] then
        local o = {mat = p.Material, col = p.Color}
        if p:IsA("MeshPart") then
            o.tex = p.TextureID
            pcall(function() p.TextureID = "" end)
        end
        local sa = p:FindFirstChildOfClass("SurfaceAppearance")
        if sa then
            o.sa = sa
            sa.Parent = nil
        end
        vmSaved[p] = o
    end
    setIf(p, "Material", (mode == "Neon") and Enum.Material.Neon or Enum.Material.ForceField)
    setIf(p, "Color", col)
end

local function hlFor(key, adornee, mode, col)
    local h = vmHl[key]
    if not h or not h.Parent then
        h = Instance.new("Highlight")
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.OutlineTransparency = 0
        h.Parent = hlFolder
        vmHl[key] = h
    end
    setIf(h, "Adornee", adornee)
    setIf(h, "FillColor", col)
    setIf(h, "OutlineColor", col)
    setIf(h, "FillTransparency", (mode == "Outline") and 1 or 0.4)
    setIf(h, "Enabled", true)
end

local function vmStep()
    local vms = workspace:FindFirstChild("ViewModels")
    local root = vms and vms:FindFirstChild("FirstPerson")
    local used = {}
    local seenMat = {}
    if root and (CFG.chWeapon or CFG.chHands) then
        local hc, wc = colorOf(CFG.handsColor), colorOf(CFG.weaponColor)
        local hlMode = function(m) return m == "Highlight" or m == "Outline" end
        local same = CFG.chWeapon and CFG.chHands and CFG.weaponMode == CFG.handsMode
            and hlMode(CFG.weaponMode) and CFG.weaponColor == CFG.handsColor
        local count = 0
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("BasePart") and (vmSaved[d] or d.Transparency < 1) then
                local hand = isHand(d)
                local on = (hand and CFG.chHands) or (not hand and CFG.chWeapon)
                if on then
                    local mode = hand and CFG.handsMode or CFG.weaponMode
                    local col = hand and hc or wc
                    if hlMode(mode) then
                        vmRestore(d)
                        if not same and count < 22 then
                            count += 1
                            hlFor(d, d, mode, col)
                            used[d] = true
                        end
                    else
                        vmPaint(d, mode, col)
                        seenMat[d] = true
                    end
                end
            end
        end
        if same then
            hlFor("root", root, CFG.weaponMode, wc)
            used.root = true
        end
    end
    for p in pairs(vmSaved) do
        if not seenMat[p] then vmRestore(p) end
    end
    for k, h in pairs(vmHl) do
        if not used[k] then
            pcall(function() h:Destroy() end)
            vmHl[k] = nil
        end
    end
end

task.spawn(function()
    while running do
        pcall(vmStep)
        task.wait(0.2)
    end
end)

------------------------------------------------------------------ anti-aim
-- Spin: real physics spin (replicates by itself). Jitter / Backwards / Pitch: the fake pose is set after
-- physics, which is what the server and other players receive, and the real one is back before your render.
local aa = {real = nil, spun = false}
local function aaRestore()
    local c = lp.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if aa.real and hrp then hrp.CFrame = aa.real end
    aa.real = nil
end
RunService:BindToRenderStep("ZenithRivals_AA", Enum.RenderPriority.First.Value, aaRestore)
connect(RunService.PreSimulation, aaRestore)

local function aaStopSpin()
    if not aa.spun then return end
    aa.spun = false
    local c = lp.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if hum then hum.AutoRotate = true end
    if hrp then hrp.AssemblyAngularVelocity = Vector3.zero end
end

local jit = 1
connect(RunService.Heartbeat, function()
    local c = lp.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not running or not CFG.aa or not hrp or not hum or hum.Health <= 0 then
        aaStopSpin()
        return
    end
    if CFG.aaYaw == "Spin" then
        aa.spun = true
        hum.AutoRotate = false
        hrp.AssemblyAngularVelocity = Vector3.new(0, math.rad(CFG.aaSpin), 0)
    else
        aaStopSpin()
    end
    local fakeYaw = CFG.aaYaw == "Jitter" or CFG.aaYaw == "Backwards"
    if not fakeYaw and CFG.aaPitch == "Off" then return end
    local real = hrp.CFrame
    local _, yaw = real:ToEulerAnglesYXZ()
    if CFG.aaYaw == "Jitter" then
        jit = -jit
        yaw += math.rad(90 * jit + math.random(-25, 25))
    elseif CFG.aaYaw == "Backwards" then
        yaw += math.pi
    end
    local pitch = 0
    if CFG.aaPitch == "Down" then
        pitch = math.rad(-89)
    elseif CFG.aaPitch == "Up" then
        pitch = math.rad(89)
    elseif CFG.aaPitch == "Random" then
        pitch = math.rad(math.random(-89, 89))
    end
    aa.real = real
    hrp.CFrame = CFrame.new(real.Position) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
end)

------------------------------------------------------------------ menu
local C = {
    bg = Color3.fromRGB(0, 0, 0), side = Color3.fromRGB(8, 8, 9), row = Color3.fromRGB(17, 17, 19),
    line = Color3.fromRGB(34, 34, 38), accent = Color3.fromRGB(245, 245, 250), text = Color3.fromRGB(235, 235, 238),
    sub = Color3.fromRGB(140, 140, 148),
}
local gui = Instance.new("ScreenGui")
gui.Name = "ZenithRivalsMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 4)
    c.Parent = o
end
local function stroke(o, col)
    local s = Instance.new("UIStroke")
    s.Color = col or C.line
    s.Thickness = 1
    s.Parent = o
    return s
end
local function label(parent, txt, size, col, font, xa)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextSize = size
    l.TextColor3 = col
    l.Font = font or Enum.Font.Ubuntu
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(320, 400)
main.BackgroundColor3 = C.bg
main.BackgroundTransparency = 0.3
main.Parent = gui
corner(main, 6)
stroke(main)
local sc = Instance.new("UIScale")
local vps = cam.ViewportSize
sc.Scale = math.clamp(math.min((vps.X - 40) / 320, (vps.Y - 40) / 400), 0.6, 1.4)
sc.Parent = main

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 40)
top.BackgroundColor3 = C.side
top.BackgroundTransparency = 0.15
top.Active = true
top.Parent = main
corner(top, 6)
local logo = Instance.new("ImageLabel")
logo.BackgroundTransparency = 1
logo.Size = UDim2.fromOffset(26, 26)
logo.Position = UDim2.new(0, 8, 0.5, -13)
logo.Image = "rbxassetid://13936134740"
logo.Parent = top
corner(logo, 4)
local title = label(top, "ZENITH", 15, C.text, Enum.Font.GothamBlack)
title.Position = UDim2.fromOffset(42, 4)
title.Size = UDim2.fromOffset(100, 18)
local sub = label(top, "rivals  by @zenithee", 11, C.sub, Enum.Font.Code)
sub.Position = UDim2.fromOffset(42, 21)
sub.Size = UDim2.fromOffset(200, 14)

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(8, 48)
list.Size = UDim2.new(1, -16, 1, -56)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 2
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.ScrollingDirection = Enum.ScrollingDirection.Y
list.Parent = main
local lay = Instance.new("UIListLayout")
lay.Padding = UDim.new(0, 4)
lay.SortOrder = Enum.SortOrder.LayoutOrder
lay.Parent = list

local order = 0
local function rowFrame(h)
    order += 1
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, h)
    f.BackgroundColor3 = C.row
    f.BackgroundTransparency = 0.25
    f.LayoutOrder = order
    f.Parent = list
    corner(f, 4)
    return f
end

local function section(txt)
    order += 1
    local l = label(list, string.upper(txt), 10, C.sub, Enum.Font.GothamBold)
    l.Size = UDim2.new(1, -4, 0, 20)
    l.LayoutOrder = order
end

local function toggle(txt, key)
    local f = rowFrame(30)
    local l = label(f, txt, 13, C.text)
    l.Position = UDim2.fromOffset(10, 0)
    l.Size = UDim2.new(1, -40, 1, 0)
    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(1, 0.5)
    box.Position = UDim2.new(1, -10, 0.5, 0)
    box.Size = UDim2.fromOffset(16, 16)
    box.Parent = f
    corner(box, 3)
    local st = stroke(box)
    local function render()
        box.BackgroundColor3 = CFG[key] and C.accent or C.row
        st.Color = CFG[key] and C.accent or C.line
    end
    render()
    local b = Instance.new("TextButton")
    b.BackgroundTransparency = 1
    b.Text = ""
    b.Size = UDim2.fromScale(1, 1)
    b.Parent = f
    b.Activated:Connect(function()
        CFG[key] = not CFG[key]
        render()
    end)
end

local function slider(txt, key, mn, mx, step)
    local f = rowFrame(42)
    local l = label(f, txt, 13, C.text)
    l.Position = UDim2.fromOffset(10, 3)
    l.Size = UDim2.new(1, -80, 0, 18)
    local v = label(f, "", 12, C.accent, Enum.Font.Code, Enum.TextXAlignment.Right)
    v.Position = UDim2.new(1, -70, 0, 3)
    v.Size = UDim2.fromOffset(60, 18)
    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(10, 28)
    bar.Size = UDim2.new(1, -20, 0, 3)
    bar.BackgroundColor3 = C.line
    bar.BorderSizePixel = 0
    bar.Parent = f
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    local function render()
        local a = (CFG[key] - mn) / (mx - mn)
        fill.Size = UDim2.new(math.clamp(a, 0, 1), 0, 1, 0)
        v.Text = tostring(CFG[key])
    end
    render()
    local drag = false
    local function set(x)
        local a = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        CFG[key] = math.clamp(math.floor((mn + a * (mx - mn)) / step + 0.5) * step, mn, mx)
        render()
    end
    local hit = Instance.new("TextButton")
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Position = UDim2.fromOffset(0, 18)
    hit.Size = UDim2.new(1, 0, 0, 24)
    hit.Parent = f
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            set(i.Position.X)
        end
    end)
    connect(UIS.InputChanged, function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            set(i.Position.X)
        end
    end)
    connect(UIS.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local function cycle(txt, key, values)
    local f = rowFrame(30)
    local l = label(f, txt, 13, C.text)
    l.Position = UDim2.fromOffset(10, 0)
    l.Size = UDim2.new(0.5, -10, 1, 0)
    local b = Instance.new("TextButton")
    b.AnchorPoint = Vector2.new(1, 0.5)
    b.Position = UDim2.new(1, -8, 0.5, 0)
    b.Size = UDim2.new(0.5, -8, 0, 22)
    b.BackgroundColor3 = C.row
    b.TextColor3 = C.text
    b.Font = Enum.Font.Code
    b.TextSize = 12
    b.Text = tostring(CFG[key])
    b.AutoButtonColor = false
    b.Parent = f
    corner(b, 4)
    stroke(b)
    b.Activated:Connect(function()
        local i = table.find(values, CFG[key]) or 0
        CFG[key] = values[i % #values + 1]
        b.Text = tostring(CFG[key])
    end)
end

local function button(txt, fn)
    local f = rowFrame(32)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -16, 0, 24)
    b.Position = UDim2.fromOffset(8, 4)
    b.BackgroundColor3 = C.row
    b.TextColor3 = C.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Text = string.upper(txt)
    b.AutoButtonColor = false
    b.Parent = f
    corner(b, 4)
    stroke(b)
    b.Activated:Connect(fn)
end

section("Silent Aim")
toggle("Silent aim", "silent")
cycle("Aim part", "part", {"Head", "Torso", "Random"})
slider("FOV", "fov", 20, 600, 5)
toggle("Show FOV", "showFov")
slider("Hit chance", "hitChance", 0, 100, 1)
toggle("Wall check", "wallCheck")
section("ESP")
toggle("ESP", "esp")
toggle("Box", "box")
toggle("Name", "name")
toggle("Health", "health")
toggle("Distance", "dist")
toggle("Show team", "showTeam")
slider("ESP range", "maxDist", 100, 3000, 50)
section("Chams")
local MODES = {"Highlight", "Outline", "Neon", "ForceField"}
toggle("Weapon", "chWeapon")
cycle("Weapon mode", "weaponMode", MODES)
cycle("Weapon color", "weaponColor", COLOR_LIST)
toggle("Hand", "chHands")
cycle("Hand mode", "handsMode", MODES)
cycle("Hand color", "handsColor", COLOR_LIST)
toggle("Body", "chBody")
cycle("Body mode", "bodyMode", MODES)
cycle("Body color", "bodyColor", {"Team", "Red", "Blue", "Purple", "Pink", "Cyan", "Green", "Yellow", "White", "Rainbow"})
section("Anti-Aim")
toggle("Anti-aim", "aa")
cycle("Yaw", "aaYaw", {"Spin", "Jitter", "Backwards", "Off"})
slider("Spin speed", "aaSpin", 100, 3000, 50)
cycle("Pitch", "aaPitch", {"Off", "Down", "Up", "Random"})
section("Script")
button("Unload", function() genv.ZenithRivals() end)

-- drag the menu
local dragging, dStart, pStart = false, nil, nil
top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging, dStart, pStart = true, i.Position, main.Position
    end
end)
connect(UIS.InputChanged, function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        main.Position = UDim2.new(pStart.X.Scale, pStart.X.Offset + d.X, pStart.Y.Scale, pStart.Y.Offset + d.Y)
    end
end)
connect(UIS.InputEnded, function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- round button opens / closes the menu
local ob = Instance.new("ImageButton")
ob.Size = UDim2.fromOffset(54, 54)
ob.Position = UDim2.new(0, 16, 0, 96)
ob.BackgroundColor3 = C.bg
ob.BackgroundTransparency = 0.1
ob.AutoButtonColor = false
ob.Image = ""
ob.Parent = gui
corner(ob, 27)
stroke(ob)
local oimg = Instance.new("ImageLabel")
oimg.BackgroundTransparency = 1
oimg.AnchorPoint = Vector2.new(0.5, 0.5)
oimg.Position = UDim2.fromScale(0.5, 0.5)
oimg.Size = UDim2.fromScale(0.8, 0.8)
oimg.Image = "rbxassetid://13936134740"
oimg.ScaleType = Enum.ScaleType.Crop
oimg.Parent = ob
corner(oimg, 22)
local oDown, oStart, oPos, oMoved = false, nil, nil, 0
ob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        oDown, oStart, oPos, oMoved = true, i.Position, ob.Position, 0
    end
end)
connect(UIS.InputChanged, function(i)
    if oDown and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - oStart
        oMoved = math.max(oMoved, d.Magnitude)
        if oMoved > 10 then
            ob.Position = UDim2.new(oPos.X.Scale, oPos.X.Offset + d.X, oPos.Y.Scale, oPos.Y.Offset + d.Y)
        end
    end
end)
connect(UIS.InputEnded, function(i)
    if oDown and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
        oDown = false
        if oMoved <= 10 then
            main.Visible = not main.Visible
            if main.Visible then
                sc.Scale = sc.Scale * 0.9
                TweenService:Create(sc, TweenInfo.new(0.22, Enum.EasingStyle.Back), {Scale = sc.Scale / 0.9}):Play()
            end
        end
    end
end)


------------------------------------------------------------------ unload
genv.ZenithRivals = function()
    running = false
    S.on, S.target = false, nil
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    pcall(function() RunService:UnbindFromRenderStep("ZenithRivals_AA") end)
    pcall(aaRestore)
    pcall(aaStopSpin)
    for p in pairs(vmSaved) do pcall(vmRestore, p) end
    for _, d in ipairs(draws) do pcall(function() d:Remove() end) end
    pcall(function() hlFolder:Destroy() end)
    pcall(function() gui:Destroy() end)
    genv.ZenithRivals = nil
end
