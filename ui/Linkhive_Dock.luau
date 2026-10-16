--[[
	Linkhive_Dock.luau — the floating quick-access dock.

	Two draggable pills pinned to the top-right of the overlay ScreenGui:
	one flips the "Player > Movement > Speed Boost" toggle, the other locks
	the dock in place. Drawn with the Linkhive toolkit (Linkhive_UI.luau).

	Fetched remotely by LH.lua: HttpGet -> disk cache -> loadstring.

	Contract: `return function(ctx) -> table`
		ctx.ui         the Linkhive_UI toolkit
		ctx.gui        the overlay ScreenGui
		ctx.services   { TweenService, UserInputService }
		ctx.lib        the hub library table (for lib.handles)
		ctx.store      the persisted settings table
		ctx.setStored  function(key, value)

	Returns { Build() }.

	----------------------------------------------------------------------
	SOURCE OF TRUTH for this surface. Edit UI behaviour HERE, never in
	LH.lua (the hub keeps no UI body). After editing, keep the
	hub ctx (LH.lua), LH.comments.md and AGENTS.md in
	sync, then re-verify with luau-compile + the adapter smoke test.
]]

return function(ctx)
	ctx = ctx or {}
	local ui = ctx.ui
	if not (ui and ui.C) then return {} end

	local C = ui.C
	local gui = ctx.gui
	local corner = ui.corner
	local addLivingStroke = ui.addLivingStroke
	local TweenService = (ctx.services and ctx.services.TweenService) or game:GetService("TweenService")
	local UIS = (ctx.services and ctx.services.UserInputService) or game:GetService("UserInputService")
	local lib = ctx.lib
	local store = ctx.store or {}
	local setStored = ctx.setStored or function() end

	--!mv:omit
	local function buildDock()
		local SZ, GAP, TOP, RIGHT = 44, 8, 66, 10
		local locked = store["Dock>Locked"] == true
		local defs = {
			{id = "speed", label = "Speed"}, {id = "lock", label = "Lock"},
		}
		for i, def in ipairs(defs) do
			local col, rw = (i - 1) % 2, math.floor((i - 1) / 2)
			local btn = Instance.new("TextButton", gui)
			btn.Name = "YE_Float_" .. def.id
			btn.Size = UDim2.new(0, SZ, 0, SZ)
			btn.Position = UDim2.new(1, -(SZ * 2 + GAP + RIGHT) + col * (SZ + GAP), 0, TOP + rw * (SZ + GAP))
			btn.BackgroundColor3 = C.ROW; btn.BackgroundTransparency = 0.2; btn.BorderSizePixel = 0
			btn.Text = ""; btn.AutoButtonColor = false; btn.ZIndex = 500; btn.Active = true
			corner(btn, 12); addLivingStroke(btn, 1.5)
			local l = Instance.new("TextLabel", btn)
			l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = def.label
			l.TextColor3 = C.TEXT; l.Font = Enum.Font.GothamBold; l.TextSize = 9; l.TextWrapped = true; l.ZIndex = 501
			local glow = Instance.new("UIStroke", btn)
			glow.Thickness = 2.5; glow.Color = C.GREEN; glow.Transparency = 1
			glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			local dot = Instance.new("Frame", btn)
			dot.Size = UDim2.new(0, 7, 0, 7); dot.Position = UDim2.new(1, -11, 0, 4)
			dot.BackgroundColor3 = C.GREEN; dot.BorderSizePixel = 0; dot.Visible = false; dot.ZIndex = 502
			corner(dot, 4)
			local function mark(on)
				dot.Visible = on == true
				TweenService:Create(glow, TweenInfo.new(0.25), {Transparency = on == true and 0.45 or 1}):Play()
			end
			local dragging, ds, dp, moved = false, nil, nil, false
			btn.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					dragging = not locked; ds = inp.Position; dp = btn.Position; moved = false
				end
			end)
			UIS.InputChanged:Connect(function(inp)
				if not dragging then return end
				if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
					local d = inp.Position - ds
					if d.Magnitude > 4 then moved = true end
					btn.Position = UDim2.new(dp.X.Scale, dp.X.Offset + d.X, dp.Y.Scale, dp.Y.Offset + d.Y)
				end
			end)
			UIS.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
			end)
			btn.MouseButton1Click:Connect(function()
				if moved then return end
				if def.id == "speed" then
					local hd = lib.handles["Player>Movement>Speed Boost"]
					if hd then hd:Set(not hd:Get(), true) end
				elseif def.id == "lock" then
					locked = not locked; setStored("Dock>Locked", locked); mark(locked)
				end
			end)
			if def.id == "speed" then
				task.spawn(function()
					while btn.Parent do
						local hd = lib.handles["Player>Movement>Speed Boost"]
						mark(hd and hd:Get())
						task.wait(0.5)
					end
				end)
			else
				mark(locked)
			end
		end
	end

	return { Build = buildDock }
end
