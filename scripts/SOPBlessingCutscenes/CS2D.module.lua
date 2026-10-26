-- CS2D (Tab, Oct 25 2026, SOP Test v492, a build task; v497 a build task: + crop / wipe / atlas rects / tiled textures for the
-- Berserker, Necromancer, Phoenix, Seraph packs; data without those flags plays exactly as before): the generic 2D cutscene player for StarterPlayerScripts.SOPBlessingCutscenes.
-- Replays a "port pack" (layers.json from the cutscene builders: per-layer segments of keyframes x,y,w,h,rot,tr,color,cell in 0-1 stage
-- coords) as ImageLabels on a 16:9 stage, 30 fps, clocked by the soundtrack's TimePosition (wall clock if the sound is not playing).
-- A scene module only carries data: M.key, M.DUR, M.RAW, M.NDATA, M.TEX (textures with first/last use + sheet grid), M.CUES (track),
-- and <key>Data1..N ModuleScripts (LZ4 + base64 binary keyframes, made by the build script). To add a blessing: build its data, add the
-- modules, map it in SOPBlessingCutsceneServer.SCENES. No game logic here: only GUI under the cutscene's own root (run2D restores all).
-- Texture memory: only textures needed now and in the next ~1.3 s are held (rolling invisible holders); labels drop their image after
-- the texture's last use. NO wider preloading: v493 (preload all) and v494 (4 s download-ahead) both overflowed the low-end client's
-- texture budget and every plate went soft. A big plate that is late keeps the previous plate on screen instead of going black. Only exit: "Tap to continue" at the end.
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

local CS2D = {}
local B64 = {}
do
	local al = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	for i = 1, 64 do B64[string.byte(al, i)] = i - 1 end
end
local function unb64(s)
	local n = #s
	local pad = (string.sub(s, -2) == "==" and 2) or (string.sub(s, -1) == "=" and 1) or 0
	local out = buffer.create(n // 4 * 3 - pad)
	local len, o = buffer.len(out), 0
	for i = 1, n, 4 do
		local a, b, c, d = string.byte(s, i, i + 3)
		local v = B64[a] * 262144 + B64[b] * 4096 + (B64[c] or 0) * 64 + (B64[d] or 0)
		buffer.writeu8(out, o, bit32.rshift(v, 16))
		if o + 1 < len then buffer.writeu8(out, o + 1, bit32.band(bit32.rshift(v, 8), 255)) end
		if o + 2 < len then buffer.writeu8(out, o + 2, bit32.band(v, 255)) end
		o += 3
	end
	return out
end
local function unlz4(src, rawLen)
	local dst = buffer.create(rawLen)
	local ip, op, n = 0, 0, buffer.len(src)
	while ip < n do
		local tok = buffer.readu8(src, ip) ip += 1
		local lit = bit32.rshift(tok, 4)
		if lit == 15 then repeat local b = buffer.readu8(src, ip) ip += 1 lit += b until b ~= 255 end
		if lit > 0 then buffer.copy(dst, op, src, ip, lit) ip += lit op += lit end
		if ip >= n then break end
		local off = buffer.readu16(src, ip) ip += 2
		local ml = bit32.band(tok, 15)
		if ml == 15 then repeat local b = buffer.readu8(src, ip) ip += 1 ml += b until b ~= 255 end
		ml += 4
		local mp = op - off
		if off >= ml then buffer.copy(dst, op, dst, mp, ml)
		else for i = 0, ml - 1 do buffer.writeu8(dst, op + i, buffer.readu8(dst, mp + i)) end end
		op += ml
	end
	return dst
end

local cache = {}
local function decode(M, base)
	if cache[M.key] then return cache[M.key] end
	local parts = {}
	for i = 1, M.NDATA do
		local ms = base:FindFirstChild(M.key .. "Data" .. i)
		assert(ms, M.key .. "Data" .. i .. " missing")
		parts[i] = require(ms)
	end
	local D = unlz4(unb64(table.concat(parts)), M.RAW)
	local o = 0
	local function u8() local v = buffer.readu8(D, o) o += 1 return v end
	local function u16() local v = buffer.readu16(D, o) o += 2 return v end
	local function i16() local v = buffer.readi16(D, o) o += 2 return v end
	local function f32() local v = buffer.readf32(D, o) o += 4 return v end
	local nL = u16()
	local nT = u16()
	assert(nT == #M.TEX, "texture count mismatch")
	local layers = {}
	for li = 1, nL do
		local L = { tex = u16(), z = i16(), segs = {} }
		local ns = u16()
		for si = 1, ns do
			local s = { a = f32(), b = f32() }
			local n = u16()
			local fl = u8()
			s.n = n
			s.toff = o
			o += 2 * n
			local function chan()
				if u8() == 0 then return { c = f32() } end
				local c = { mn = f32(), sc = f32(), off = 0 }
				c.off = o
				o += 2 * n
				return c
			end
			s.ch = { chan(), chan(), chan(), chan(), chan(), chan() }
			if bit32.band(fl, 1) ~= 0 then s.col = { chan(), chan(), chan() } end
			if bit32.band(fl, 2) ~= 0 then
				if u8() == 0 then s.cell = { c = u16() } else s.cell = { off = o } o += 2 * n end
			end
			-- v497 extensions (absent from the Judas/KW data, so their playback is unchanged): 4 = crop (fraction of the cell/texture shown
			-- from the left/top -> ImageRectSize), 8 = wipe (fraction hidden from the top -> UIGradient)
			if bit32.band(fl, 4) ~= 0 then s.crop = { chan(), chan() } end
			if bit32.band(fl, 8) ~= 0 then s.wipe = chan() end
			L.segs[si] = s
		end
		layers[li] = L
	end
	assert(o == buffer.len(D), "data length mismatch")
	-- draw order = the emulator's: by z, ties by layer order (each layer its own ZIndex rank, so same-z siblings never swap)
	local order = {}
	for li = 1, nL do order[li] = li end
	table.sort(order, function(a, b) if layers[a].z ~= layers[b].z then return layers[a].z < layers[b].z end return a < b end)
	for rank, li in ipairs(order) do layers[li].zi = rank + 1 end
	local d = { D = D, layers = layers }
	cache[M.key] = d
	return d
end
CS2D.decode = decode

function CS2D.play(C, M, base)
	local st, root = C.st, C.root
	local data = decode(M, base)
	local D, layers = data.D, data.layers
	local TEX = M.TEX
	local FPS = M.FPS or 30
	local DUR = M.DUR
	local LASTT = M.HOLD or ((math.floor(DUR * FPS + 0.5) - 1) / FPS) -- M.HOLD: freeze on the reveal before a fade-out ending
	local WARM = M.WARM or 1.3
	local WARMBIG = M.WARMBIG or WARM
	root.BackgroundColor3 = Color3.new(0, 0, 0)
	root.BackgroundTransparency = 0
	local stage = Instance.new("Frame")
	stage.Name = "Stage" stage.BackgroundTransparency = 1 stage.BorderSizePixel = 0 stage.ClipsDescendants = true
	stage.AnchorPoint = Vector2.new(0.5, 0.5) stage.Position = UDim2.fromScale(0.5, 0.5) stage.Size = UDim2.fromScale(1, 1) stage.ZIndex = 2
	stage.Parent = root
	local masks = {}
	for i = 1, 4 do
		local f = Instance.new("Frame")
		f.Name = "Bar" .. i f.BackgroundColor3 = Color3.new(0, 0, 0) f.BackgroundTransparency = 0 f.BorderSizePixel = 0 f.ZIndex = 3
		f.Size = UDim2.fromOffset(0, 0) f.Parent = root
		masks[i] = f
	end
	local cam = workspace.CurrentCamera
	local lastW, lastH = -1, -1
	local function layout()
		local v = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
		pcall(function() local a = root.AbsoluteSize if a.X > 10 then v = a end end)
		local w, h = v.X, v.Y
		if w / math.max(h, 1) > 16 / 9 then w = h * 16 / 9 else h = w * 9 / 16 end
		w, h = math.floor(w + 0.5), math.floor(h + 0.5)
		if w ~= lastW or h ~= lastH then
			lastW, lastH = w, h
			stage.Size = UDim2.fromOffset(w, h)
			-- black bars over everything outside the 16:9 stage (top, bottom, left, right)
			local bw, bh = (v.X - w) / 2, (v.Y - h) / 2
			masks[1].Position = UDim2.fromOffset(0, 0) masks[1].Size = UDim2.new(1, 0, 0, math.max(0, math.ceil(bh)))
			masks[2].Position = UDim2.new(0, 0, 1, -math.max(0, math.ceil(bh))) masks[2].Size = UDim2.new(1, 0, 0, math.max(0, math.ceil(bh)))
			masks[3].Position = UDim2.fromOffset(0, 0) masks[3].Size = UDim2.new(0, math.max(0, math.ceil(bw)), 1, 0)
			masks[4].Position = UDim2.new(1, -math.max(0, math.ceil(bw)), 0, 0) masks[4].Size = UDim2.new(0, math.max(0, math.ceil(bw)), 1, 0)
		end
	end
	layout()
	-- rolling texture holders (invisible, under the stage)
	local holders = {}
	for j = 1, (M.NHOLD or 40) do
		local im = Instance.new("ImageLabel")
		-- full-stage size (behind every layer): the engine streams a texture at the mip its label is drawn at, so a tiny holder
		-- only warmed a blurry low mip (cs495a: the KW world showed blocky for seconds after each sheet switch)
		im.Name = "Warm" im.BackgroundTransparency = 1 im.Size = UDim2.fromScale(1, 1) im.Position = UDim2.fromScale(0.5, 0.5)
		im.AnchorPoint = Vector2.new(0.5, 0.5) im.ImageTransparency = 0.995 im.ZIndex = 1 im.Visible = false im.Parent = stage
		holders[j] = im
	end
	local requested = {}
	local function warm(t)
		local list = {}
		for i, tx in ipairs(TEX) do
			if tx[2] - (tx[8] and WARMBIG or WARM) <= t and t <= tx[3] + 0.05 then table.insert(list, i) end
		end
		table.sort(list, function(a, b) return TEX[a][2] < TEX[b][2] end)
		local fresh = {}
		for j, im in ipairs(holders) do
			local i = list[j]
			if i then
				if im.Image ~= TEX[i][1] then
					im.Image = TEX[i][1]
					-- M.NATIVEHOLD (v497 scenes with up to ~65 textures in a 1.3 s window): the holder is drawn at the texture's own pixel size
					-- (capped at the stage) instead of full-stage, so a small sprite still warms its full-res mip without a full-screen overdraw each
					if M.NATIVEHOLD and TEX[i].tw then im.Size = UDim2.fromOffset(math.min(TEX[i].tw, math.max(lastW, 1)), math.min(TEX[i].th, math.max(lastH, 1))) end
				end
				im.Visible = true
				if not requested[i] then requested[i] = true table.insert(fresh, im) end
			elseif im.Visible then
				im.Visible = false im.Image = ""
			end
		end
		if #fresh > 0 then task.spawn(function() pcall(function() ContentProvider:PreloadAsync(fresh) end) end) end
		return list
	end
	-- the first textures must be in memory before frame 0 (black meanwhile, max ~5 s)
	do
		local list = warm(0)
		local w0 = os.clock()
		while not st.done and os.clock() - w0 < 5 do
			local all = true
			for j = 1, math.min(#list, #holders) do if not holders[j].IsLoaded then all = false break end end
			if all then break end
			task.wait(0.1)
		end
		if st.done then return end
	end
	-- one ImageLabel per layer, made on first use
	local labs = {}
	local function labFor(li)
		local L = labs[li]
		if L then return L end
		local o = Instance.new("ImageLabel")
		o.Name = "L" .. li o.BackgroundTransparency = 1 o.BorderSizePixel = 0 o.AnchorPoint = Vector2.new(0.5, 0.5)
		o.ScaleType = Enum.ScaleType.Stretch o.ZIndex = layers[li].zi o.Visible = false
		local tx = TEX[layers[li].tex]
		if tx[4] then o.ImageRectSize = Vector2.new(tx[6], tx[7]) end
		if tx.tile then o.ScaleType = Enum.ScaleType.Tile end
		o.Parent = stage
		L = { o = o, vis = false, img = "", x = -9, y = -9, w = -9, h = -9, r = -999, tr = -9, cr = -9, cg = -9, cb = -9, cell = -1 }
		labs[li] = L
		return L
	end
	local function tk(s, k) return buffer.readu16(D, s.toff + 2 * k) / 1000 end
	local function cv(c, k, f)
		if c.c then return c.c end
		local a = c.mn + c.sc * buffer.readu16(D, c.off + 2 * k)
		if f > 0 then local b = c.mn + c.sc * buffer.readu16(D, c.off + 2 * k + 2) return a + (b - a) * f end
		return a
	end
	for _, L in ipairs(layers) do for _, s in ipairs(L.segs) do s.k = 0 end end
	local nVis, peakVis = 0, 0
	local pendZ = {}
	local function drawAt(t)
		nVis = 0
		table.clear(pendZ)
		for li, Ld in ipairs(layers) do
			local seg = nil
			for _, s in ipairs(Ld.segs) do if t >= s.a and t < s.b then seg = s break end end
			local L = labs[li]
			if seg then
				L = L or labFor(li)
				local o = L.o
				local tx = TEX[Ld.tex]
				if L.img ~= tx[1] then L.img = tx[1] o.Image = tx[1] L.loaded = false end
				local k = seg.k
				if k > 0 and tk(seg, k) > t then k = 0 end
				while k + 1 < seg.n and tk(seg, k + 1) <= t + 1e-4 do k += 1 end
				seg.k = k
				local f = 0
				if k + 1 < seg.n then
					local t0, t1 = tk(seg, k), tk(seg, k + 1)
					if t1 > t0 and t > t0 then f = math.clamp((t - t0) / (t1 - t0), 0, 1) end
				end
				local ch = seg.ch
				local x, y, w, h, r, tr = cv(ch[1], k, f), cv(ch[2], k, f), cv(ch[3], k, f), cv(ch[4], k, f), cv(ch[5], k, f), cv(ch[6], k, f)
				if x ~= L.x or y ~= L.y then L.x, L.y = x, y o.Position = UDim2.fromScale(x, y) end
				if w ~= L.w or h ~= L.h then L.w, L.h = w, h o.Size = UDim2.fromScale(w, h) end
				if r ~= L.r then L.r = r o.Rotation = r end
				tr = math.clamp(tr, 0, 1)
				if tr ~= L.tr then L.tr = tr o.ImageTransparency = tr end
				local cr, cg, cb = 1, 1, 1
				if seg.col then cr, cg, cb = math.clamp(cv(seg.col[1], k, f), 0, 1), math.clamp(cv(seg.col[2], k, f), 0, 1), math.clamp(cv(seg.col[3], k, f), 0, 1) end
				if cr ~= L.cr or cg ~= L.cg or cb ~= L.cb then L.cr, L.cg, L.cb = cr, cg, cb o.ImageColor3 = Color3.new(cr, cg, cb) end
				if seg.cell and tx[4] then
					local cell = seg.cell.c or buffer.readu16(D, seg.cell.off + 2 * k)
					if cell ~= L.cell then
						L.cell = cell
						o.ImageRectOffset = Vector2.new((cell % tx[4]) * tx[6], (cell // tx[4]) * tx[7])
					end
				elseif seg.cell and tx.rects then -- atlas sheet: explicit rect per cell
					local cell = seg.cell.c or buffer.readu16(D, seg.cell.off + 2 * k)
					if cell ~= L.cell then
						L.cell = cell
						local rr = tx.rects
						o.ImageRectOffset = Vector2.new(rr[cell * 4 + 1], rr[cell * 4 + 2])
						if not seg.crop then o.ImageRectSize = Vector2.new(rr[cell * 4 + 3], rr[cell * 4 + 4]) end
						L.ck = nil
					end
				end
				if seg.crop then
					local cx, cy = math.clamp(cv(seg.crop[1], k, f), 0, 1), math.clamp(cv(seg.crop[2], k, f), 0, 1)
					local bw, bh
					if tx[4] then bw, bh = tx[6], tx[7]
					elseif tx.rects and L.cell >= 0 then bw, bh = tx.rects[L.cell * 4 + 3], tx.rects[L.cell * 4 + 4]
					else bw, bh = tx.tw, tx.th end
					local sw, sh = math.max(1, math.floor(bw * cx + 0.5)), math.max(1, math.floor(bh * cy + 0.5))
					local ck = sw * 65536 + sh
					if ck ~= L.ck then L.ck = ck o.ImageRectSize = Vector2.new(sw, sh) end
				elseif L.ck then
					L.ck = nil
					if tx[4] then o.ImageRectSize = Vector2.new(tx[6], tx[7])
					elseif tx.rects and L.cell >= 0 then o.ImageRectSize = Vector2.new(tx.rects[L.cell * 4 + 3], tx.rects[L.cell * 4 + 4])
					else o.ImageRectSize = Vector2.new(0, 0) end
				end
				if seg.wipe then
					local wp = cv(seg.wipe, k, f)
					if wp ~= L.wp then
						L.wp = wp
						local g = L.grad
						if wp <= 0.0005 then
							if g then g.Enabled = false end
						else
							if not g then g = Instance.new("UIGradient") g.Rotation = 90 g.Parent = o L.grad = g end
							local a = math.clamp(wp, 0.0005, 0.978)
							g.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(a, 1),
								NumberSequenceKeypoint.new(a + 0.02, 0), NumberSequenceKeypoint.new(1, 0) })
							g.Enabled = true
						end
					end
				elseif L.grad and L.wp then
					L.wp = nil L.grad.Enabled = false
				end
				if tx.tile and L.tileH ~= lastH then
					L.tileH = lastH
					local px = tx.tile * lastH / 720
					o.TileSize = UDim2.fromOffset(px, px)
				end
				if not L.vis then L.vis = true o.Visible = true end
				if tr < 0.999 then nVis += 1 end
				if tx[8] then
					if not L.loaded then L.loaded = o.IsLoaded end
					if not L.loaded then pendZ[Ld.z] = true end
				end
				L.on = true
			elseif L then
				L.on = false
			end
		end
		-- a big plate whose texture is still loading keeps the previous plate of the same z on screen (a held frame, never a black one)
		for li, Ld in ipairs(layers) do
			local L = labs[li]
			if L and not L.on then
				local keep = L.vis and pendZ[Ld.z] and L.loaded and TEX[Ld.tex][8]
				if not keep then
					if L.vis then L.vis = false L.o.Visible = false end
					if L.img ~= "" and t > TEX[Ld.tex][3] + 0.1 then L.img = "" L.o.Image = "" L.loaded = false end
				end
			end
		end
		if nVis > peakVis then peakVis = nVis end
	end
	CS2D.lastPeak = function() return peakVis end
	local snd = C.bank and C.bank.s and C.bank.s.track
	local t0 = nil
	local ended = false
	local lastFi = -1
	local lastWarm = -1
	local function finishUi()
		if ended then return end
		ended = true
		local hint = Instance.new("TextLabel")
		hint.Name = "TapHint" hint.BackgroundTransparency = 1 hint.Text = "Tap to continue" hint.TextSize = 20
		hint.TextColor3 = M.HINT or Color3.fromRGB(235, 232, 225) hint.AnchorPoint = Vector2.new(0.5, 1)
		hint.Position = UDim2.new(0.5, 0, 0.965, 0) hint.Size = UDim2.fromOffset(400, 30) hint.ZIndex = 5000 hint.TextTransparency = 1
		hint.TextStrokeTransparency = 0.6
		hint.Parent = root
		pcall(function() if C.lockFont then C.lockFont(hint, C.faceOf(Enum.Font.GothamMedium)) end end)
		local tapper = Instance.new("TextButton")
		tapper.Name = "TapToClose" tapper.Text = "" tapper.BackgroundTransparency = 1 tapper.Size = UDim2.fromScale(1, 1) tapper.ZIndex = 5001
		tapper.AutoButtonColor = false tapper.Parent = root
		tapper.Activated:Connect(function() C.close() end)
		table.insert(st.conns, UIS.InputBegan:Connect(function(input)
			local kc = input.KeyCode
			if kc == Enum.KeyCode.ButtonA or kc == Enum.KeyCode.ButtonB or kc == Enum.KeyCode.Return or kc == Enum.KeyCode.KeypadEnter or kc == Enum.KeyCode.Space then C.close() end
		end))
		local h0 = os.clock()
		table.insert(st.conns, RunService.RenderStepped:Connect(function()
			local e = os.clock() - h0
			if e < 0.5 then hint.TextTransparency = 1 - 0.8 * (e / 0.5) else hint.TextTransparency = 0.2 + 0.35 * (0.5 + 0.5 * math.sin((e - 0.5) * 3.2)) end
		end))
	end
	RunService:BindToRenderStep("SOPBlessingCutscene", Enum.RenderPriority.Last.Value, function()
		if st.done then return end
		local nowc = os.clock()
		if not t0 then
			t0 = nowc
			if snd then pcall(function() snd.TimePosition = 0 snd:Play() end) end
		end
		layout()
		local tp = nowc - t0
		if snd and snd.IsPlaying and snd.TimeLength > 0 then
			local sp = snd.TimePosition
			if sp > 0 then tp = sp end
		end
		if tp - lastWarm >= 0.25 or tp < lastWarm then lastWarm = tp warm(tp) end
		local fi = math.floor(tp * FPS + 1e-4)
		local t = fi / FPS
		if t >= LASTT then
			t = LASTT
			fi = math.floor(LASTT * FPS + 0.5)
			if not ended then finishUi() end
		end
		if fi ~= lastFi then
			lastFi = fi
			drawAt(t)
		end
	end)
end

return CS2D
