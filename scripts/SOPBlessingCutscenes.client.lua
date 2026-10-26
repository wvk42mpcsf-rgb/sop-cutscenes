-- SOPBlessingCutscenes (Tab, Oct 24 2026, SOP Test v470+): the LEGENDARY / MYTHICAL / CELESTIAL blessing DRAW CUTSCENES, client half.
-- owner: "for every legendary kit and above, make a cutscene for them like you did with Infinity ... make every cutscene unique
-- and fitting the actual Blessing itself ... fonts fitting the blessing". Infinity keeps its own (StarterPlayerScripts.SOPRollCutscene).
-- This LocalScript is the shared PLAYER; each blessing's scene is a ModuleScript child of it (Judas, KeyboardWarrior, Phoenix, Berserker,
-- Necromancer, Seraph, Chronos). The grammar is Infinity's: cold open (letterbox in) -> quote card in that blessing's voice and font ->
-- a "power-up" shot of what the blessing really does -> its own signature transition -> ONE true-black beat -> the reveal (hero pose,
-- name banner, NEW! first time only, BLESSING + rarity tags, the real ability card from KitAbilities, speech box + name plate, Tap to
-- continue). NO SKIP anywhere: Tap to continue on the reveal is the only exit (a round starting / death / leaving abort + restore).
-- The game's own HUD (PanelHud) and Roblox's chat / player list / backpack / emotes / health are hidden for the cinematic; the Roblox
-- menu + mic top bar are left alone. Camera, controls, HUD, CoreGui, Lighting, post effects and audio are put back exactly on close.
-- AVATAR: every scene uses a plain DEFAULT R6 placeholder built here at runtime (scene field `avatar = "DEFAULT_R6"`). To drop in a real
-- model later: put it in ReplicatedStorage.SOPBlessingCutsceneRigs (server AVATAR_RIGS list) and set that scene's `avatar` to its name.
-- Fonts: StarterGui FontEnforcer forces FredokaOne on every label, so every label here re-applies its own FontFace (lockFont).
-- Sound: parked by the owner (visuals first). Each scene has its own CUES table (only generic approved cues from Infinity's set, or none).
-- ROLLBACK: disable this LocalScript (and ServerScriptService.SOPBlessingCutsceneServer).

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local TextService = game:GetService("TextService")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

local function A(id) return "rbxassetid://" .. tostring(id) end
-- shared art (generic sprites, all white unless noted, tinted per scene with ImageColor3)
local IMG = {
	glow = A("<ASSET_ID>"), sparkle = A("<ASSET_ID>"), starburst = A("<ASSET_ID>"), speedlines = A("<ASSET_ID>"),
	mist = A("<ASSET_ID>"), rays = A("<ASSET_ID>"), stars = A("<ASSET_ID>"), dust = A("<ASSET_ID>"), skyStars = A("<ASSET_ID>"),
	slash = A("<ASSET_ID>"), streak = A("<ASSET_ID>"), ring = A("<ASSET_ID>"), burst = A("<ASSET_ID>"), smoke = A("<ASSET_ID>"), smoke2 = A("<ASSET_ID>"),
}
local AUDIO = { -- Infinity's approved GENERIC cues that scenes may reuse (boom/hit, heartbeat/ember, glass crack, low rumble)
	impact = "<ASSET_ID>", black = "<ASSET_ID>", crack = "<ASSET_ID>", open = "<ASSET_ID>",
}

local PURE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.new(0, 0, 0)
local INK = Color3.fromRGB(10, 10, 16)
local STAGE = Vector3.new(-7600, 3200, 7600) -- far from the map (and from Infinity's stage); everything here is local to this client
local FRONT = Vector3.new(0, 0, -1) -- the avatar faces -Z

local busy = false
local pending = nil
local S = nil

-- ================= small helpers =================
local function inst(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function tween(o, t, props, style, dir)
	local ok, tw = pcall(function()
		return TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	end)
	if ok and tw then tw:Play() return tw end
	for k, v in pairs(props) do pcall(function() o[k] = v end) end
	return nil
end
local function lerp(a, b, x) return a + (b - a) * x end
local function clamp01(x) return math.clamp(x, 0, 1) end
local function smooth(x) x = clamp01(x) return x * x * (3 - 2 * x) end
local function sine(x) x = clamp01(x) return 0.5 - 0.5 * math.cos(x * math.pi) end
local function easeOut(x) x = clamp01(x) return 1 - (1 - x) ^ 3 end
local function easeIn(x) x = clamp01(x) return x ^ 3 end
local function nsk(list) local k = {} for _, v in ipairs(list) do table.insert(k, NumberSequenceKeypoint.new(v[1], v[2], v[3] or 0)) end return NumberSequence.new(k) end
local function cs(a, b) return ColorSequence.new(a, b or a) end
local function cseq(list) local k = {} for _, v in ipairs(list) do table.insert(k, ColorSequenceKeypoint.new(v[1], v[2])) end return ColorSequence.new(k) end
local RNG = Random.new(470)
local function rnd(a, b) return a + RNG:NextNumber() * (b - a) end

local function part(props, parent)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props or {}) do p[k] = v end
	p.Parent = parent
	return p
end
local function bulk(parts, cfs)
	if #parts == 0 then return end
	local ok = pcall(function() workspace:BulkMoveTo(parts, cfs, Enum.BulkMoveMode.FireCFrameChanged) end)
	if not ok then for i, p in ipairs(parts) do p.CFrame = cfs[i] end end
end
local function emitter(parent, props)
	local e = Instance.new("ParticleEmitter")
	e.Texture = IMG.sparkle
	e.LightEmission = 1
	e.LightInfluence = 0
	e.Rate = 0
	for k, v in pairs(props) do
		local ok = pcall(function() e[k] = v end)
		if not ok then warn("[SOPBlessingCutscenes] emitter prop " .. tostring(k)) end
	end
	e.Parent = parent
	return e
end
local function billboard(parent, img, size, color, transp, bright, alwaysOnTop)
	local bb = inst("BillboardGui", { Size = UDim2.fromScale(size, size), LightInfluence = 0, AlwaysOnTop = alwaysOnTop == true,
		MaxDistance = 5000, ResetOnSpawn = false }, parent)
	pcall(function() bb.Brightness = bright or 1 end)
	local im = inst("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = img, ImageColor3 = color or PURE,
		ImageTransparency = transp or 0 }, bb)
	return bb, im
end
local function anchorPart(parent, pos, name)
	return part({ Name = name or "Anchor", Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1, CFrame = CFrame.new(pos) }, parent)
end
local function spot(parent, pos, at, color, bright, range, angle)
	local p = part({ Name = "Light", Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1, CFrame = CFrame.lookAt(pos, at) }, parent)
	local l = inst("SpotLight", { Color = color, Brightness = bright, Range = range, Angle = angle or 60, Face = Enum.NormalId.Front, Shadows = false }, p)
	return l, p
end
local function pointLight(parent, pos, color, bright, range)
	local p = anchorPart(parent, pos, "PLight")
	return inst("PointLight", { Color = color, Brightness = bright, Range = range, Shadows = false }, p), p
end
-- a big flat backdrop (a wall of colour/texture facing `from`) placed `dist` studs behind `at`; returns the part + its SurfaceGui
local function backdrop(parent, at, from, dist, w, h, c0, c1, img, imgTransp, imgTint, tile)
	local dir = (at - from)
	dir = Vector3.new(dir.X, 0, dir.Z)
	dir = dir.Magnitude > 0.01 and dir.Unit or Vector3.new(0, 0, -1)
	local p = part({ Name = "Backdrop", Size = Vector3.new(w, h, 1), Transparency = 1, CFrame = CFrame.lookAt(at + dir * dist, at + dir * (dist - 10)) }, parent)
	local sg = inst("SurfaceGui", { Face = Enum.NormalId.Front, LightInfluence = 0, SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
		CanvasSize = Vector2.new(1024, math.floor(1024 * h / w)), ClipsDescendants = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, p)
	pcall(function() sg.Brightness = 1 end)
	local f = inst("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = PURE, BorderSizePixel = 0 }, sg)
	inst("UIGradient", { Rotation = 90, Color = ColorSequence.new(c0, c1) }, f)
	local im = nil
	if img then
		im = inst("ImageLabel", { Size = UDim2.new(1, 512, 1, 512), Position = UDim2.fromOffset(-256, -256), BackgroundTransparency = 1, Image = img,
			ImageTransparency = imgTransp or 0.3, ImageColor3 = imgTint or PURE, ZIndex = 2,
			ScaleType = tile and Enum.ScaleType.Tile or Enum.ScaleType.Stretch, TileSize = UDim2.fromOffset(tile or 256, tile or 256) }, sg)
	end
	return p, sg, im
end

-- a closed sky box of 6 walls around `c` (radius r, kept well inside the render distance of low graphics settings - walls past ~300
-- studs were culled on the test client): each wall is a dark Neon part (renders its colour without any light) with a gradient +
-- optional tiled star layer on its inner face, so the game's own sky never shows from any camera angle
local function skybox(parent, c, r, top, bottom, starsImg, starsTint, starsTransp, tile)
	local folder = inst("Folder", { Name = "SkyBox" }, parent)
	local faces = {
		{ d = Vector3.new(1, 0, 0) }, { d = Vector3.new(-1, 0, 0) }, { d = Vector3.new(0, 0, 1) }, { d = Vector3.new(0, 0, -1) },
		{ d = Vector3.new(0, 1, 0), cap = top }, { d = Vector3.new(0, -1, 0), cap = bottom },
	}
	for _, f in ipairs(faces) do
		local pos = c + f.d * r
		local up = (math.abs(f.d.Y) > 0.5) and Vector3.new(0, 0, 1) or Vector3.new(0, 1, 0)
		local mid = f.cap or top:Lerp(bottom, 0.75)
		local p = part({ Name = "SkyWall", Size = Vector3.new(r * 2 + 4, r * 2 + 4, 1), Color = mid, Material = Enum.Material.Neon,
			CFrame = CFrame.lookAt(pos, c, up) }, folder)
		local sg = inst("SurfaceGui", { Face = Enum.NormalId.Front, LightInfluence = 0, SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
			CanvasSize = Vector2.new(1024, 1024), ClipsDescendants = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, p)
		pcall(function() sg.Brightness = 1 end)
		local fr = inst("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = PURE, BorderSizePixel = 0 }, sg)
		if f.cap then fr.BackgroundColor3 = f.cap else inst("UIGradient", { Rotation = 90, Color = ColorSequence.new(top, bottom) }, fr) end
		if starsImg and f.d.Y > -0.5 then
			inst("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = starsImg, ImageColor3 = starsTint or PURE,
				ImageTransparency = starsTransp or 0.4, ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(tile or 384, tile or 384), ZIndex = 2 }, sg)
		end
	end
	return folder
end

-- ================= the screen guis =================
-- gui: full-bleed layers (backdrops, flashes, the letterbox bars on top). ui: the UI layer inside the device safe inset, above the bars.
local gui = inst("ScreenGui", { Name = "SOPBlessingCutscene", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 2000,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = false })
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
gui:SetAttribute("PanelHudKeep", true)
gui.Parent = pgui
local ui = inst("ScreenGui", { Name = "SOPBlessingCutsceneUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 2001,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = false })
pcall(function() ui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end)
ui:SetAttribute("PanelHudKeep", true)
ui.Parent = pgui

local hud = nil
task.spawn(function()
	local okPH, PanelHud = pcall(function() return require(RS:WaitForChild("PanelHud", 10)) end)
	if okPH and type(PanelHud) == "table" and PanelHud.new then
		local ok, h = pcall(function() return PanelHud.new(gui) end)
		if ok then hud = h end
	end
end)
local SopUI = nil
task.spawn(function()
	local ok, K = pcall(function() return require(RS:WaitForChild("SopUI", 10)) end)
	if ok and type(K) == "table" then SopUI = K end
end)
local function viewport()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

-- ================= sounds (each scene's own CUES table) =================
local function gameVolume()
	local v = player:GetAttribute("GameVolume")
	return (type(v) == "number") and math.clamp(v, 0, 1) or 1
end
local function makeBank(cues)
	local folder = Instance.new("Folder")
	folder.Name = "SOPBlessingCutsceneAudio"
	local group = Instance.new("SoundGroup")
	group.Name = "SOPBlessingCutsceneGroup" -- our own group (the game's sliders + round compressor don't touch it), Game Volume only
	group.Volume = gameVolume()
	group.Parent = folder
	local bank = { folder = folder, group = group, s = {} }
	for _, c in ipairs(cues or {}) do
		if c.id then
			local s = Instance.new("Sound")
			s.Name = c.key
			s.SoundId = "rbxassetid://" .. tostring(c.id)
			s.Volume = c.vol or 0.6
			s.Looped = c.looped == true
			s.SoundGroup = group
			s.Parent = folder
			bank.s[c.key] = s
		end
	end
	folder.Parent = SoundService
	return bank
end

-- ================= fonts =================
-- StarterGui.SOPClientScripts.FontEnforcer sets Font = FredokaOne on every label added to PlayerGui. Each label here keeps its own
-- FontFace: set after parenting, and put back (deferred) whenever anything changes it.
local function lockFont(t, face)
	if not face then return end
	t.FontFace = face
	t:GetPropertyChangedSignal("FontFace"):Connect(function()
		if t.FontFace ~= face then
			task.defer(function() if t.Parent and t.FontFace ~= face then t.FontFace = face end end)
		end
	end)
	task.defer(function() if t.Parent and t.FontFace ~= face then t.FontFace = face end end)
end
local function faceOf(font, weight, style)
	local f = Font.fromEnum(font)
	if weight or style then pcall(function() f = Font.new(f.Family, weight or f.Weight, style or f.Style) end) end
	return f
end
local function textWidth(s, size, font)
	local ok, v = pcall(function() return TextService:GetTextSize(s, size, font, Vector2.new(10000, 1000)).X end)
	return (ok and type(v) == "number") and v or (#s * size * 0.8)
end

-- ================= 2D helpers =================
local function full(parent, props)
	local f = inst("Frame", { Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, BackgroundColor3 = BLACK }, parent)
	for k, v in pairs(props or {}) do f[k] = v end
	return f
end
local function text(parent, props)
	props = props or {}
	local face = props.FontFace or faceOf(props.Font or Enum.Font.GothamBold)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.TextColor3 = PURE
	t.TextScaled = false
	t.TextWrapped = true
	t.RichText = false
	for k, v in pairs(props) do if k ~= "Font" and k ~= "FontFace" then t[k] = v end end
	t.FontFace = face
	t.Parent = parent
	lockFont(t, face)
	return t
end
local function img(parent, image, props)
	local i = inst("ImageLabel", { BackgroundTransparency = 1, Image = image, AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0 }, nil)
	for k, v in pairs(props or {}) do i[k] = v end
	i.Parent = parent
	return i
end
local function corner(o, r) return inst("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function stroke(o, color, th, tr)
	return inst("UIStroke", { Color = color, Thickness = th, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
end
local function tstroke(o, color, th, tr)
	return inst("UIStroke", { Color = color, Thickness = th, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual }, o)
end
local function hex3(t) -- SopUI palette ("FFD43B") -> Color3
	local out = {}
	for i, h in ipairs(t) do out[i] = Color3.fromRGB(tonumber(string.sub(h, 1, 2), 16), tonumber(string.sub(h, 3, 4), 16), tonumber(string.sub(h, 5, 6), 16)) end
	return out
end
-- the rarity pill's colours: LEGENDARY = the roll screen's gold, MYTHICAL = the roll screen's pink (what RollView draws, like Infinity),
-- CELESTIAL = pale celestial gold (255, 230, 140)
local function rarityColors(rarity)
	local pal = ({ LEGENDARY = { "FFD43B", "FFAE1F", "FF8A0A" }, MYTHICAL = { "FFA3D2", "FF6FB5", "E2408F" } })[rarity]
	if rarity == "CELESTIAL" then return { Color3.fromRGB(255, 246, 206), Color3.fromRGB(255, 230, 140), Color3.fromRGB(226, 188, 88) } end
	local cols = hex3(pal or { "FFD43B", "FFAE1F", "FF8A0A" })
	pcall(function()
		if SopUI and SopUI.cols3 and SopUI.RARITY and rarity ~= "CELESTIAL" then
			local c = SopUI.cols3(SopUI.RARITY[rarity] or "gold")
			if type(c) == "table" and typeof(c[1]) == "Color3" then cols = c end
		end
	end)
	return cols
end

-- ================= the placeholder avatar: a plain DEFAULT R6 Roblox rig, built here (no model asset, nothing edited) =================
-- Standard R6 sizes + joints (Head 2x1x1 with the classic head mesh + default face, Torso 2x2x1, limbs 1x2x1), classic default colours.
local R6_COLORS = { Head = Color3.fromRGB(245, 205, 48), Torso = Color3.fromRGB(13, 105, 172), ["Left Arm"] = Color3.fromRGB(245, 205, 48),
	["Right Arm"] = Color3.fromRGB(245, 205, 48), ["Left Leg"] = Color3.fromRGB(164, 189, 71), ["Right Leg"] = Color3.fromRGB(164, 189, 71) }
local function buildDefaultR6(name)
	local m = Instance.new("Model")
	m.Name = name or "DefaultR6"
	local function limb(n, size)
		local p = Instance.new("Part")
		p.Name = n
		p.Size = size
		p.Color = R6_COLORS[n] or Color3.fromRGB(163, 162, 165)
		p.Material = Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.CanCollide, p.CanQuery, p.CanTouch, p.Massless, p.Anchored, p.CastShadow = false, false, false, true, false, false
		p.Parent = m
		return p
	end
	local hrp = limb("HumanoidRootPart", Vector3.new(2, 2, 1))
	hrp.Transparency = 1
	hrp.Anchored = true
	local torso = limb("Torso", Vector3.new(2, 2, 1))
	local head = limb("Head", Vector3.new(2, 1, 1))
	inst("SpecialMesh", { MeshType = Enum.MeshType.Head, Scale = Vector3.new(1.25, 1.25, 1.25) }, head)
	inst("Decal", { Name = "face", Texture = "rbxasset://textures/face.png", Face = Enum.NormalId.Front }, head)
	local la, ra = limb("Left Arm", Vector3.new(1, 2, 1)), limb("Right Arm", Vector3.new(1, 2, 1))
	local ll, rl = limb("Left Leg", Vector3.new(1, 2, 1)), limb("Right Leg", Vector3.new(1, 2, 1))
	local function motor(n, p0, p1, c0, c1)
		local j = Instance.new("Motor6D")
		j.Name, j.Part0, j.Part1, j.C0, j.C1 = n, p0, p1, c0, c1
		j.Parent = p0
		return j
	end
	local R = CFrame.fromMatrix(Vector3.new(), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 1, 0)) -- R6 root/neck basis
	local RS_ = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 0, -1), Vector3.new(0, 1, 0), Vector3.new(1, 0, 0)) -- right side basis
	local LS_ = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 0, 1), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0)) -- left side basis
	motor("RootJoint", hrp, torso, R, R)
	motor("Neck", torso, head, CFrame.new(0, 1, 0) * R, CFrame.new(0, -0.5, 0) * R)
	motor("Right Shoulder", torso, ra, CFrame.new(1, 0.5, 0) * RS_, CFrame.new(-0.5, 0.5, 0) * RS_)
	motor("Left Shoulder", torso, la, CFrame.new(-1, 0.5, 0) * LS_, CFrame.new(0.5, 0.5, 0) * LS_)
	motor("Right Hip", torso, rl, CFrame.new(1, -1, 0) * RS_, CFrame.new(0.5, 1, 0) * RS_)
	motor("Left Hip", torso, ll, CFrame.new(-1, -1, 0) * LS_, CFrame.new(-0.5, 1, 0) * LS_)
	local hum = Instance.new("Humanoid")
	pcall(function() hum.RigType = Enum.HumanoidRigType.R6 end)
	hum.Parent = m
	m.PrimaryPart = hrp
	return m
end

-- R6 poses, as rotations in the parent part's space (x right, y up, -z forward): { pitch, yaw, roll }. Transform = rot0^-1 * R * rot0
-- (rot0 = the joint's C0 rotation), so the same numbers read the same on the placeholder and on a real R6 avatar later.
local BASE_POSES = {
	idle = { ["Right Shoulder"] = { 0.08, 0, 0.16 }, ["Left Shoulder"] = { 0.08, 0, -0.16 }, ["Right Hip"] = { -0.06, 0, 0.03 },
		["Left Hip"] = { 0.06, 0, -0.03 }, Neck = { 0, 0, 0 }, RootJoint = { 0, 0, 0 } },
	hero = { ["Right Shoulder"] = { 0.06, 0, 0.3 }, ["Left Shoulder"] = { 0.04, 0, -0.22 }, ["Right Hip"] = { -0.03, 0, 0.11 },
		["Left Hip"] = { 0.03, 0, -0.11 }, Neck = { 0.1, -0.06, 0 }, RootJoint = { 0, 0.08, 0 } },
}
local function poseCF(v) return CFrame.Angles(0, v[2], 0) * CFrame.Angles(v[1], 0, v[3]) end

local function buildAvatar(st, scene)
	local m = nil
	local want = scene.avatar
	if want and want ~= "DEFAULT_R6" then
		local folder = RS:FindFirstChild("SOPBlessingCutsceneRigs")
		local src = folder and folder:FindFirstChild(want)
		if src then pcall(function() m = src:Clone() end) end
	end
	if not m then m = buildDefaultR6(scene.key or "Avatar") end
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("LuaSourceContainer") then d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored = false
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
			d.Massless = true
		end
	end
	local hrp = m:FindFirstChild("HumanoidRootPart")
	local hum = m:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then m:Destroy() return nil end
	hrp.Anchored = true
	m.PrimaryPart = hrp
	pcall(function()
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		hum.EvaluateStateMachine = false
		hum.BreakJointsOnDeath = false
	end)
	pcall(function() local an = hum:FindFirstChildOfClass("Animator") if an then an:Destroy() end end)
	m:PivotTo(CFrame.new(STAGE))
	m.Parent = st.world
	local motors = {}
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("Motor6D") then motors[d.Name] = { m = d, rot0 = d.C0 - d.C0.Position, cur = CFrame.new() } end
	end
	local poses = table.clone(BASE_POSES)
	for k, v in pairs(scene.poses or {}) do poses[k] = v end
	st.avatar = { model = m, hrp = hrp, hum = hum, motors = motors, pose = "idle", poses = poses, breathe = 1,
		head = m:FindFirstChild("Head"), torso = m:FindFirstChild("Torso"), ra = m:FindFirstChild("Right Arm"), la = m:FindFirstChild("Left Arm") }
	return st.avatar
end
local function setPose(st, name, dur, style)
	local av = st.avatar
	if not av then return end
	av.poseFrom = {}
	for k, mo in pairs(av.motors) do av.poseFrom[k] = mo.cur end
	av.pose, av.poseT0, av.poseDur, av.poseStyle = name, os.clock(), dur or 0.6, style
end
local function drivePose(st, t)
	local av = st.avatar
	if not av then return end
	local target = av.poses[av.pose] or av.poses.idle
	local u = math.clamp((os.clock() - (av.poseT0 or 0)) / math.max(av.poseDur or 0.6, 0.01), 0, 1)
	if av.poseStyle == "snap" then u = 1 - (1 - u) ^ 4 elseif av.poseStyle == "back" then
		local c1, c3 = 1.9, 2.9
		u = 1 + c3 * (u - 1) ^ 3 + c1 * (u - 1) ^ 2
	else u = u * u * (3 - 2 * u) end
	local b = av.breathe or 1
	local breath = math.sin(t * 2.2) * b
	local sway = math.sin(t * 0.7) * b
	for k, mo in pairs(av.motors) do
		local v = target[k] or { 0, 0, 0 }
		local goal = poseCF(v)
		if k == "Right Shoulder" or k == "Left Shoulder" then
			goal = goal * CFrame.Angles(0.025 * breath, 0, (k == "Right Shoulder" and 1 or -1) * 0.02 * breath)
		elseif k == "Neck" then
			goal = goal * CFrame.Angles(-0.02 * breath, 0.03 * sway, 0)
		elseif k == "RootJoint" then
			goal = goal * CFrame.Angles(0.012 * breath, 0.03 * sway, 0.01 * sway)
		end
		local from = (av.poseFrom and av.poseFrom[k]) or mo.cur
		mo.cur = from:Lerp(goal, u)
		pcall(function() mo.m.Transform = mo.rot0:Inverse() * mo.cur * mo.rot0 end)
	end
end
-- world position of a point given in a body part's local space (after the current pose)
local function partPoint(av, partName, localPos)
	local p = av and av.model:FindFirstChild(partName)
	if not p then return av and av.hrp.Position or STAGE end
	return (p.CFrame * CFrame.new(localPos or Vector3.new())).Position
end

-- ================= cleanup / restore =================
local function restoreWorld(st)
	if st.restored then return end
	st.restored = true
	pcall(function() RunService:UnbindFromRenderStep("SOPBlessingCutscene") end)
	for _, c in ipairs(st.conns) do pcall(function() c:Disconnect() end) end
	st.conns = {}
	for _, o in ipairs(st.trash) do pcall(function() o:Destroy() end) end
	st.trash = {}
	pcall(function() if st.world then st.world:Destroy() end end)
	pcall(function() if st.bank then for _, s in pairs(st.bank.s) do s:Stop() end st.bank.folder:Destroy() end end)
	st.bank = nil
	for _, c in ipairs(st.coreWas or {}) do pcall(function() StarterGui:SetCoreGuiEnabled(c.t, c.was) end) end
	st.coreWas = {}
	for _, tw in ipairs(st.lightTweens or {}) do pcall(function() tw:Cancel() end) end
	st.lightTweens = {}
	if st.light then
		-- every Lighting property the cutscene touched goes back to exactly what it was (the cutscene owned Lighting while it played)
		for k, v in pairs(st.light) do pcall(function() Lighting[k] = v end) end
		st.light = nil
	end
	for _, e in ipairs(st.effectsOff or {}) do pcall(function() e.o[e.prop] = e.was end) end
	st.effectsOff = {}
	for _, d in ipairs(st.ducked or {}) do pcall(function() if math.abs(d.g.Volume - d.set) < 1e-3 then d.g.Volume = d.was end end) end
	st.ducked = {}
	local cam = workspace.CurrentCamera
	if st.cam and cam then
		pcall(function()
			cam.FieldOfView = st.cam.fov
			cam.CameraType = (st.cam.ctype == Enum.CameraType.Scriptable) and Enum.CameraType.Custom or st.cam.ctype
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			cam.CameraSubject = hum or st.cam.subject
			cam.CFrame = st.cam.cf
		end)
		st.cam = nil
	end
	if st.touchWas ~= nil then pcall(function() GuiService.TouchControlsEnabled = st.touchWas end) st.touchWas = nil end
	if st.controls then pcall(function() st.controls:Enable() end) st.controls = nil end
end
local function finish(st, reopen)
	if st.done then return end
	st.done = true
	restoreWorld(st)
	if reopen and st.rollGui and st.rollGui.Parent and not player:GetAttribute("InRound") then
		pcall(function() st.rollGui.Enabled = true end)
	end
	if hud and st.hudHidden then pcall(function() hud:show() end) end
	for o, h in pairs(st.held or {}) do if h.want and o.Parent then pcall(function() o.Visible = true end) end end
	st.held = nil
	pcall(function() if st.root then st.root:Destroy() end end)
	pcall(function() if st.uiRoot then st.uiRoot:Destroy() end end)
	gui.Enabled = false
	ui.Enabled = false
	gui:SetAttribute("Playing", nil)
	if S == st then S = nil end
	busy = false
	if pending then
		local p = pending
		pending = nil
		task.delay(0.6, function() if not busy and p then p() end end)
	end
end
local function abort(st)
	if not st or st.done then return end
	finish(st, false)
end

-- =====================================================================================================================
-- THE PLAYER: runs one scene (a ModuleScript child) with Infinity's grammar
-- =====================================================================================================================
local DEFAULT_T = { bars = 0.05, quote = 1.0, typeStart = 1.4, cps = 18, commaPause = 0.3, quoteOut = 6.0, power = 6.4,
	trans = 13.0, black = 15.2, reveal = 16.5, uiDelay = 0.8, tapDelay = 1.1, speechDelay = 1.8, hardMax = 240 }

local function run(info, scene)
	local st = { conns = {}, trash = {}, ups = {}, events = {}, ducked = {}, effectsOff = {}, info = info, done = false, scene = scene }
	S = st
	gui:SetAttribute("Playing", scene.key)
	local T = table.clone(DEFAULT_T)
	for k, v in pairs(scene.T or {}) do T[k] = v end
	T.ui, T.tapOk, T.speech = T.reveal + T.uiDelay, T.reveal + T.tapDelay, T.reveal + T.speechDelay
	st.T = T
	local clockStart = os.clock()
	local function now() return os.clock() - clockStart end
	local QUAL = 1
	pcall(function() if SopUI and SopUI.lowGfx and SopUI.lowGfx() then QUAL = 0.6 end end)
	local reduced = player:GetAttribute("ReducedMotion") == true

	-- the reveal's data, read from the game's own tables
	local rarity = info.rarity or "LEGENDARY"
	pcall(function()
		local C = require(RS:WaitForChild("BlessingCatalog", 3))
		local b = C.get(info.blessing)
		if b and b.rarity then rarity = b.rarity end
	end)
	local ability = {}
	pcall(function()
		local KA = require(RS:WaitForChild("KitAbilities", 3))
		local d = KA[info.blessing]
		if type(d) == "table" then ability = { name = d.name, desc = d.desc, cd = d.cooldown } end
	end)
	st.rarity, st.ability = rarity, ability

	-- ---------- the two GUI roots ----------
	local root = inst("Frame", { Name = "Root", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, gui)
	st.root = root
	local uiRoot = inst("Frame", { Name = "UIRoot", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, ui)
	st.uiRoot = uiRoot
	local vp = viewport()
	local aspect = vp.X / math.max(vp.Y, 1)
	local barFrac = aspect >= 2.15 and 0.095 or 0.11
	local barPx = math.floor(vp.Y * barFrac + 0.5)
	-- full-bleed layer order (ZIndex): backdrops 2-12, quote text 13, scene overlays 14-16, flash 17, black 18, letterbox bars 20
	local blackout = full(root, { Name = "Black", ZIndex = 18, BackgroundTransparency = 0 })
	local flash = full(root, { Name = "Flash", ZIndex = 17, BackgroundColor3 = PURE, BackgroundTransparency = 1 })
	local bars = {}
	for i = 1, 2 do
		bars[i] = inst("Frame", { Name = i == 1 and "BarTop" or "BarBottom", BackgroundColor3 = BLACK, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0), ZIndex = 20, AnchorPoint = Vector2.new(0, i == 1 and 0 or 1), Position = UDim2.fromScale(0, i == 1 and 0 or 1) }, root)
	end
	local band = inst("Frame", { Name = "Band", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, uiRoot)
	local function layoutBand()
		local top, h = barPx, vp.Y - 2 * barPx
		pcall(function()
			local ap = ui.AbsolutePosition
			local as = ui.AbsoluteSize
			if as.Y > 10 then
				top = math.max(0, barPx - ap.Y)
				h = math.min(as.Y - top, (vp.Y - barPx) - ap.Y - top)
			end
		end)
		band.Position = UDim2.new(0, 0, 0, top)
		band.Size = UDim2.new(1, 0, 0, math.max(h, 100))
		return h
	end
	local bandH = layoutBand()
	local SC = math.clamp(math.min(vp.X / 1280, bandH / 520), 0.45, 1.5)

	-- ---------- world / camera / lighting ----------
	local world = inst("Model", { Name = "SOPBlessingCutsceneStage" }, workspace)
	st.world = world
	st.bank = info.bank
	info.bank = nil
	pcall(function() if st.bank then st.bank.group.Volume = gameVolume() end end)
	pcall(function()
		for _, g in ipairs(SoundService:GetDescendants()) do
			if g:IsA("SoundGroup") and (g.Name == "SOP_Music" or g.Name == "SOP_Ambience") then
				table.insert(st.ducked, { g = g, was = g.Volume, set = 0 })
			end
		end
	end)
	local cam = workspace.CurrentCamera
	st.cam = { ctype = cam.CameraType, subject = cam.CameraSubject, fov = cam.FieldOfView, cf = cam.CFrame }
	local look = scene.look or {}
	local bloom = inst("BloomEffect", { Name = "SOPBlessingCutsceneBloom", Intensity = look.bloomIntensity or 0.4, Size = look.bloomSize or 18,
		Threshold = look.bloomThreshold or 1.5, Enabled = false }, cam)
	local cc = inst("ColorCorrectionEffect", { Name = "SOPBlessingCutsceneCC", Brightness = 0, Contrast = look.contrast or 0.08,
		Saturation = look.saturation or 0, TintColor = look.tint or PURE, Enabled = false }, cam)
	local blur = inst("BlurEffect", { Name = "SOPBlessingCutsceneBlur", Size = 0, Enabled = false }, cam)
	for _, o in ipairs({ bloom, cc, blur }) do table.insert(st.trash, o) end

	local camCF = CFrame.lookAt(STAGE + Vector3.new(0, 1, -12), STAGE)
	local camFov = 50
	local shake = 0
	local sceneOn = false
	local function setCam(cf, fov) camCF = cf if fov then camFov = fov end end
	local function setShake(v) shake = v end

	-- Lighting: every property a scene sets is remembered once and put back on close (only if it is still the value we set)
	st.light, st.lightSet = {}, {}
	local function setLight(props)
		for k, v in pairs(props) do
			local ok, was = pcall(function() return Lighting[k] end)
			if ok then
				if st.light[k] == nil then st.light[k] = was end
				pcall(function() Lighting[k] = v end)
				pcall(function() st.lightSet[k] = Lighting[k] end)
			end
		end
	end
	-- tween Lighting (remembered the same way; cancelled + put back on close)
	st.lightTweens = {}
	local function lightTo(props, dur)
		for k, v in pairs(props) do
			local ok, was = pcall(function() return Lighting[k] end)
			if ok and st.light[k] == nil then st.light[k] = was end
		end
		if not dur or dur <= 0 then for k, v in pairs(props) do pcall(function() Lighting[k] = v end) end return end
		local okT, tw = pcall(function() return TweenService:Create(Lighting, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props) end)
		if okT and tw then table.insert(st.lightTweens, tw) tw:Play() else for k, v in pairs(props) do pcall(function() Lighting[k] = v end) end end
	end
	local function enterWorld()
		if st.done or sceneOn then return end
		sceneOn = true
		local base = { Brightness = 0, Ambient = Color3.fromRGB(30, 30, 36), OutdoorAmbient = Color3.fromRGB(24, 24, 30), ExposureCompensation = 0,
			ColorShift_Top = BLACK, ColorShift_Bottom = BLACK, FogStart = 100000, FogEnd = 100000, EnvironmentDiffuseScale = 0, EnvironmentSpecularScale = 0.1 }
		for k, v in pairs(scene.lighting or {}) do base[k] = v end
		setLight(base)
		-- the game's own post effects, sky bodies, atmosphere and clouds are off while the cutscene owns the screen (each goes back exactly)
		local function off(o, prop, v)
			local ok, was = pcall(function() return o[prop] end)
			if ok and was ~= v then
				table.insert(st.effectsOff, { o = o, prop = prop, was = was })
				pcall(function() o[prop] = v end)
			end
		end
		for _, e in ipairs(Lighting:GetChildren()) do
			if e:IsA("PostEffect") then off(e, "Enabled", false)
			elseif e:IsA("Sky") then off(e, "CelestialBodiesShown", false) off(e, "StarCount", 0)
			elseif e:IsA("Atmosphere") then off(e, "Density", 0) off(e, "Haze", 0) off(e, "Glare", 0) end
		end
		pcall(function()
			local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
			if clouds then off(clouds, "Enabled", false) end
		end)
		bloom.Enabled = true
		cc.Enabled = true
		blur.Enabled = true
	end

	RunService:BindToRenderStep("SOPBlessingCutscene", Enum.RenderPriority.Camera.Value + 5, function(dt)
		if st.done then return end
		local t = now()
		for _, ev in ipairs(st.events) do
			if not ev.done and t >= ev.t then
				ev.done = true
				local ok, err = pcall(ev.fn, t)
				if not ok then warn("[SOPBlessingCutscenes] " .. tostring(err)) end
			end
		end
		for i = #st.ups, 1, -1 do
			local u = st.ups[i]
			local ok, keep = pcall(u, t, dt)
			if not ok then warn("[SOPBlessingCutscenes] " .. tostring(keep)) table.remove(st.ups, i)
			elseif keep == false then table.remove(st.ups, i) end
		end
		if sceneOn and not st.restored then
			local c = workspace.CurrentCamera
			if c then
				c.CameraType = Enum.CameraType.Scriptable
				local sh = CFrame.new()
				if shake > 0.001 then
					local k = shake * (reduced and 0.3 or 1)
					sh = CFrame.Angles(math.noise(t * 31, 1.7) * 0.05 * k, math.noise(t * 29, 5.3) * 0.05 * k, math.noise(t * 23, 9.1) * 0.03 * k)
						* CFrame.new(math.noise(t * 37, 2.2) * 0.3 * k, math.noise(t * 41, 7.7) * 0.3 * k, 0)
				end
				c.CFrame = camCF * sh
				c.FieldOfView = camFov
			end
		end
		if st.avatar and st.avatar.model.Parent then drivePose(st, t) end
		if t > T.hardMax then abort(st) end
	end)
	local function at(t, fn) table.insert(st.events, { t = t, fn = fn }) end
	local function every(fn) table.insert(st.ups, fn) end

	-- abort rules: a round starts, the player dies (a new body in the lobby is not a reason to stop)
	table.insert(st.conns, player:GetAttributeChangedSignal("InRound"):Connect(function()
		if player:GetAttribute("InRound") then abort(st) end
	end))
	local rev = RS:FindFirstChild("RoundUIEvent")
	-- v498 (bug 1): a player who sits the round out because of this cutscene keeps watching it; only being put in the round stops it
	if rev then table.insert(st.conns, rev.OnClientEvent:Connect(function(a) if a == "RoundStart" and player:GetAttribute("InRound") then abort(st) end end)) end
	local function bindDeath(char)
		local h = char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5))
		if h and not st.done then table.insert(st.conns, h.Died:Connect(function() abort(st) end)) end
	end
	bindDeath(player.Character)
	table.insert(st.conns, player.CharacterAdded:Connect(function(c) task.spawn(bindDeath, c) end))

	-- hide the game UI (PanelHud) + Roblox's chat / player list / backpack / emotes / health; the Roblox menu + mic top bar stay
	gui.Enabled = true
	ui.Enabled = true
	st.coreWas = {}
	for _, ct in ipairs({ Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat, Enum.CoreGuiType.Backpack, Enum.CoreGuiType.EmotesMenu, Enum.CoreGuiType.Health }) do
		local ok, was = pcall(function() return StarterGui:GetCoreGuiEnabled(ct) end)
		if ok and was then
			table.insert(st.coreWas, { t = ct, was = was })
			pcall(function() StarterGui:SetCoreGuiEnabled(ct, false) end)
		end
	end
	if hud then local ok = pcall(function() hud:hide() end) st.hudHidden = ok end
	-- stay on top of anything the game pops up mid-cinematic (e.g. the round-end VICTORY panel): our two guis always sit just above the
	-- highest DisplayOrder in PlayerGui (the game's guis themselves are never touched)
	local function stayOnTop()
		local mx = 0
		for _, g in ipairs(pgui:GetChildren()) do
			if g:IsA("ScreenGui") and g ~= gui and g ~= ui and g.Enabled then mx = math.max(mx, g.DisplayOrder) end
		end
		if mx >= gui.DisplayOrder then gui.DisplayOrder = mx + 1 ui.DisplayOrder = mx + 2 end
	end
	pcall(stayOnTop)
	local topT = 0
	every(function(t)
		if t - topT > 0.2 then topT = t pcall(stayOnTop) end
		return true
	end)
	-- guis the game turns ON mid-cinematic (e.g. the round-end VICTORY panel, seen leaking into a recording on v480) are hidden until the
	-- close by hiding their top-level frames (never their Enabled: WinScreenV2 re-asserts Enabled), then every frame gets back the
	-- Visible state the game last asked for. Guis already on at the start are left to PanelHud.
	st.held = {}
	pcall(function()
		local startOn = {}
		for _, g in ipairs(pgui:GetChildren()) do if g:IsA("ScreenGui") and g.Enabled then startOn[g] = true end end
		local function holdObj(o)
			if st.held[o] or st.done or not o:IsA("GuiObject") then return end
			local h = { want = o.Visible, echo = 0 }
			st.held[o] = h
			local function force() if o.Visible then h.echo += 1 o.Visible = false end end
			table.insert(st.conns, o:GetPropertyChangedSignal("Visible"):Connect(function()
				if o.Visible then h.want = true if not st.done then pcall(force) end
				elseif h.echo > 0 then h.echo -= 1
				else h.want = false end
			end))
			force()
		end
		local function watchGui(g)
			if g == gui or g == ui or g.Name == "RollUI" or not g:IsA("ScreenGui") or startOn[g] then return end
			local function sweep() if g.Enabled and not st.done then for _, c in ipairs(g:GetChildren()) do pcall(holdObj, c) end end end
			table.insert(st.conns, g:GetPropertyChangedSignal("Enabled"):Connect(function() pcall(sweep) end))
			table.insert(st.conns, g.ChildAdded:Connect(function(c) if g.Enabled then task.defer(function() pcall(holdObj, c) end) end end))
			sweep()
		end
		for _, g in ipairs(pgui:GetChildren()) do pcall(watchGui, g) end
		table.insert(st.conns, pgui.ChildAdded:Connect(function(g) task.defer(function() pcall(watchGui, g) end) end))
	end)
	local rollGui = pgui:FindFirstChild("RollUI")
	if info.source == "roll" and rollGui and rollGui:IsA("ScreenGui") and rollGui.Enabled then
		st.rollGui = rollGui
		pcall(function() rollGui:SetAttribute("DP_Close", os.clock()) end)
		task.delay(0.6, function() if not st.done and rollGui.Enabled then pcall(function() rollGui.Enabled = false end) end end)
	end
	for _, d in ipairs(st.ducked) do pcall(function() d.g.Volume = d.set end) end
	pcall(function() st.touchWas = GuiService.TouchControlsEnabled GuiService.TouchControlsEnabled = false end)
	pcall(function()
		local ps = player:FindFirstChild("PlayerScripts")
		local pm = ps and ps:FindFirstChild("PlayerModule")
		if pm then
			local controls = require(pm):GetControls()
			if controls then controls:Disable() st.controls = controls end
		end
	end)

	-- ---------- the API a scene module gets ----------
	local E = {
		st = st, scene = scene, T = T, vp = vp, SC = SC, barFrac = barFrac, aspect = aspect, root = root, uiRoot = uiRoot, band = band,
		world = world, center = STAGE, FRONT = FRONT, IMG = IMG, AUDIO = AUDIO, QUAL = QUAL, reduced = reduced, rarity = rarity, ability = ability,
		isNew = info.isNew == true, blackout = blackout, flashFrame = flash, bars = bars, cc = cc, bloom = bloom, blur = blur,
		inst = inst, part = part, tween = tween, lerp = lerp, clamp01 = clamp01, smooth = smooth, sine = sine, easeOut = easeOut, easeIn = easeIn,
		nsk = nsk, cs = cs, cseq = cseq, rnd = rnd, bulk = bulk, emitter = emitter, billboard = billboard, anchorPart = anchorPart, spot = spot,
		pointLight = pointLight, backdrop = backdrop, full = full, text = text, img = img, corner = corner, stroke = stroke, tstroke = tstroke,
		faceOf = faceOf, lockFont = lockFont, textWidth = textWidth, now = now, at = at, every = every, setCam = setCam, setShake = setShake,
		setLight = setLight, lightTo = lightTo, enterWorld = enterWorld, skybox = skybox, PURE = PURE, BLACK = BLACK,
	}
	function E.trash(o) table.insert(st.trash, o) return o end
	function E.setPose(name, dur, style) setPose(st, name, dur, style) end
	function E.partPoint(partName, localPos) return partPoint(st.avatar, partName, localPos) end
	function E.cue(key, vol, from)
		local s = st.bank and st.bank.s[key]
		if not s then return nil end
		pcall(function() if vol then s.Volume = vol end s.TimePosition = from or 0 s:Play() end)
		return s
	end
	-- a white (or coloured) flash that never holds longer than ~2 frames at 60 fps unless asked
	function E.flash(color, hold, fadeOut, peak)
		flash.BackgroundColor3 = color or PURE
		flash.BackgroundTransparency = 1 - (peak or 1)
		local h = math.min(hold or 0.017, 0.034)
		task.delay(h, function() if flash.Parent then tween(flash, math.min(fadeOut or 0.12, 0.15), { BackgroundTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) end end)
	end
	function E.black(transp, dur) if dur and dur > 0 then tween(blackout, dur, { BackgroundTransparency = transp }) else blackout.BackgroundTransparency = transp end end
	function E.overlay(name, z) return full(root, { Name = name or "Overlay", ZIndex = z or 15, BackgroundTransparency = 1 }) end
	-- 3D -> screen (fallback to centre)
	function E.toScreen(pos)
		local c = workspace.CurrentCamera
		local ok, v, on = pcall(function() return c:WorldToViewportPoint(pos) end)
		if ok and v then return Vector2.new(v.X, v.Y), on and v.Z > 0 end
		return vp / 2, false
	end
	st.E = E

	-- the avatar (default R6 placeholder unless the scene names a real one)
	local av = buildAvatar(st, scene)
	E.av = av
	if av then av.hrp.CFrame = CFrame.new(STAGE) end

	-- every sound from the scene's CUES table
	for _, c in ipairs(scene.CUES or {}) do
		if c.id then
			at(c.at, function()
				local s = E.cue(c.key, c.fadeIn and 0 or c.vol, c.from)
				if s and c.fadeIn then tween(s, c.fadeIn, { Volume = c.vol }) end
				if s and c.len then
					task.delay(math.max(c.len - 0.08, 0), function()
						if s.Parent then tween(s, 0.08, { Volume = 0 }) task.delay(0.09, function() pcall(function() s:Stop() end) end) end
					end)
				end
			end)
		end
	end

	-- =================================================================================================================
	-- SHOT 1 - COLD OPEN: true black, the letterbox slides in (the scene may add its own first sign of life)
	-- =================================================================================================================
	at(T.bars, function()
		for _, b in ipairs(bars) do tween(b, 0.35, { Size = UDim2.new(1, 0, barFrac, 0) }, Enum.EasingStyle.Quart) end
	end)
	if scene.coldOpen then scene.coldOpen(E) end

	-- =================================================================================================================
	-- SHOT 2 - QUOTE CARD: the scene's own font, colours, typing style and background layers (the scene's emblem small and faint,
	-- always ABOVE the text block, never over a word)
	-- =================================================================================================================
	local Q = scene.quote
	local quote = full(root, { Name = "Quote", ZIndex = 2, BackgroundColor3 = PURE, BackgroundTransparency = 1 })
	inst("UIGradient", { Rotation = 90, Color = cseq({ { 0, Q.bgTop or BLACK }, { 0.55, Q.bgMid or Q.bgTop or BLACK }, { 1, Q.bgBot or BLACK } }) }, quote)
	E.quote = quote
	local QFONT = Q.font or Enum.Font.Garamond
	local qFace = faceOf(QFONT, Q.weight, Q.style)
	local TRACK = Q.track or 0.1
	local lines = Q.lines
	local function glyphText(c) return Q.upper and string.upper(c) or c end
	local function lineWidth(ln, size)
		local w, n = 0, 0
		for _, ch in utf8.codes(ln) do
			local c = glyphText(utf8.char(ch))
			w += (c == " ") and size * (Q.space or 0.3) or textWidth(c, size, QFONT)
			n += 1
		end
		return w + TRACK * size * math.max(n - 1, 0)
	end
	local base = Q.size or 44
	local qSize = base
	do
		local widest = 0
		for i, ln in ipairs(lines) do widest = math.max(widest, lineWidth(ln, base) * ((Q.lineScale and Q.lineScale[i]) or 1)) end
		qSize = math.floor(math.clamp(base * (vp.X * (Q.widthFrac or 0.84)) / math.max(widest, 1), 15, Q.maxSize or 60))
		qSize = math.min(qSize, math.floor((vp.Y * (1 - 2 * barFrac)) * (0.36 / math.max(#lines, 1))))
	end
	local lineGap = qSize * (Q.lineGap or 1.75)
	local glyphs, words = {}, {}
	local typed = 0
	local mode = Q.mode or "carve"
	local cps = Q.cps or T.cps
	local wordIdx = 0
	local tWord = T.typeStart
	for li, ln in ipairs(lines) do
		local size = math.floor(qSize * ((Q.lineScale and Q.lineScale[li]) or 1))
		local lw = lineWidth(ln, size)
		local y = 0.5 + ((li - 1) - (#lines - 1) / 2) * lineGap / math.max(vp.Y, 1) + (Q.yOffset or 0)
		local holder = inst("Frame", { Name = "QuoteLine" .. li, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, y), Size = UDim2.fromOffset(math.ceil(lw), math.floor(size * 1.4)), ZIndex = 12 }, quote)
		holder:SetAttribute("Text", ln)
		local x = 0
		local chars = {}
		for _, ch in utf8.codes(ln) do table.insert(chars, utf8.char(ch)) end
		local newWord = true
		for k, c in ipairs(chars) do
			local tc
			if mode == "slam" or mode == "tick" then
				if c ~= " " and newWord then
					wordIdx += 1
					tWord = T.typeStart + (wordIdx - 1) * (Q.wordGap or 0.34) + ((li > 1) and (Q.linePause or T.commaPause) * (li - 1) or 0)
					table.insert(words, { t = tWord })
				end
				newWord = (c == " ")
				tc = tWord
			else
				tc = T.typeStart + (typed / cps) + ((li > 1) and (Q.linePause or T.commaPause) * (li - 1) or 0)
			end
			typed += 1
			local g = glyphText(c)
			local cw = (g == " ") and size * (Q.space or 0.3) or textWidth(g, size, QFONT)
			if g ~= " " then
				local sh = nil
				if Q.shadow ~= false then
					sh = text(holder, { Name = "S", Text = g, FontFace = qFace, TextSize = size, TextColor3 = Q.shadowColor or BLACK, TextTransparency = 1,
						Position = UDim2.fromOffset(x + 2, 2), Size = UDim2.fromOffset(math.ceil(cw) + 2, math.floor(size * 1.4)), TextWrapped = false, ZIndex = 12 })
				end
				local gl = text(holder, { Name = "G", Text = g, FontFace = qFace, TextSize = size, TextColor3 = PURE, TextTransparency = 1,
					Position = UDim2.fromOffset(x, 0), Size = UDim2.fromOffset(math.ceil(cw) + 2, math.floor(size * 1.4)), TextWrapped = false, ZIndex = 13 })
				inst("UIGradient", { Rotation = 90, Color = ColorSequence.new(Q.top or PURE, Q.bot or Q.top or PURE) }, gl)
				local strk = nil
				if Q.strokeColor then strk = tstroke(gl, Q.strokeColor, Q.strokeThick or 1.5, 1) end
				table.insert(glyphs, { g = gl, s = sh, k = strk, t = tc, x = x, li = li, done = false, size = size, w = cw })
			end
			x += cw + TRACK * size
		end
		typed += 1
	end
	st.glyphs = glyphs
	local lastGlyph = 0
	for _, g in ipairs(glyphs) do lastGlyph = math.max(lastGlyph, g.t) end
	st.quoteDoneAt = lastGlyph + 0.3
	-- the text block's box (screen px) so a scene's decor never covers a word; the emblem sits above it
	local blockTop = vp.Y * (0.5 + (Q.yOffset or 0)) - ((#lines - 1) * lineGap) / 2 - qSize * 0.7
	local blockBot = vp.Y * (0.5 + (Q.yOffset or 0)) + ((#lines - 1) * lineGap) / 2 + qSize * 0.8
	local blockW = 0
	for i, ln in ipairs(lines) do blockW = math.max(blockW, lineWidth(ln, math.floor(qSize * ((Q.lineScale and Q.lineScale[i]) or 1)))) end
	E.textBox = { top = blockTop, bottom = blockBot, left = vp.X / 2 - blockW / 2, right = vp.X / 2 + blockW / 2, size = qSize }
	st.textBox = E.textBox
	local emblem = nil
	if Q.emblem then
		local gap = math.max(8, qSize * 0.35)
		local topLimit = vp.Y * barFrac + 6
		local emH = math.clamp(blockTop - gap - topLimit, 0, qSize * (Q.emblemScale or 2.0))
		local emCY = blockTop - gap - emH / 2
		local ar = Q.emblemAspect or 1
		emblem = img(quote, Q.emblem, { Name = "Emblem", Position = UDim2.new(0.5, 0, 0, math.floor(emCY)), Size = UDim2.fromOffset(math.floor(emH * ar), math.floor(emH)),
			ImageColor3 = Q.emblemTint or PURE, ImageTransparency = 1, ZIndex = 7, Visible = emH >= 14 })
		st.emblemBox = { y0 = emCY - emH / 2, y1 = emCY + emH / 2, h = emH }
		E.emblem = emblem
	end
	if Q.cursor then -- a blinking block cursor that rides the typing (terminal style)
		E.cursor = inst("Frame", { Name = "Cursor", BackgroundColor3 = Q.cursorColor or Q.top or PURE, BorderSizePixel = 0, ZIndex = 13,
			Size = UDim2.fromOffset(math.max(3, math.floor(qSize * 0.5)), math.floor(qSize * 1.0)), AnchorPoint = Vector2.new(0, 0.5), Visible = false }, quote)
	end
	if scene.quoteDecor then scene.quoteDecor(E, quote) end

	at(T.quote, function()
		quote.BackgroundTransparency = 0
		if emblem then tween(emblem, 1.4, { ImageTransparency = Q.emblemTransp or 0.8 }) end
		blackout.BackgroundTransparency = 1
	end)
	local function glyphTo(g, e)
		g.g.TextTransparency = 1 - e
		if g.s then g.s.TextTransparency = 1 - (Q.shadowAlpha or 0.55) * e end
	end
	every(function(t)
		if t < T.quote then return true end
		if t > T.power + 1 or not quote.Parent then return false end
		if t < T.quoteOut then
			local lastShown = nil
			for _, g in ipairs(glyphs) do
				if t >= g.t then lastShown = g end
				if not g.done and t >= g.t then
					local u
					if mode == "type" then
						u = 1
						glyphTo(g, 1)
					elseif mode == "slam" then
						u = clamp01((t - g.t) / 0.16)
						local e = easeOut(u)
						glyphTo(g, math.min(1, u * 3))
						local s = 1 + 0.9 * (1 - e)
						g.g.TextSize = math.floor(g.size * s)
						g.g.Position = UDim2.fromOffset(g.x - g.w * (s - 1) / 2, -g.size * 0.2 * (s - 1))
						if u >= 1 then g.g.TextSize = g.size g.g.Position = UDim2.fromOffset(g.x, 0) end
					elseif mode == "ignite" then
						u = clamp01((t - g.t) / 0.5)
						glyphTo(g, easeOut(math.min(1, u * 2.5)))
						g.g.TextColor3 = (Q.hot or Color3.fromRGB(255, 236, 190)):Lerp(PURE, smooth(u))
						if g.k then g.k.Transparency = lerp(0.2, 0.75, smooth(u)) end
						g.g.Position = UDim2.fromOffset(g.x, 3 * (1 - easeOut(u)))
					elseif mode == "fade" then
						u = clamp01((t - g.t) / 0.7)
						local e = sine(u)
						glyphTo(g, e)
						g.g.Position = UDim2.fromOffset(g.x, -5 * (1 - e))
						if g.s then g.s.Position = UDim2.fromOffset(g.x + 2, 2 - 5 * (1 - e)) end
					elseif mode == "smoke" then
						u = clamp01((t - g.t) / 0.45)
						local e = easeOut(u)
						glyphTo(g, e)
						g.g.TextColor3 = (Q.smokeColor or Color3.fromRGB(90, 80, 100)):Lerp(PURE, smooth(u))
						g.g.Position = UDim2.fromOffset(g.x + 3 * (1 - e), 6 * (1 - e))
						if g.s then g.s.Position = UDim2.fromOffset(g.x + 2, 2 + 6 * (1 - e)) end
					elseif mode == "tick" then
						u = clamp01((t - g.t) / 0.12)
						glyphTo(g, u >= 1 and 1 or 0.6)
						g.g.Position = UDim2.fromOffset(g.x, -4 * (1 - u))
					else -- carve (Infinity's)
						u = clamp01((t - g.t) / 0.22)
						local e = easeOut(u)
						glyphTo(g, e)
						g.g.Position = UDim2.fromOffset(g.x, 4 * (1 - e))
						if g.s then g.s.Position = UDim2.fromOffset(g.x + 2, 2 + 4 * (1 - e)) end
					end
					if u >= 1 then g.done = true end
				end
			end
			if E.cursor then
				local blink = (math.floor(t * 2.4) % 2 == 0)
				if lastShown and t < st.quoteDoneAt + 0.05 then
					local hp = lastShown.g.Parent
					E.cursor.Visible = true
					pcall(function()
						local qa = quote.AbsolutePosition
						E.cursor.Position = UDim2.fromOffset(hp.AbsolutePosition.X - qa.X + lastShown.x + lastShown.w + qSize * 0.12, hp.AbsolutePosition.Y - qa.Y + hp.AbsoluteSize.Y / 2)
					end)
				elseif lastShown then
					E.cursor.Visible = blink
				else
					E.cursor.Visible = blink and t >= T.quote + 0.2
					E.cursor.Position = UDim2.fromOffset(E.textBox.left, vp.Y * (0.5 + (Q.yOffset or 0)) - ((#lines - 1) * lineGap) / 2)
				end
			end
		end
		if scene.quoteUpdate then scene.quoteUpdate(E, t, t - T.quote) end
		return true
	end)
	at(T.quoteOut, function()
		for _, g in ipairs(glyphs) do
			g.done = true
			tween(g.g, 0.25, { TextTransparency = 1 })
			if g.s then tween(g.s, 0.25, { TextTransparency = 1 }) end
		end
		if emblem then tween(emblem, 0.25, { ImageTransparency = 1 }) end
		if E.cursor then E.cursor.Visible = false end
	end)
	-- the card hands over to the power shot (the scene may do its own exit instead)
	at(T.power, function()
		enterWorld()
		if scene.quoteExit then scene.quoteExit(E, quote)
		else
			tween(quote, 0.5, { BackgroundTransparency = 1 })
			for _, d in ipairs(quote:GetDescendants()) do
				if d:IsA("ImageLabel") then tween(d, 0.5, { ImageTransparency = 1 }) elseif d:IsA("Frame") then tween(d, 0.5, { BackgroundTransparency = 1 }) end
			end
			task.delay(0.6, function() if quote.Parent then quote.Visible = false end end)
		end
	end)

	-- =================================================================================================================
	-- SHOTS 3-5 - the scene's own power-up shot(s) and signature transition (scene.setup schedules them with E.at / E.every)
	-- =================================================================================================================
	if scene.setup then scene.setup(E) end

	-- =================================================================================================================
	-- SHOT 6 - ONE true-black beat
	-- =================================================================================================================
	at(T.black, function()
		blackout.BackgroundTransparency = 0
		flash.BackgroundTransparency = 1
		setShake(0)
		blur.Size = 0
		if scene.onBlack then scene.onBlack(E) end
	end)

	-- =================================================================================================================
	-- SHOT 7 - THE REVEAL (until a tap): the scene builds its set + camera (hero pose, slow push-in that never stops, rising particles);
	-- the UI is Infinity's layout in the scene's own fonts + colours: name banner, NEW! (first time only), BLESSING + rarity tags,
	-- the real ability card (KitAbilities), the speech box with the name plate, Tap to continue (the only exit)
	-- =================================================================================================================
	local rv = nil
	local function buildReveal()
		if rv or st.done then return end
		rv = scene.reveal(E) or {}
		st.rv = rv
		if av then
			av.hrp.CFrame = rv.avatarCF or CFrame.new(STAGE)
			setPose(st, rv.pose or "hero", 0.01)
		end
		if rv.camAt then setCam(rv.camAt(T.reveal)) end
	end
	at(T.black + 0.2, buildReveal)
	at(T.reveal, function()
		buildReveal()
		enterWorld()
		blackout.BackgroundTransparency = 0
		tween(blackout, T.revealFade or 1.3, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
		if rv.start then rv.start(E) end
	end)
	every(function(t, dt)
		if t < T.reveal or not rv then return true end
		local k = t - T.reveal
		if rv.camAt then
			local cf, fov = rv.camAt(t)
			setCam(cf, fov)
		end
		setShake(0)
		if rv.update then rv.update(t, k, dt) end
		return true
	end)

	local U = scene.ui or {}
	local ACC = U.accent or PURE
	local PANEL = U.panel or INK
	local u = {}
	local function scaled(o) inst("UIScale", { Scale = SC }, o) return o end
	at(T.ui, function()
		local banner = scaled(inst("Frame", { Name = "NameBanner", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 40, 0, 16 * SC),
			Size = UDim2.fromOffset(560, 96), BackgroundColor3 = PANEL, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 40 }, band))
		inst("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.35, 0.25), NumberSequenceKeypoint.new(1, 0.1) }) }, banner)
		local edge = inst("Frame", { Name = "Edge", AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1), Size = UDim2.new(0.8, 0, 0, 3),
			BackgroundColor3 = ACC, BorderSizePixel = 0, ZIndex = 41, BackgroundTransparency = 1 }, banner)
		inst("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }, edge)
		local bFace = faceOf(U.bannerFont or Enum.Font.Michroma, U.bannerWeight, U.bannerStyle)
		local bSize = U.bannerSize or 56
		local nameGlow = text(banner, { Name = "NameGlow", Text = scene.name, FontFace = bFace, TextSize = bSize, TextColor3 = U.glow or ACC, TextTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -22, 0.5, 0), Size = UDim2.new(1, -30, 1, 0), TextXAlignment = Enum.TextXAlignment.Right,
			TextWrapped = false, ZIndex = 41 })
		tstroke(nameGlow, U.glow or ACC, 5, 1)
		local name = text(banner, { Name = "Name", Text = scene.name, FontFace = bFace, TextSize = bSize, TextColor3 = PURE, TextTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -22, 0.5, 0), Size = UDim2.new(1, -30, 1, 0), TextXAlignment = Enum.TextXAlignment.Right,
			TextWrapped = false, ZIndex = 42 })
		if U.nameTop then inst("UIGradient", { Rotation = 90, Color = ColorSequence.new(U.nameTop, U.nameBot or U.nameTop) }, name) end
		local nameStroke = tstroke(name, U.nameStroke or ACC, 1.6, 1)
		u.banner, u.name = banner, name
		tween(banner, 0.55, { Position = UDim2.new(1, -24 * SC, 0, 16 * SC), BackgroundTransparency = 0 }, Enum.EasingStyle.Quart)
		tween(edge, 0.6, { BackgroundTransparency = 0.15 })
		tween(name, 0.5, { TextTransparency = 0 })
		tween(nameGlow, 0.7, { TextTransparency = 0.8 })
		tween(nameStroke, 0.6, { Transparency = 0.45 })
		local gs = nameGlow:FindFirstChildOfClass("UIStroke")
		if gs then tween(gs, 0.7, { Transparency = 0.86 }) end
	end)
	at(T.ui + 0.2, function()
		local row = scaled(inst("Frame", { Name = "Tags", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24 * SC, 0, 122 * SC),
			Size = UDim2.fromOffset(440, 42), BackgroundTransparency = 1, ZIndex = 40 }, band))
		inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, row)
		local tagFace = faceOf(U.tagFont or Enum.Font.Michroma)
		local bl = inst("Frame", { Name = "BlessingTag", Size = UDim2.fromOffset(160, 40), BackgroundColor3 = PANEL, BackgroundTransparency = 0.15, LayoutOrder = 1, ZIndex = 41 }, row)
		corner(bl, 8) stroke(bl, PURE, 1.4, 0.45)
		text(bl, { Text = "BLESSING", FontFace = tagFace, TextSize = 17, Size = UDim2.fromScale(1, 1), ZIndex = 42, TextWrapped = false })
		local cols = rarityColors(rarity)
		local rw = math.max(200, math.floor(textWidth(string.upper(rarity), 17, U.tagFont or Enum.Font.Michroma) * 1.3 + (scene.tagIcon and 70 or 40)))
		local my = inst("Frame", { Name = "RarityTag", Size = UDim2.fromOffset(rw, 40), BackgroundColor3 = PURE, BackgroundTransparency = 0, LayoutOrder = 2, ZIndex = 41 }, row)
		corner(my, 8) stroke(my, PURE, 1.4, 0.3)
		inst("UIGradient", { Rotation = 90, Color = cseq({ { 0, cols[1] }, { 0.55, cols[2] }, { 1, cols[3] } }) }, my)
		if scene.tagIcon then
			img(my, scene.tagIcon, { Name = "TagIcon", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.fromOffset(26, 26),
				ImageColor3 = PURE, ImageTransparency = 0.05, ZIndex = 42 })
		end
		local rt = text(my, { Text = string.upper(rarity), FontFace = tagFace, TextSize = 17, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.new(1, scene.tagIcon and -48 or -24, 1, 0), ZIndex = 42, TextWrapped = false, TextXAlignment = scene.tagIcon and Enum.TextXAlignment.Right or Enum.TextXAlignment.Center })
		tstroke(rt, cols[3]:Lerp(BLACK, 0.72), 1.8, 0)
		u.tags, u.rarityTag = row, my
		row.Position = UDim2.new(1, 30, 0, 122 * SC)
		tween(row, 0.45, { Position = UDim2.new(1, -24 * SC, 0, 122 * SC) }, Enum.EasingStyle.Quart)
	end)
	at(T.ui + 0.4, function()
		if not ability.name then return end
		local card = scaled(inst("Frame", { Name = "AbilityCard", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24 * SC, 0, 178 * SC),
			Size = UDim2.fromOffset(470, 132), BackgroundColor3 = PANEL, BackgroundTransparency = 1, ZIndex = 40 }, band))
		corner(card, 12)
		local cst = stroke(card, ACC, 1.5, 1)
		local title = text(card, { Name = "AbilityName", Text = ability.name, Font = U.titleFont or Enum.Font.Sarpanch, TextSize = 32, Size = UDim2.new(1, -150, 0, 40),
			Position = UDim2.fromOffset(20, 12), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 41, TextWrapped = false, TextTransparency = 1, TextScaled = false })
		local cd = text(card, { Name = "Cooldown", Text = ability.cd and (tostring(ability.cd) .. "s cooldown") or "", Font = Enum.Font.GothamBold, TextSize = 17,
			TextColor3 = U.cdColor or ACC, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -18, 0, 22), Size = UDim2.fromOffset(140, 24),
			TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 41, TextTransparency = 1 })
		local desc = text(card, { Name = "AbilityDesc", Text = ability.desc or "", Font = U.descFont or Enum.Font.GothamMedium, TextSize = 19, TextColor3 = Color3.fromRGB(226, 226, 236),
			Size = UDim2.new(1, -40, 0, 70), Position = UDim2.fromOffset(20, 54), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 41, TextTransparency = 1 })
		pcall(function() desc.TextScaled = true end)
		inst("UITextSizeConstraint", { MaxTextSize = 19, MinTextSize = 12 }, desc)
		u.card = card
		tween(card, 0.45, { BackgroundTransparency = 0.22 })
		tween(cst, 0.45, { Transparency = 0.45 })
		for _, l in ipairs({ title, cd, desc }) do tween(l, 0.5, { TextTransparency = 0 }) end
	end)
	at(T.ui + 0.6, function()
		if not info.isNew then return end
		local cols = rarityColors(rarity)
		local stamp = scaled(inst("Frame", { Name = "NewStamp", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 110 * SC, 0, 52 * SC),
			Size = UDim2.fromOffset(150, 62), BackgroundColor3 = PURE, Rotation = -8, ZIndex = 45 }, band))
		corner(stamp, 14) stroke(stamp, PURE, 3, 0)
		inst("UIGradient", { Rotation = 90, Color = ColorSequence.new(cols[1], cols[3]) }, stamp)
		local nt = text(stamp, { Text = "NEW!", Font = Enum.Font.FredokaOne, TextSize = 40, Size = UDim2.fromScale(1, 1), ZIndex = 46, TextWrapped = false })
		tstroke(nt, cols[3]:Lerp(BLACK, 0.6), 2.5, 0)
		local us = stamp:FindFirstChildOfClass("UIScale")
		if us then us.Scale = SC * 1.8 tween(us, 0.28, { Scale = SC }, Enum.EasingStyle.Back) end
		u.stamp = stamp
	end)
	at(T.speech, function()
		local box = scaled(inst("Frame", { Name = "SpeechBox", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14 * SC),
			Size = UDim2.fromOffset(760, 96), BackgroundColor3 = PANEL, BackgroundTransparency = 1, ZIndex = 40 }, band))
		corner(box, 16)
		local bst = stroke(box, ACC, 1.6, 1)
		local tag = inst("Frame", { Name = "Speaker", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(26, 0), Size = UDim2.fromOffset(170, 30),
			BackgroundColor3 = U.plate or ACC, ZIndex = 41, BackgroundTransparency = 1 }, box)
		corner(tag, 8)
		local tagT = text(tag, { Text = scene.speaker or scene.name, Font = U.plateFont or U.bannerFont or Enum.Font.Michroma, TextSize = 16, Size = UDim2.fromScale(1, 1),
			ZIndex = 42, TextTransparency = 1, TextWrapped = false, TextColor3 = U.plateText or PURE })
		local line = text(box, { Name = "Speech", Text = scene.speech, Font = U.speechFont or Enum.Font.GothamBold, TextSize = U.speechSize or 30, Size = UDim2.new(1, -60, 0, 44),
			Position = UDim2.fromOffset(30, 26), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 41, MaxVisibleGraphemes = 0, TextColor3 = U.speechColor or PURE })
		local hint = text(box, { Name = "TapHint", Text = "Tap to continue", Font = Enum.Font.GothamMedium, TextSize = 18, TextColor3 = U.hint or Color3.fromRGB(230, 230, 240),
			AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -18, 1, -8), Size = UDim2.fromOffset(200, 20), TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 41, TextTransparency = 1 })
		u.speech, u.hint = line, hint
		tween(box, 0.35, { BackgroundTransparency = 0.18 })
		tween(bst, 0.35, { Transparency = 0.4 })
		tween(tag, 0.35, { BackgroundTransparency = 0 })
		tween(tagT, 0.35, { TextTransparency = 0 })
		local n = utf8.len(scene.speech) or #scene.speech
		local t0 = now() + 0.25
		every(function(t)
			if not line.Parent then return false end
			local m = math.clamp(math.floor((t - t0) * (U.speechCps or 20)), 0, n)
			line.MaxVisibleGraphemes = m
			if m >= n then hint.TextTransparency = 0.2 + 0.4 * (0.5 + 0.5 * math.sin(t * 3.2)) end
			return true
		end)
	end)

	local function close()
		if st.done then return end
		finish(st, true)
	end
	at(T.tapOk, function()
		local tapper = inst("TextButton", { Name = "TapToClose", Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 70,
			AutoButtonColor = false }, uiRoot)
		lockFont(tapper, faceOf(Enum.Font.GothamBold))
		tapper.Activated:Connect(close)
	end)
	table.insert(st.conns, UIS.InputBegan:Connect(function(input)
		local kc = input.KeyCode
		if kc == Enum.KeyCode.ButtonA or kc == Enum.KeyCode.ButtonB or kc == Enum.KeyCode.Return or kc == Enum.KeyCode.KeypadEnter then
			if now() >= T.tapOk then close() end
		end
	end))
end

-- =====================================================================================================================
-- TRIGGER: the server says this player rolled a cutscene blessing (or an owner typed /cutscene <name>)
-- =====================================================================================================================
local loaded = {}
local function loadScene(name)
	if loaded[name] then return loaded[name] end
	local ms = script:FindFirstChild(name)
	if not (ms and ms:IsA("ModuleScript")) then return nil end
	local ok, sc = pcall(require, ms)
	if ok and type(sc) == "table" then
		sc.key = sc.key or name
		loaded[name] = sc
		return sc
	end
	warn("[SOPBlessingCutscenes] scene " .. tostring(name) .. " failed: " .. tostring(sc))
	return nil
end
local preloadedScenes = {}
local function preload(scene, maxWait)
	if preloadedScenes[scene.key] then return end
	local list = {}
	local function addImg(id) if type(id) == "string" then local im = Instance.new("ImageLabel") im.Image = id table.insert(list, im) end end
	for _, id in pairs(IMG) do addImg(id) end
	for _, id in pairs(scene.IMG or {}) do
		if type(id) == "table" then for _, sid in pairs(id) do addImg(sid) end else addImg(id) end
	end
	local done = false
	task.spawn(function()
		pcall(function() ContentProvider:PreloadAsync(list) end)
		done = true
		preloadedScenes[scene.key] = true
	end)
	local t0 = os.clock()
	while not done and os.clock() - t0 < (maxWait or 0) do task.wait(0.1) end
end
-- wait until the roll machine has shown the result (its ResultName reads "<name>!  ·  ..."), then a beat for its banner
local function waitForRollReveal(name, t0)
	local rollGui = pgui:FindFirstChild("RollUI")
	local label = rollGui and rollGui:FindFirstChild("ResultName", true)
	local before = label and label:IsA("TextLabel") and label.Text or nil
	while os.clock() - t0 < 3.6 do
		if label and label.Parent and label.Text ~= before and string.sub(label.Text, 1, #name + 1) == name .. "!" then break end
		if not (rollGui and rollGui.Enabled) and os.clock() - t0 > 0.5 then break end
		task.wait(0.05)
	end
	task.wait(1.25)
end
-- =====================================================================================================================
-- 2D SCENES (Chronos part 1, v485): a scene with mode = "2D" draws itself full-screen (scene.play2D). Same abort rules, UI hiding,
-- stay-on-top and restore as the 3D scenes; the scene's own "Tap to continue" is the only exit.
-- =====================================================================================================================
local function run2D(info, scene)
	local st = { conns = {}, trash = {}, ups = {}, events = {}, ducked = {}, effectsOff = {}, info = info, done = false, scene = scene }
	S = st
	gui:SetAttribute("Playing", scene.key)
	st.bank = info.bank
	local root = inst("Frame", { Name = "Root", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0, BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0 }, gui)
	st.root = root
	-- abort rules: a round starts, the player dies (a new body in the lobby is not a reason to stop)
	table.insert(st.conns, player:GetAttributeChangedSignal("InRound"):Connect(function()
		if player:GetAttribute("InRound") then abort(st) end
	end))
	local rev = RS:FindFirstChild("RoundUIEvent")
	-- v498 (bug 1): a player who sits the round out because of this cutscene keeps watching it; only being put in the round stops it
	if rev then table.insert(st.conns, rev.OnClientEvent:Connect(function(a) if a == "RoundStart" and player:GetAttribute("InRound") then abort(st) end end)) end
	local function bindDeath(char)
		local h = char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5))
		if h and not st.done then table.insert(st.conns, h.Died:Connect(function() abort(st) end)) end
	end
	bindDeath(player.Character)
	table.insert(st.conns, player.CharacterAdded:Connect(function(c) task.spawn(bindDeath, c) end))

	-- hide the game UI (PanelHud) + Roblox's chat / player list / backpack / emotes / health; the Roblox menu + mic top bar stay
	gui.Enabled = true
	ui.Enabled = true
	st.coreWas = {}
	for _, ct in ipairs({ Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat, Enum.CoreGuiType.Backpack, Enum.CoreGuiType.EmotesMenu, Enum.CoreGuiType.Health }) do
		local ok, was = pcall(function() return StarterGui:GetCoreGuiEnabled(ct) end)
		if ok and was then
			table.insert(st.coreWas, { t = ct, was = was })
			pcall(function() StarterGui:SetCoreGuiEnabled(ct, false) end)
		end
	end
	if hud then local ok = pcall(function() hud:hide() end) st.hudHidden = ok end
	-- stay on top of anything the game pops up mid-cinematic (e.g. the round-end VICTORY panel): our two guis always sit just above the
	-- highest DisplayOrder in PlayerGui (the game's guis themselves are never touched)
	local function stayOnTop()
		local mx = 0
		for _, g in ipairs(pgui:GetChildren()) do
			if g:IsA("ScreenGui") and g ~= gui and g ~= ui and g.Enabled then mx = math.max(mx, g.DisplayOrder) end
		end
		if mx >= gui.DisplayOrder then gui.DisplayOrder = mx + 1 ui.DisplayOrder = mx + 2 end
	end
	pcall(stayOnTop)
	local topT = 0
	table.insert(st.conns, RunService.Heartbeat:Connect(function()
		if os.clock() - topT > 0.2 then topT = os.clock() pcall(stayOnTop) end
	end))
	-- guis the game turns ON mid-cinematic (e.g. the round-end VICTORY panel, seen leaking into a recording on v480) are hidden until the
	-- close by hiding their top-level frames (never their Enabled: WinScreenV2 re-asserts Enabled), then every frame gets back the
	-- Visible state the game last asked for. Guis already on at the start are left to PanelHud.
	st.held = {}
	pcall(function()
		local startOn = {}
		for _, g in ipairs(pgui:GetChildren()) do if g:IsA("ScreenGui") and g.Enabled then startOn[g] = true end end
		local function holdObj(o)
			if st.held[o] or st.done or not o:IsA("GuiObject") then return end
			local h = { want = o.Visible, echo = 0 }
			st.held[o] = h
			local function force() if o.Visible then h.echo += 1 o.Visible = false end end
			table.insert(st.conns, o:GetPropertyChangedSignal("Visible"):Connect(function()
				if o.Visible then h.want = true if not st.done then pcall(force) end
				elseif h.echo > 0 then h.echo -= 1
				else h.want = false end
			end))
			force()
		end
		local function watchGui(g)
			if g == gui or g == ui or g.Name == "RollUI" or not g:IsA("ScreenGui") or startOn[g] then return end
			local function sweep() if g.Enabled and not st.done then for _, c in ipairs(g:GetChildren()) do pcall(holdObj, c) end end end
			table.insert(st.conns, g:GetPropertyChangedSignal("Enabled"):Connect(function() pcall(sweep) end))
			table.insert(st.conns, g.ChildAdded:Connect(function(c) if g.Enabled then task.defer(function() pcall(holdObj, c) end) end end))
			sweep()
		end
		for _, g in ipairs(pgui:GetChildren()) do pcall(watchGui, g) end
		table.insert(st.conns, pgui.ChildAdded:Connect(function(g) task.defer(function() pcall(watchGui, g) end) end))
	end)
	local rollGui = pgui:FindFirstChild("RollUI")
	if info.source == "roll" and rollGui and rollGui:IsA("ScreenGui") and rollGui.Enabled then
		st.rollGui = rollGui
		pcall(function() rollGui:SetAttribute("DP_Close", os.clock()) end)
		task.delay(0.6, function() if not st.done and rollGui.Enabled then pcall(function() rollGui.Enabled = false end) end end)
	end
	for _, d in ipairs(st.ducked) do pcall(function() d.g.Volume = d.set end) end
	pcall(function() st.touchWas = GuiService.TouchControlsEnabled GuiService.TouchControlsEnabled = false end)
	pcall(function()
		local ps = player:FindFirstChild("PlayerScripts")
		local pm = ps and ps:FindFirstChild("PlayerModule")
		if pm then
			local controls = require(pm):GetControls()
			if controls then controls:Disable() st.controls = controls end
		end
	end)

	local ok, err = pcall(scene.play2D, { st = st, root = root, bank = info.bank, lockFont = lockFont, faceOf = faceOf,
		close = function() if not st.done then finish(st, true) end end })
	if not ok then
		warn("[SOPBlessingCutscenes] 2D scene " .. tostring(scene.key) .. " failed: " .. tostring(err))
		abort(st)
	end
end

local waitingInf = false
local function infinityPlaying()
	local g = pgui:FindFirstChild("SOPRollCutscene")
	return g and g:IsA("ScreenGui") and g.Enabled
end

local function start(info)
	if type(info) ~= "table" or type(info.scene) ~= "string" then return end
	local scene = loadScene(info.scene)
	if not scene then return end
	if busy or infinityPlaying() then
		pending = function() start(info) end
		if not busy and not waitingInf then
			-- Infinity's own cutscene is on screen: wait for it to close, then play
			waitingInf = true
			task.spawn(function()
				local t0 = os.clock()
				while infinityPlaying() and os.clock() - t0 < 300 do task.wait(0.5) end
				waitingInf = false
				task.wait(0.6)
				if pending and not busy then local p = pending pending = nil p() end
			end)
		end
		return
	end
	busy = true
	local t0 = os.clock()
	task.spawn(function()
		local ok, err = pcall(function()
			if info.source == "roll" then
				task.spawn(preload, scene, 0)
				waitForRollReveal(info.blessing, t0)
			else
				preload(scene, 2.5)
			end
			if player:GetAttribute("InRound") then busy = false return end
			local bank = makeBank(scene.CUES)
			pcall(function()
				local list = {}
				for _, s in pairs(bank.s) do table.insert(list, s) end
				if #list > 0 then ContentProvider:PreloadAsync(list) end
			end)
			if player:GetAttribute("InRound") then bank.folder:Destroy() busy = false return end
			info.bank = bank
			if scene.mode == "2D" and type(scene.play2D) == "function" then run2D(info, scene) else run(info, scene) end
		end)
		if not ok then
			warn("[SOPBlessingCutscenes] " .. tostring(err))
			if S then abort(S) else busy = false end
		end
	end)
end

local remote = RS:WaitForChild("SOPBlessingCutscene", 60)
if remote then remote.OnClientEvent:Connect(start) end

-- v498 (owner "Fix all of the bugs"):
-- bug 1: while a cutscene is on screen (playing, waiting on Tap to continue, queued, or Infinity's own), tell the server every
-- ~5 s so RoundSystem waits for it / lets this player sit the round out instead of cutting it; say so the moment it closes.
-- bug 3: the mouse cursor is hidden while a cutscene of this script plays (other scripts also set it, so it is re-applied
-- every frame) and put back to what it was when it closes. Infinity's own cutscene script is not touched.
do
	local infRemote = RS:FindFirstChild("SOPRollCutscene")
	local infAt = -100
	if infRemote and infRemote:IsA("RemoteEvent") then infRemote.OnClientEvent:Connect(function() infAt = os.clock() end) end
	local function active()
		return busy or pending ~= nil or S ~= nil or waitingInf or infinityPlaying() or os.clock() - infAt < 12
	end
	if remote then
		task.spawn(function()
			local sent, lastSend = false, 0
			while true do
				local on = active() and true or false
				if on ~= sent or (on and os.clock() - lastSend > 5) then
					sent, lastSend = on, os.clock()
					pcall(function() remote:FireServer("cs", on) end)
				end
				task.wait(0.25)
			end
		end)
	end
	local mouseWas = nil
	RunService.RenderStepped:Connect(function()
		if S and not S.done then
			if mouseWas == nil then mouseWas = UIS.MouseIconEnabled end
			if UIS.MouseIconEnabled then pcall(function() UIS.MouseIconEnabled = false end) end
		elseif mouseWas ~= nil then
			local was = mouseWas
			mouseWas = nil
			pcall(function() UIS.MouseIconEnabled = was end)
		end
	end)
end
