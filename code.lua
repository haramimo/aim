--// Mini Aimbot by ChatGPT

local Players, RunService, UserInputService, Camera = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Aimbot, Running, Typing, Locking = {}, false, false, nil

-- Settings
Aimbot.Enabled = true
Aimbot.TeamCheck = false
Aimbot.Sensitivity = 0
Aimbot.TriggerKey = "MouseButton2" -- MouseButton2 = Right Click
Aimbot.Toggle = false
Aimbot.LockPart = "Head"
Aimbot.FOVRadius = 100

-- Drawing Circle
local FOV = Drawing.new("Circle")
FOV.Visible = true
FOV.Color = Color3.fromRGB(255, 255, 255)
FOV.Radius = Aimbot.FOVRadius
FOV.Thickness = 1
FOV.Filled = false

-- Typing Detection
UserInputService.TextBoxFocused:Connect(function() Typing = true end)
UserInputService.TextBoxFocusReleased:Connect(function() Typing = false end)

-- Find Closest Target
local function GetClosest()
	local Target, ClosestDist = nil, Aimbot.FOVRadius
	for _,v in ipairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Aimbot.LockPart) then
			if Aimbot.TeamCheck and v.Team == LocalPlayer.Team then continue end
			local Pos, Vis = Camera:WorldToViewportPoint(v.Character[Aimbot.LockPart].Position)
			if Vis then
				local Dist = (Vector2.new(Pos.X, Pos.Y) - UserInputService:GetMouseLocation()).Magnitude
				if Dist < ClosestDist then
					ClosestDist = Dist
					Target = v
				end
			end
		end
	end
	return Target
end

-- Aim Function
RunService.RenderStepped:Connect(function()
	FOV.Position = UserInputService:GetMouseLocation()
	if Running and Aimbot.Enabled then
		Locking = GetClosest()
		if Locking and Locking.Character and Locking.Character:FindFirstChild(Aimbot.LockPart) then
			local Pos = Locking.Character[Aimbot.LockPart].Position
			if Aimbot.Sensitivity > 0 then
				Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Pos), Aimbot.Sensitivity)
			else
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, Pos)
			end
			FOV.Color = Color3.fromRGB(255, 70, 70)
		else
			FOV.Color = Color3.fromRGB(255, 255, 255)
		end
	end
end)

-- Input Handling
UserInputService.InputBegan:Connect(function(input)
	if Typing then return end
	pcall(function()
		if Aimbot.TriggerKey:find("MouseButton") then
			if input.UserInputType == Enum.UserInputType[Aimbot.TriggerKey] then
				if Aimbot.Toggle then
					Running = not Running
				else
					Running = true
				end
			end
		else
			if input.KeyCode == Enum.KeyCode[Aimbot.TriggerKey] then
				if Aimbot.Toggle then
					Running = not Running
				else
					Running = true
				end
			end
		end
	end)
end)

UserInputService.InputEnded:Connect(function(input)
	if Typing then return end
	pcall(function()
		if Aimbot.TriggerKey:find("MouseButton") then
			if input.UserInputType == Enum.UserInputType[Aimbot.TriggerKey] then
				if not Aimbot.Toggle then
					Running = false
				end
			end
		else
			if input.KeyCode == Enum.KeyCode[Aimbot.TriggerKey] then
				if not Aimbot.Toggle then
					Running = false
				end
			end
		end
	end)
end)
