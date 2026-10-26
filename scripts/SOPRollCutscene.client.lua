-- v469 (round 4, helper bot "three fixes" + Tab's v468 review): feed channels into a pulsing core, depth layers (quote + charge),
-- one beam-pillar flash + one ring, a real shard break-apart before the black, lit stones, front-lit calm reveal. Timeline unchanged.
-- SOPRollCutscene (Tab, Oct 24 2026, SOP Test v467): the blessing DRAW CUTSCENE, client half, v3 (round 2 of the owner's brief, (local file) + (notes)). ONLY INFINITY for now.
--   a letterboxed 17.5 s cinematic with its own ORIGINAL score + voice, then the reveal holds until the player taps.
--   Shot 1  0.0-1.0   cold open: true black, letterbox snaps in, sub rumble, one distant star blinks on
--   Shot 2  1.0-7.0   quote card: 3-layer parallax starfield, faint nebula infinity, the quote in Garamond (warm white -> pale gold,
--                     soft drop shadow, wide tracking), carved in at ~18 chars/s with a comma pause, then held 1.5 s
--                     (the brief's own rule: card +0.5 s, black suspense 1.0 s - room for the spoken line when the voice returns)
--   Shot 3  7.0-13.0  the charge: cupped-hands pose, white-magenta wisp ribbons + soft particles spiral into the core (one path),
--                     two thin infinity trails, faceted asteroids for parallax, the camera rotating from behind to the front
--   Shot 4 13.0-14.5  0.3 s of total silence, manga impact frame, varied speed-lines, vertical beam pillars, one shockwave ring,
--                     chunks blast out; one rock flies at the lens
--   Shot 5 14.5-16.5  the crack, 4 stages: white hit frame -> 5 primary cracks spider out -> secondary cracks + light bleeding through
--                     -> the shards drift apart toward the camera as light bursts through the gaps -> cut to black
--   Shot 6 16.5-17.5  true black, one heartbeat, one ember
--   Shot 7 17.5-      reveal: calm hero pose on the floating rock, god rays, rising sparkles, endless push-in; NEW! (first time only),
--                     INFINITY banner, BLESSING + MYTHICAL tags, ability card, speech typed with the spoken line, Tap to continue
-- NO SKIP anywhere: the only exit is Tap to continue on the reveal (aborts on round start / death / leaving still restore everything).
-- The avatar model is used AS-IS (no mesh/material/glow edits): light comes from external lights + VFX; poses are Motor6D.Transform
-- on this client's copy only. Fonts: StarterGui FontEnforcer forces FredokaOne on every label, so every label here re-applies its own
-- FontFace whenever something changes it (lockFont). Audio: 7 original music/SFX cues (Tab, Oct 24 2026), uploaded by the
-- experience's owner so they play here, through this script's own SoundGroup (Game Volume only). Voice lines: slots off for now.
-- Plumbing kept: the server hook (SOPRollCutsceneServer), owner-only /infinitycutscene [old], roll window close/reopen, full restore.
-- To add another blessing later: add it to the server TRIGGERS and give it an entry in SCENES below.
-- ROLLBACK: disable this LocalScript (and ServerScriptService.SOPRollCutsceneServer).

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

local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

local function A(id) return "rbxassetid://" .. tostring(id) end
local IMG = {
	-- v466 art
	sky = A("<ASSET_ID>"), starsMid = A("<ASSET_ID>"), starsDust = A("<ASSET_ID>"), emblem = A("<ASSET_ID>"), infTag = A("<ASSET_ID>"),
	rays = A("<ASSET_ID>"), planet = A("<ASSET_ID>"),
	-- v468: thin crisp glass crack set from ONE geometry (lines and shards line up), 20 glass shards, and the VFX sprites
	-- (white with a thin magenta fringe: energy wisp, beam pillar, burst streak, shock ring, burst rays, manga speed lines)
	c4P0 = A("<ASSET_ID>"), c4P1 = A("<ASSET_ID>"), c4P2 = A("<ASSET_ID>"), c4P3 = A("<ASSET_ID>"), c4P4 = A("<ASSET_ID>"),
	c4SA = A("<ASSET_ID>"), c4SB = A("<ASSET_ID>"), c4Bleed = A("<ASSET_ID>"), c4Crush = A("<ASSET_ID>"),
	wisp = A("<ASSET_ID>"), pillar = A("<ASSET_ID>"), streak = A("<ASSET_ID>"), shock = A("<ASSET_ID>"), burstRays = A("<ASSET_ID>"), manga = A("<ASSET_ID>"),
	-- v469: the shatter's shards (same cells as the crack lines; darker glass, a crisp white rim and a thin magenta outer glow so each
	-- piece reads on its own as it separates), the burst's ring + pillar (white core, thin magenta fringe), the feed-channel texture
	-- (white comets flowing along the channel into the core) and the asteroid silhouettes for the quote card's depth layers
	shards = { c5_sh00 = A("<ASSET_ID>"), c5_sh01 = A("<ASSET_ID>"), c5_sh02 = A("<ASSET_ID>"), c5_sh03 = A("<ASSET_ID>"), c5_sh10 = A("<ASSET_ID>"), c5_sh11 = A("<ASSET_ID>"), c5_sh12 = A("<ASSET_ID>"), c5_sh13 = A("<ASSET_ID>"), c5_sh20 = A("<ASSET_ID>"), c5_sh21 = A("<ASSET_ID>"), c5_sh22 = A("<ASSET_ID>"), c5_sh23 = A("<ASSET_ID>"), c5_sh30 = A("<ASSET_ID>"), c5_sh31 = A("<ASSET_ID>"), c5_sh32 = A("<ASSET_ID>"), c5_sh33 = A("<ASSET_ID>"), c5_sh40 = A("<ASSET_ID>"), c5_sh41 = A("<ASSET_ID>"), c5_sh42 = A("<ASSET_ID>"), c5_sh43 = A("<ASSET_ID>") },
	ring5 = A("<ASSET_ID>"), pillar5 = A("<ASSET_ID>"), feed = A("<ASSET_ID>"),
	rocks2d = { A("<ASSET_ID>"), A("<ASSET_ID>"), A("<ASSET_ID>") }, rocksBlur = { A("<ASSET_ID>"), A("<ASSET_ID>") },
	-- v465 art kept (the shared glow texture, sparkle, starburst, manga speed lines, shock ring, nebula mist)
	glow = A("<ASSET_ID>"), sparkle = A("<ASSET_ID>"), starburst = A("<ASSET_ID>"), speedlines = A("<ASSET_ID>"),
	ring = A("<ASSET_ID>"), mist = A("<ASSET_ID>"),
}
-- ===== THE CUE TABLE: every sound in the cutscene, its asset id, when it starts (seconds from the start) and its volume =====
-- ORIGINAL audio made for this cutscene (Tab, Oct 24 2026), uploaded by the experience owner (the upload API) so it may play here.
-- To swap in new audio: change id / at / vol here and nothing else. id = nil leaves a slot off. Timeline is LOCKED (see T below).
-- The game's own music and wind are ducked for the whole cutscene; everything stops at 13.0 for the 0.3 s silence before the boom.
local CUES = {
	{ key = "open", id = "<ASSET_ID>", at = 0.0, vol = 0.20 }, -- 0-7.3 sub rumble, star ping at 0.45, low drone + celesta motif
	{ key = "voice1", id = nil, at = 1.35, vol = 0.79 }, -- "Throughout the Galaxies and Universe, I alone am the Infinite one" (slot OFF)
	{ key = "charge", id = "<ASSET_ID>", at = 7.0, vol = 0.77 }, -- 7-13 rising pulse, taiko heartbeat from 9.5, riser, hard cut at 13.0
	{ key = "impact", id = "<ASSET_ID>", at = 13.3, vol = 1.0 }, -- boom + glassy hit + debris, the rock's whoosh into the lens
	-- the crack file (2.0 s: impact+cracks 0-0.5, creaks 0.5-1.25, shatter 1.25-2.0) is played in three slices so it follows
	-- the longer v468 crack (14.5-17.2): from = seconds into the file, len = how long the slice plays
	{ key = "crack", id = "<ASSET_ID>", at = 14.5, vol = 1.0, from = 0, len = 1.25 }, -- impact, the 5 primary cracks, first creaks
	{ key = "crackCreak", id = "<ASSET_ID>", at = 15.55, vol = 0.75, from = 0.55, len = 0.7 }, -- more glass stress under the spread
	{ key = "crackShatter", id = "<ASSET_ID>", at = 16.35, vol = 1.0, from = 1.25, len = 0.75 }, -- the slow airy shatter as the shards drift
	{ key = "black", id = "<ASSET_ID>", at = 17.2, vol = 0.56 }, -- 17.2-18.6 the one black beat: one low heartbeat, one fading ember
	{ key = "reveal", id = "<ASSET_ID>", at = 18.6, vol = 0.54 }, -- warm resolve chord, choir pad, sparkle arpeggio
	{ key = "voice2", id = nil, at = 20.65, vol = 0.79 }, -- "The Universe is Infinite." with the speech typing (slot OFF)
	{ key = "loop", id = "<ASSET_ID>", at = 24.6, vol = 0.16, looped = true, fadeIn = 3 }, -- quiet seamless loop under the hold
}
local SILENCE_AT = 13.0 -- every cue stops here (0.3 s of total silence before the boom at 13.3)
local SND, VOL, LOOPED = {}, {}, {}
for _, c in ipairs(CUES) do
	if c.id then SND[c.key] = "rbxassetid://" .. tostring(c.id) VOL[c.key] = c.vol LOOPED[c.key] = c.looped == true end
end

-- palette: the energy is Infinity's own (white light + neon pink-magenta); the environment is deep space navy (never saturated purple)
local PINK = Color3.fromRGB(239, 64, 242)
local MAG = Color3.fromRGB(255, 90, 230)
local LAV = Color3.fromRGB(250, 228, 255)
local PURE = Color3.fromRGB(255, 255, 255)
local STAR = Color3.fromRGB(222, 230, 255)
local NAVY = Color3.fromRGB(5, 7, 20)
local NAVY2 = Color3.fromRGB(10, 13, 34)
local INK = Color3.fromRGB(8, 8, 22)
local ROCK = Color3.fromRGB(44, 42, 56)
local SIL = Color3.fromRGB(11, 11, 19)
local BLACK = Color3.new(0, 0, 0)

local SCENES = {
	Infinity = {
		quote = "Throughout the Galaxies and Universe, I alone am the Infinite one", -- locked text
		quoteLines = { "Throughout the Galaxies and Universe,", "I alone am the Infinite one" }, -- one phrase per line (joined by a space = the quote)
		speech = "The Universe is Infinite.", -- locked text (owner)
		name = "INFINITY",
		rig = "Infinity",
	},
}

-- timeline (seconds from the start). 0-18.6 is the active cinematic; the reveal then holds until a tap. NO skip.
-- v468: the crack runs 14.5-17.2 (2.7 s, four stages), then ONE true-black beat 17.2-18.6 (1.4 s), the reveal at 18.6
local T = {
	bars = 0.05, star = 0.45, quote = 1.0, typeStart = 1.4, cps = 18, commaPause = 0.35, quoteOut = 6.75,
	charge = 7.0, stage2 = 9.5, stage3 = 12.0, cut = 13.0, boom = 13.3, rockGo = 13.7, rockHit = 14.5,
	crack2 = 14.567, crack3 = 15.2, crack4 = 16.35, black = 17.2,
	reveal = 18.6, ui = 19.4, tapOk = 19.7, speech = 20.4, loop = 24.6, hardMax = 240,
}
-- exposure + light (tuning knobs). The white armour must read WHITE: a neutral white key, a NARROW magenta rim from behind,
-- a neutral ambient (round 1's blue-lavender key + wide rim + navy ambient is what turned him lavender)
local LOOK = {
	bloomIntensity = 0.35, bloomSize = 16, bloomThreshold = 1.6,
	ambient = Color3.fromRGB(34, 36, 44), outdoor = Color3.fromRGB(26, 28, 34),
	key = 1.7, keyColor = Color3.fromRGB(255, 248, 240), rim = 1.2, rimColor = Color3.fromRGB(255, 70, 228), rimAngle = 35, rimRange = 10,
	-- v468 charge: the white key is ~2x and never backs off; the core's light is short-range, low and nearly white; the rim is thin
	chargeKey = 3.4, chargeFill = 1.1, chargeRim = 0.55, chargeRimRange = 7, chargeRimAngle = 22,
	coreMax = 0.85, coreRange = 5, coreColor = Color3.fromRGB(255, 226, 250),
	rockLight = 2.4, -- each asteroid's own small light on its core-facing side (lit faces + a white-magenta edge from the core)
}
-- the crack set's placement on a 1024x576 screen canvas (scale coords), impact point at (0.58, 0.43)
local CRACK4 = {
	c4_bleed = { x = 0.00000, y = 0.00000, w = 1.00000, h = 1.00000 },
	c4_crush = { x = 0.52141, y = 0.32583, w = 0.11719, h = 0.20833 },
	c4_p0 = { x = 0.57227, y = 0.41319, w = 0.42773, h = 0.58160 },
	c4_p1 = { x = 0.57031, y = 0.41667, w = 0.11621, h = 0.58333 },
	c4_p2 = { x = 0.13184, y = 0.41493, w = 0.45605, h = 0.58507 },
	c4_p3 = { x = 0.00000, y = 0.13194, w = 0.58789, h = 0.31424 },
	c4_p4 = { x = 0.57129, y = 0.00000, w = 0.16699, h = 0.44444 },
	c4_sa = { x = 0.34766, y = 0.05208, w = 0.41504, h = 0.78819 },
	c4_sb = { x = 0.20801, y = 0.00000, w = 0.79199, h = 1.00000 },
	c4_sh00 = { x = 0.57715, y = 0.42535, w = 0.06641, h = 0.10417, band = 0 },
	c4_sh01 = { x = 0.58594, y = 0.47049, w = 0.10840, h = 0.23611, band = 1 },
	c4_sh02 = { x = 0.61426, y = 0.52778, w = 0.20312, h = 0.46875, band = 2 },
	c4_sh03 = { x = 0.67285, y = 0.69097, w = 0.32715, h = 0.30903, band = 3 },
	c4_sh10 = { x = 0.51758, y = 0.42708, w = 0.07324, h = 0.11458, band = 0 },
	c4_sh11 = { x = 0.46875, y = 0.49132, w = 0.15137, h = 0.21701, band = 1 },
	c4_sh12 = { x = 0.31445, y = 0.53819, w = 0.36426, h = 0.46181, band = 2 },
	c4_sh13 = { x = 0.14062, y = 0.74132, w = 0.53906, h = 0.25868, band = 3 },
	c4_sh20 = { x = 0.50879, y = 0.38194, w = 0.07422, h = 0.11979, band = 0 },
	c4_sh21 = { x = 0.43652, y = 0.33160, w = 0.08691, h = 0.21528, band = 1 },
	c4_sh22 = { x = 0.26270, y = 0.26215, w = 0.21191, h = 0.48958, band = 2 },
	c4_sh23 = { x = 0.00000, y = 0.14583, w = 0.31934, h = 0.85417, band = 3 },
	c4_sh30 = { x = 0.51758, y = 0.31771, w = 0.09277, h = 0.11806, band = 0 },
	c4_sh31 = { x = 0.43652, y = 0.17188, w = 0.22754, h = 0.21875, band = 1 },
	c4_sh32 = { x = 0.26270, y = 0.00000, w = 0.46875, h = 0.34028, band = 2 },
	c4_sh33 = { x = 0.00000, y = 0.00000, w = 0.40723, h = 0.27257, band = 3 },
	c4_sh40 = { x = 0.57812, y = 0.33854, w = 0.07031, h = 0.14236, band = 0 },
	c4_sh41 = { x = 0.60449, y = 0.18229, w = 0.11816, h = 0.35590, band = 1 },
	c4_sh42 = { x = 0.65918, y = 0.00000, w = 0.21680, h = 0.69965, band = 2 },
	c4_sh43 = { x = 0.73926, y = 0.00000, w = 0.26074, h = 0.98090, band = 3 },
}
local IMPACT = Vector2.new(0.58, 0.43)
-- v469: the shatter shards' boxes (each padded so its rim glow fits), same canvas
local CRACK5 = {
	c5_sh00 = { x = 0.57031, y = 0.41319, w = 0.08008, h = 0.12847, band = 0 },
	c5_sh01 = { x = 0.57910, y = 0.45833, w = 0.12207, h = 0.26042, band = 1 },
	c5_sh02 = { x = 0.60742, y = 0.51562, w = 0.21680, h = 0.49306, band = 2 },
	c5_sh03 = { x = 0.66602, y = 0.67882, w = 0.34375, h = 0.33854, band = 3 },
	c5_sh10 = { x = 0.51074, y = 0.41493, w = 0.08691, h = 0.13889, band = 0 },
	c5_sh11 = { x = 0.46191, y = 0.47917, w = 0.16504, h = 0.24132, band = 1 },
	c5_sh12 = { x = 0.30762, y = 0.52604, w = 0.37793, h = 0.49132, band = 2 },
	c5_sh13 = { x = 0.13379, y = 0.72917, w = 0.55273, h = 0.28819, band = 3 },
	c5_sh20 = { x = 0.50195, y = 0.36979, w = 0.08789, h = 0.14410, band = 0 },
	c5_sh21 = { x = 0.42969, y = 0.31944, w = 0.10059, h = 0.23958, band = 1 },
	c5_sh22 = { x = 0.25586, y = 0.25000, w = 0.22559, h = 0.51389, band = 2 },
	c5_sh23 = { x = -0.00977, y = 0.13368, w = 0.33594, h = 0.88368, band = 3 },
	c5_sh30 = { x = 0.51074, y = 0.30556, w = 0.10645, h = 0.14236, band = 0 },
	c5_sh31 = { x = 0.42969, y = 0.15972, w = 0.24121, h = 0.24306, band = 1 },
	c5_sh32 = { x = 0.25586, y = -0.01736, w = 0.48242, h = 0.36979, band = 2 },
	c5_sh33 = { x = -0.00977, y = -0.01736, w = 0.42383, h = 0.30208, band = 3 },
	c5_sh40 = { x = 0.57129, y = 0.32639, w = 0.08398, h = 0.16667, band = 0 },
	c5_sh41 = { x = 0.59766, y = 0.17014, w = 0.13184, h = 0.38021, band = 1 },
	c5_sh42 = { x = 0.65234, y = -0.01736, w = 0.23047, h = 0.72917, band = 2 },
	c5_sh43 = { x = 0.73242, y = -0.01736, w = 0.27734, h = 1.01042, band = 3 },
}

local STAGE = Vector3.new(7600, 3200, 7600) -- far from the map; everything here is local to this client
local HS = 600 -- half size of the far star box
local FRONT = Vector3.new(0, 0, -1) -- the avatar faces -Z

local busy = false
local pending = nil
local S = nil -- the running cutscene's state

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
local RNG = Random.new(466)
local function rnd(a, b) return a + RNG:NextNumber() * (b - a) end
local function lem(t, a) -- the infinity curve (lemniscate of Bernoulli)
	local s, c = math.sin(t), math.cos(t)
	local den = 1 + s * s
	return a * c / den, a * s * c / den
end

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

-- ================= the screen guis =================
-- gui: full-bleed layers (backdrops, flashes, the letterbox bars on top of them). ui: the UI layer, inside the device safe inset,
-- drawn above the bars, so the bars never cover the reveal UI and notches never overlap it.
local gui = inst("ScreenGui", { Name = "SOPRollCutscene", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 2000,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = false })
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
gui:SetAttribute("PanelHudKeep", true)
gui.Parent = pgui
local ui = inst("ScreenGui", { Name = "SOPRollCutsceneUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 2001,
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

-- ================= sounds =================
-- the bank: one Sound per cue, made when a cutscene starts (preloaded), played on its beat, destroyed on close
local function gameVolume()
	local v = player:GetAttribute("GameVolume")
	return (type(v) == "number") and math.clamp(v, 0, 1) or 1
end
local function makeBank()
	local folder = Instance.new("Folder")
	folder.Name = "SOPRollCutsceneAudio"
	local group = Instance.new("SoundGroup")
	group.Name = "SOPRollCutsceneGroup" -- our own group: the game's Effects/Music sliders and its round compressor don't touch it
	group.Volume = gameVolume()
	group.Parent = folder
	local bank = { folder = folder, group = group, s = {} }
	for key, id in pairs(SND) do
		local s = Instance.new("Sound")
		s.Name = key
		s.SoundId = id
		s.Volume = VOL[key] or 0.6
		s.Looped = LOOPED[key] == true
		s.SoundGroup = group
		s.Parent = folder
		bank.s[key] = s
	end
	folder.Parent = SoundService
	return bank
end
local function cue(key, vol, from)
	local st = S
	local s = st and st.bank and st.bank.s[key]
	if not s then return nil end
	pcall(function()
		s.Volume = vol or VOL[key] or 0.6
		s.TimePosition = from or 0
		s:Play()
	end)
	return s
end
local function silenceAll(st, fade)
	if not (st.bank and st.bank.folder) then return end
	for _, s in ipairs(st.bank.folder:GetChildren()) do
		if s:IsA("Sound") then
			if fade and fade > 0 then
				tween(s, fade, { Volume = 0 })
				task.delay(fade + 0.05, function() pcall(function() s:Stop() end) end)
			else
				pcall(function() s:Stop() end)
			end
		end
	end
end
local function audioReport(bank)
	local n, total, lens = 0, 0, {}
	for key, s in pairs(bank.s) do
		total += 1
		local ok = s.IsLoaded and s.TimeLength > 0
		if ok then n += 1 end
		gui:SetAttribute("SOPAudio_" .. key, ok and math.floor(s.TimeLength * 100 + 0.5) / 100 or -1)
		table.insert(lens, key .. "=" .. (ok and string.format("%.2f", s.TimeLength) or "NOT LOADED"))
	end
	table.sort(lens)
	gui:SetAttribute("SOPAudioLoaded", n .. "/" .. total)
	print(string.format("[SOPRollCutscene] audio %d/%d loaded (GameVolume %.2f) %s", n, total, gameVolume(), table.concat(lens, " ")))
	return n, total
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
local function faceOf(font, weight)
	local f = Font.fromEnum(font)
	if weight then pcall(function() f = Font.new(f.Family, weight, f.Style) end) end
	return f
end


-- ================= cleanup / restore =================
local function restoreWorld(st)
	if st.restored then return end
	st.restored = true
	pcall(function() RunService:UnbindFromRenderStep("SOPRollCutscene") end)
	for _, c in ipairs(st.conns) do pcall(function() c:Disconnect() end) end
	st.conns = {}
	for _, o in ipairs(st.trash) do pcall(function() o:Destroy() end) end
	st.trash = {}
	pcall(function() if st.world then st.world:Destroy() end end)
	pcall(function() if st.revealSet then st.revealSet:Destroy() end end)
	pcall(function() if st.bank then for _, s in pairs(st.bank.s) do s:Stop() end st.bank.folder:Destroy() end end)
	st.bank = nil
	-- Roblox's own top bar / chat / player list, exactly as they were
	for _, c in ipairs(st.coreWas or {}) do pcall(function() StarterGui:SetCoreGuiEnabled(c.t, c.was) end) end
	st.coreWas = {}
	-- Lighting properties (only values that are still ours go back) and the Lighting effects we switched off
	if st.light then
		for k, v in pairs(st.light) do pcall(function() if Lighting[k] == st.lightSet[k] then Lighting[k] = v end end) end
		st.light = nil
	end
	for _, e in ipairs(st.effectsOff or {}) do pcall(function() e.o[e.prop] = e.was end) end
	st.effectsOff = {}
	-- game audio
	for _, d in ipairs(st.ducked or {}) do pcall(function() if math.abs(d.g.Volume - d.set) < 1e-3 then d.g.Volume = d.was end end) end
	st.ducked = {}
	-- camera
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
	-- controls
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
	pcall(function() if st.root then st.root:Destroy() end end)
	pcall(function() if st.uiRoot then st.uiRoot:Destroy() end end)
	gui.Enabled = false
	ui.Enabled = false
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

-- ================= world builders =================
-- far layer: a big box of inward-facing star walls (deep navy, cold white stars), slowly turning
local function buildSkyBox(st, parent)
	local faces = {
		{ dir = Vector3.new(1, 0, 0), face = Enum.NormalId.Left, rot = 0 },
		{ dir = Vector3.new(-1, 0, 0), face = Enum.NormalId.Right, rot = 90 },
		{ dir = Vector3.new(0, 0, 1), face = Enum.NormalId.Front, rot = 180 },
		{ dir = Vector3.new(0, 0, -1), face = Enum.NormalId.Back, rot = 270 },
		{ dir = Vector3.new(0, 1, 0), face = Enum.NormalId.Bottom, rot = 0 },
		{ dir = Vector3.new(0, -1, 0), face = Enum.NormalId.Top, rot = 180 },
	}
	st.sky = { parts = {}, offs = {} }
	for _, f in ipairs(faces) do
		local big = HS * 2 + 8
		local size
		if f.dir.X ~= 0 then size = Vector3.new(1, big, big) elseif f.dir.Y ~= 0 then size = Vector3.new(big, 1, big) else size = Vector3.new(big, big, 1) end
		local w = part({ Name = "Sky", Size = size, CFrame = CFrame.new(STAGE + f.dir * HS), Transparency = 1 }, parent)
		local sg = inst("SurfaceGui", { Face = f.face, LightInfluence = 0, SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
			CanvasSize = Vector2.new(1024, 1024), ClipsDescendants = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, w)
		pcall(function() sg.Brightness = 1 end)
		inst("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = NAVY, BorderSizePixel = 0 }, sg)
		inst("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1, Image = IMG.sky, Rotation = f.rot, ZIndex = 2 }, sg)
		table.insert(st.sky.parts, w)
		table.insert(st.sky.offs, CFrame.new(f.dir * HS))
	end
end

-- mid stars + near dust: particles locked to a turning part (cheap: a handful of emitters, re-emitted, never rebuilt)
local function starShell(parent, radius, count, sizeA, sizeB, transp, volume)
	local p = part({ Name = "Stars", Shape = Enum.PartType.Ball, Size = Vector3.new(radius * 2, radius * 2, radius * 2), Transparency = 1,
		CFrame = CFrame.new(STAGE) }, parent)
	local e = inst("ParticleEmitter", {
		Texture = IMG.glow, LightEmission = 1, LightInfluence = 0, Rate = count / 18, Lifetime = NumberRange.new(14, 20),
		Speed = NumberRange.new(0), LockedToPart = true, Shape = Enum.ParticleEmitterShape.Sphere,
		ShapeStyle = volume and Enum.ParticleEmitterShapeStyle.Volume or Enum.ParticleEmitterShapeStyle.Surface,
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, (sizeA + sizeB) / 2, (sizeB - sizeA) / 2), NumberSequenceKeypoint.new(1, (sizeA + sizeB) / 2, (sizeB - sizeA) / 2) }),
		Transparency = nsk({ { 0, 1 }, { 0.06, transp }, { 0.94, transp }, { 1, 1 } }), Color = cs(STAR),
	}, p)
	pcall(function() e.Brightness = 1.3 end)
	pcall(function() e:Emit(count) end)
	return p, e
end

-- a faceted asteroid chunk: blocks + wedges + corner wedges overlapping at random angles (hard facets, never a ball or a cube)
local SHAPES = { "Part", "WedgePart", "CornerWedgePart", "WedgePart", "Part", "CornerWedgePart", "WedgePart" }
local function makeRock(parent, R, color, mat, seed, n)
	local rr = Random.new(seed)
	local function r(a, b) return a + rr:NextNumber() * (b - a) end
	local rock = { parts = {}, offs = {}, R = R }
	for i = 1, n or 6 do
		local cls = SHAPES[((i + seed) % #SHAPES) + 1]
		local sz = Vector3.new(R * r(0.9, 1.6), R * r(0.7, 1.3), R * r(0.9, 1.5))
		local off = CFrame.new(r(-0.35, 0.35) * R, r(-0.3, 0.3) * R, r(-0.35, 0.35) * R) * CFrame.Angles(r(0, 6.28), r(0, 6.28), r(0, 6.28))
		local k = r(0.8, 1.15)
		local c = Color3.new(math.clamp(color.R * k, 0, 1), math.clamp(color.G * k, 0, 1), math.clamp(color.B * k, 0, 1))
		local p = Instance.new(cls)
		p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
		p.Name = "Rock"
		p.Size = sz
		p.Color = c
		p.Material = mat or Enum.Material.Basalt
		p.CFrame = CFrame.new(STAGE - Vector3.new(0, 500, 0))
		p.Parent = parent
		table.insert(rock.parts, p)
		table.insert(rock.offs, off)
	end
	rock.spin = Vector3.new(r(-1, 1), r(-1, 1), r(-1, 1) + 0.01).Unit
	rock.spinRate = r(0.2, 0.7)
	rock.cf = CFrame.new(STAGE - Vector3.new(0, 500, 0))
	return rock
end
local function queueRock(rock, cf, parts, cfs)
	rock.cf = cf
	for i, p in ipairs(rock.parts) do
		table.insert(parts, p)
		table.insert(cfs, cf * rock.offs[i])
	end
end
-- v468: an asteroid reads as a lit, faceted rock: its own small light sits on the side that faces the light source (the core or
-- the blast), so the facing facets catch a white-magenta key and the far side falls off into a rim; plus a faint edge outline
local function litRock(rock, parent, color, bright, edge)
	local holder = part({ Name = "RockLight", Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1, CFrame = CFrame.new(STAGE - Vector3.new(0, 500, 0)) }, parent)
	rock.light = inst("PointLight", { Color = color, Brightness = bright, Range = rock.R * 3.2, Shadows = false }, holder)
	rock.lightP = holder
	if edge then
		local m = inst("Model", { Name = "RockEdge" }, parent)
		for _, p in ipairs(rock.parts) do p.Parent = m end
		rock.model = m
		pcall(function()
			rock.hl = inst("Highlight", { FillTransparency = 1, OutlineColor = Color3.fromRGB(255, 214, 250), OutlineTransparency = edge,
				DepthMode = Enum.HighlightDepthMode.Occluded, Adornee = m }, m)
		end)
	end
	return rock
end
-- put a rock's light between it and the light source
local function aimRockLight(rock, src, parts, cfs)
	if not rock.lightP then return end
	local p = rock.cf.Position
	local d = src - p
	local pos = p + (d.Magnitude > 0.01 and d.Unit or Vector3.new(0, 1, 0)) * (rock.R * 1.5)
	table.insert(parts, rock.lightP)
	table.insert(cfs, CFrame.new(pos))
end
-- v469: an asteroid reads as a LIT STONE, not a grey blob: each facet's colour follows the direction to the light (facets facing it
-- go warm white, facets turned away fall to near black), so the rock has a bright lit face, a dark shadow side and a hard terminator
-- whatever the engine light falloff does on a phone. `amt` 0..1 is how much light reaches it.
local SHADE_DARK = Color3.fromRGB(16, 15, 22)
local function shadeRock(rock, lightPos, lit, amt, dark)
	local cf = rock.cf
	local c = cf.Position
	local L = lightPos - c
	if L.Magnitude < 0.01 then return end
	L = L.Unit
	dark = dark or SHADE_DARK
	for i, p in ipairs(rock.parts) do
		local off = rock.offs[i]
		local o = cf:VectorToWorldSpace(off.Position)
		local n = o.Magnitude > 0.01 and o.Unit or L
		local up = (cf * off).UpVector
		local d = n:Dot(L) * 0.7 + up:Dot(L) * 0.3
		local k = math.clamp(0.42 + 0.75 * d, 0, 1)
		k = k * k * (3 - 2 * k)
		p.Color = dark:Lerp(lit, k * math.clamp(amt, 0, 1))
	end
end
local function setRockVisible(rock, on)
	for _, p in ipairs(rock.parts) do p.Transparency = on and 0 or 1 end
end

-- a pre-built thin trail head (an invisible mover carrying a Trail); moved by CFrame each frame, never rebuilt
local function trailHead(parent, width, life, c0, c1, t0, bright)
	local p = part({ Name = "TrailHead", Size = Vector3.new(0.1, 0.1, 0.1), Transparency = 1, CFrame = CFrame.new(STAGE - Vector3.new(0, 500, 0)) }, parent)
	local a0 = inst("Attachment", { Position = Vector3.new(0, width / 2, 0) }, p)
	local a1 = inst("Attachment", { Position = Vector3.new(0, -width / 2, 0) }, p)
	local tr = inst("Trail", { Attachment0 = a0, Attachment1 = a1, Lifetime = life, MinLength = 0.02, FaceCamera = true, LightEmission = 1,
		LightInfluence = 0, Color = ColorSequence.new(c0, c1), Transparency = nsk({ { 0, t0 or 0.1 }, { 0.7, 0.7 }, { 1, 1 } }),
		WidthScale = nsk({ { 0, 1 }, { 1, 0.15 } }), Enabled = false }, p)
	pcall(function() tr.Brightness = bright or 1.4 end)
	return { p = p, tr = tr }
end

local function emitter(parent, props)
	local e = Instance.new("ParticleEmitter")
	e.Texture = IMG.sparkle
	e.LightEmission = 1
	e.LightInfluence = 0
	e.Rate = 0
	for k, v in pairs(props) do
		local ok = pcall(function() e[k] = v end)
		if not ok then warn("[SOPRollCutscene] emitter prop " .. tostring(k)) end
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

-- the real avatar (as-is), posed locally
local function buildAvatar(st, sceneDef)
	local folder = RS:FindFirstChild("SOPCutsceneRigs") or RS:WaitForChild("SOPCutsceneRigs", 3)
	local src = folder and (folder:FindFirstChild(sceneDef.rig) or folder:WaitForChild(sceneDef.rig, 2))
	if not src then return nil end
	local m = src:Clone()
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
	m:PivotTo(CFrame.new(STAGE))
	m.Parent = st.world
	-- poses are Motor6D.Transform on this client-only copy (no animation assets needed, nothing on the model is edited);
	-- the copy's Animator is removed so nothing else drives the joints
	pcall(function() local an = hum:FindFirstChildOfClass("Animator") if an then an:Destroy() end end)
	local motors = {}
	for _, d in ipairs(m:GetDescendants()) do
		if d:IsA("Motor6D") then motors[d.Name] = { m = d, rot0 = d.C0 - d.C0.Position, cur = CFrame.new() } end
	end
	st.avatar = { model = m, hrp = hrp, hum = hum, motors = motors, pose = "idle",
		ra = m:FindFirstChild("Right Arm"), la = m:FindFirstChild("Left Arm"), torso = m:FindFirstChild("Torso") }
	return st.avatar
end

-- R6 poses, as rotations in the parent part's space (x right, y up, -z forward). A rotation R about the joint becomes
-- Transform = rot0^-1 * R * rot0 (rot0 = the joint's C0 rotation), so poses read the same on any R6 rig.
local POSES = {
	-- hovering idle: arms a little away from the body, one leg trailing
	idle = { ["Right Shoulder"] = { 0.08, 0, 0.16 }, ["Left Shoulder"] = { 0.08, 0, -0.16 }, ["Right Hip"] = { -0.12, 0, 0.03 },
		["Left Hip"] = { 0.1, 0, -0.03 }, Neck = { 0, 0, 0 }, RootJoint = { 0, 0, 0 } },
	-- the charge: both arms forward and in, hands cupped together in front of the chest around the core; head bowed to it
	-- v468: both arms mirror-exact, hands meet ~1 stud apart at chest height 1.45 studs in front of the torso (CORE_LOCAL),
	-- so the core sits BETWEEN both cupped hands, centred on his chest (never at one hand)
	cup = { ["Right Shoulder"] = { 1.30, 0.66, 0 }, ["Left Shoulder"] = { 1.30, -0.66, 0 }, ["Right Hip"] = { -0.14, 0, 0.04 },
		["Left Hip"] = { 0.14, 0, -0.04 }, Neck = { -0.16, 0, 0 }, RootJoint = { 0, 0, 0 } },
	-- the reveal: calm hero pose, chin up, the right hand open and low to the side, the left relaxed, a slight turn
	-- v468 hero: confident and open - the right arm presented out and forward at shoulder height (palm to the world), the left
	-- arm out and slightly back, a wider stance, chin up, chest square to the camera with a slight turn
	-- v469 hero: CALM and confident (v468's raised right arm read as a wave): both arms down and slightly away from the body, the
	-- right a touch further out with the hand open, a planted wide stance, chest square, chin slightly up, the smallest turn
	hero = { ["Right Shoulder"] = { 0.06, 0, 0.3 }, ["Left Shoulder"] = { 0.04, 0, -0.22 }, ["Right Hip"] = { -0.03, 0, 0.11 },
		["Left Hip"] = { 0.03, 0, -0.11 }, Neck = { 0.1, -0.06, 0 }, RootJoint = { 0, 0.08, 0 } },
}
-- the core's place on the torso during the charge (torso space: centred, chest height, in front) = between the cupped hands
local CORE_LOCAL = Vector3.new(0, 0.12, -1.55)
local function poseCF(v) return CFrame.Angles(0, v[2], 0) * CFrame.Angles(v[1], 0, v[3]) end
-- blend toward a pose over `dur` seconds; the per-frame driver adds breathing + sway on top
local function setPose(st, name, dur)
	local av = st.avatar
	if not av then return end
	av.poseFrom = {}
	for k, mo in pairs(av.motors) do av.poseFrom[k] = mo.cur end
	av.pose, av.poseT0, av.poseDur = name, os.clock(), dur or 0.6
end
local function drivePose(st, t)
	local av = st.avatar
	if not av then return end
	local target = POSES[av.pose] or POSES.idle
	local u = math.clamp((os.clock() - (av.poseT0 or 0)) / math.max(av.poseDur or 0.6, 0.01), 0, 1)
	u = u * u * (3 - 2 * u)
	local breath = math.sin(t * 2.2) -- ~3.5 s breathing
	local sway = math.sin(t * 0.7)
	for k, mo in pairs(av.motors) do
		local v = target[k] or { 0, 0, 0 }
		local goal = poseCF(v)
		if k == "Right Shoulder" or k == "Left Shoulder" then
			goal = goal * CFrame.Angles(0.025 * breath, 0, (k == "Right Shoulder" and 1 or -1) * 0.02 * breath)
		elseif k == "Neck" then
			goal = goal * CFrame.Angles(-0.02 * breath, 0.03 * sway, 0)
		elseif k == "RootJoint" then
			goal = goal * CFrame.Angles(0.012 * breath, 0.04 * sway, 0.015 * sway)
		elseif k == "Right Hip" or k == "Left Hip" then
			goal = goal * CFrame.Angles(0.03 * math.sin(t * 1.1 + (k == "Right Hip" and 0 or 1.6)), 0, 0)
		end
		local from = (av.poseFrom and av.poseFrom[k]) or mo.cur
		mo.cur = from:Lerp(goal, u)
		pcall(function() mo.m.Transform = mo.rot0:Inverse() * mo.cur * mo.rot0 end)
	end
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
local function corner(o, r) return inst("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function stroke(o, color, th, tr)
	return inst("UIStroke", { Color = color, Thickness = th, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
end
local function tstroke(o, color, th, tr)
	return inst("UIStroke", { Color = color, Thickness = th, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual }, o)
end
local function textWidth(s, size, font)
	local ok, v = pcall(function() return TextService:GetTextSize(s, size, font, Vector2.new(10000, 1000)).X end)
	return (ok and type(v) == "number") and v or (#s * size * 0.8)
end
local function mythicColors()
	local cols = { Color3.fromRGB(255, 163, 210), Color3.fromRGB(255, 111, 181), Color3.fromRGB(226, 64, 143) } -- SopUI pink (Mythical)
	pcall(function()
		if SopUI and SopUI.cols3 and SopUI.RARITY then
			local c = SopUI.cols3(SopUI.RARITY.MYTHICAL or "pink")
			if type(c) == "table" and typeof(c[1]) == "Color3" then cols = c end
		end
	end)
	return cols
end

-- =====================================================================================================================
-- THE CUTSCENE
-- =====================================================================================================================
local function run(info)
	local sceneDef = SCENES[info.blessing]
	if not sceneDef then busy = false return end
	local st = { conns = {}, trash = {}, ups = {}, events = {}, ducked = {}, effectsOff = {}, info = info, done = false }
	S = st
	local clockStart = os.clock()
	local offset = 0
	local function now() return os.clock() - clockStart + offset end
	local QUAL = 1
	pcall(function() if SopUI and SopUI.lowGfx and SopUI.lowGfx() then QUAL = 0.6 end end)
	local reduced = player:GetAttribute("ReducedMotion") == true

	-- the reveal's data, read from the game's own tables
	local rarity = info.rarity or "MYTHICAL"
	pcall(function()
		local C = require(RS:WaitForChild("BlessingCatalog", 3))
		local b = C.get(info.blessing)
		if b and b.rarity then rarity = b.rarity end
	end)
	local abilityName, abilityDesc, abilityCd = nil, nil, nil
	pcall(function()
		local KA = require(RS:WaitForChild("KitAbilities", 3))
		local d = KA[info.blessing]
		if type(d) == "table" then abilityName, abilityDesc, abilityCd = d.name, d.desc, d.cooldown end
	end)

	-- ---------- the two GUI roots ----------
	local root = inst("Frame", { Name = "Root", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, gui)
	st.root = root
	local uiRoot = inst("Frame", { Name = "UIRoot", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, ui)
	st.uiRoot = uiRoot
	local vp = viewport()
	local aspect = vp.X / math.max(vp.Y, 1)
	local barFrac = aspect >= 2.15 and 0.095 or 0.11 -- tall phones (20:9 and up) get thinner bars
	local barPx = math.floor(vp.Y * barFrac + 0.5)
	st.barFrac = barFrac
	-- full-bleed layer order (ZIndex): backdrops 2-12, quote text 13, manga/flash 15-17, black 18, letterbox bars 20
	local blackout = full(root, { Name = "Black", ZIndex = 18, BackgroundTransparency = 0 })
	local flash = full(root, { Name = "Flash", ZIndex = 17, BackgroundColor3 = PURE, BackgroundTransparency = 1 })
	local bars = {}
	for i = 1, 2 do
		bars[i] = inst("Frame", { Name = i == 1 and "BarTop" or "BarBottom", BackgroundColor3 = BLACK, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0), ZIndex = 20, AnchorPoint = Vector2.new(0, i == 1 and 0 or 1), Position = UDim2.fromScale(0, i == 1 and 0 or 1) }, root)
	end
	st.bars = bars

	-- the middle band between the bars, in the UI layer's own (safe-inset) space
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

	-- NO skip button and no tap-to-skip (the owner, round 2): the cinematic always plays through; Tap to continue on the reveal is the exit

	-- ---------- world / camera / lighting ----------
	local world = inst("Model", { Name = "SOPRollCutsceneStage" }, workspace)
	st.world = world
	-- the sound bank (made + preloaded by start()); the game's own music and wind go quiet while the designed sound plays
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
	-- post effects on the camera (this client only); removed in restoreWorld
	local bloom = inst("BloomEffect", { Name = "SOPRollCutsceneBloom", Intensity = LOOK.bloomIntensity, Size = LOOK.bloomSize,
		Threshold = LOOK.bloomThreshold, Enabled = false }, cam)
	local cc = inst("ColorCorrectionEffect", { Name = "SOPRollCutsceneCC", Brightness = 0, Contrast = 0.06, Saturation = 0,
		TintColor = Color3.fromRGB(246, 247, 255), Enabled = false }, cam)
	local blur = inst("BlurEffect", { Name = "SOPRollCutsceneBlur", Size = 0, Enabled = false }, cam)
	table.insert(st.trash, bloom)
	table.insert(st.trash, cc)
	table.insert(st.trash, blur)
	st.cc = cc

	local camCF = CFrame.lookAt(STAGE + Vector3.new(0, 1, -12), STAGE)
	local camFov = 50
	local shake = 0
	local sceneOn = false
	local function setCam(cf, fov) camCF = cf if fov then camFov = fov end end
	local function setShake(v) shake = v end

	-- one place sets the space lighting; everything it changes is remembered and put back on restore
	local function enterWorld()
		if st.done or sceneOn then return end
		sceneOn = true
		st.light = {}
		st.lightSet = {
			Brightness = 0, Ambient = LOOK.ambient, OutdoorAmbient = LOOK.outdoor, ExposureCompensation = 0,
			ColorShift_Top = BLACK, ColorShift_Bottom = BLACK, FogStart = 100000, FogEnd = 100000,
			EnvironmentDiffuseScale = 0, EnvironmentSpecularScale = 0.1,
		}
		for k, v in pairs(st.lightSet) do
			local ok, was = pcall(function() return Lighting[k] end)
			if ok then
				st.light[k] = was
				pcall(function() Lighting[k] = v end)
				pcall(function() st.lightSet[k] = Lighting[k] end) -- the value as stored (float rounding)
			end
		end
		-- the game's own Lighting effects (its bloom, colour grade, sun rays, blur, depth of field) and sky bodies are switched off
		-- while the cutscene owns the screen, so they never stack with ours; each goes back to exactly what it was
		local function off(o, prop, v)
			local ok, was = pcall(function() return o[prop] end)
			if ok and was ~= v then
				table.insert(st.effectsOff, { o = o, prop = prop, was = was })
				pcall(function() o[prop] = v end)
			end
		end
		for _, e in ipairs(Lighting:GetChildren()) do
			if e:IsA("PostEffect") then off(e, "Enabled", false)
			elseif e:IsA("Sky") then off(e, "CelestialBodiesShown", false)
			elseif e:IsA("Atmosphere") then off(e, "Density", 0) off(e, "Haze", 0) off(e, "Glare", 0) end
		end
		pcall(function()
			local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
			if clouds then off(clouds, "Enabled", false) end
		end)
		bloom.Enabled = true
		cc.Enabled = true
	end
	st.enterWorld = enterWorld

	RunService:BindToRenderStep("SOPRollCutscene", Enum.RenderPriority.Camera.Value + 5, function(dt)
		if st.done then return end
		local t = now()
		for _, ev in ipairs(st.events) do
			if not ev.done and t >= ev.t then
				ev.done = true
				local ok, err = pcall(ev.fn, t)
				if not ok then warn("[SOPRollCutscene] " .. tostring(err)) end
			end
		end
		for i = #st.ups, 1, -1 do
			local u = st.ups[i]
			local ok, keep = pcall(u, t, dt)
			if not ok then warn("[SOPRollCutscene] " .. tostring(keep)) table.remove(st.ups, i)
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

	-- abort rules: a round starts, the player dies, the character is replaced
	table.insert(st.conns, player:GetAttributeChangedSignal("InRound"):Connect(function()
		if player:GetAttribute("InRound") then abort(st) end
	end))
	local rev = RS:FindFirstChild("RoundUIEvent")
	if rev then table.insert(st.conns, rev.OnClientEvent:Connect(function(a) if a == "RoundStart" then abort(st) end end)) end
	local function bindDeath(char)
		local h = char and (char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5))
		if h and not st.done then table.insert(st.conns, h.Died:Connect(function() abort(st) end)) end
	end
	bindDeath(player.Character)
	-- a new body (the blessing morph swaps the character in the lobby) is not a reason to stop; only a death is
	table.insert(st.conns, player.CharacterAdded:Connect(function(c) task.spawn(bindDeath, c) end))

	-- hide the rest of the game UI, close the roll window through its own hook (re-opened at the end), park the controls
	gui.Enabled = true
	ui.Enabled = true
	-- Roblox's own top bar, chat, player list and backpack are hidden for the cinematic and put back exactly as they were
	st.coreWas = {}
	for _, ct in ipairs({ Enum.CoreGuiType.PlayerList, Enum.CoreGuiType.Chat, Enum.CoreGuiType.Backpack, Enum.CoreGuiType.EmotesMenu, Enum.CoreGuiType.Health }) do
		local ok, was = pcall(function() return StarterGui:GetCoreGuiEnabled(ct) end)
		if ok and was then
			table.insert(st.coreWas, { t = ct, was = was })
			pcall(function() StarterGui:SetCoreGuiEnabled(ct, false) end)
		end
	end
	if hud then local ok = pcall(function() hud:hide() end) st.hudHidden = ok end
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

	-- =================================================================================================================
	-- SHOT 1 - COLD OPEN (0-1 s): true black, the letterbox snaps in, a barely audible sub rumble, one distant star blinks on
	-- =================================================================================================================
	-- every sound plays from the one cue table (CUES, top of the script)
	for _, c in ipairs(CUES) do
		if c.id then
			at(c.at, function()
				local s = cue(c.key, c.fadeIn and 0 or c.vol, c.from)
				if s and c.fadeIn then tween(s, c.fadeIn, { Volume = c.vol }) end
				if s and c.len then
					-- a slice of a longer file: fade it out at the end of its slice
					task.delay(math.max(c.len - 0.08, 0), function()
						if s.Parent then tween(s, 0.08, { Volume = 0 }) task.delay(0.09, function() pcall(function() s:Stop() end) end) end
					end)
				end
			end)
		end
	end
	at(T.bars, function()
		for _, b in ipairs(bars) do tween(b, 0.35, { Size = UDim2.new(1, 0, barFrac, 0) }, Enum.EasingStyle.Quart) end
	end)
	local quote = full(root, { Name = "Quote", ZIndex = 2, BackgroundColor3 = NAVY, BackgroundTransparency = 1 })
	st.quote = quote
	local firstStar = inst("ImageLabel", { Name = "FirstStar", BackgroundTransparency = 1, Image = IMG.glow, ImageColor3 = STAR,
		ImageTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.68, 0.33), Size = UDim2.fromOffset(14, 14), ZIndex = 19 }, root)
	at(T.star, function()
		tween(firstStar, 0.25, { ImageTransparency = 0.05, Size = UDim2.fromOffset(18, 18) })
		task.delay(0.3, function() if firstStar.Parent then tween(firstStar, 0.4, { Size = UDim2.fromOffset(11, 11), ImageTransparency = 0.25 }) end end)
	end)

	-- =================================================================================================================
	-- SHOT 2 - QUOTE CARD (1.0-7.0 s): 3 parallax star layers (clearly moving), the small faint nebula infinity, and the quote:
	-- Garamond, warm white -> pale gold, soft dark drop shadow, wide tracking, no glow outline, no magenta. Each letter is carved in
	-- at ~18 characters a second (short pause at the comma), then the line holds >= 1.2 s with only the stars moving.
	-- =================================================================================================================
	inst("UIGradient", { Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(3, 4, 12)),
		ColorSequenceKeypoint.new(0.55, NAVY2), ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 5, 15)) }) }, quote)
	local layers = {}
	local qrocks = {} -- v469 asteroid depth layers (filled once the text block is placed)
	local function starLayer(img, tile, transp, vx, vy, z, zoom)
		local l = inst("ImageLabel", { BackgroundTransparency = 1, Image = img, ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(tile, tile),
			Size = UDim2.new(1, tile * 2, 1, tile * 2), Position = UDim2.fromOffset(-tile, -tile), ImageTransparency = 1, ZIndex = z }, quote)
		table.insert(layers, { l = l, tile = tile, vx = vx, vy = vy, tr = transp, zoom = zoom })
		return l
	end
	-- v469 (helper bot round 4, fix 3): real depth - the layers drift AND push past the camera at different rates (far stars barely,
	-- mid stars more, near dust fast), plus mid asteroid silhouettes and two big soft near rocks (added below, once the text is placed)
	starLayer(IMG.sky, 512, 0.35, -5, -1.5, 3, 0.006) -- far: dense faint stars, almost still
	starLayer(IMG.starsMid, 320, 0.12, -24, -6, 4, 0.03) -- mid
	starLayer(IMG.starsDust, 460, 0.18, -84, -20, 6, 0.075) -- near dust: fast and growing, so the depth reads
	-- the small, faint, nebula-filled infinity behind the text (the right level of presence: keep it subordinate)
	-- v468: it sits ABOVE the text block, centred, small - it never overlaps a word (placed once the text size is known, below)
	local emblem = inst("ImageLabel", { Name = "Emblem", BackgroundTransparency = 1, Image = IMG.emblem, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.3), Size = UDim2.fromOffset(120, 60), ImageTransparency = 1, ZIndex = 7 }, quote)
	-- the energy language starts here: faint white-magenta wisps drifting in toward the centre
	local wisps2d = {}
	for i = 1, 5 do
		local ang = (i / 5) * math.pi * 2 + 0.4
		local w = inst("ImageLabel", { Name = "Wisp", BackgroundTransparency = 1, Image = IMG.glow, ImageColor3 = (i % 2 == 0) and PURE or MAG,
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(math.floor(150 * SC + 60), math.floor(8 * SC + 4)),
			ImageTransparency = 1, Rotation = math.deg(ang), ZIndex = 8 }, quote)
		table.insert(wisps2d, { l = w, ang = ang, r0 = rnd(0.42, 0.55), speed = rnd(0.018, 0.03), ph = rnd(0, 1) })
	end
	-- the quote, letter by letter (tracked type: each glyph its own label so the spacing is generous and even)
	local lines = sceneDef.quoteLines
	local QFONT = Enum.Font.Garamond
	local qFace = faceOf(QFONT)
	local TRACK = 0.12 -- letter spacing, as a fraction of the size
	local function lineWidth(ln, size)
		local w, n = 0, 0
		for _, ch in utf8.codes(ln) do
			local c = utf8.char(ch)
			w += (c == " ") and size * 0.3 or textWidth(c, size, QFONT)
			n += 1
		end
		return w + TRACK * size * math.max(n - 1, 0)
	end
	local qSize = 44
	do
		local widest = 0
		for i, ln in ipairs(lines) do widest = math.max(widest, lineWidth(ln, 44) * (i == 2 and 1.1 or 1)) end
		qSize = math.floor(math.clamp(44 * (vp.X * 0.84) / math.max(widest, 1), 15, 60))
		qSize = math.min(qSize, math.floor((vp.Y * (1 - 2 * barFrac)) * 0.12))
	end
	st.qSize = qSize
	local glyphs = {}
	local typed = 0
	local GOLD_TOP, GOLD_BOT = Color3.fromRGB(255, 247, 232), Color3.fromRGB(236, 208, 152) -- warm white -> pale gold
	for li, ln in ipairs(lines) do
		local size = math.floor(qSize * (li == 2 and 1.1 or 1))
		local lw = lineWidth(ln, size)
		local y = 0.5 + ((li - 1) - (#lines - 1) / 2) * (qSize * 1.75) / math.max(vp.Y, 1)
		local holder = inst("Frame", { Name = "QuoteLine" .. li, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, y), Size = UDim2.fromOffset(math.ceil(lw), math.floor(size * 1.4)), ZIndex = 12 }, quote)
		holder:SetAttribute("Text", ln)
		local x = 0
		local chars = {}
		for _, ch in utf8.codes(ln) do table.insert(chars, utf8.char(ch)) end
		for k, c in ipairs(chars) do
			-- typed at ~18 characters a second across both lines, with a short pause after the comma (the brief's timing math)
			local tc = T.typeStart + (typed / T.cps) + ((li == 2) and T.commaPause or 0)
			typed += 1
			local cw = (c == " ") and size * 0.3 or textWidth(c, size, QFONT)
			if c ~= " " then
				local sh = text(holder, { Name = "S", Text = c, FontFace = qFace, TextSize = size, TextColor3 = BLACK, TextTransparency = 1,
					Position = UDim2.fromOffset(x + 2, 2), Size = UDim2.fromOffset(math.ceil(cw) + 2, math.floor(size * 1.4)), TextWrapped = false, ZIndex = 12 })
				local gl = text(holder, { Name = "G", Text = c, FontFace = qFace, TextSize = size, TextColor3 = PURE, TextTransparency = 1,
					Position = UDim2.fromOffset(x, 0), Size = UDim2.fromOffset(math.ceil(cw) + 2, math.floor(size * 1.4)), TextWrapped = false, ZIndex = 13 })
				inst("UIGradient", { Rotation = 90, Color = ColorSequence.new(GOLD_TOP, GOLD_BOT) }, gl)
				table.insert(glyphs, { g = gl, s = sh, t = tc, x = x, done = false })
			end
			x += cw + TRACK * size
		end
		typed += 1 -- the line break counts as the space between the phrases
	end
	st.glyphs = glyphs
	-- the emblem's box: centred above line 1 with a clear gap, inside the band between the letterbox bars, never over the words
	local emH, emCY
	do
		local blockTop = vp.Y * 0.5 - (qSize * 1.75) / 2 - qSize * 0.7 -- top of line 1's box
		local gap = math.max(8, qSize * 0.35)
		local topLimit = vp.Y * barFrac + 6
		emH = math.clamp(blockTop - gap - topLimit, 0, qSize * 1.9)
		emCY = blockTop - gap - emH / 2
		emblem.Size = UDim2.fromOffset(math.floor(emH * 2), math.floor(emH))
		emblem.Position = UDim2.new(0.5, 0, 0, math.floor(emCY))
		emblem.Visible = emH >= 14 -- too little room (very short screens): no symbol rather than a symbol over the words
		st.emblemBox = { y0 = emCY - emH / 2, y1 = emCY + emH / 2, textTop = blockTop }
	end
	-- v469: the asteroid depth layers (mid: small dark silhouettes with a faint warm/magenta rim; near: two big soft-focus rocks in
	-- the corners). Placed only in the empty bands above / below the text (never over a word, never on the symbol's box)
	qrocks = {}
	do
		local blockTop = st.emblemBox.textTop
		local blockBot = vp.Y * 0.5 + (qSize * 1.75) / 2 + qSize * 1.1 * 0.7 -- bottom of line 2's box
		local top0, top1 = vp.Y * barFrac, blockTop - 4
		local bot0, bot1 = blockBot + 4, vp.Y * (1 - barFrac)
		local emX0, emX1 = vp.X * 0.5 - emH * 1.3 - 20, vp.X * 0.5 + emH * 1.3 + 20
		local function addRock(img, x, y, s, zr, vx, vy, tr, z)
			local l = inst("ImageLabel", { Name = "QRock", BackgroundTransparency = 1, Image = img, AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(s, s), ImageTransparency = 1, ZIndex = z, Rotation = rnd(0, 360) }, quote)
			table.insert(qrocks, { l = l, x0 = x, y0 = y, s = s, zr = zr, vx = vx, vy = vy, tr = tr, rot0 = l.Rotation, spin = rnd(-6, 6) })
		end
		-- mid layer: up to 4 above (left / right of the symbol) and 4 below
		local function band(y0, y1, xs, avoidEmblem)
			local h = y1 - y0
			if h < 22 then return end
			for i, fx in ipairs(xs) do
				local x = vp.X * fx
				if not (avoidEmblem and x > emX0 and x < emX1) then
					local s = math.clamp(h * rnd(0.32, 0.5), 14, 64 * SC + 10)
					local y = y0 + h * rnd(0.35, 0.65)
					addRock(IMG.rocks2d[(i % 3) + 1], x, y, s, rnd(0.018, 0.028), -rnd(8, 14), -rnd(1, 3), rnd(0.18, 0.38), 5)
				end
			end
		end
		band(top0, top1, { 0.08, 0.24, 0.77, 0.93 }, true)
		band(bot0, bot1, { 0.14, 0.37, 0.61, 0.86 }, false)
		-- near layer: two big soft rocks, mostly off-frame in opposite corners, sliding out fast (strong parallax against the stars)
		local big = vp.Y * 0.34
		addRock(IMG.rocksBlur[1], vp.X * 0.1, vp.Y * (1 - barFrac) - big * 0.2, big, 0.03, -12, 6, 0.15, 9)
		addRock(IMG.rocksBlur[2], vp.X * 0.9, vp.Y * barFrac + big * 0.12, big * 0.8, 0.03, 9, -4, 0.15, 9)
		st.qrocks = qrocks
	end
	local lastGlyph = 0
	for _, g in ipairs(glyphs) do lastGlyph = math.max(lastGlyph, g.t) end
	st.quoteDoneAt = lastGlyph + 0.25

	at(T.quote, function()
		quote.BackgroundTransparency = 0
		for _, L in ipairs(layers) do tween(L.l, 0.8, { ImageTransparency = L.tr }) end
		for _, R in ipairs(qrocks) do tween(R.l, 1.0, { ImageTransparency = R.tr }) end
		tween(emblem, 1.4, { ImageTransparency = 0.82 })
		tween(firstStar, 1.0, { ImageTransparency = 0.5 })
		blackout.BackgroundTransparency = 1
	end)
	-- (voice line 1 slot: off for now - the owner rejected the first voice; sound gets its own pass)
	every(function(t)
		if t < T.quote then return true end
		if t > T.charge + 0.05 or not quote.Parent then return false end
		local k = t - T.quote
		for _, L in ipairs(layers) do
			-- v469: each layer scales about the screen centre at its own rate (a slow push through space) while it drifts
			local z = 1 + L.zoom * k
			local ts = L.tile * z
			local x = (k * L.vx * SC) % ts
			local y = (k * L.vy * SC) % ts
			local cx, cy = vp.X / 2, vp.Y / 2
			L.l.TileSize = UDim2.fromOffset(ts, ts)
			L.l.Position = UDim2.fromOffset(cx - (cx + L.tile) * z + x, cy - (cy + L.tile) * z + y)
			L.l.Size = UDim2.fromOffset((vp.X + 2 * L.tile) * z + ts, (vp.Y + 2 * L.tile) * z + ts)
		end
		-- the asteroid layers: they slide outward from the centre (nearer = faster, growing) and drift with the stars; they start in
		-- the empty bands above / below the words and at the corners, and only ever move AWAY from the text block
		for _, R in ipairs(qrocks) do
			local z = 1 + R.zr * k
			local px = vp.X / 2 + (R.x0 - vp.X / 2) * z + R.vx * SC * k
			local py = vp.Y / 2 + (R.y0 - vp.Y / 2) * z + R.vy * SC * k
			R.l.Position = UDim2.fromOffset(px, py)
			R.l.Size = UDim2.fromOffset(R.s * z, R.s * z)
			R.l.Rotation = R.rot0 + R.spin * k
		end
		local bz = 1 + 0.03 * math.sin(k * 0.9) -- a slow breath (shrinking only into its own gap, never over the text)
		emblem.Size = UDim2.fromOffset(math.floor(emH * 2 * bz), math.floor(emH * bz))
		-- carve the letters in: each fades up over 0.22 s and settles 4 px
		if t < T.quoteOut then
			for _, g in ipairs(glyphs) do
				if not g.done and t >= g.t then
					local u = clamp01((t - g.t) / 0.22)
					local e = easeOut(u)
					g.g.TextTransparency = 1 - e
					g.s.TextTransparency = 1 - 0.55 * e
					g.g.Position = UDim2.fromOffset(g.x, 4 * (1 - e))
					g.s.Position = UDim2.fromOffset(g.x + 2, 2 + 4 * (1 - e))
					if u >= 1 then g.done = true end
				end
			end
		end
		-- wisps drift in; in the last beat they rush to the centre (into the next shot)
		local rush = easeIn(clamp01((t - (T.quoteOut - 0.35)) / 0.55))
		for _, w in ipairs(wisps2d) do
			local life = (k * w.speed + w.ph) % 1
			local r = w.r0 * (1 - life * 0.35) * (1 - rush)
			local a = w.ang + life * 0.6
			w.l.Position = UDim2.fromScale(0.5 + math.cos(a) * r * 0.9, 0.5 + math.sin(a) * r * 1.2)
			w.l.Rotation = math.deg(a) + 90
			local fade = math.sin(life * math.pi)
			w.l.ImageTransparency = 1 - (0.28 * fade + 0.5 * rush) * clamp01(k / 1.2)
		end
		return true
	end)
	at(T.quoteOut, function()
		-- v468: no black dip here (the cut has ONE black beat, before the reveal): the words fade, then the card dissolves into space
		for _, g in ipairs(glyphs) do g.done = true tween(g.g, 0.22, { TextTransparency = 1 }) tween(g.s, 0.22, { TextTransparency = 1 }) end
		tween(emblem, 0.22, { ImageTransparency = 1 })
		tween(firstStar, 0.22, { ImageTransparency = 1 })
	end)

	-- =================================================================================================================
	-- the 3D sets are pre-built now (behind the black), so nothing is created mid-shot
	-- =================================================================================================================
	local env = inst("Folder", { Name = "Space" }, world) -- shared by the charge and the reveal: far box, mid stars, near dust, silhouettes
	buildSkyBox(st, env)
	local midShell, midEm = starShell(env, 130, math.floor(60 * QUAL), 0.35, 0.75, 0.15, false)
	local dustShell, dustEm = starShell(env, 30, math.floor(110 * QUAL), 0.1, 0.24, 0.18, true) -- near layer: denser + brighter so it reads
	local spinFar, spinMid, spinDust = 0, 0, 0
	local spinBoost = 0
	-- asteroid silhouettes (black, drifting, for parallax): 2 foreground, the rest behind
	local sils = {}
	local silDefs = {
		{ 20, 6.5, 0.8, 1.4 }, { 21, -5.8, 2.4, 1.1 }, -- foreground: above / below the eye line
		{ 38, 3, 0.4, 3.2 }, { 46, -7, 1.6, 4.5 }, { 55, 9, 2.9, 3.6 }, { 64, -2, 3.9, 6.0 }, { 72, 14, 5.1, 5.2 },
		{ 85, -12, 0.2, 7.5 }, { 95, 4, 4.6, 6.8 },
	}
	-- v469 (helper bot round 4, fix 3): three depth layers that read - the near rocks are lit stones (facet-shaded by the key light) that
	-- slide past fast; the mid silhouettes carry a faint cool rim so they separate from the navy and drift visibly; the far star box
	-- barely moves
	for i, d in ipairs(silDefs) do
		local rock = makeRock(env, d[4], (i <= 2) and Color3.fromRGB(30, 29, 38) or Color3.fromRGB(20, 21, 32), Enum.Material.Basalt, 700 + i, 6)
		if i <= 2 then
			litRock(rock, env, Color3.fromRGB(255, 240, 248), 1.4, 0.55) rock.fg = true
		else
			pcall(function()
				local m = inst("Model", { Name = "SilEdge" }, env)
				for _, p in ipairs(rock.parts) do p.Parent = m end
				inst("Highlight", { FillTransparency = 1, OutlineColor = Color3.fromRGB(196, 206, 255), OutlineTransparency = 0.62,
					DepthMode = Enum.HighlightDepthMode.Occluded, Adornee = m }, m)
			end)
		end
		rock.home = STAGE + Vector3.new(math.cos(d[3]) * d[1], d[2], math.sin(d[3]) * d[1])
		rock.vel = Vector3.new(rnd(-1, 1), rnd(-0.3, 0.3), rnd(-1, 1)).Unit * ((i <= 2) and rnd(1.6, 2.4) or rnd(1.8, 3.2))
		rock.rot = CFrame.Angles(rnd(0, 6), rnd(0, 6), rnd(0, 6))
		rock.push = Vector3.zero
		table.insert(sils, rock)
	end
	local function driftSpace(t, dt, parts, cfs)
		spinFar = spinFar + dt * math.rad(0.35 + spinBoost * 4)
		spinMid = spinMid + dt * math.rad(1.2 + spinBoost * 30)
		spinDust = spinDust - dt * math.rad(4 + spinBoost * 60)
		local farCF = CFrame.new(STAGE) * CFrame.fromAxisAngle(Vector3.new(0.25, 1, 0.15).Unit, spinFar)
		for i, w in ipairs(st.sky.parts) do table.insert(parts, w) table.insert(cfs, farCF * st.sky.offs[i]) end
		table.insert(parts, midShell) table.insert(cfs, CFrame.new(STAGE) * CFrame.fromAxisAngle(Vector3.new(0.1, 1, -0.2).Unit, spinMid))
		table.insert(parts, dustShell) table.insert(cfs, CFrame.new(STAGE) * CFrame.fromAxisAngle(Vector3.new(-0.3, 1, 0.1).Unit, spinDust))
		for _, r in ipairs(sils) do
			r.push = r.push * math.max(0, 1 - dt * 0.6)
			r.home = r.home + (r.vel + r.push) * dt
			queueRock(r, CFrame.new(r.home) * r.rot * CFrame.fromAxisAngle(r.spin, t * 0.25), parts, cfs)
			if r.fg then
				aimRockLight(r, camCF.Position:Lerp(STAGE, 0.3), parts, cfs)
				shadeRock(r, camCF.Position + Vector3.new(-6, 9, 0), Color3.fromRGB(214, 208, 214), 1) -- lit from the camera side, upper left
			end
		end
	end

	-- the space layers drift for the whole cutscene (charge, burst and reveal)
	every(function(t, dt)
		if t < T.charge - 0.1 then return true end
		local parts, cfs = {}, {}
		driftSpace(t, dt, parts, cfs)
		bulk(parts, cfs)
		return true
	end)

	local charge = inst("Folder", { Name = "Charge" }, world)
	local av = buildAvatar(st, sceneDef)
	local center = STAGE
	local function chest() return (av and av.hrp.Position or STAGE) + Vector3.new(0, 0.6, 0) end
	-- v468: the core is centred on his chest, between both cupped hands (a fixed point on the torso, so it never drifts to one hand)
	local function handsPos()
		if av and av.torso and av.torso.Parent then
			local p = av.torso.CFrame:PointToWorldSpace(CORE_LOCAL)
			if (p - chest()).Magnitude < 4 then return p end
		end
		return chest() + FRONT * 1.55 - Vector3.new(0, 0.48, 0)
	end
	-- lights: a dim cool key from the front, magenta rims from behind; the core becomes the hero light
	-- lights: a NEUTRAL WHITE key from front-left above (so the armour reads white), ONE narrow magenta rim behind/above
	-- (edges only); the core then becomes the shot's hero light
	-- v468: the white key ~2x and steady (the armour must read WHITE in the charge as in the reveal), a white fill from the other
	-- front side, the magenta rim thin (narrow cone, short range, low); the core's own light is short-range and nearly white
	local key = spot(charge, center + Vector3.new(-3.2, 4.2, -7.2), center + Vector3.new(0, 0.4, 0), LOOK.keyColor, LOOK.chargeKey, 20, 55)
	local fillL = spot(charge, center + Vector3.new(4.2, 1.4, -6.4), center + Vector3.new(0, 0.5, 0), Color3.fromRGB(246, 246, 255), LOOK.chargeFill, 16, 50)
	local rimA = spot(charge, center + Vector3.new(1.6, 3.4, 5.2), center + Vector3.new(0, 0.8, 0), LOOK.rimColor, LOOK.chargeRim, LOOK.chargeRimRange, LOOK.chargeRimAngle)
	local rimB = spot(charge, center + Vector3.new(-2.4, 1.6, 4.8), center + Vector3.new(0, 0.6, 0), Color3.fromRGB(235, 235, 255), 0.35, 9, 30)
	-- the core (the visual anchor): a tiny white-hot ball, a magenta glow, and the shot's one real light
	local coreP = part({ Name = "Core", Shape = Enum.PartType.Ball, Size = Vector3.new(0.12, 0.12, 0.12), Material = Enum.Material.Neon,
		Color = Color3.fromRGB(255, 236, 252), Transparency = 1, CFrame = CFrame.new(STAGE - Vector3.new(0, 500, 0)) }, charge)
	-- v468: the glow is a pale pink halo (not a magenta card over his chest); the hot white centre carries the brightness
	local coreGlow, coreGlowIm = billboard(coreP, IMG.glow, 1, Color3.fromRGB(255, 196, 246), 1, 1.2)
	local coreHot, coreHotIm = billboard(coreP, IMG.glow, 0.5, PURE, 1, 2.2)
	local coreLight = inst("PointLight", { Color = LOOK.coreColor, Brightness = 0, Range = LOOK.coreRange, Shadows = false }, coreP)
	-- soft particles stream in from a shell around the core and end AT the core (inward), the same path the wisps take
	local suckP = part({ Name = "Suck", Size = Vector3.new(7, 7, 7), Shape = Enum.PartType.Ball, Transparency = 1, CFrame = CFrame.new(STAGE - Vector3.new(0, 500, 0)) }, charge)
	local suck = emitter(suckP, { Texture = IMG.glow, Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface,
		ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward, Speed = NumberRange.new(5.2, 5.8), Lifetime = NumberRange.new(0.6, 0.62),
		Size = nsk({ { 0, 0.32 }, { 1, 0.05 } }), Transparency = nsk({ { 0, 1 }, { 0.25, 0.25 }, { 1, 0.1 } }), Color = cs(PURE, Color3.fromRGB(255, 170, 240)) })
	-- a flare at the core each time a wisp arrives (the energy visibly lands in the core)
	local coreFlare = emitter(coreP, { Texture = IMG.glow, Speed = NumberRange.new(0.2, 0.6), SpreadAngle = Vector2.new(180, 180), Lifetime = NumberRange.new(0.18, 0.3),
		Size = nsk({ { 0, 0.6 }, { 1, 1.4 } }), Transparency = nsk({ { 0, 0.25 }, { 1, 1 } }), Color = cs(PURE, Color3.fromRGB(255, 200, 246)) })
	-- v468 wisps: real wispy energy - a streaky noise-textured ribbon (white core, soft white-magenta edges, broken up along its
	-- length) with a thin hot thread inside, each shedding a stream of soft particles that stay on its path; every wisp spirals
	-- INWARD (well under one turn, the radius falling fast) and ends AT the core, where it flares: one connected path
	local wisps = {}
	for i = 1, 7 do
		local h = trailHead(charge, 0.95, 0.42, PURE, MAG, 0.05, 1.5)
		pcall(function()
			h.tr.Texture = IMG.wisp
			h.tr.TextureMode = Enum.TextureMode.Stretch
			h.tr.WidthScale = nsk({ { 0, 0.35 }, { 0.25, 1 }, { 0.7, 0.55 }, { 1, 0 } })
			h.tr.Transparency = nsk({ { 0, 0.15 }, { 0.5, 0.35 }, { 1, 1 } })
			h.tr.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, PURE), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255, 205, 248)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 232)) })
		end)
		local core2 = inst("Trail", { Attachment0 = h.p:FindFirstChildOfClass("Attachment"), Attachment1 = h.p:GetChildren()[2], Lifetime = 0.22,
			MinLength = 0.02, FaceCamera = true, LightEmission = 1, LightInfluence = 0, Color = cs(PURE), WidthScale = nsk({ { 0, 0.14 }, { 1, 0 } }),
			Transparency = nsk({ { 0, 0.15 }, { 1, 1 } }), Enabled = false }, h.p)
		h.core2 = core2
		h.sparks = emitter(h.p, { Texture = IMG.glow, Rate = 0, Speed = NumberRange.new(0, 0.25), SpreadAngle = Vector2.new(180, 180), Lifetime = NumberRange.new(0.45, 0.8),
			Size = nsk({ { 0, 0.22 }, { 1, 0 } }), Transparency = nsk({ { 0, 0.3 }, { 1, 1 } }), Color = cs(PURE, Color3.fromRGB(255, 160, 238)), Drag = 4 })
		h.active = false
		table.insert(wisps, h)
	end
	-- v469 (helper bot round 4, fix 2): ONE energy path into the core. Every wisp rides its own fixed FEED CHANNEL - a soft tapered beam
	-- that starts wide and faint out in space, curves in, narrows and brightens, and terminates INSIDE the chest core, with white comets
	-- flowing along it toward the core (texture flow, nothing rebuilt). The wisp head races down that same curve and lands in the core,
	-- and the core PULSES brighter each time it is fed. No orbiting rings: nothing circles him, everything goes into him.
	local feeds = {}
	local coreAtt = inst("Attachment", { Name = "FeedEnd" }, coreP)
	for i = 1, 7 do
		local outer = part({ Name = "FeedStart", Size = Vector3.new(0.1, 0.1, 0.1), Transparency = 1, CFrame = CFrame.new(STAGE - Vector3.new(0, 500, 0)) }, charge)
		local a0 = inst("Attachment", { Name = "FeedStart" }, outer)
		local bm = inst("Beam", { Attachment0 = a0, Attachment1 = coreAtt, Texture = IMG.feed, TextureMode = Enum.TextureMode.Wrap, TextureLength = 2.4,
			TextureSpeed = 1.2, LightEmission = 1, LightInfluence = 0, FaceCamera = true, Segments = 18, Width0 = 0, Width1 = 0, CurveSize0 = 0, CurveSize1 = 0,
			Enabled = false, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 232)),
				ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255, 218, 250)), ColorSequenceKeypoint.new(1, PURE) }),
			Transparency = nsk({ { 0, 1 }, { 0.15, 0.72 }, { 0.65, 0.38 }, { 1, 0.08 } }) }, outer)
		pcall(function() bm.Brightness = 1.6 end)
		local ang = (i / 7) * math.pi * 2 + rnd(-0.25, 0.25)
		local r0 = rnd(5.4, 7.4)
		local h0 = ({ 2.6, -1.8, 1.2, -2.6, 2.9, -0.6, 0.4 })[i]
		local sgn = (i % 2 == 0) and -1 or 1
		table.insert(feeds, { p = outer, beam = bm, ang = ang, r0 = r0, h0 = h0, sgn = sgn, w = 0, on = false })
	end
	-- the channel's curve (a Bezier with CurveSize1 = 0, exactly the curve the Beam draws): P0 out in space, P1 = P0 + tangent * c0,
	-- P2 = P3 = the core
	local function feedFrame(f, cp, t)
		local a = f.ang + (t - T.charge) * 0.06 * f.sgn -- the channels sweep very slowly (alive, never orbiting)
		local radial = Vector3.new(math.cos(a), 0, math.sin(a))
		local p0 = cp + radial * f.r0 + Vector3.new(0, f.h0, 0)
		local tangent = Vector3.new(-radial.Z, 0, radial.X) * f.sgn
		local inward = (cp - p0).Unit
		local tdir = (tangent * 0.85 + inward * 0.35).Unit
		f.p0, f.tdir, f.c0 = p0, tdir, f.r0 * 0.6
		local z = tdir:Cross(Vector3.new(0, 1, 0))
		if z.Magnitude < 0.1 then z = tdir:Cross(Vector3.new(1, 0, 0)) end
		local up = z.Unit:Cross(tdir).Unit
		return CFrame.fromMatrix(p0, tdir, up) -- the attachment's axis (X) = the curve's start tangent

	end
	local function feedPoint(f, cp, p)
		local P0, P1 = f.p0, f.p0 + f.tdir * f.c0
		local q = 1 - p
		return P0 * (q * q * q) + P1 * (3 * q * q * p) + cp * (3 * q * p * p + p * p * p)
	end
	for i, w in ipairs(wisps) do w.feed = feeds[i] end
	local function respawnWisp(w, t)
		w.t0 = t
	end
	local corePulse = 0 -- jumps each time a wisp lands in the core, decays fast: the core visibly gulps the energy
	-- (round 4: no orbiting infinity trail any more - it read as decoration circling him)
	local rings = {}
	-- the debris pool: 7 asteroid chunks + 6 small chips; they lift and orbit in stage 2 and are the chunks the burst throws
	local chunks = {}
	for i = 1, 7 do
		local R = (i == 1) and 0.95 or rnd(0.45, 0.85)
		local rock = makeRock(charge, R, Color3.fromRGB(82, 78, 92), Enum.Material.Slate, 900 + i, 6)
		litRock(rock, charge, Color3.fromRGB(255, 226, 250), 0, 0.42) -- v469: a clearer white-magenta edge
		rock.orbitR = rnd(4.2, 6.4)
		rock.orbitH = rnd(-1.6, 2.4)
		rock.ang = (i / 7) * math.pi * 2
		rock.w = rnd(0.35, 0.6)
		rock.rot = CFrame.Angles(rnd(0, 6), rnd(0, 6), rnd(0, 6))
		table.insert(chunks, rock)
	end
	for i = 1, 6 do
		local R = rnd(0.16, 0.3)
		local rock = makeRock(charge, R, Color3.fromRGB(96, 92, 106), Enum.Material.Slate, 950 + i, 3)
		rock.orbitR = rnd(3.2, 5.2)
		rock.orbitH = rnd(-2.2, 2.8)
		rock.ang = rnd(0, 6.28)
		rock.w = rnd(0.5, 0.9)
		rock.rot = CFrame.Angles(rnd(0, 6), rnd(0, 6), rnd(0, 6))
		rock.chip = true
		table.insert(chunks, rock)
	end
	st.chunks = chunks

	-- =================================================================================================================
	-- SHOT 3 - THE CHARGE (6.5-12.5 s): stage 1 wisps + core ignition, stage 2 debris lifts + real light, stage 3 contraction + shake
	-- =================================================================================================================
	local coreSize, coreBright = 0.12, 0
	local camState = { theta = 190, d = 15, h = -3.4, fov = 52 }
	at(T.charge, function()
		enterWorld()
		-- v468: no black dip - the quote card dissolves straight into space (the one black beat is the one before the reveal)
		blackout.BackgroundTransparency = 1
		tween(quote, 0.5, { BackgroundTransparency = 1 })
		for _, L in ipairs(layers) do tween(L.l, 0.45, { ImageTransparency = 1 }) end
		for _, R in ipairs(qrocks) do tween(R.l, 0.45, { ImageTransparency = 1 }) end
		for _, w in ipairs(wisps2d) do tween(w.l, 0.3, { ImageTransparency = 1 }) end
		task.delay(0.55, function() if quote.Parent then quote.Visible = false end end)
		setPose(st, "cup", 0.9) -- hands come together in front of the chest, around the core
		coreP.Transparency = 0.05
		for _, w in ipairs(wisps) do respawnWisp(w, T.charge + rnd(-1.2, 0)) end
		suck.Rate = 10 * QUAL
	end)
	at(T.stage2, function()
		suck.Rate = 22 * QUAL
		for _, c in ipairs(chunks) do c.lift0 = T.stage2 + rnd(0, 0.6) end
	end)
	at(T.stage3, function()
		suck.Rate = 40 * QUAL
		suck.Speed = NumberRange.new(9, 10)
		suck.Lifetime = NumberRange.new(0.5, 0.55)
	end)

	every(function(t, dt)
		if st.chargeCleared then return false end
		if t < T.charge then return true end
		local parts, cfs = {}, {}
		local u = clamp01((t - T.charge) / (T.cut - T.charge))
		local frozen = t >= T.cut and t < T.boom -- the held breath before the boom: everything stops
		if t >= T.boom then
			if av then av.hrp.CFrame = CFrame.new(center + Vector3.new(0, math.sin((t - T.charge) * 1.6) * 0.12, 0)) end
			return true -- the burst owns the core, the trails and the chunks from here
		end
		-- him: calm, hovering, composed
		if av and not frozen then
			av.hrp.CFrame = CFrame.new(center + Vector3.new(0, math.sin((t - T.charge) * 1.6) * 0.12, 0))
		end
		-- the core grows in three stages
		local target
		if t < T.stage2 then target = lerp(0.12, 0.38, smooth((t - T.charge) / 2.5))
		elseif t < T.stage3 then target = lerp(0.38, 0.62, smooth((t - T.stage2) / 2.5))
		else target = lerp(0.62, 0.95, smooth((t - T.stage3) / 1.0)) end
		local cm = LOOK.coreMax
		local bright = (t < T.stage2) and lerp(0.15, 0.4, smooth((t - T.charge) / 2.5)) * cm or ((t < T.stage3) and lerp(0.4, 0.75, smooth((t - T.stage2) / 1.5)) * cm or lerp(0.75, 1, smooth((t - T.stage3) / 1)) * cm)
		if frozen then target = 0.22 bright = 1.0 end
		coreSize = lerp(coreSize, target, math.min(1, dt * 6))
		coreBright = lerp(coreBright, bright, math.min(1, dt * 5))
		local pulse = 1 + 0.07 * math.sin(t * 9) * (frozen and 0 or 1)
		local cp = handsPos()
		table.insert(parts, coreP) table.insert(cfs, CFrame.new(cp))
		coreP.Size = Vector3.new(coreSize, coreSize, coreSize) * pulse
		coreGlow.Size = UDim2.fromScale(coreSize * 3.4 * pulse, coreSize * 3.4 * pulse)
		coreGlowIm.ImageTransparency = lerp(0.75, 0.42, u)
		coreHot.Size = UDim2.fromScale(coreSize * 2.6, coreSize * 2.6)
		coreHotIm.ImageTransparency = lerp(0.45, 0.0, u)
		coreLight.Brightness = coreBright
		coreLight.Range = lerp(LOOK.coreRange * 0.7, LOOK.coreRange, u)
		table.insert(parts, suckP) table.insert(cfs, CFrame.new(cp))
		pcall(function() suck.TimeScale = frozen and 0 or 1 end)
		-- the feed channels + the wisps riding them into the core (more channels, faster flow, each stage)
		local nActive = (t < T.stage2) and 3 or ((t < T.stage3) and 5 or 7)
		local dur = (t < T.stage2) and 1.7 or ((t < T.stage3) and 1.25 or 0.8)
		local flow = (t < T.stage2) and 1.2 or ((t < T.stage3) and 1.9 or 3.2)
		corePulse = corePulse * math.exp(-dt * 6)
		for i, w in ipairs(wisps) do
			local f = w.feed
			local on = i <= nActive and t < T.cut
			-- the channel: follows the core, fades in when its stage starts (width), stays put through the held breath
			if on or frozen then
				table.insert(parts, f.p) table.insert(cfs, feedFrame(f, cp, t))
				f.beam.CurveSize0 = f.c0
			end
			if on and not f.on then
				f.on = true
				f.beam.Enabled = true
				f.beam.Width0, f.beam.Width1 = 0, 0
				tween(f.beam, 0.5, { Width0 = 0.8, Width1 = 0.12 })
			end
			if f.on then f.beam.TextureSpeed = frozen and 0 or flow end
			if on and not frozen then
				local p = (t - (w.t0 or t)) / dur
				if p >= 1 then
					respawnWisp(w, t) p = 0 w.clear = true
					corePulse = math.min(1.5, corePulse + 0.75) -- it lands IN the core: the core flares
					pcall(function() coreFlare:Emit(3) end)
				end
				local pos = feedPoint(f, cp, math.max(p, 0) ^ 1.25)
				table.insert(parts, w.p) table.insert(cfs, CFrame.new(pos))
				if w.clear then w.clear = false pcall(function() w.tr:Clear() w.core2:Clear() end) end
				w.tr.Enabled = true
				w.core2.Enabled = true
				w.sparks.Rate = 30 * QUAL
			else
				w.tr.Enabled = false
				w.core2.Enabled = false
				w.sparks.Rate = 0
			end
		end
		-- the core pulses as it is fed (on top of the stage growth)
		local pz = 1 + 0.35 * corePulse
		coreP.Size = coreP.Size * pz
		coreHot.Size = UDim2.fromScale(coreSize * 2.6 * (1 + 0.9 * corePulse), coreSize * 2.6 * (1 + 0.9 * corePulse))
		coreGlow.Size = UDim2.fromScale(coreSize * 3.4 * pulse * (1 + 0.45 * corePulse), coreSize * 3.4 * pulse * (1 + 0.45 * corePulse))
		coreHotIm.ImageTransparency = math.max(0, lerp(0.45, 0.0, u) - 0.25 * corePulse)
		coreLight.Brightness = coreBright * (1 + 0.6 * corePulse)
		-- debris: lifts from below in stage 2 and orbits; stage 3 tightens and speeds up
		for _, c in ipairs(chunks) do
			if t >= T.boom then
				-- the burst owns the chunks from here
			elseif c.lift0 and t >= c.lift0 and not frozen then
				local lift = easeOut((t - c.lift0) / 1.3)
				local tight = (t < T.stage3) and 1 or lerp(1, 0.82, smooth((t - T.stage3) / 1.0))
				c.ang = c.ang + dt * c.w * ((t < T.stage3) and 1 or 2.3)
				local pos = center + Vector3.new(math.cos(c.ang) * c.orbitR * tight, lerp(-7, c.orbitH, lift), math.sin(c.ang) * c.orbitR * tight)
				queueRock(c, CFrame.new(pos) * c.rot * CFrame.fromAxisAngle(c.spin, t * c.spinRate * 2), parts, cfs)
				local litAmt = clamp01(coreBright / math.max(LOOK.coreMax, 0.01)) * lift
				if c.light then
					-- lit by the core: its light sits on the core-facing side and grows with the charge
					aimRockLight(c, cp, parts, cfs)
					c.light.Brightness = LOOK.rockLight * litAmt
				end
				-- v469: facet-shaded from the core - a bright warm-white face toward the core, a dark shadow side (a lit stone, not a blob)
				shadeRock(c, cp, Color3.fromRGB(244, 234, 242), 0.55 + 0.45 * litAmt)
			elseif not c.lift0 then
				queueRock(c, CFrame.new(center - Vector3.new(0, 60, 0)), parts, cfs)
			end
		end
		bulk(parts, cfs)
		-- camera: low behind him, orbiting up into a hero angle with a gentle push-in across all 6 seconds
		if not frozen and t < T.boom then
			-- v468: still back -> front, but it leaves his back fast (side by ~1.8 s, front 3/4 by ~3 s) and the last half of the
			-- charge holds on his FRONT and face, ending almost square on, at chest height, before the burst
			local e = 1 - (1 - u) ^ 2.4
			camState.theta = 190 - 184 * e
			camState.d = 15 - 5.6 * e
			camState.h = -3.4 + 3.6 * e
			camState.fov = 52 - 6 * e
			local th = math.rad(camState.theta)
			local look = chest():Lerp(cp, 0.2) + Vector3.new(0, 0.3 * e, 0)
			local pos = center + Vector3.new(math.sin(th) * camState.d, camState.h + 0.6, -math.cos(th) * camState.d)
			setCam(CFrame.lookAt(pos, look), camState.fov)
			setShake(t >= T.stage3 and lerp(0.05, 0.4, smooth((t - T.stage3) / 1.0)) or 0)
			-- v468: the white key stays strong the whole charge (it no longer backs off as the core grows)
			key.Brightness = LOOK.chargeKey
		elseif frozen then
			setShake(0)
		end
		return true
	end)

	-- =================================================================================================================
	-- SHOT 4 - THE BURST (13.0-14.5 s): the music cuts, 0.3 s of total silence, the 2-frame manga impact frame, then varied speed-lines,
	-- vertical beam pillars and ONE expanding shockwave ring (white core, magenta fringe) behind him - he stays a calm dark silhouette
	-- at the centre - chunks blast out, and one rock flies at the lens
	-- =================================================================================================================
	local blast = inst("Folder", { Name = "Blast" }, charge)
	local blastLight
	at(SILENCE_AT, function()
		silenceAll(st) -- the riser cuts: total silence
		for _, d in ipairs(st.ducked) do pcall(function() d.g.Volume = d.set end) end
		suck.Rate = 0
		for _, r in ipairs(rings) do r.tr.Enabled = false end
	end)
	-- pre-built burst layers. v468: vertical beam PILLARS with a real pillar texture (white core, thin magenta fringe, solid along
	-- the length so they read), a pool of 2D speed-lines (tapered streak sprite, mostly white, varied lengths/widths/opacities/
	-- speeds, dark space between them), ONE screen-space shockwave ring (a true circle: thin white core, magenta fringe)
	local pillars = {}
	do
		-- { x, z offset from him, width, delay, life }
		-- v469 (helper bot round 4, fix 3): ONE big beam-pillar flash straight up through him (it owns the beat) + two thin satellites
		local defs = { { 0, 0.8, 5.2, 0.04, 0.8 }, { 3.4, 1.6, 0.55, 0.1, 0.45 }, { -3.6, 1.2, 0.6, 0.13, 0.48 } }
		for _, d in ipairs(defs) do
			local base = center + Vector3.new(d[1], 0, d[2])
			local pa = anchorPart(blast, base - Vector3.new(0, 40, 0), "PillarLo")
			local pb = anchorPart(blast, base + Vector3.new(0, 60, 0), "PillarHi")
			local a0 = inst("Attachment", {}, pa)
			local a1 = inst("Attachment", {}, pb)
			local beam = inst("Beam", { Attachment0 = a0, Attachment1 = a1, Texture = IMG.pillar5, TextureMode = Enum.TextureMode.Stretch, TextureLength = 1,
				LightEmission = 1, LightInfluence = 0, FaceCamera = true, Width0 = 0, Width1 = 0, Segments = 1, Enabled = false, Color = cs(PURE),
				Transparency = nsk({ { 0, 1 }, { 0.22, 0.05 }, { 0.78, 0.05 }, { 1, 1 } }) }, pa)
			pcall(function() beam.Brightness = 2.6 end)
			table.insert(pillars, { beam = beam, w = d[3], delay = d[4], life = d[5] })
		end
	end
	local speedLines = {}
	local PALE = Color3.fromRGB(255, 214, 248)
	for i = 1, math.floor(40 * math.max(QUAL, 0.7)) do
		local l = inst("ImageLabel", { Name = "SpeedLine", BackgroundTransparency = 1, Image = IMG.streak, AnchorPoint = Vector2.new(0, 0.5),
			ImageColor3 = (i % 6 == 0) and PALE or PURE, ImageTransparency = 1, ZIndex = 14, Size = UDim2.fromOffset(10, 4) }, root)
		-- asymmetric: a few long fat slow ones, many thin fast short ones, each its own opacity and start
		-- v469: three clearly different families - a few long fat slow beams, a middle set, and many hair-thin fast darts; each its own
		-- length, width, opacity, speed and start, so the burst never reads as a uniform burst card
		local fam = (i % 8 == 0) and 1 or ((i % 3 == 0) and 2 or 3)
		local s = { l = l, ang = rnd(0, 360), r0 = rnd(0.03, 0.2) }
		if fam == 1 then
			s.len, s.w, s.op, s.v, s.t0, s.life = rnd(0.5, 0.8), math.floor(rnd(10, 18) * math.max(SC, 0.7)), rnd(0.7, 0.95), rnd(0.25, 0.45), rnd(0, 0.12), rnd(0.6, 0.85)
		elseif fam == 2 then
			s.len, s.w, s.op, s.v, s.t0, s.life = rnd(0.2, 0.4), math.floor(rnd(4, 8)), rnd(0.45, 0.75), rnd(0.6, 1.1), rnd(0.03, 0.3), rnd(0.35, 0.6)
		else
			s.len, s.w, s.op, s.v, s.t0, s.life = rnd(0.05, 0.18), math.floor(rnd(1, 3)), rnd(0.25, 0.65), rnd(1.3, 2.8), rnd(0, 0.45), rnd(0.14, 0.35)
		end
		table.insert(speedLines, s)
	end
	local shock = inst("ImageLabel", { Name = "Shockwave", BackgroundTransparency = 1, Image = IMG.ring5, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(10, 10), ImageTransparency = 1, ZIndex = 14 }, root)
	every(function(t)
		if not st.burstT0 then return true end
		local k = now() - st.burstT0
		local vpx = math.max(vp.X, vp.Y)
		local cx, cy = st.burstScreen and st.burstScreen.X or vp.X / 2, st.burstScreen and st.burstScreen.Y or vp.Y / 2
		local done = true
		-- everything 2D clears out of the way as THE rock closes on the lens (so it never reads see-through)
		local clearK = 1 - clamp01((t - (T.rockHit - 0.5)) / 0.3)
		for _, s in ipairs(speedLines) do
			local q = (k - s.t0) / s.life
			if q < 1 then done = false end
			if q >= 0 and q < 1 then
				local r = (s.r0 + s.v * (k - s.t0)) * vpx
				local a = math.rad(s.ang)
				s.l.Rotation = s.ang
				s.l.Position = UDim2.fromOffset(cx + math.cos(a) * r, cy + math.sin(a) * r)
				s.l.Size = UDim2.fromOffset(math.floor(s.len * vpx * (0.6 + 0.4 * q)), s.w)
				s.l.ImageTransparency = 1 - s.op * math.sin(q * math.pi) * clearK
			else
				s.l.ImageTransparency = 1
			end
		end
		-- the one shockwave ring: expands fast then slows, thins out as it fades
		-- v469: a thick white ring (thin magenta fringe), slower (1.0 s) and solid for its first third so it reads as ONE ring
		local qr = (k - 0.05) / 1.0
		if qr < 1 then
			done = false
			qr = math.max(qr, 0)
			local d = math.floor(lerp(0.06, 1.7, 1 - (1 - qr) ^ 2.2) * vpx)
			shock.Position = UDim2.fromOffset(cx, cy)
			shock.Size = UDim2.fromOffset(d, d)
			shock.ImageTransparency = 1 - (1 - clamp01((qr - 0.3) / 0.7) ^ 1.3) * clearK
		else
			shock.ImageTransparency = 1
		end
		if done or st.chargeCleared then
			for _, s in ipairs(speedLines) do pcall(function() s.l:Destroy() end) end
			pcall(function() shock:Destroy() end)
			return false
		end
		return true
	end)
	-- the manga impact frame (2 frames, crisp black and white, no blur): frame 1 = white paper, Infinity as a hard black silhouette
	-- (a client-only copy of the posed rig in a ViewportFrame tinted black - the model itself is never edited) and sharp black speed
	-- lines radiating from the core; frame 2 = the 3D in hard black and white with white speed lines
	local inkPanel = full(root, { Name = "MangaPanel", ZIndex = 15, BackgroundColor3 = PURE, BackgroundTransparency = 1 })
	local inkLines = inst("ImageLabel", { Name = "MangaLines", BackgroundTransparency = 1, Image = IMG.manga, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), ZIndex = 16, ImageTransparency = 1, ImageColor3 = BLACK }, root)
	inst("UIAspectRatioConstraint", { AspectRatio = 1, DominantAxis = Enum.DominantAxis.Width }, inkLines)
	local inkVP = inst("ViewportFrame", { Name = "MangaSilhouette", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 16,
		ImageColor3 = BLACK, ImageTransparency = 1, Ambient = Color3.new(1, 1, 1), LightColor = Color3.new(1, 1, 1), Visible = false }, root)
	local inkCam = inst("Camera", { Name = "MangaCam" }, inkVP)
	inkVP.CurrentCamera = inkCam
	at(T.cut + 0.05, function()
		-- the held breath before the boom: he is frozen, so copy him into the panel now (once; nothing is built at the boom itself)
		pcall(function()
			if av and av.model.Parent then
				local m = av.model:Clone()
				for _, d in ipairs(m:GetDescendants()) do
					if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Light") or d:IsA("BillboardGui") then d:Destroy() end
				end
				m.Parent = inkVP
			end
		end)
	end)
	local FR = 1 / 30
	-- v469: the manga frame holds long enough to land in a 30 fps recording (frame 1 ~0.067 s, frame 2 ~0.05 s; ~0.12 s total)
	local MANGA1, MANGA2 = 0.067, 0.117
	at(T.boom, function()
		local c = workspace.CurrentCamera
		inkCam.CFrame = c and c.CFrame or camCF
		inkCam.FieldOfView = camFov
		local sp = c and c:WorldToViewportPoint(coreP.Position)
		st.burstScreen = sp and Vector2.new(math.clamp(sp.X, vp.X * 0.2, vp.X * 0.8), math.clamp(sp.Y, vp.Y * 0.2, vp.Y * 0.8)) or Vector2.new(vp.X / 2, vp.Y / 2)
		-- frame 1: white paper, black silhouette, black speed lines
		inkPanel.BackgroundColor3 = PURE inkPanel.BackgroundTransparency = 0
		inkVP.Visible = true inkVP.ImageTransparency = 0
		inkLines.Position = UDim2.fromOffset(st.burstScreen.X, st.burstScreen.Y)
		inkLines.Size = UDim2.fromScale(1.5, 1.5)
		inkLines.ImageColor3 = BLACK inkLines.ImageTransparency = 0
		st.boomPos = coreP.Position
		for _, f in ipairs(feeds) do f.beam.Enabled = false end -- the channels are spent: everything went into the core
	end)
	at(T.boom + MANGA1, function()
		-- frame 2: the 3D in hard black and white, white speed lines over it
		inkPanel.BackgroundTransparency = 1
		inkVP.Visible = false
		inkLines.ImageColor3 = PURE inkLines.ImageTransparency = 0.05
		cc.Saturation = -1 cc.Contrast = 2.6 cc.Brightness = 0.12
	end)
	at(T.boom + MANGA2, function()
		inkLines.ImageTransparency = 1
		cc.Saturation = 0 cc.Contrast = 0.06 cc.Brightness = 0
		pcall(function() inkPanel:Destroy() inkLines:Destroy() inkVP:Destroy() end)
		-- the readable blast: built behind him (relative to the camera), so his body cuts a dark silhouette against it
		local away = (chest() - camCF.Position)
		away = Vector3.new(away.X, 0, away.Z).Unit
		local bc = chest() + away * 4.5
		st.blastAway = away
		coreP.Transparency = 1
		coreGlowIm.ImageTransparency = 1 coreHotIm.ImageTransparency = 1
		coreLight.Brightness = 0
		key.Brightness = 0.9 fillL.Brightness = 0.35 rimA.Brightness = 0 rimB.Brightness = 0 -- he stays a calm, readable figure at the centre
		for _, w in ipairs(wisps) do w.tr.Enabled = false w.core2.Enabled = false w.sparks.Rate = 0 end
		for _, f in ipairs(feeds) do f.beam.Enabled = false end
		-- the vertical beam pillars (pre-built, tweened, never rebuilt) + the varied speed-lines + the shockwave start now
		st.burstT0 = now()
		for i, b in ipairs(pillars) do
			task.delay(b.delay, function()
				if st.done then return end
				b.beam.Enabled = true
				tween(b.beam, 0.06, { Width0 = b.w, Width1 = b.w * 0.75 })
				task.delay(b.life * 0.35, function() if b.beam.Parent then tween(b.beam, b.life * 0.65, { Width0 = 0, Width1 = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In) end end)
			end)
		end
		local ap = anchorPart(blast, bc, "Boom")
		st.blastP = ap
		blastLight = inst("PointLight", { Color = Color3.fromRGB(255, 232, 252), Brightness = 7, Range = 40, Shadows = false }, ap)
		tween(blastLight, 1.4, { Brightness = 1.2 })
		-- white rays (varied, dark gaps between) and a pale bloom - mostly white, a thin magenta fringe, never a purple screen
		-- v469: smaller and thinner than v468 (it washed the frame and buried the pillar + ring): white rays with dark gaps
		local sbb, sim = billboard(ap, IMG.burstRays, 8, PURE, 0.3, 1.8)
		tween(sbb, 0.8, { Size = UDim2.fromScale(34, 34) }, Enum.EasingStyle.Quart)
		tween(sim, 1.1, { ImageTransparency = 1, Rotation = 18 })
		local sbb2, sim2 = billboard(ap, IMG.burstRays, 6, PURE, 0.2, 1.6)
		sim2.Rotation = 40
		tween(sbb2, 0.6, { Size = UDim2.fromScale(30, 30) }, Enum.EasingStyle.Quart)
		tween(sim2, 0.8, { ImageTransparency = 1, Rotation = 22 })
		local gbb, gim = billboard(ap, IMG.glow, 5, PURE, 0.45, 1.4) -- a short pure-white bloom (no pink haze around him)
		tween(gbb, 0.5, { Size = UDim2.fromScale(14, 14) })
		tween(gim, 0.6, { ImageTransparency = 1 })
		-- the energy flows out as the blast: white sparks + pale glow + a little dark dust (short lifetimes, ~160 particles at the peak)
		local dp = part({ Name = "Debris", Size = Vector3.new(1, 1, 1), CFrame = CFrame.new(chest()), Transparency = 1 }, blast)
		emitter(dp, { Shape = Enum.ParticleEmitterShape.Sphere, Speed = NumberRange.new(28, 80), Lifetime = NumberRange.new(0.4, 0.9),
			Drag = 3, Size = nsk({ { 0, 0.4 }, { 1, 0 } }), Color = cs(PURE, PALE), SpreadAngle = Vector2.new(180, 180), RotSpeed = NumberRange.new(-300, 300) }):Emit(math.floor(95 * QUAL))
		emitter(dp, { Texture = IMG.glow, Shape = Enum.ParticleEmitterShape.Sphere, Speed = NumberRange.new(14, 36), Lifetime = NumberRange.new(0.45, 0.85),
			Drag = 2, Size = nsk({ { 0, 0.5 }, { 1, 0 } }), Color = cs(PURE, Color3.fromRGB(255, 214, 248)), SpreadAngle = Vector2.new(180, 180) }):Emit(math.floor(24 * QUAL))
		emitter(dp, { Texture = IMG.mist, Shape = Enum.ParticleEmitterShape.Sphere, Speed = NumberRange.new(12, 22), Lifetime = NumberRange.new(0.9, 1.3),
			Drag = 1.4, LightEmission = 0.2, Size = nsk({ { 0, 3 }, { 1, 12 } }), Transparency = nsk({ { 0, 0.7 }, { 1, 1 } }),
			Color = cs(Color3.fromRGB(70, 72, 84), Color3.fromRGB(18, 20, 30)), RotSpeed = NumberRange.new(-50, 50) }):Emit(math.floor(6 * QUAL))
		-- the galaxy blows away: the silhouettes are pushed out, the star layers whip past
		for _, r in ipairs(sils) do
			local dir = (r.home - center)
			r.push = dir.Unit * rnd(6, 14)
		end
		spinBoost = 1
		-- the chunks: all thrown outward, away from the camera's lane (THE rock is its own, bigger, pre-built chunk below)
		local camPos = camCF.Position
		local toCam = (camPos - center).Unit
		for _, c in ipairs(chunks) do
			local dir = (c.cf.Position - center)
			if dir.Magnitude < 0.1 then dir = Vector3.new(1, 0, 0) end
			dir = (dir.Unit + Vector3.new(0, rnd(-0.15, 0.3), 0)).Unit
			if dir:Dot(toCam) > 0.5 then dir = (dir - toCam * 0.9).Unit end
			c.vel = dir * (c.chip and rnd(30, 50) or rnd(18, 32))
			c.tumbleRate = rnd(4, 8)
		end
	end)
	-- THE rock: a big faceted chunk, pre-built and hidden until the blast. It is born in the light behind him, lit on the side that
	-- faces the camera (its own light) with a white-magenta edge from the blast, and flies straight at the lens, growing until it
	-- fills the frame - it stops just short of the lens (so it never clips through the camera), then the impact
	-- v469: an OPAQUE lit stone (it read as a pale lavender ghost): more, tighter facets around a solid centre block (no gaps to see
	-- through), facet-shaded every frame (warm-white lit face toward the camera's upper left, near-black shadow side), a warm-white
	-- light on the camera side and only a faint magenta rim; the 2D burst layers clear out of its way before it fills the frame
	local hitRock = makeRock(blast, 1.5, Color3.fromRGB(70, 66, 72), Enum.Material.Slate, 4681, 11)
	do
		local cpart = Instance.new("Part")
		cpart.Anchored, cpart.CanCollide, cpart.CanQuery, cpart.CanTouch, cpart.CastShadow = true, false, false, false, false
		cpart.Name = "Rock" cpart.Size = Vector3.new(2.1, 1.8, 2.0) cpart.Material = Enum.Material.Slate cpart.Color = Color3.fromRGB(40, 38, 44)
		cpart.CFrame = CFrame.new(STAGE - Vector3.new(0, 500, 0)) cpart.Parent = blast
		table.insert(hitRock.parts, cpart) table.insert(hitRock.offs, CFrame.Angles(0.4, 0.7, 0.2))
	end
	litRock(hitRock, blast, Color3.fromRGB(255, 244, 232), 0, 0.5)
	pcall(function() hitRock.hl.OutlineColor = Color3.fromRGB(255, 120, 236) end)
	setRockVisible(hitRock, false)
	st.hitRock = hitRock
	-- burst camera: kicked back a touch, FOV punch, hard shake decaying; he stays still and composed
	local burstCam = nil
	every(function(t, dt)
		if st.chargeCleared then return false end
		if t < T.boom then return true end
		if not burstCam then burstCam = { cf = camCF, fov = camFov } end
		local k = t - T.boom
		local back = easeOut(k / 0.6) * 2.4
		local cf0 = burstCam.cf
		local pos = cf0.Position - cf0.LookVector * back
		if t < T.rockHit then setCam(CFrame.lookAt(pos, pos + cf0.LookVector), lerp(burstCam.fov + 9, burstCam.fov + 4, easeOut(k / 0.5))) end
		if t < T.rockHit then setShake(lerp(0.45, 0.06, easeOut(k / 0.5)) + ((t > T.rockHit - 0.25) and 0.25 or 0)) end
		spinBoost = math.max(0, 1 - k / 0.8)
		-- flying chunks (pooled; no new rocks)
		local parts, cfs = {}, {}
		for _, c in ipairs(chunks) do
			if c.vel then
				c.vel = c.vel * math.max(0, 1 - dt * 0.8)
				local p = c.cf.Position + c.vel * dt
				queueRock(c, CFrame.new(p) * (c.cf - c.cf.Position) * CFrame.fromAxisAngle(c.spin, dt * c.tumbleRate), parts, cfs)
				if c.light then
					-- now lit by the blast behind them: a white-magenta edge on the blast side
					aimRockLight(c, st.blastP and st.blastP.Position or center, parts, cfs)
					c.light.Brightness = LOOK.rockLight * math.max(0, 1 - k / 1.2)
				end
			end
		end
		-- THE rock: born in the light, then straight at the lens, filling the frame
		if not hitRock.hit and t >= T.rockGo - 0.25 then
			local camNow = camCF
			if not hitRock.start then
				local away = st.blastAway or (center - camNow.Position).Unit
				hitRock.start = chest() + away * 3.2 + camNow.RightVector * 1.6 + Vector3.new(0, 1.1, 0)
				setRockVisible(hitRock, true)
			end
			local q = clamp01((t - (T.rockGo - 0.25)) / (T.rockHit - (T.rockGo - 0.25)))
			local f = q ^ 1.7
			-- the stop point: centred, a little right/up of the lens axis, far enough out that it fills the frame without clipping
			local lens = camNow.Position + camNow.LookVector * (hitRock.R * 2.0) + camNow.RightVector * 0.25 + camNow.UpVector * 0.12
			local mid = hitRock.start:Lerp(lens, 0.5) + camNow.UpVector * 0.8
			local p = hitRock.start:Lerp(mid, f):Lerp(mid:Lerp(lens, f), f)
			hitRock.ang = (hitRock.ang or 0) + dt * 2.6
			queueRock(hitRock, CFrame.new(p) * CFrame.fromAxisAngle(hitRock.spin, hitRock.ang), parts, cfs)
			-- its own light sits on its camera side: the faces we see are lit; the blast behind gives the edge
			aimRockLight(hitRock, camNow.Position, parts, cfs)
			hitRock.light.Range = hitRock.R * 3.4
			hitRock.light.Brightness = lerp(1.2, 2.2, f)
			shadeRock(hitRock, camNow.Position + camNow.UpVector * 5 - camNow.RightVector * 4, Color3.fromRGB(238, 230, 222), 1, Color3.fromRGB(14, 13, 18))
		end
		bulk(parts, cfs)
		return true
	end)
	-- =================================================================================================================
	-- SHOT 5 - THE CRACK (14.5-17.2 s, 2.7 s), a process the player watches happen (pre-drawn sprites, tweened stages, phone-cheap).
	-- v468: the glass stays DARK and CLEAR (the scene stays visible behind it, only slightly darkened); the cracks are thin crisp
	-- white lines; the light behind is white with a faint magenta breath; nothing washes the screen lavender.
	--   1 impact (2 frames): the white manga hit-flash as the rock connects
	--   2 first fracture (14.57-15.2): the glass darkens a little, the impact point glows, 5 primary cracks spider out one by one
	--   3 spread (15.2-16.35): rings and branches crack between them, faint white-magenta light bleeds through the cracks
	--   4 shatter apart (16.35-17.2): 20 shards (cut from the same lines) separate and drift toward the camera while white light
	--     bursts through the widening gaps from the impact point; then a hard cut to true black (the one black beat)
	-- =================================================================================================================
	local crackRoot = full(root, { Name = "Crack", ZIndex = 16, BackgroundTransparency = 1 })
	local function cimg(key, img, z)
		local L = CRACK4[key]
		return inst("ImageLabel", { Name = key, BackgroundTransparency = 1, Image = img, ImageTransparency = 1, ZIndex = z,
			Position = UDim2.fromScale(L.x, L.y), Size = UDim2.fromScale(L.w, L.h), ScaleType = Enum.ScaleType.Stretch }, crackRoot)
	end
	local GLASS_T = 0.42 -- the glass tint (alpha 0.58 of near-black navy); the shards carry exactly this tint, so the swap is seamless
	local glass = inst("Frame", { Name = "DeepGlass", BackgroundColor3 = Color3.fromRGB(6, 8, 22), BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), ZIndex = 16 }, crackRoot)
	-- the light behind the glass: a white glow from the impact point with a faint magenta outer breath (never a full-screen fill)
	local function glowAt(name, color, size, z)
		local g = inst("ImageLabel", { Name = name, BackgroundTransparency = 1, Image = IMG.glow, ImageColor3 = color, ImageTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(IMPACT.X, IMPACT.Y), Size = UDim2.fromScale(size, size), ZIndex = z }, crackRoot)
		inst("UIAspectRatioConstraint", { AspectRatio = 1 }, g)
		return g
	end
	-- v469: behind the separating shards, the glass gives way onto dark space with the light bursting through (never a white flash)
	local beyond = inst("Frame", { Name = "Beyond", BackgroundColor3 = Color3.fromRGB(3, 4, 12), BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), ZIndex = 16 }, crackRoot)
	local gapRays = inst("ImageLabel", { Name = "GapRays", BackgroundTransparency = 1, Image = IMG.burstRays, ImageColor3 = PURE, ImageTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(IMPACT.X, IMPACT.Y), Size = UDim2.fromScale(0.7, 0.7), ZIndex = 17 }, crackRoot)
	inst("UIAspectRatioConstraint", { AspectRatio = 1 }, gapRays)
	local gapHalo = glowAt("GapHalo", Color3.fromRGB(255, 170, 240), 0.5, 17)
	local gapLight = glowAt("GapLight", PURE, 0.3, 17)
	local bleed = cimg("c4_bleed", IMG.c4Bleed, 18)
	local impactCore = glowAt("ImpactGlow", PURE, 0.12, 21)
	local crush = cimg("c4_crush", IMG.c4Crush, 22)
	local prims = {}
	local PRIM_DIR = { 22, 82, 148, 202, 298 } -- each primary's direction (screen degrees), for the outward wipe
	local PRIM_ORDER = { 4, 1, 2, 5, 3 } -- the order they spider out
	for i = 0, 4 do
		local im = cimg("c4_p" .. i, IMG["c4P" .. i], 21)
		local g = inst("UIGradient", { Rotation = PRIM_DIR[i + 1], Transparency = nsk({ { 0, 1 }, { 1, 1 } }) }, im)
		prims[i + 1] = { im = im, g = g }
	end
	local secA = cimg("c4_sa", IMG.c4SA, 20)
	local secB = cimg("c4_sb", IMG.c4SB, 20)
	local shards = {}
	for key, id in pairs(IMG.shards) do
		local L = CRACK5[key]
		if L then
			local cx, cy = L.x + L.w / 2, L.y + L.h / 2
			local im = inst("ImageLabel", { Name = key, BackgroundTransparency = 1, Image = id, ImageTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(cx, cy), Size = UDim2.fromScale(L.w, L.h), ZIndex = 19, Visible = false }, crackRoot)
			-- the drift direction is from the impact point (in screen pixels, so it is correct on every aspect)
			local dir = Vector2.new((cx - IMPACT.X) * vp.X, (cy - IMPACT.Y) * vp.Y)
			dir = dir.Magnitude > 1 and dir.Unit or Vector2.new(0, -1)
			local band = L.band or 1
			-- v469: they really come apart - each slides well away from the impact (a big push), grows as it flies at the lens (inner
			-- pieces most), and turns slowly; the inner ring goes first
			table.insert(shards, { im = im, cx = cx, cy = cy, w = L.w, h = L.h, dir = dir, band = band,
				rot = rnd(10, 28) * (RNG:NextNumber() < 0.5 and -1 or 1), push = 0.12 + 0.045 * band + rnd(0, 0.07),
				grow = 0.3 + rnd(0, 0.3) + (3 - band) * 0.14, lag = band * 0.035 + rnd(0, 0.04) })
		end
	end
	st.shards = shards

	-- stage 1: impact
	at(T.rockHit, function()
		hitRock.hit = true
		setRockVisible(hitRock, false)
		pcall(function() hitRock.light.Brightness = 0 end)
		flash.BackgroundColor3 = PURE
		flash.BackgroundTransparency = 0 -- the manga hit-flash: 2 frames, never a sustained white-out
		crush.ImageTransparency = 0
		impactCore.ImageTransparency = 0
		impactCore.Size = UDim2.fromScale(0.2, 0.2)
		tween(impactCore, 0.3, { Size = UDim2.fromScale(0.08, 0.08), ImageTransparency = 0.2 })
		blur.Enabled = true blur.Size = 6
		tween(blur, 0.25, { Size = 0 })
		setShake(1.6)
		-- behind the glass: the camera settles back on him in the blast's afterglow (the scene stays visible)
		if burstCam then setCam(CFrame.lookAt(burstCam.cf.Position - burstCam.cf.LookVector * 2.4, chest()), burstCam.fov + 2) end
	end)
	at(T.rockHit + 0.045, function() flash.BackgroundTransparency = 1 end)
	-- stage 2: first fracture
	at(T.crack2, function()
		tween(glass, 0.3, { BackgroundTransparency = GLASS_T })
		tween(gapHalo, 0.4, { ImageTransparency = 0.88 })
		tween(cc, 0.3, { Brightness = -0.04, Saturation = -0.15 })
		for n, idx in ipairs(PRIM_ORDER) do prims[idx].t0 = T.crack2 + (n - 1) * 0.11 end
	end)
	-- stage 3: spread + light bleeding through (faint: thin white, a magenta breath)
	at(T.crack3, function()
		tween(secA, 0.16, { ImageTransparency = 0 })
		task.delay(0.42, function() if secB.Parent then tween(secB, 0.22, { ImageTransparency = 0 }) end end)
		tween(bleed, 0.7, { ImageTransparency = 0.45 })
		tween(gapHalo, 0.8, { ImageTransparency = 0.8, Size = UDim2.fromScale(0.62, 0.62) })
		tween(gapLight, 0.8, { ImageTransparency = 0.8 })
	end)
	-- stage 4: the shards (same tint as the glass, same lines as the cracks) take over, separate and drift toward the camera;
	-- the white light bursts through the widening gaps
	at(T.crack4, function()
		-- the shards (same cells as the crack lines) take over at exactly the glass's tint, then deepen as they lift off
		local A0 = 1 - (1 - GLASS_T) / 0.74 -- the shard art is 0.74 glass alpha; this matches the 0.58 glass for a seamless swap
		for _, s in ipairs(shards) do s.im.Visible = true s.im.ImageTransparency = A0 end
		glass.BackgroundTransparency = 1
		st.shatterT0 = now()
		for _, o in ipairs({ secA, secB, crush }) do o.ImageTransparency = 1 end
		for _, p in ipairs(prims) do p.im.ImageTransparency = 1 end
		tween(bleed, 0.2, { ImageTransparency = 1 })
		-- behind them: dark space, and the white light (thin magenta breath) bursting through the widening gaps from the impact point
		tween(beyond, 0.3, { BackgroundTransparency = 0.12 })
		impactCore.ZIndex = 17 -- the light source sits BEHIND the glass now: it shows only through the gaps
		tween(impactCore, 0.6, { ImageTransparency = 0.1, Size = UDim2.fromScale(0.22, 0.22) })
		tween(gapRays, 0.7, { ImageTransparency = 0.3, Size = UDim2.fromScale(1.6, 1.6), Rotation = 14 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tween(gapLight, 0.7, { ImageTransparency = 0.38, Size = UDim2.fromScale(1.1, 1.1) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tween(gapHalo, 0.7, { ImageTransparency = 0.72, Size = UDim2.fromScale(1.5, 1.5) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end)
	every(function(t)
		if t < T.rockHit then return true end
		if st.chargeCleared then return false end
		-- the camera keeps trembling through the fracture, settling as the glass gives
		if t < T.crack4 then setShake(lerp(1.6, 0.14, clamp01((t - T.rockHit) / 0.7))) else setShake(0.1) end
		-- primaries: each wipes outward from the impact point in ~0.09 s
		for _, p in ipairs(prims) do
			if p.t0 and not p.done and t >= p.t0 then
				local e = easeOut(clamp01((t - p.t0) / 0.09))
				p.im.ImageTransparency = 0
				if e >= 1 then
					p.g.Transparency = nsk({ { 0, 0 }, { 1, 0 } })
					p.done = true
				else
					local a = math.max(0.001, math.min(0.98, e))
					p.g.Transparency = nsk({ { 0, 0 }, { a, 0 }, { math.min(a + 0.02, 0.999), 1 }, { 1, 1 } })
				end
			end
		end
		-- the light bleeding through pulses gently
		if t >= T.crack3 and t < T.crack4 then
			impactCore.ImageTransparency = 0.2 + 0.1 * math.sin(t * 16)
		end
		-- shards: drift apart and toward the camera (slow start, inner ones first), gaps widening onto the light
		if st.shatterT0 then
			local span = T.black - T.crack4
			for _, s in ipairs(shards) do
				local q = clamp01((now() - st.shatterT0 - s.lag) / math.max(span - s.lag, 0.1))
				local e = q ^ 1.6 -- they visibly part within the first third, then accelerate past the lens
				local sc = 1 + s.grow * e
				local dx, dy = s.dir.X * s.push * e, s.dir.Y * s.push * e
				s.im.Position = UDim2.new(s.cx, dx * vp.X, s.cy, dy * vp.X)
				s.im.Size = UDim2.fromScale(s.w * sc, s.h * sc)
				s.im.Rotation = s.rot * e
				local A0 = 1 - (1 - GLASS_T) / 0.74
				s.im.ImageTransparency = A0 * (1 - clamp01(q / 0.15)) + 0.12 * e -- deepens as it lifts off, thins a little as it nears the lens
			end
		end
		return true
	end)

	-- =================================================================================================================
	-- SHOT 6 - BLACK SUSPENSE (17.2-18.6 s, ONE beat of 1.4 s): a hard cut to true black, near silence, one low heartbeat, one ember
	-- =================================================================================================================
	local function clearCharge()
		if st.chargeCleared then return end
		st.chargeCleared = true
		blackout.BackgroundTransparency = 0
		flash.BackgroundTransparency = 1
		pcall(function() crackRoot:Destroy() end)
		pcall(function() charge:Destroy() end)
		pcall(function() quote:Destroy() end)
		pcall(function() firstStar:Destroy() end)
		blur.Enabled = false blur.Size = 0
		cc.Saturation = 0 cc.Contrast = 0.06 cc.Brightness = 0
		setShake(0)
		spinBoost = 0
		for _, r in ipairs(sils) do r.push = Vector3.zero end
	end
	st.clearCharge = clearCharge
	at(T.black, function()
		clearCharge()
	end)

	-- =================================================================================================================
	-- SHOT 7 - THE REVEAL (18.6 s until a tap): Infinity, calm, on a floating obsidian rock; god rays, rising sparkles, planet limb,
	-- a slow push-in that never stops; then the UI (NEW! first time only, INFINITY banner, BLESSING + MYTHICAL tags, ability, speech)
	-- =================================================================================================================
	local rv = nil -- reveal set state
	local function buildReveal()
		if rv or st.done then return end
		local set = inst("Folder", { Name = "Reveal" }, world)
		st.revealSet = set
		rv = { set = set, phi0 = math.rad(4) } -- looking square at one wall of the far star box (no wall edge in view)
		local chestP = center + Vector3.new(0, 0.6, 0)
		local camDir = Vector3.new(math.sin(rv.phi0), 0, -math.cos(rv.phi0)) -- from him toward the camera
		local away = -camDir
		local left = Vector3.new(0, 1, 0):Cross(camDir).Unit -- screen-left of him as the camera sees it
		rv.camDir, rv.away = camDir, away
		-- the floating obsidian rock (flat top under his feet, broken spikes underneath, a few faint magenta veins)
		local rr = Random.new(4660)
		local function r(a, b) return a + rr:NextNumber() * (b - a) end
		rv.rockParts, rv.rockOffs = {}, {}
		local top = -3.05
		local function add(p, off) table.insert(rv.rockParts, p) table.insert(rv.rockOffs, off) end
		for i = 1, 6 do
			local sz = Vector3.new(r(3.6, 5.2), r(0.9, 1.4), r(3.0, 4.4))
			local off = CFrame.new(r(-0.7, 0.7), top - sz.Y / 2 + r(-0.05, 0.02), r(-0.6, 0.6)) * CFrame.Angles(r(-0.06, 0.06), r(0, 3.14), r(-0.06, 0.06))
			-- v469: lighter stone so the light can show on it (v468's near-black slabs swallowed the top light)
			add(part({ Name = "Obsidian", Size = sz, Color = (i <= 2) and Color3.fromRGB(132, 128, 138) or Color3.fromRGB(96, 92, 104), Material = Enum.Material.Slate }, set), off)
		end
		for i = 1, 4 do
			local sz = Vector3.new(r(1.2, 2.2), r(1.6, 2.8), r(1.2, 2.0))
			local off = CFrame.new(r(-1.2, 1.2), top - 1.6 - r(0.2, 0.9), r(-1, 1)) * CFrame.Angles(r(0.5, 0.9), r(0, 6.28), r(0.5, 0.9))
			add(part({ Name = "Obsidian", Size = sz, Color = Color3.fromRGB(46, 44, 54), Material = Enum.Material.Slate }, set), off)
		end
		for i = 1, 3 do
			local ang = r(0, 6.28)
			local off = CFrame.new(math.cos(ang) * r(1.1, 1.8), top + 0.01, math.sin(ang) * r(1.1, 1.8)) * CFrame.Angles(0, r(0, 6.28), 0)
			add(part({ Name = "Vein", Size = Vector3.new(0.06, 0.03, r(0.8, 1.5)), Color = PINK, Material = Enum.Material.Neon, Transparency = 0.35 }, set), off)
		end
		pcall(function()
			local rm = inst("Model", { Name = "RevealRock" }, set)
			for _, p in ipairs(rv.rockParts) do p.Parent = rm end
			inst("Highlight", { FillTransparency = 1, OutlineColor = Color3.fromRGB(255, 150, 238), OutlineTransparency = 0.55,
				DepthMode = Enum.HighlightDepthMode.Occluded, Adornee = rm }, rm)
		end)
		-- the planet limb, low on the horizon, far behind him; god rays + a soft halo behind him (his body occludes them)
		local pl = anchorPart(set, center + away * 430 + Vector3.new(0, -140, 0), "Planet")
		local pbb = inst("BillboardGui", { Size = UDim2.fromScale(900, 450), LightInfluence = 0, MaxDistance = 5000, ResetOnSpawn = false }, pl)
		pcall(function() pbb.Brightness = 1 end)
		rv.planet = inst("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = IMG.planet, ImageColor3 = Color3.fromRGB(186, 196, 236), ImageTransparency = 1 }, pbb) -- v469: cooled (no purple)
		local rayP = anchorPart(set, chestP + away * 6 + Vector3.new(0, 0.9, 0), "Rays")
		-- v469: WHITE god rays over a dark navy sky (v468 read as a heavy purple glow): the main rays are white, the magenta set is only
		-- a faint accent, the halo is a small cool white
		local r1, r1im = billboard(rayP, IMG.rays, 26, PURE, 1, 1.35)
		local r2, r2im = billboard(rayP, IMG.rays, 17, Color3.fromRGB(255, 140, 236), 1, 0.8)
		local halo, haloIm = billboard(rayP, IMG.glow, 9, Color3.fromRGB(236, 240, 255), 1, 1.0)
		rv.rays = { r1im, r2im, haloIm }
		-- lights: magenta rim from behind, a soft cool key from the front, a dim navy fill; all external
		-- lights: a NEUTRAL WHITE key from the front (white armour reads white), ONE narrow magenta rim from behind/above (edges only),
		-- a cool-white edge from the other side, a neutral low fill; all external, nothing on the model changes
		rv.rim = spot(set, chestP + away * 4.4 + Vector3.new(0.6, 3.0, 0), chestP + Vector3.new(0, 0.3, 0), LOOK.rimColor, 0, LOOK.rimRange + 2, LOOK.rimAngle)
		rv.rim2 = spot(set, chestP + away * 3.6 - left * 2.6 + Vector3.new(0, 1.2, 0), chestP, Color3.fromRGB(236, 238, 255), 0, 10, 35)
		rv.key = spot(set, chestP + camDir * 7 + left * 3 + Vector3.new(0, 4, 0), chestP, LOOK.keyColor, 0, 18, 50)
		-- v469: he was backlit (grey armour, face in shadow): the same strong white front key + white fill as the charge
		rv.fill2 = spot(set, chestP + camDir * 6.4 - left * 3.6 + Vector3.new(0, 1.2, 0), chestP + Vector3.new(0, 0.2, 0), Color3.fromRGB(246, 246, 255), 0, 16, 50)
		rv.face = spot(set, chestP + camDir * 4.5 + Vector3.new(0, 2.6, 0), chestP + Vector3.new(0, 1.4, 0), LOOK.keyColor, 0, 9, 40)
		rv.fill = inst("PointLight", { Color = Color3.fromRGB(150, 155, 170), Brightness = 0, Range = 12, Shadows = false }, anchorPart(set, chestP + camDir * 4, "Fill"))
		-- v468: the floating rock reads as a lit rock, not a dark blob: a soft white top light grazing its flat top from the front,
		-- and a magenta-white rim from behind/below catching its edges and spikes
		rv.rockTop = spot(set, center + camDir * 4.2 + Vector3.new(0, 1.6, 0), center + Vector3.new(0, -3.1, 0), Color3.fromRGB(255, 248, 242), 0, 12, 75)
		rv.rockRim = spot(set, center + away * 4.5 + Vector3.new(0, -5.5, 0), center + Vector3.new(0, -3.4, 0), Color3.fromRGB(255, 150, 236), 0, 9, 55)
		-- one continuous backdrop wall far behind him (deep navy, tiled stars) so no star-box seam can ever be in frame
		local wall = part({ Name = "Backdrop", Size = Vector3.new(1500, 900, 1), Transparency = 1,
			CFrame = CFrame.lookAt(center + away * 470 + Vector3.new(0, 60, 0), center + Vector3.new(0, 60, 0)) }, set)
		local wsg = inst("SurfaceGui", { Face = Enum.NormalId.Front, LightInfluence = 0, SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
			CanvasSize = Vector2.new(1500, 900), ClipsDescendants = true }, wall)
		pcall(function() wsg.Brightness = 1 end)
		local wbg = inst("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = NAVY, BorderSizePixel = 0 }, wsg)
		inst("UIGradient", { Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(3, 4, 12)), ColorSequenceKeypoint.new(0.6, NAVY2),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 16, 40)) }) }, wbg)
		rv.wallStars = inst("ImageLabel", { BackgroundTransparency = 1, Image = IMG.sky, ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(500, 500),
			Size = UDim2.new(1, 1000, 1, 1000), Position = UDim2.fromOffset(-500, -500), ImageTransparency = 0.15, ZIndex = 2 }, wsg)
		-- the energy, settled: white + magenta sparkles drifting upward (one emitter, plus a few soft motes)
		local sp = part({ Name = "Sparkles", Size = Vector3.new(14, 0.5, 9), Transparency = 1, CFrame = CFrame.new(center + Vector3.new(0, -3.8, 0) + away * 1) }, set)
		rv.sparkle = emitter(sp, { EmissionDirection = Enum.NormalId.Top, Speed = NumberRange.new(0.8, 1.8), SpreadAngle = Vector2.new(20, 20),
			Acceleration = Vector3.new(0, 0.25, 0), Lifetime = NumberRange.new(3.5, 5.5), Size = nsk({ { 0, 0.16 }, { 1, 0.04 } }),
			Transparency = nsk({ { 0, 1 }, { 0.15, 0.1 }, { 0.8, 0.3 }, { 1, 1 } }), Color = cs(PURE, PINK), RotSpeed = NumberRange.new(-90, 90) })
		-- v468: the frame is richer (CRK fills its reveal with light): twinkling stars all around him at different depths, and a
		-- few big soft white-magenta motes drifting up close to the lens (foreground depth)
		local ring = part({ Name = "Twinkle", Size = Vector3.new(16, 9, 6), Transparency = 1, CFrame = CFrame.new(center + Vector3.new(0, 0.5, 0) + away * 2.5) }, set)
		rv.twinkle = emitter(ring, { Shape = Enum.ParticleEmitterShape.Box, ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume, Speed = NumberRange.new(0.2, 0.6),
			EmissionDirection = Enum.NormalId.Top, Lifetime = NumberRange.new(1.2, 2.4), Size = nsk({ { 0, 0 }, { 0.5, 0.26 }, { 1, 0 } }),
			Transparency = nsk({ { 0, 0.1 }, { 1, 0.4 } }), Color = cs(PURE, Color3.fromRGB(255, 190, 246)), RotSpeed = NumberRange.new(-60, 60) })
		local fg = part({ Name = "Bokeh", Size = Vector3.new(9, 0.5, 2), Transparency = 1, CFrame = CFrame.new(center + camDir * 6.5 + Vector3.new(0, -3.6, 0)) }, set)
		rv.bokeh = emitter(fg, { Texture = IMG.glow, EmissionDirection = Enum.NormalId.Top, Speed = NumberRange.new(0.5, 1.1), SpreadAngle = Vector2.new(25, 25),
			Lifetime = NumberRange.new(4, 6), Size = nsk({ { 0, 0.5 }, { 1, 0.3 } }), Transparency = nsk({ { 0, 1 }, { 0.25, 0.7 }, { 0.8, 0.8 }, { 1, 1 } }),
			Color = cs(PURE, Color3.fromRGB(255, 170, 240)) })
		rv.motes = emitter(sp, { Texture = IMG.glow, EmissionDirection = Enum.NormalId.Top, Speed = NumberRange.new(0.4, 1), SpreadAngle = Vector2.new(30, 30),
			Lifetime = NumberRange.new(4, 6), Size = nsk({ { 0, 0.32 }, { 1, 0.1 } }), Transparency = nsk({ { 0, 1 }, { 0.2, 0.5 }, { 1, 1 } }), Color = cs(PURE, Color3.fromRGB(255, 170, 240)) })
		-- him: calm hero pose
		if av then
			av.hrp.CFrame = CFrame.new(center)
			setPose(st, "hero", 0.01) -- calm hero pose; the per-frame driver adds the breathing + slow sway
		end
		-- the camera starts wider and lower; the push-in runs for the whole hold
		local function camAt(t)
			local k = math.max(0, t - T.reveal)
			local d = math.max(8.4, 11.3 + 4.7 * math.exp(-k / 9) - 0.035 * k) -- eases in, then keeps visibly creeping closer
			local phi = rv.phi0 - math.rad(7) * (1 - math.exp(-k / 14)) - math.rad(0.05) * k
			local dir = Vector3.new(math.sin(phi), 0, -math.cos(phi))
			local tgt0 = center + Vector3.new(0, -0.75, 0)
			local pos = tgt0 + dir * d + Vector3.new(0, -0.35 + 0.12 * math.sin(k * 0.35), 0)
			local base = CFrame.lookAt(pos, tgt0)
			local tgt = tgt0 + base.RightVector * (1.7 * d / 11.3) -- he sits left of centre, the UI owns the right
			return CFrame.lookAt(pos, tgt), 38.5 + 5.5 * math.exp(-k / 10) - 0.03 * math.min(k, 40) -- a gentle push-in that never stops
		end
		rv.camAt = camAt
		setCam(camAt(T.reveal))
	end
	st.buildReveal = buildReveal
	at(T.black + 0.2, buildReveal)

	at(T.reveal, function()
		buildReveal()
		enterWorld()
		if not rv then return end
		-- light rises
		blackout.BackgroundTransparency = 0
		tween(blackout, 1.3, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
		tween(rv.rim, 1.6, { Brightness = LOOK.rim * 0.55 }) -- a thin magenta edge only
		tween(rv.rim2, 1.8, { Brightness = 0.4 })
		tween(rv.key, 2.0, { Brightness = LOOK.chargeKey }) -- v469: front-lit like the charge: white armour reads WHITE
		tween(rv.fill2, 2.0, { Brightness = LOOK.chargeFill })
		tween(rv.face, 2.0, { Brightness = 0.9 })
		tween(rv.fill, 2.0, { Brightness = 0.5 })
		tween(rv.planet, 2.2, { ImageTransparency = 0.25 })
		tween(rv.rays[1], 2.4, { ImageTransparency = 0.4 })
		tween(rv.rays[2], 2.8, { ImageTransparency = 0.9 })
		tween(rv.rays[3], 2.0, { ImageTransparency = 0.7 })
		rv.sparkle.Rate = 20 * QUAL
		rv.motes.Rate = 3.5 * QUAL
		rv.twinkle.Rate = 9 * QUAL
		rv.bokeh.Rate = 0.9 * QUAL
		tween(rv.rockTop, 2.0, { Brightness = 2.8 })
		tween(rv.rockRim, 2.2, { Brightness = 1.3 })
		pcall(function() rv.sparkle:Emit(math.floor(10 * QUAL)) end)
		-- the reveal: warm resolve chord, choir pad, sparkle arpeggio; then the quiet loop under the hold (T.loop)
	end)
	every(function(t, dt)
		if t < T.reveal or not rv then return true end
		local k = t - T.reveal
		local cf, fov = rv.camAt(t)
		setCam(cf, fov)
		setShake(0)
		-- the rock floats, he rides it, calm
		local bob = Vector3.new(0, math.sin(k * 2.1) * 0.12, 0)
		local base = CFrame.new(center + bob)
		local cfs = {}
		for i, off in ipairs(rv.rockOffs) do cfs[i] = base * off end
		bulk(rv.rockParts, cfs)
		if av then av.hrp.CFrame = base end
		rv.rays[1].Rotation = k * 3
		rv.rays[2].Rotation = -k * 2
		if rv.wallStars then rv.wallStars.Position = UDim2.fromOffset(-500 + (k * 4) % 500, -500 + (k * 1.2) % 500) end
		return true
	end)

	-- ---------- the reveal UI (in the safe-inset UI layer, inside the band between the bars) ----------
	local u = {}
	local function scaled(o) inst("UIScale", { Scale = SC }, o) return o end
	at(T.ui, function()
		-- name banner, top right
		local banner = scaled(inst("Frame", { Name = "NameBanner", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 40, 0, 16 * SC),
			Size = UDim2.fromOffset(540, 96), BackgroundColor3 = INK, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 40 }, band))
		inst("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.35, 0.25), NumberSequenceKeypoint.new(1, 0.1) }) }, banner)
		local edge = inst("Frame", { Name = "Edge", AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1), Size = UDim2.new(0.8, 0, 0, 3),
			BackgroundColor3 = MAG, BorderSizePixel = 0, ZIndex = 41, BackgroundTransparency = 1 }, banner)
		inst("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) }) }, edge)
		local nameGlow = text(banner, { Name = "NameGlow", Text = sceneDef.name, Font = Enum.Font.Michroma, TextSize = 56, TextColor3 = MAG, TextTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -22, 0.5, 0), Size = UDim2.new(1, -30, 1, 0), TextXAlignment = Enum.TextXAlignment.Right,
			TextWrapped = false, ZIndex = 41 })
		tstroke(nameGlow, MAG, 5, 1)
		local name = text(banner, { Name = "Name", Text = sceneDef.name, Font = Enum.Font.Michroma, TextSize = 56, TextColor3 = PURE, TextTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -22, 0.5, 0), Size = UDim2.new(1, -30, 1, 0), TextXAlignment = Enum.TextXAlignment.Right,
			TextWrapped = false, ZIndex = 42 })
		local nameStroke = tstroke(name, PINK, 1.6, 1)
		u.banner, u.name = banner, name
		tween(banner, 0.55, { Position = UDim2.new(1, -24 * SC, 0, 16 * SC), BackgroundTransparency = 0 }, Enum.EasingStyle.Quart)
		tween(edge, 0.6, { BackgroundTransparency = 0.15 })
		tween(name, 0.5, { TextTransparency = 0 })
		tween(nameGlow, 0.7, { TextTransparency = 0.8 })
		tween(nameStroke, 0.6, { Transparency = 0.5 })
		local gs = nameGlow:FindFirstChildOfClass("UIStroke")
		if gs then tween(gs, 0.7, { Transparency = 0.88 }) end
	end)
	at(T.ui + 0.2, function()
		-- tags: BLESSING + MYTHICAL (the roll's own Mythical colours, a small infinity emblem inside)
		local row = scaled(inst("Frame", { Name = "Tags", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24 * SC, 0, 122 * SC),
			Size = UDim2.fromOffset(420, 42), BackgroundTransparency = 1, ZIndex = 40 }, band))
		inst("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, row)
		local bl = inst("Frame", { Name = "BlessingTag", Size = UDim2.fromOffset(160, 40), BackgroundColor3 = INK, BackgroundTransparency = 0.15, LayoutOrder = 1, ZIndex = 41 }, row)
		corner(bl, 8) stroke(bl, PURE, 1.4, 0.45)
		text(bl, { Text = "BLESSING", Font = Enum.Font.Michroma, TextSize = 17, Size = UDim2.fromScale(1, 1), ZIndex = 42, TextWrapped = false })
		local cols = mythicColors()
		local my = inst("Frame", { Name = "RarityTag", Size = UDim2.fromOffset(200, 40), BackgroundColor3 = PURE, BackgroundTransparency = 0, LayoutOrder = 2, ZIndex = 41 }, row)
		corner(my, 8) stroke(my, PURE, 1.4, 0.3)
		inst("UIGradient", { Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, cols[1]), ColorSequenceKeypoint.new(0.55, cols[2]), ColorSequenceKeypoint.new(1, cols[3]) }) }, my)
		inst("ImageLabel", { Name = "InfinityEmblem", BackgroundTransparency = 1, Image = IMG.infTag, ImageColor3 = PURE, ImageTransparency = 0.05,
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(36, 18), ZIndex = 42 }, my)
		local rt = text(my, { Text = string.upper(rarity), Font = Enum.Font.Michroma, TextSize = 17, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.new(1, -58, 1, 0), ZIndex = 42, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Right })
		tstroke(rt, Color3.fromRGB(120, 20, 80), 1.2, 0.35)
		u.tags, u.rarityTag = row, my
		row.Position = UDim2.new(1, 30, 0, 122 * SC)
		tween(row, 0.45, { Position = UDim2.new(1, -24 * SC, 0, 122 * SC) }, Enum.EasingStyle.Quart)
	end)
	at(T.ui + 0.4, function()
		-- the ability card (the game's own Infinity ability text)
		if not abilityName then return end
		local card = scaled(inst("Frame", { Name = "AbilityCard", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -24 * SC, 0, 178 * SC),
			Size = UDim2.fromOffset(470, 132), BackgroundColor3 = INK, BackgroundTransparency = 1, ZIndex = 40 }, band))
		corner(card, 12)
		local cst = stroke(card, MAG, 1.5, 1)
		local title = text(card, { Name = "AbilityName", Text = abilityName, Font = Enum.Font.Sarpanch, TextSize = 32, Size = UDim2.new(1, -150, 0, 40),
			Position = UDim2.fromOffset(20, 12), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 41, TextWrapped = false, TextTransparency = 1 })
		local cd = text(card, { Name = "Cooldown", Text = abilityCd and (tostring(abilityCd) .. "s cooldown") or "", Font = Enum.Font.GothamBold, TextSize = 17,
			TextColor3 = Color3.fromRGB(255, 160, 236), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -18, 0, 22), Size = UDim2.fromOffset(140, 24),
			TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 41, TextTransparency = 1 })
		local desc = text(card, { Name = "AbilityDesc", Text = abilityDesc or "", Font = Enum.Font.GothamMedium, TextSize = 21, TextColor3 = Color3.fromRGB(222, 226, 242),
			Size = UDim2.new(1, -40, 0, 66), Position = UDim2.fromOffset(20, 58), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = 41, TextTransparency = 1 })
		u.card = card
		tween(card, 0.45, { BackgroundTransparency = 0.22 })
		tween(cst, 0.45, { Transparency = 0.45 })
		for _, l in ipairs({ title, cd, desc }) do tween(l, 0.5, { TextTransparency = 0 }) end
	end)
	at(T.ui + 0.6, function()
		-- NEW! stamp, top left: ONLY on the player's first-ever Infinity
		if not info.isNew then return end
		local cols = mythicColors()
		local stamp = scaled(inst("Frame", { Name = "NewStamp", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 110 * SC, 0, 52 * SC),
			Size = UDim2.fromOffset(150, 62), BackgroundColor3 = PURE, Rotation = -8, ZIndex = 45 }, band))
		corner(stamp, 14) stroke(stamp, PURE, 3, 0)
		inst("UIGradient", { Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, cols[1]), ColorSequenceKeypoint.new(1, cols[3]) }) }, stamp)
		local nt = text(stamp, { Text = "NEW!", Font = Enum.Font.FredokaOne, TextSize = 40, Size = UDim2.fromScale(1, 1), ZIndex = 46, TextWrapped = false })
		tstroke(nt, Color3.fromRGB(110, 16, 76), 2.5, 0)
		local us = stamp:FindFirstChildOfClass("UIScale")
		if us then us.Scale = SC * 1.8 tween(us, 0.28, { Scale = SC }, Enum.EasingStyle.Back) end
		u.stamp = stamp
	end)
	-- the speech box: types the line, then holds with "Tap to continue"
	at(T.speech, function()
		local box = scaled(inst("Frame", { Name = "SpeechBox", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -14 * SC),
			Size = UDim2.fromOffset(760, 96), BackgroundColor3 = INK, BackgroundTransparency = 1, ZIndex = 40 }, band))
		corner(box, 16)
		local bst = stroke(box, MAG, 1.6, 1)
		local tag = inst("Frame", { Name = "Speaker", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(26, 0), Size = UDim2.fromOffset(150, 30),
			BackgroundColor3 = Color3.fromRGB(226, 64, 143), ZIndex = 41, BackgroundTransparency = 1 }, box)
		corner(tag, 8)
		local tagT = text(tag, { Text = "Infinity", Font = Enum.Font.Michroma, TextSize = 15, Size = UDim2.fromScale(1, 1), ZIndex = 42, TextTransparency = 1, TextWrapped = false })
		local line = text(box, { Name = "Speech", Text = sceneDef.speech, Font = Enum.Font.GothamBold, TextSize = 30, Size = UDim2.new(1, -60, 0, 44),
			Position = UDim2.fromOffset(30, 26), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 41, MaxVisibleGraphemes = 0 })
		local hint = text(box, { Name = "TapHint", Text = "Tap to continue", Font = Enum.Font.GothamMedium, TextSize = 18, TextColor3 = Color3.fromRGB(235, 220, 245),
			AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -18, 1, -8), Size = UDim2.fromOffset(200, 20), TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 41, TextTransparency = 1 })
		u.speech, u.hint = line, hint
		tween(box, 0.35, { BackgroundTransparency = 0.18 })
		tween(bst, 0.35, { Transparency = 0.4 })
		tween(tag, 0.35, { BackgroundTransparency = 0 })
		tween(tagT, 0.35, { TextTransparency = 0 })
		local n = utf8.len(sceneDef.speech) or #sceneDef.speech
		local t0 = now() + 0.25
		every(function(t)
			if not line.Parent then return false end
			local m = math.clamp(math.floor((t - t0) * 20), 0, n)
			line.MaxVisibleGraphemes = m
			if m >= n then
				hint.TextTransparency = 0.2 + 0.4 * (0.5 + 0.5 * math.sin(t * 3.2))
			end
			return true
		end)
	end)

	-- closing: a tap/click anywhere on the reveal (or A / Enter) closes it and restores everything
	local function close()
		if st.done then return end
		finish(st, true)
	end
	local tapper = nil
	at(T.tapOk, function()
		tapper = inst("TextButton", { Name = "TapToClose", Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 70,
			AutoButtonColor = false }, uiRoot)
		lockFont(tapper, faceOf(Enum.Font.GothamBold))
		tapper.Activated:Connect(close)
	end)

	-- NO skip: nothing before the reveal reacts to taps or keys; the reveal closes on a tap / A / Enter after T.tapOk
	table.insert(st.conns, UIS.InputBegan:Connect(function(input)
		local kc = input.KeyCode
		if kc == Enum.KeyCode.ButtonA or kc == Enum.KeyCode.ButtonB or kc == Enum.KeyCode.Return or kc == Enum.KeyCode.KeypadEnter then
			if now() >= T.tapOk then close() end
		end
	end))
end

-- =====================================================================================================================
-- TRIGGER: the server says this player rolled a cutscene blessing (or an owner typed /infinitycutscene)
-- =====================================================================================================================
local preloaded = false
local function preload(maxWait)
	if preloaded then return end
	local list = {}
	local function addImg(id) local im = Instance.new("ImageLabel") im.Image = id table.insert(list, im) end
	for _, id in pairs(IMG) do
		if type(id) == "table" then for _, sid in pairs(id) do addImg(sid) end else addImg(id) end
	end
	for _, id in pairs(SND) do local s = Instance.new("Sound") s.SoundId = id table.insert(list, s) end
	local done = false
	task.spawn(function()
		pcall(function() ContentProvider:PreloadAsync(list) end)
		done = true
		preloaded = true
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

local function start(info)
	if type(info) ~= "table" or not SCENES[info.blessing] then return end
	if busy then
		pending = function() start(info) end
		return
	end
	busy = true
	local t0 = os.clock()
	task.spawn(function()
		local ok, err = pcall(function()
			if info.source == "roll" then
				task.spawn(preload, 0)
				waitForRollReveal(info.blessing, t0)
			else
				preload(2.5)
			end
			if player:GetAttribute("InRound") then busy = false return end
			-- the sound bank: made + preloaded now; wait (bounded) until every cue reports loaded, then log what loaded
			local bank = makeBank()
			pcall(function()
				local list = {}
				for _, s in pairs(bank.s) do table.insert(list, s) end
				ContentProvider:PreloadAsync(list)
			end)
			local tw = os.clock()
			while os.clock() - tw < 2.5 do
				local all = true
				for _, s in pairs(bank.s) do if not s.IsLoaded then all = false break end end
				if all then break end
				task.wait(0.05)
			end
			audioReport(bank)
			if player:GetAttribute("InRound") then bank.folder:Destroy() busy = false return end
			info.bank = bank
			run(info)
		end)
		if not ok then
			warn("[SOPRollCutscene] " .. tostring(err))
			if S then abort(S) else busy = false end
		end
	end)
end

local remote = RS:WaitForChild("SOPRollCutscene", 60)
if remote then
	remote.OnClientEvent:Connect(start)
end
-- warm the art in the background so the first cutscene starts sharp
task.delay(20, function() preload(0) end)
