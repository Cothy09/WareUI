-- ui/Library.lua
-- A sleek, website-like UI library for Roblox
-- API Overview:
-- local Library = require(path.to.Library)
-- local Window = Library:CreateWindow({ Title = "My App", Subtitle = "v1.0", Theme = "Dark" })
-- local Tab = Window:AddTab({ Title = "Home", Icon = "🏠" })
-- local Section = Tab:AddSection("Quick Actions")
-- Section:AddButton({ Text = "Do Thing", Callback = function() end })
-- Section:AddToggle({ Text = "God Mode", Default = false, Callback = function(value) end })
-- Section:AddSlider({ Text = "Speed", Min = 0, Max = 100, Default = 25, Suffix = "%", Callback = function(value) end })
-- Section:AddInput({ Placeholder = "Type here...", Default = "", ClearTextOnFocus = false, Callback = function(text) end })
-- Section:AddDropdown({ Text = "Mode", Options = {"Easy","Normal","Hard"}, Default = "Normal", Callback = function(value) end })
-- Tab:Notify({ Text = "Welcome!", Variant = "success" })

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Themes = {
    Dark = {
        Panel = Color3.fromRGB(30, 30, 30),
        Card = Color3.fromRGB(40, 40, 40),
        Muted = Color3.fromRGB(60, 60, 60),
        Accent = Color3.fromRGB(0, 170, 255),
        AccentHover = Color3.fromRGB(0, 200, 255),
        Stroke = Color3.fromRGB(0,0,0),
        TextPrimary = Color3.fromRGB(255,255,255),
        TextSecondary = Color3.fromRGB(200,200,200),
        Success = Color3.fromRGB(0, 255, 0),
        Warning = Color3.fromRGB(255, 255, 0),
        Danger = Color3.fromRGB(255, 0, 0),
        Shadow = Color3.fromRGB(0,0,0),
        ShadowTransparency = 0.5,
        Font = Enum.Font.Gotham
    }
}

local Library = {}
Library.__index = Library

local function create(instance, props)
	local obj = Instance.new(instance)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function tween(obj, info, props)
	return TweenService:Create(obj, info, props)
end

local function applyStroke(instance, color)
	local stroke = create("UIStroke", {
		Parent = instance,
		Color = color,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Transparency = 0.25
	})
	return stroke
end

local function rounded(instance, radius)
	create("UICorner", { Parent = instance, CornerRadius = UDim.new(0, radius or 8) })
end

local function shadow(parent, theme)
	-- Subtle drop shadow using an image
	local s = create("ImageLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageTransparency = theme.ShadowTransparency,
		ImageColor3 = theme.Shadow,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(0, 6),
		ZIndex = 0
	})
	return s
end

local function ripple(button, theme)
	-- Simple ripple effect on click
	button.ClipsDescendants = true
	button.AutoButtonColor = false
	button.MouseButton1Click:Connect(function(x, y)
		local r = create("Frame", {
			Parent = button,
			BackgroundColor3 = theme.Accent,
			BackgroundTransparency = 0.85,
			Size = UDim2.fromOffset(0, 0),
			Position = UDim2.fromOffset(x - button.AbsolutePosition.X, y - button.AbsolutePosition.Y),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = (button.ZIndex or 1) + 1
		})
		rounded(r, 100)
		local max = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.2
		tween(r, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(max, max)
		}):Play()
		game:GetService("Debris"):AddItem(r, 0.55)
	end)
end

local function makeDraggable(frame, dragHandle)
	local dragging, dragStart, startPos
	dragHandle = dragHandle or frame
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Window class
local Window = {}
Window.__index = Window

function Library:CreateWindow(config)
	config = config or {}
	local theme = Themes[config.Theme or "Dark"] or Themes.Dark

	local screen = create("ScreenGui", {
		Name = "UI_Library",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	})

	local container = create("Frame", {
		Parent = screen,
		BackgroundColor3 = theme.Panel,
		Size = UDim2.fromOffset(720, 480),
		Position = UDim2.new(0.5, -360, 0.5, -240),
		ZIndex = 2
	})
	rounded(container, 14)
	applyStroke(container, theme.Stroke)
	shadow(container, theme)

	local header = create("Frame", {
		Parent = container,
		BackgroundColor3 = theme.Card,
		Size = UDim2.new(1, 0, 0, 64),
		ZIndex = 3
	})
	rounded(header, 14)
	applyStroke(header, theme.Stroke)

	local title = create("TextLabel", {
		Parent = header,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = tostring(config.Title or "App"),
		TextColor3 = theme.TextPrimary,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(20, 10),
		Size = UDim2.fromScale(0.6, 0.5),
		ZIndex = 4
	})

	local subtitle = create("TextLabel", {
		Parent = header,
		BackgroundTransparency = 1,
		Font = theme.Font,
		Text = tostring(config.Subtitle or ""),
		TextColor3 = theme.TextSecondary,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(20, 34),
		Size = UDim2.fromScale(0.6, 0.4),
		ZIndex = 4
	})

	local headerGrip = create("Frame", {
		Parent = header,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -160, 1, 0),
		Position = UDim2.fromOffset(0,0),
		ZIndex = 5
	})
	makeDraggable(container, headerGrip)

	local tabBar = create("Frame", {
		Parent = header,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 160, 0, 0),
		ZIndex = 4
	})

	local tabList = create("UIListLayout", {
		Parent = tabBar,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center
	})

	local content = create("Frame", {
		Parent = container,
		BackgroundColor3 = theme.Panel,
		Position = UDim2.fromOffset(0, 64),
		Size = UDim2.new(1, 0, 1, -64),
		ZIndex = 2,
		ClipsDescendants = true
	})

	local pages = {}
	local currentTab

	function Window:AddTab(tabConfig)
		tabConfig = tabConfig or {}
		local tabBtn = create("TextButton", {
			Parent = tabBar,
			AutoButtonColor = false,
			BackgroundColor3 = theme.Muted,
			Size = UDim2.fromOffset(120, 36),
			Text = string.format("%s %s", tabConfig.Icon or "", tabConfig.Title or "Tab"),
			TextColor3 = theme.TextPrimary,
			Font = theme.Font,
			TextSize = 14,
			ZIndex = 5
		})
		rounded(tabBtn, 10)
		applyStroke(tabBtn, theme.Stroke)
		ripple = ripple(tabBtn, theme)

		local page = create("ScrollingFrame", {
			Parent = content,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarThickness = 6,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 2
		})

		local padding = create("UIPadding", {
			Parent = page,
			PaddingTop = UDim.new(0, 16),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16)
		})

		local pageList = create("UIListLayout", {
			Parent = page,
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 12)
		})

		local Tab = {}
		Tab.__index = Tab

		function Tab:Show()
			if currentTab == page then return end
			for _, pg in pairs(pages) do pg.Visible = false end
			page.Visible = true
			currentTab = page
		end

		function Tab:AddSection(titleText)
			local card = create("Frame", {
				Parent = page,
				BackgroundColor3 = theme.Card,
				Size = UDim2.new(1, -0, 0, 64),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 2
			})
			rounded(card, 12)
			applyStroke(card, theme.Stroke)

			local innerPad = create("UIPadding", {
				Parent = card,
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12)
			})

			local title = create("TextLabel", {
				Parent = card,
				BackgroundTransparency = 1,
				Font = theme.Font,
				Text = tostring(titleText or "Section"),
				TextColor3 = theme.TextPrimary,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -0, 0, 22),
				ZIndex = 3
			})

			local list = create("UIListLayout", {
				Parent = card,
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8)
			})

			local Section = {}
			Section.__index = Section

			local function addRow(height)
				local row = create("Frame", {
					Parent = card,
					BackgroundColor3 = theme.Muted,
					Size = UDim2.new(1, 0, 0, height or 40),
					ZIndex = 2
				})
				rounded(row, 10)
				applyStroke(row, theme.Stroke)
				return row
			end

			function Section:AddButton(opts)
				opts = opts or {}
				local row = addRow(40)
				local btn = create("TextButton", {
					Parent = row,
					BackgroundColor3 = theme.Accent,
					AutoButtonColor = false,
					Text = tostring(opts.Text or "Button"),
					TextColor3 = Color3.new(1,1,1),
					Font = theme.Font,
					TextSize = 14,
					Size = UDim2.fromOffset(140, 32),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					ZIndex = 3
				})
				rounded(btn, 8)
				applyStroke(btn, theme.Stroke)
				ripple = ripple(btn, theme)

				local label = create("TextLabel", {
					Parent = row,
					BackgroundTransparency = 1,
					Text = tostring(opts.Text or "Button"),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.TextPrimary,
					Font = theme.Font,
					TextSize = 14,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -160, 1, 0),
					ZIndex = 3
				})

				btn.MouseButton1Click:Connect(function()
					if typeof(opts.Callback) == "function" then
						task.spawn(opts.Callback)
					end
				end)
				return btn
			end

			function Section:AddToggle(opts)
				opts = opts or {}
				local state = opts.Default == true
				local row = addRow(40)
				local switch = create("Frame", {
					Parent = row,
					BackgroundColor3 = theme.Panel,
					Size = UDim2.fromOffset(44, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					ZIndex = 3
				})
				rounded(switch, 12)
				applyStroke(switch, theme.Stroke)

				local knob = create("Frame", {
					Parent = switch,
					BackgroundColor3 = state and theme.Accent or theme.Muted,
					Size = UDim2.fromOffset(20, 20),
					Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
					ZIndex = 4
				})
				rounded(knob, 10)

				local hit = create("TextButton", {
					Parent = switch,
					BackgroundTransparency = 1,
					Text = "",
					Size = UDim2.fromScale(1, 1)
				})
				ripple = ripple(hit, theme)

				local label = create("TextLabel", {
					Parent = row,
					BackgroundTransparency = 1,
					Text = tostring(opts.Text or "Toggle"),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.TextPrimary,
					Font = theme.Font,
					TextSize = 14,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -160, 1, 0),
					ZIndex = 3
				})

				local function set(v)
					state = v
					tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
						BackgroundColor3 = state and theme.Accent or theme.Muted
					}):Play()
					if typeof(opts.Callback) == "function" then task.spawn(opts.Callback, state) end
				end

				hit.MouseButton1Click:Connect(function()
					set(not state)
				end)

				return {
					Set = set,
					Get = function() return state end
				}
			end

			function Section:AddSlider(opts)
				opts = opts or {}
				local min = tonumber(opts.Min) or 0
				local max = tonumber(opts.Max) or 100
				local value = math.clamp(tonumber(opts.Default) or min, min, max)
				local row = addRow(48)

				local bar = create("Frame", {
					Parent = row,
					BackgroundColor3 = theme.Panel,
					Size = UDim2.new(0, 240, 0, 8),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					ZIndex = 3
				})
				rounded(bar, 4)
				applyStroke(bar, theme.Stroke)

				local fill = create("Frame", {
					Parent = bar,
					BackgroundColor3 = theme.Accent,
					Size = UDim2.fromScale((value - min) / (max - min), 1),
					ZIndex = 4
				})
				rounded(fill, 4)

				local label = create("TextLabel", {
					Parent = row,
					BackgroundTransparency = 1,
					Text = string.format("%s: %s%s", tostring(opts.Text or "Slider"), tostring(value), tostring(opts.Suffix or "")),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.TextPrimary,
					Font = theme.Font,
					TextSize = 14,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -260, 1, 0),
					ZIndex = 3
				})

				local sliding = false
				local function set(val)
					value = math.clamp(val, min, max)
					local alpha = (value - min) / math.max(1, (max - min))
					fill.Size = UDim2.fromScale(alpha, 1)
					label.Text = string.format("%s: %s%s", tostring(opts.Text or "Slider"), tostring(value), tostring(opts.Suffix or ""))
					if typeof(opts.Callback) == "function" then task.spawn(opts.Callback, value) end
				end

				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding = true
						set(min + (max - min) * ((input.Position.X - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X)))
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
						set(min + (max - min) * ((input.Position.X - bar.AbsolutePosition.X) / math.max(1, bar.AbsoluteSize.X)))
					end
				end)

				return { Set = set, Get = function() return value end }
			end

			function Section:AddInput(opts)
				opts = opts or {}
				local row = addRow(44)
				local input = create("TextBox", {
					Parent = row,
					BackgroundColor3 = theme.Panel,
					PlaceholderText = tostring(opts.Placeholder or "Type..."),
					Text = tostring(opts.Default or ""),
					ClearTextOnFocus = opts.ClearTextOnFocus == true,
					Size = UDim2.fromOffset(260, 32),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					TextColor3 = theme.TextPrimary,
					Font = theme.Font,
					TextSize = 14,
					ZIndex = 3
				})
				rounded(input, 8)
				applyStroke(input, theme.Stroke)

				local label = create("TextLabel", {
					Parent = row,
					BackgroundTransparency = 1,
					Text = tostring(opts.Text or "Input"),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.TextPrimary,
					Font = theme.Font,
					TextSize = 14,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -280, 1, 0),
					ZIndex = 3
				})

				input.FocusLost:Connect(function(enterPressed)
					if typeof(opts.Callback) == "function" then task.spawn(opts.Callback, input.Text, enterPressed) end
				end)

				return input
			end

			function Section:AddDropdown(opts)
				opts = opts or {}
				local options = opts.Options or {"Option"}
				local current = opts.Default or options[1]
				local open = false
				local row = addRow(44)

				local button = create("TextButton", {
					Parent = row,
					BackgroundColor3 = theme.Panel,
					AutoButtonColor = false,
					Text = tostring(current),
					TextColor3 = theme.TextPrimary,
					Font = theme.Font,
					TextSize = 14,
					Size = UDim2.fromOffset(260, 32),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					ZIndex = 4
				})
				rounded(button, 8)
				applyStroke(button, theme.Stroke)
				ripple = ripple(button, theme)

				local label = create("TextLabel", {
					Parent = row,
					BackgroundTransparency = 1,
					Text = tostring(opts.Text or "Dropdown"),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.TextPrimary,
					Font = theme.Font,
					TextSize = 14,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -280, 1, 0),
					ZIndex = 3
				})

				local menu = create("Frame", {
					Parent = row,
					BackgroundColor3 = theme.Card,
					Visible = false,
					Position = UDim2.new(1, -12, 1, 6),
					AnchorPoint = Vector2.new(1, 0),
					Size = UDim2.fromOffset(260, 0),
					ZIndex = 10
				})
				rounded(menu, 8)
				applyStroke(menu, theme.Stroke)

				local mList = create("UIListLayout", {
					Parent = menu,
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder
				})

				local function rebuild()
					for _, c in ipairs(menu:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, opt in ipairs(options) do
						local optBtn = create("TextButton", {
							Parent = menu,
							AutoButtonColor = false,
							BackgroundTransparency = 1,
							Text = tostring(opt),
							TextColor3 = theme.TextPrimary,
							Font = theme.Font,
							TextSize = 14,
							Size = UDim2.new(1, -12, 0, 32),
							ZIndex = 11
						})
						optBtn.MouseButton1Click:Connect(function()
							current = opt
							button.Text = tostring(current)
							open = false
							menu.Visible = false
							menu.Size = UDim2.fromOffset(260, 0)
							if typeof(opts.Callback) == "function" then task.spawn(opts.Callback, current) end
						end)
					end
					menu.Size = UDim2.fromOffset(260, #options * 32 + 8)
				end
				rebuild()

				button.MouseButton1Click:Connect(function()
					open = not open
					menu.Visible = open
					if open then
						menu.Size = UDim2.fromOffset(260, #options * 32 + 8)
					else
						menu.Size = UDim2.fromOffset(260, 0)
					end
				end)

				return {
					Set = function(v)
						current = v
						button.Text = tostring(current)
						if typeof(opts.Callback) == "function" then task.spawn(opts.Callback, current) end
					end,
					Get = function() return current end,
					SetOptions = function(newOptions)
						options = newOptions or options
						rebuild()
					end
				}
			end

			function Tab:Notify(opts)
				opts = opts or {}
				local text = tostring(opts.Text or "")
				local variant = tostring(opts.Variant or "info")
				local color = theme.Accent
				if variant == "success" then color = theme.Success
				elseif variant == "warning" then color = theme.Warning
				elseif variant == "danger" then color = theme.Danger end

				local toast = create("TextLabel", {
					Parent = container,
					BackgroundColor3 = theme.Card,
					Text = text,
					TextColor3 = theme.TextPrimary,
					Font = theme.Font,
					TextSize = 14,
					BackgroundTransparency = 0,
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(1, -16, 1, -16),
					Size = UDim2.fromOffset(0, 36),
					ZIndex = 50
				})
				rounded(toast, 10)
				local st = applyStroke(toast, color)

				local pad = create("UIPadding", { Parent = toast, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

				toast.Size = UDim2.fromOffset(toast.TextBounds.X + 24, 36)
				tween(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
				task.delay(2.0, function()
					tween(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
					game:GetService("Debris"):AddItem(toast, 0.3)
				end)
			end

			-- expose Section factory
			return setmetatable({ }, Section)
		end

		tabBtn.MouseEnter:Connect(function()
			tween(tabBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = theme.AccentHover }):Play()
		end)
		tabBtn.MouseLeave:Connect(function()
			tween(tabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = theme.Muted }):Play()
		end)

		tabBtn.MouseButton1Click:Connect(function()
			for _, btn in ipairs(tabBar:GetChildren()) do
				if btn:IsA("TextButton") then
					tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = theme.Muted }):Play()
				end
			end
			tween(tabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = theme.Accent }):Play()
			for _, pg in pairs(pages) do pg.Visible = false end
			page.Visible = true
			currentTab = page
		end)

		if #pages == 0 then
			page.Visible = true
			currentTab = page
			tween(tabBtn, TweenInfo.new(0.1), { BackgroundColor3 = theme.Accent }):Play()
		end

		table.insert(pages, page)
		return setmetatable({}, { __index = function(_, k)
			if k == "AddSection" then return function(_, ...) return Tab:AddSection(...) end end
			if k == "Notify" then return function(_, ...) return Tab:Notify(...) end end
			if k == "Show" then return function(_) return Tab:Show() end end
			return nil
		end })
	end

	function Window:Destroy()
		screen:Destroy()
	end

	return setmetatable({ AddTab = function(_, ...) return Window.AddTab(Window, ...) end, Destroy = function(_) return Window:Destroy() end }, Window)
end

return setmetatable(Library, Library)
