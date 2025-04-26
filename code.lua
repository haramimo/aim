--// Preventing Multiple Processes
pcall(function()
	getgenv().Aimbot.Functions:Exit()
end)

--// Environment
getgenv().Aimbot = {}
local Environment = getgenv().Aimbot

--// Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

--// Variables
local LocalPlayer = Players.LocalPlayer
local Title = "Exunys Developer"
local FileNames = {"Aimbot", "Configuration.json", "Drawing.json"}
local Typing, Running, Animation, RequiredDistance, ServiceConnections = false, false, nil, 2000, {}

--// Support Functions
local mousemoverel = mousemoverel or (Input and Input.MouseMove)
local queueonteleport = queue_on_teleport or syn.queue_on_teleport

--// Script Settings
Environment.Settings = {
	SendNotifications = true,
	SaveSettings = true,
	ReloadOnTeleport = true,
	Enabled = true,
	TeamCheck = false,
	AliveCheck = true,
	WallCheck = false,
	Sensitivity = 0,
	ThirdPerson = false,
	ThirdPersonSensitivity = 3,
	TriggerKey = "MouseButton2",
	Toggle = false,
	LockPart = "Head"
}

Environment.FOVSettings = {
	Enabled = true,
	Visible = true,
	Amount = 90,
	Color = "255, 255, 255",
	LockedColor = "255, 70, 70",
	Transparency = 0.5,
	Sides = 60,
	Thickness = 1,
	Filled = false
}

Environment.FOVCircle = Drawing.new("Circle")
Environment.Locked = nil

--// Core Functions
local function Encode(Table)
	return HttpService:JSONEncode(Table)
end

local function Decode(String)
	return HttpService:JSONDecode(String)
end

local function GetColor(Color)
	local R = tonumber(string.match(Color, "([%d]+)[%s]*,[%s]*[%d]+[%s]*,[%s]*[%d]+"))
	local G = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*([%d]+)[%s]*,[%s]*[%d]+"))
	local B = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*[%d]+[%s]*,[%s]*([%d]+)"))
	return Color3.fromRGB(R, G, B)
end

local function SendNotification(TitleArg, DescriptionArg, DurationArg)
	if Environment.Settings.SendNotifications then
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = TitleArg,
				Text = DescriptionArg,
				Duration = DurationArg
			})
		end)
	end
end

local function SaveSettings()
	if Environment.Settings.SaveSettings then
		if not isfolder(Title) then
			makefolder(Title)
		end
		if not isfolder(Title.."/"..FileNames[1]) then
			makefolder(Title.."/"..FileNames[1])
		end
		writefile(Title.."/"..FileNames[1].."/"..FileNames[2], Encode(Environment.Settings))
		writefile(Title.."/"..FileNames[1].."/"..FileNames[3], Encode(Environment.FOVSettings))
	end
end

local function GetClosestPlayer()
	if not Environment.Locked then
		RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000
		for _, v in next, Players:GetPlayers() do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
				if Environment.Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
				if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
				if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end

				local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position)
				local Distance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude

				if Distance < RequiredDistance and OnScreen then
					RequiredDistance = Distance
					Environment.Locked = v
				end
			end
		end
	elseif (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).X, Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position).Y)).Magnitude > RequiredDistance then
		Environment.Locked = nil
		if Animation then Animation:Cancel() end
		Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
	end
end

--// Typing Check
ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Load Settings
if Environment.Settings.SaveSettings then
	if not isfolder(Title) then makefolder(Title) end
	if not isfolder(Title.."/"..FileNames[1]) then makefolder(Title.."/"..FileNames[1]) end
	if isfile(Title.."/"..FileNames[1].."/"..FileNames[2]) then
		Environment.Settings = Decode(readfile(Title.."/"..FileNames[1].."/"..FileNames[2]))
	end
	if isfile(Title.."/"..FileNames[1].."/"..FileNames[3]) then
		Environment.FOVSettings = Decode(readfile(Title.."/"..FileNames[1].."/"..FileNames[3]))
	end
end

--// Main Load
local function Load()
	ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
		if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
			Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
			Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
			Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
			Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
			Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
			Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
			Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
			Environment.FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
		else
			Environment.FOVCircle.Visible = false
		end

		if Running and Environment.Settings.Enabled then
			GetClosestPlayer()
			if Environment.Settings.ThirdPerson then
				local Vector = Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position)
				mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
			else
				if Environment.Settings.Sensitivity > 0 then
					Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)})
					Animation:Play()
				else
					Camera.CFrame = CFrame.new(Camera.CFrame.Position, Environment.Locked.Character[Environment.Settings.LockPart].Position)
				end
			end
			Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.LockedColor)
		end
	end)

	-- Input Handling
	ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Environment.Settings.TriggerKey:find("MouseButton") then
					if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
						if Environment.Settings.Toggle then
							Running = not Running
							if not Running then
								Environment.Locked = nil
								if Animation then Animation:Cancel() end
								Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
							end
						else
							Running = true
						end
					end
				else
					if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
						if Environment.Settings.Toggle then
							Running = not Running
							if not Running then
								Environment.Locked = nil
								if Animation then Animation:Cancel() end
								Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
							end
						else
							Running = true
						end
					end
				end
			end)
		end
	end)

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
		if not Typing then
			pcall(function()
				if Environment.Settings.TriggerKey:find("MouseButton") then
					if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
						if not Environment.Settings.Toggle then
							Running = false
							Environment.Locked = nil
							if Animation then Animation:Cancel() end
							Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
						end
					end
				else
					if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
						if not Environment.Settings.Toggle then
							Running = false
							Environment.Locked = nil
							if Animation then Animation:Cancel() end
							Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
						end
					end
				end
			end)
		end
	end)
end

--// Functions
Environment.Functions = {}

function Environment.Functions:Exit()
	SaveSettings()
	for _, v in next, ServiceConnections do v:Disconnect() end
	if Environment.FOVCircle then Environment.FOVCircle:Remove() end
	getgenv().Aimbot.Functions = nil
	getgenv().Aimbot = nil
end

function Environment.Functions:Restart()
	SaveSettings()
	for _, v in next, ServiceConnections do v:Disconnect() end
	Load()
end

function Environment.Functions:ResetSettings()
	Environment.Settings = {
		SendNotifications = true,
		SaveSettings = true,
		ReloadOnTeleport = true,
		Enabled = true,
		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,
		Sensitivity = 0,
		ThirdPerson = false,
		ThirdPersonSensitivity = 3,
		TriggerKey = "MouseButton2",
		Toggle = false,
		LockPart = "Head"
	}

	Environment.FOVSettings = {
		Enabled = true,
		Visible = true,
		Amount = 90,
		Color = "255, 255, 255",
		LockedColor = "255, 70, 70",
		Transparency = 0.5,
		Sides = 60,
		Thickness = 1,
		Filled = false
	}
end

--// Support Check
if not Drawing or not getgenv then
	SendNotification(Title, "Your exploit does not support this script", 3)
	return
end

--// Reload On Teleport
if Environment.Settings.ReloadOnTeleport and queueonteleport then
	queueonteleport(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V2/main/Resources/Scripts/Main.lua"))
end

--// Load Everything
Load()
SendNotification(Title, "Aimbot script successfully loaded! Check the GitHub page on how to configure the script.", 5)
