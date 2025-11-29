wait(game:IsLoaded())

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--// Main variables
local AIM_ENABLED = false
local WALL_CHECK = false
local FOV_RADIUS = 100
local FOV_DRAW = true
local ESP_ENABLED = true
local HITBOX_ENABLED = false
local HITBOX_SIZE = Vector3.new(6, 6, 6)

local playerHitboxSizes = {}

-- ===========================
--  TEAM CHECK (NOVO)
-- ===========================
local function isEnemy(plr)
	if LocalPlayer.Team == nil or plr.Team == nil then
		return true
	end
	return plr.Team ~= LocalPlayer.Team
end
-- ===========================


-- Utility: HSV -> RGB
local function HSVtoRGB(h, s, v)
	if s <= 0 then return v, v, v end
	h = (h % 1) * 6
	local i = math.floor(h)
	local f = h - i
	local p = v * (1 - s)
	local q = v * (1 - s * f)
	local t = v * (1 - s * (1 - f))
	if i == 0 then return v, t, p end
	if i == 1 then return q, v, p end
	if i == 2 then return p, v, t end
	if i == 3 then return p, q, v end
	if i == 4 then return t, p, v end
	return v, p, q
end

--// GUI creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Micazin_XITER_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

-- Root container
local root = Instance.new("Frame", screenGui)
root.Size = UDim2.new(1,0,1,0)
root.Position = UDim2.new(0,0,0,0)
root.BackgroundTransparency = 1
root.ZIndex = 50

-- Panel (Main) - FIXO
local panel = Instance.new("Frame", root)
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 360, 0, 460)
panel.Position = UDim2.new(0.03, 0, 0.12, 0)
panel.BackgroundColor3 = Color3.fromRGB(10,10,10)
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.ZIndex = 51
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

local bgGrad = Instance.new("UIGradient", panel)
bgGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(15,15,15)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,25))
}
bgGrad.Rotation = 90

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, 0, 0, 56)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "🎅🏻 Itz_DARK 🎅🏻"
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255,255,255)
title.ZIndex = 52

local content = Instance.new("ScrollingFrame", panel)
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -80)
content.Position = UDim2.new(0, 10, 0, 70)
content.BackgroundTransparency = 1
content.ScrollBarImageColor3 = Color3.fromRGB(255,100,200)
content.CanvasSize = UDim2.new(0,0,0,600)
content.ZIndex = 52
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 12)

local border = Instance.new("Frame", panel)
border.Name = "RGBBorder"
border.Size = UDim2.new(1, 6, 1, 6)
border.Position = UDim2.new(0, -3, 0, -3)
border.BackgroundTransparency = 0
border.BorderSizePixel = 0
border.ZIndex = 50
border.ClipsDescendants = true
Instance.new("UICorner", border).CornerRadius = UDim.new(0, 16)

-- Toggles
local function createToggle(name, posY, color)
	local btn = Instance.new("TextButton", content)
	btn.Size = UDim2.new(1, -20, 0, 36)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.BackgroundColor3 = color or Color3.fromRGB(60,60,60)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Text = name .. ": OFF"
	btn.Name = name
	btn.ZIndex = 52
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
	return btn
end

local y = 10
local aimToggle = createToggle("Enable Aim", y, Color3.fromRGB(255,100,100)); y = y + 50
local wallToggle = createToggle("Wall Check", y, Color3.fromRGB(255,180,80)); y = y + 50
local fovPlus = createToggle("FOV +", y, Color3.fromRGB(100,180,255)); y = y + 50
local fovMinus = createToggle("FOV -", y, Color3.fromRGB(100,180,255)); y = y + 50
local fovDrawToggle = createToggle("FOV Draw", y, Color3.fromRGB(180,180,255)); y = y + 50
local espToggle = createToggle("ESP", y, Color3.fromRGB(200,100,255)); y = y + 50
local hitboxToggle = createToggle("Hitbox Head", y, Color3.fromRGB(255,80,150)); y = y + 50
local hitboxPlus = createToggle("Hitbox +", y, Color3.fromRGB(255,150,150)); y = y + 50
local hitboxMinus = createToggle("Hitbox -", y, Color3.fromRGB(255,150,150)); y = y + 50

-- Toggle logic
aimToggle.MouseButton1Click:Connect(function()
	AIM_ENABLED = not AIM_ENABLED
	aimToggle.Text = "Enable Aim: " .. (AIM_ENABLED and "ON" or "OFF")
end)
wallToggle.MouseButton1Click:Connect(function()
	WALL_CHECK = not WALL_CHECK
	wallToggle.Text = "Wall Check: " .. (WALL_CHECK and "ON" or "OFF")
end)
fovPlus.MouseButton1Click:Connect(function()
	FOV_RADIUS = FOV_RADIUS + 10
	fovPlus.Text = "FOV +: " .. tostring(FOV_RADIUS)
end)
fovMinus.MouseButton1Click:Connect(function()
	FOV_RADIUS = math.max(20, FOV_RADIUS - 10)
	fovMinus.Text = "FOV -: " .. tostring(FOV_RADIUS)
end)
fovDrawToggle.MouseButton1Click:Connect(function()
	FOV_DRAW = not FOV_DRAW
	fovDrawToggle.Text = "FOV Draw: " .. (FOV_DRAW and "ON" or "OFF")
end)
espToggle.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED
	espToggle.Text = "ESP: " .. (ESP_ENABLED and "ON" or "OFF")
end)
hitboxToggle.MouseButton1Click:Connect(function()
	HITBOX_ENABLED = not HITBOX_ENABLED
	hitboxToggle.Text = "Hitbox Head: " .. (HITBOX_ENABLED and "ON" or "OFF")
end)
hitboxPlus.MouseButton1Click:Connect(function()
	HITBOX_SIZE = HITBOX_SIZE + Vector3.new(1,1,1)
	hitboxPlus.Text = "Hitbox +: " .. tostring(HITBOX_SIZE)
end)
hitboxMinus.MouseButton1Click:Connect(function()
	HITBOX_SIZE = HITBOX_SIZE - Vector3.new(1,1,1)
	hitboxMinus.Text = "Hitbox -: " .. tostring(HITBOX_SIZE)
end)

-- BOTÃO 3D MÓVEL
local imageButton = Instance.new("ImageButton", screenGui)
imageButton.Name = "Round3DButton"
imageButton.Size = UDim2.new(0, 90, 0, 90)
imageButton.AnchorPoint = Vector2.new(1, 1)
imageButton.Position = UDim2.new(1, -16, 1, -16)
imageButton.BackgroundColor3 = Color3.fromRGB(18,18,18)
imageButton.BorderSizePixel = 0
imageButton.ZIndex = 100
imageButton.Image = "rbxassetid://PUT_ASSET_ID_HERE"
imageButton.ScaleType = Enum.ScaleType.Crop
imageButton.Active = true
imageButton.Selectable = false

local imgCorner = Instance.new("UICorner", imageButton)
imgCorner.CornerRadius = UDim.new(1, 0)

local rim = Instance.new("Frame", imageButton)
rim.Size = UDim2.new(1, -6, 1, -6)
rim.Position = UDim2.new(0, 3, 0, 3)
rim.BackgroundColor3 = Color3.fromRGB(8,8,8)
rim.BorderSizePixel = 0
Instance.new("UICorner", rim).CornerRadius = UDim.new(1, 0)
rim.ZIndex = 101

local highlight = Instance.new("Frame", imageButton)
highlight.Size = UDim2.new(0.6, 0, 0.28, 0)
highlight.Position = UDim2.new(0.18, 0, 0.08, 0)
highlight.BackgroundTransparency = 0.85
highlight.BackgroundColor3 = Color3.fromRGB(255,255,255)
highlight.BorderSizePixel = 0
Instance.new("UICorner", highlight).CornerRadius = UDim.new(1, 0)
highlight.ZIndex = 102

imageButton.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

-- DRAG SYSTEM (PC + TOUCH)
local function makeDraggable(guiObject)
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		guiObject.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
			dragInput = input
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

makeDraggable(imageButton)

-- Clamp do painel
RunService.RenderStepped:Connect(function()
	local pos = panel.Position
	local size = panel.Size
	local screenW = Camera.ViewportSize.X
	local screenH = Camera.ViewportSize.Y
	local absX = pos.X.Offset
	local absY = pos.Y.Offset
	absX = math.clamp(absX, -screenW + 60, screenW - 60)
	absY = math.clamp(absY, -screenH + 60, screenH - 60)
	panel.Position = UDim2.new(pos.X.Scale, absX, pos.Y.Scale, absY)
end)

-- RGB border
local hue = 0
RunService.RenderStepped:Connect(function(dt)
	hue = (hue + dt * 0.12) % 1
	local r,g,b = HSVtoRGB(hue, 0.9, 1)
	border.BackgroundColor3 = Color3.new(r,g,b)
end)

--=== ESP / Hitbox / Aimbot ===--
local function createESP(plr)
	local box = Drawing.new("Square")
	box.Color = Color3.fromRGB(0,255,0)
	box.Thickness = 1
	box.Transparency = 1
	box.Filled = false

	local healthText = Drawing.new("Text")
	healthText.Color = Color3.fromRGB(255,255,255)
	healthText.Size = 16
	healthText.Center = true
	healthText.Outline = true

	return { box = box, healthText = healthText, player = plr }
end

local espTable = {}
local function applyModsToPlayer(plr)
	if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
		local head = plr.Character.Head
		if not playerHitboxSizes[plr] then playerHitboxSizes[plr] = head.Size end
		if HITBOX_ENABLED then
			head.Size = HITBOX_SIZE
			head.Transparency = 0.5
			head.BrickColor = BrickColor.new("Bright red")
			head.Material = Enum.Material.Neon
		else
			local saved = playerHitboxSizes[plr]
			if saved then head.Size = saved end
			head.Transparency = 0
			head.BrickColor = BrickColor.new("Medium stone grey")
			head.Material = Enum.Material.Plastic
		end
	end
end

local function setupPlayer(plr)
	if plr ~= LocalPlayer then
		plr.CharacterAdded:Connect(function()
			wait(1)
			applyModsToPlayer(plr)
			table.insert(espTable, createESP(plr))
		end)
		if plr.Character then
			applyModsToPlayer(plr)
			table.insert(espTable, createESP(plr))
		end
	end
end

for _,plr in ipairs(Players:GetPlayers()) do
	setupPlayer(plr)
end
Players.PlayerAdded:Connect(setupPlayer)

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255,255,0)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false

-- Main loop
local lastTick = tick()
RunService.RenderStepped:Connect(function()
	local now = tick()
	local dt = now - lastTick
	lastTick = now

	for _, plr in ipairs(Players:GetPlayers()) do
		applyModsToPlayer(plr)
	end

	fovCircle.Radius = FOV_RADIUS
	fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	fovCircle.Visible = FOV_DRAW

	local closest, closestDist = nil, FOV_RADIUS
	for _, esp in pairs(espTable) do
		local plr = esp.player
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		if char and hrp and hum and hum.Health > 0 then
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				if ESP_ENABLED then
					esp.box.Size = Vector2.new(50,80)
					esp.box.Position = Vector2.new(pos.X - 25, pos.Y - 40)
					esp.box.Visible = true
					esp.healthText.Text = tostring(math.floor(hum.Health))
					esp.healthText.Position = Vector2.new(pos.X, pos.Y - 50)
					esp.healthText.Visible = true
				else
					esp.box.Visible = false
					esp.healthText.Visible = false
				end

				local dist = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(pos.X, pos.Y)).Magnitude

				-- =====================================
				-- AIMBOT + TEAM CHECK (ADICIONADO)
				-- =====================================
				if AIM_ENABLED and dist < closestDist and isEnemy(plr) then
					if WALL_CHECK then
						local ray = Ray.new(Camera.CFrame.Position, (hrp.Position - Camera.CFrame.Position).unit * 1000)
						local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
						if hit and not hit:IsDescendantOf(char) then
						else
							closest = hrp
							closestDist = dist
						end
					else
						closest = hrp
						closestDist = dist
					end
				end
				-- =====================================

			else
				esp.box.Visible = false
				esp.healthText.Visible = false
			end
		else
			esp.box.Visible = false
			esp.healthText.Visible = false
		end
	end

	if AIM_ENABLED and closest and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		local head = closest.Parent:FindFirstChild("Head")
		if head then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
		end
	end
end)
